import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:flutter/material.dart';
import 'package:projek_uts_mbr/model/purchaseHistoryModel.dart';

class Eventlogs {
  final analytics = FirebaseAnalytics.instance;
  Future<void> categoryIconButtonClicked(
    String categoryName,
    String screenName,
  ) async {
    print("log event category dipanggil , category : ${categoryName}");
    await analytics.logEvent(
      name: 'category_IconButton_clicked',
      parameters: {
        'category_name': categoryName,
        'button_label': 'category_button',
        'screen_name': screenName,
        'timestamp': DateTime.now().toIso8601String(),
      },
    );
  }

  Future<void> LihatHalKategori() async {
    print("tombol lihat halaman kategori diklik");
    await analytics.logEvent(
      name: 'Lihat_halaman_kategori_button_clicked',
      parameters: {
        'button_label': 'Lihat_Halaman_Kategori',
        'timestamp': DateTime.now().toIso8601String(),
      },
    );
  }

  Future<void> beliPaket(
    String namaVendor,
    String selectedPackage,
    String selectedPrice,
    String selectedDate,
    String location,
    String email,
  ) async {
    await analytics.logEvent(
      name: 'beli_paket_sukses',
      parameters: {
        'button': 'tombol bayar',
        'vendor_name': namaVendor,
        'package_name': selectedPackage,
        'price': selectedPrice,
        'event_date': selectedDate,
        'location': location,
        'user_email': email,
        'timestamp': DateTime.now().toIso8601String(),
      },
    );
  }

  Future<void> ratingFilter(int rating) async {
    print("rating di set menjadi ${rating} bintang");
    await analytics.logEvent(
      name: 'set_rating_filter',
      parameters: {
        'button': 'star_icon_button',
        'selected_rating': rating,
        'timestamp': DateTime.now().toIso8601String(),
      },
    );
  }

  Future<void> HargaFilter(RangeValues harga) async {
    print("filter harga diset, harga min : ${harga.start}");
    await analytics.logEvent(
      name: 'set_harga_filter',
      parameters: {
        'button': 'harga_slider',
        'min_price': harga.start,
        'max_price': harga.end,
        'timestamp': DateTime.now().toIso8601String(),
      },
    );
  }

  Future<void> bestInWeek(
    BuildContext context,
    String name,
    String rating,
    String imgPath,
  ) async {
    print("best in week vendor : ${name}");
    try {
      await analytics.logEvent(
        name: 'user_click_card_best_week',
        parameters: {
          'button': 'tombol_card',
          'vendor_name': name,
          'vendor_rating': rating,
          'vendor_image': imgPath,
        },
      );
    } catch (e) {
      print('analytics error bestInWeek: $e');
    }
  }

  Future<void> portNReview(
    BuildContext context,
    String name,
    String desc,
    String imgPath,
  ) async {
    try {
      await analytics.logEvent(
        name: 'user_click_card_portofolio_review',
        parameters: {
          'button': 'tombol_portofolio_review',
          'vendor_name': name,
          'vendor_desc': desc,
          'vendor_image': imgPath,
        },
      );
    } catch (e) {
      print('analytics error portofolios&Review: $e');
    }
  }

  Future<void> editPaket(
    int? purchaseId,
    int customerId,
    PurchaseDetails purchaseDetails,
    DateTime purchaseDate,
  ) async {
    print("eventlog edit dipanggil");
    await analytics.logEvent(
      name: 'edit_paket_sukses',
      parameters: {
        'button': 'tombol_edit',
        'purchaseId': purchaseId.toString(),
        'customerId': customerId,
        'purchaseDetails': purchaseDetails.toString(),
        'purchaseDate': DateTime.now().toIso8601String(),
      },
    );
  }

  Future<void> deletePaket(int? purchaseId, String vendorName) async {
    await analytics.logEvent(
      name: 'hapus_paket_sukses',
      parameters: {
        'button': 'tombol_delete',
        'purchaseId': ?purchaseId,
        'namaVendor': vendorName,
      },
    );
  }
}
