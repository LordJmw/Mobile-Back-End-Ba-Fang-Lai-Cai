import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:flutter/material.dart';

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
}
