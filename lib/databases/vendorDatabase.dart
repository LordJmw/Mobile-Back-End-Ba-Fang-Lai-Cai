import 'dart:convert';

import 'package:projek_uts_mbr/databases/database.dart';
import 'package:projek_uts_mbr/model/VendorModel.dart';
import 'package:projek_uts_mbr/services/dataServices.dart';
import 'package:sqflite/sqflite.dart';
import 'package:sqflite/sqlite_api.dart';

class Vendordatabase {
  Dataservices dataservices = Dataservices();
  DatabaserService databaserService = DatabaserService();
  initDataAwal() async {
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

    for (var kategori in respond) {
      for (var penyedia in kategori['penyedia']) {
        await db.insert('Vendor', {
          'nama': penyedia['nama'],
          'deskripsi': penyedia['deskripsi'],
          'rating': penyedia['rating'],
          'harga': jsonEncode(
            penyedia['harga'],
          ), //ubah ke string dulu pas simpan ke db
          'testimoni': jsonEncode(penyedia['testimoni']),
          'email': penyedia['email'],
          'telepon': penyedia['telepon'],
          'image': penyedia['image'],
          'kategori': kategori['kategori'],
          'alamat': penyedia['alamat'],
          'password': penyedia['password']
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
    Database db = await databaserService.getDatabase();
    List<Map<String, dynamic>> dataVendor = await db.query(
      'Vendor',
      limit: limit > 0 ? limit : null,
    );

    if (dataVendor.isNotEmpty) {
      return dataVendor.map((map) => Vendormodel.fromMap(map)).toList();
    }
    return [];
  }

  Future<List<String>> getCategories() async {
    final db = await databaserService.getDatabase();
    final res = await db.rawQuery("SELECT DISTINCT kategori FROM Vendor");
    return res.map((row) => row["kategori"].toString()).toList();
  }

  Future<int> insertVendor(Vendormodel vendor) async {
    final db = await databaserService.getDatabase();
    return await db.insert("Vendor", vendor.toMap());
  }

  Future<Vendormodel?> LoginVendor(String email, String password) async {
    final db = await databaserService.getDatabase();
    final maps = await db.query(
      'Vendor',
      where: 'email = ? AND password = ?',
      whereArgs: [email, password],
    );

    if (maps.isNotEmpty) {
      return Vendormodel.fromMap(maps.first);
    }
    return null;
  }

  Future<void> printAllVendors() async {
  final db = await databaserService.getDatabase();
  final vendors = await db.query('Vendor'); // ambil semua data
  print("Daftar vendor:");
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
    print("Passwords updated successfully.");
  }
}
