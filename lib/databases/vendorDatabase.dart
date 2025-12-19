import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:projek_uts_mbr/databases/database.dart';
import 'package:projek_uts_mbr/model/VendorModel.dart';
import 'package:projek_uts_mbr/services/dataServices.dart';
import 'package:sqflite/sqflite.dart';
import 'package:sqflite/sqlite_api.dart';

// isolate

List<Map<String, dynamic>> processVendorRows(List<Map<String, dynamic>> rows) {
  final List<Map<String, dynamic>> normalized = rows.map((row) {
    final r = Map<String, dynamic>.from(row);

    try {
      r['harga'] = r['harga'] != null && r['harga'].toString().isNotEmpty
          ? jsonDecode(r['harga'])
          : {};
    } catch (_) {
      r['harga'] = {};
    }

    try {
      r['testimoni'] =
          r['testimoni'] != null && r['testimoni'].toString().isNotEmpty
          ? jsonDecode(r['testimoni'])
          : [];
    } catch (_) {
      r['testimoni'] = [];
    }

    return r;
  }).toList();

  // grouping by kategori
  final Map<String, List<Map<String, dynamic>>> grouped = {};

  for (final row in normalized) {
    final kategori = (row['kategori'] ?? '').toString();
    if (kategori.isEmpty) continue;

    grouped.putIfAbsent(kategori, () => []).add(row);
  }

  // flatten lagi agar bisa dikembalikan
  final List<Map<String, dynamic>> result = [];

  grouped.forEach((_, list) {
    list.sort((a, b) => (b['rating'] as num).compareTo(a['rating'] as num));
    result.addAll(list);
  });

  return result;
}

class Vendordatabase {
  Dataservices dataservices = Dataservices();
  DatabaserService databaserService = DatabaserService();

  Future<void> initDataAwal() async {
    Database db = await databaserService.getDatabase();

    int count =
        Sqflite.firstIntValue(
          await db.rawQuery('SELECT COUNT(*) FROM Vendor'),
        ) ??
        0;
    if (count > 0) {
      print("Data vendor sudah ada di DB ($count records), skip insert.");
      return;
    }

    List<dynamic> respond = await dataservices.loadData();

    for (var kategoriMap in respond) {
      final vm = Vendormodel.fromJson(Map<String, dynamic>.from(kategoriMap));
      for (var penyedia in vm.penyedia) {
        await db.insert('Vendor', {
          'nama': penyedia.nama,
          'deskripsi': penyedia.deskripsi,
          'rating': penyedia.rating,
          'harga': jsonEncode(penyedia.harga.toJson()),
          'testimoni': jsonEncode(
            penyedia.testimoni.map((t) => t.toJson()).toList(),
          ),
          'email': penyedia.email,
          'telepon': penyedia.telepon,
          'image': penyedia.image,
          'kategori': vm.kategori,
          'alamat': '',
          'password': penyedia.password,
        });
      }
    }

    int total =
        Sqflite.firstIntValue(
          await db.rawQuery('SELECT COUNT(*) FROM Vendor'),
        ) ??
        0;
    print("Selesai insert, total data vendor di DB: $total");
  }

  Future<List<Vendormodel>> getData({int limit = 0}) async {
    final db = await databaserService.getDatabase();

    final rows = await db.query('Vendor', limit: limit > 0 ? limit : null);

    if (rows.isEmpty) return [];

    // memindahkan kerja berat ke isolate
    final processedRows = await compute(
      processVendorRows,
      rows.map((e) => Map<String, dynamic>.from(e)).toList(),
    );

    final Map<String, List<Penyedia>> groupedByKategori = {};

    for (final row in processedRows) {
      final kategori = (row['kategori'] ?? '').toString();
      final penyedia = Penyedia.fromJson(row);

      groupedByKategori.putIfAbsent(kategori, () => []).add(penyedia);
    }

    return groupedByKategori.entries.map((entry) {
      return Vendormodel(kategori: entry.key, penyedia: entry.value);
    }).toList();
  }

  Future<void> deletePackage(String vendorEmail, String packageName) async {
    final db = await databaserService.getDatabase();
    final vm = await getVendorByEmail(vendorEmail);

    if (vm != null && vm.penyedia.isNotEmpty) {
      final penyedia = vm.penyedia.first;
      final harga = penyedia.harga;
      switch (packageName.toLowerCase()) {
        case 'basic':
          harga.basic = TipePaket(harga: 0, jasa: '');
          break;
        case 'premium':
          harga.premium = TipePaket(harga: 0, jasa: '');
          break;
        case 'custom':
          harga.custom = TipePaket(harga: 0, jasa: '');
          break;
        default:
          return;
      }

      await db.update(
        'Vendor',
        {'harga': jsonEncode(harga.toJson())},
        where: 'email = ?',
        whereArgs: [vendorEmail],
      );
    }
  }

  Future<void> updatePackage(
    String vendorEmail,
    String oldPackageName,
    String newPackageName,
    Map<String, dynamic> newPackageData,
  ) async {
    final db = await databaserService.getDatabase();
    final vm = await getVendorByEmail(vendorEmail);
    if (vm == null || vm.penyedia.isEmpty) return;

    final penyedia = vm.penyedia.first;
    final harga = penyedia.harga;

    switch (oldPackageName.toLowerCase()) {
      case 'basic':
        harga.basic = TipePaket(harga: 0, jasa: '');
        break;
      case 'premium':
        harga.premium = TipePaket(harga: 0, jasa: '');
        break;
      case 'custom':
        harga.custom = TipePaket(harga: 0, jasa: '');
        break;
      default:
        break;
    }

    final updated = TipePaket(
      harga: newPackageData['harga'] ?? 0,
      jasa: newPackageData['jasa'] ?? '',
    );
    switch (newPackageName.toLowerCase()) {
      case 'basic':
        harga.basic = updated;
        break;
      case 'premium':
        harga.premium = updated;
        break;
      case 'custom':
        harga.custom = updated;
        break;
      default:
        break;
    }

    await db.update(
      'Vendor',
      {'harga': jsonEncode(harga.toJson())},
      where: 'email = ?',
      whereArgs: [vendorEmail],
    );
  }

  Future<Vendormodel?> getVendorByEmail(String email) async {
    final db = await databaserService.getDatabase();
    final maps = await db.query(
      'Vendor',
      where: 'email = ?',
      whereArgs: [email],
      limit: 1,
    );
    if (maps.isNotEmpty) {
      final row = Map<String, dynamic>.from(maps.first);
      try {
        row['harga'] = jsonDecode(row['harga'] ?? '{}');
      } catch (_) {
        row['harga'] = row['harga'] ?? {};
      }
      try {
        row['testimoni'] = jsonDecode(row['testimoni'] ?? '[]');
      } catch (_) {
        row['testimoni'] = [];
      }
      final penyedia = Penyedia.fromJson(row);
      final kategori = (row['kategori'] ?? '').toString();
      return Vendormodel(kategori: kategori, penyedia: [penyedia]);
    }
    return null;
  }

  Future<Vendormodel?> getVendorByName(String name) async {
    final db = await databaserService.getDatabase();
    final maps = await db.query(
      'Vendor',
      where: 'nama = ?',
      whereArgs: [name],
      limit: 1,
    );
    if (maps.isNotEmpty) {
      final row = Map<String, dynamic>.from(maps.first);
      try {
        row['harga'] = jsonDecode(row['harga'] ?? '{}');
      } catch (_) {
        row['harga'] = row['harga'] ?? {};
      }
      try {
        row['testimoni'] = jsonDecode(row['testimoni'] ?? '[]');
      } catch (_) {
        row['testimoni'] = [];
      }
      final penyedia = Penyedia.fromJson(row);
      final kategori = (row['kategori'] ?? '').toString();
      return Vendormodel(kategori: kategori, penyedia: [penyedia]);
    }
    return null;
  }

  Future<List<String>> getCategories() async {
    final db = await databaserService.getDatabase();
    final res = await db.rawQuery("SELECT DISTINCT kategori FROM Vendor");
    return res.map((row) => row["kategori"].toString()).toList();
  }

  Future<int> insertVendor(dynamic vendor, {String kategori = ''}) async {
    final db = await databaserService.getDatabase();
    if (vendor is Vendormodel) {
      int lastId = 0;
      for (var penyedia in vendor.penyedia) {
        lastId = await db.insert('Vendor', {
          'nama': penyedia.nama,
          'deskripsi': penyedia.deskripsi,
          'rating': penyedia.rating,
          'harga': jsonEncode(penyedia.harga.toJson()),
          'testimoni': jsonEncode(
            penyedia.testimoni.map((t) => t.toJson()).toList(),
          ),
          'email': penyedia.email,
          'telepon': penyedia.telepon,
          'image': penyedia.image,
          'kategori': kategori.isNotEmpty ? kategori : vendor.kategori,
          'alamat': '',
          'password': penyedia.password,
        });
      }
      return lastId;
    } else if (vendor is Penyedia) {
      return await db.insert('Vendor', {
        'nama': vendor.nama,
        'deskripsi': vendor.deskripsi,
        'rating': vendor.rating,
        'harga': jsonEncode(vendor.harga.toJson()),
        'testimoni': jsonEncode(
          vendor.testimoni.map((t) => t.toJson()).toList(),
        ),
        'email': vendor.email,
        'telepon': vendor.telepon,
        'image': vendor.image,
        'kategori': kategori,
        'alamat': '',
        'password': vendor.password,
      });
    } else {
      throw ArgumentError('vendor must be Vendormodel or Penyedia');
    }
  }

  Future<Penyedia?> LoginVendor(String email, String password) async {
    final db = await databaserService.getDatabase();
    final maps = await db.query(
      'Vendor',
      where: 'email = ? AND password = ?',
      whereArgs: [email, password],
    );
    if (maps.isNotEmpty) {
      final row = Map<String, dynamic>.from(maps.first);
      try {
        row['harga'] = jsonDecode(row['harga'] ?? '{}');
      } catch (_) {
        row['harga'] = row['harga'] ?? {};
      }
      try {
        row['testimoni'] = jsonDecode(row['testimoni'] ?? '[]');
      } catch (_) {
        row['testimoni'] = [];
      }
      return Penyedia.fromJson(row);
    }
    return null;
  }

  Future<void> printAllVendors() async {
    final db = await databaserService.getDatabase();
    final vendors = await db.query('Vendor');
    print('Daftar vendor:');
    for (var v in vendors) {
      print(v);
    }
  }

  Future<void> updatePasswords() async {
    Database db = await databaserService.getDatabase();
    List<dynamic> respond = await dataservices.loadData();

    for (var kategori in respond) {
      for (var penyedia in kategori['penyedia']) {
        await db.update(
          'Vendor',
          {'password': penyedia['password']},
          where: 'email = ?',
          whereArgs: [penyedia['email']],
        );
      }
    }
    print('Passwords updated successfully.');
  }

  Future<List<Penyedia>> searchVendors(String query) async {
    final db = await databaserService.getDatabase();
    final maps = await db.query(
      'Vendor',
      where: 'nama LIKE ? OR kategori LIKE ?',
      whereArgs: ['%$query%', '%$query%'],
    );

    return maps.map((row) {
      final r = Map<String, dynamic>.from(row);
      try {
        r['harga'] = jsonDecode(r['harga'] ?? '{}');
      } catch (_) {
        r['harga'] = {};
      }
      try {
        r['testimoni'] = jsonDecode(r['testimoni'] ?? '[]');
      } catch (_) {
        r['testimoni'] = [];
      }
      return Penyedia.fromJson(r);
    }).toList();
  }

  Future<void> updateVendorImage(String email, String imageUrl) async {
    final db = await databaserService.getDatabase();
    await db.update(
      'Vendor',
      {'image': imageUrl},
      where: 'email = ?',
      whereArgs: [email],
    );
  }
}
