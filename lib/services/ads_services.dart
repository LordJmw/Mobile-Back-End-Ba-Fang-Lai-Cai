import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

class AdsServices {
  final InterAdId = 'ca-app-pub-3940256099942544/1033173712';
  InterstitialAd? _interstitialAd;
  void loadInterStitialAd() {
    print("dipanggil");
    InterstitialAd.load(
      adUnitId: InterAdId,
      request: AdRequest(),
      adLoadCallback: InterstitialAdLoadCallback(
        onAdLoaded: (InterstitialAd ad) {
          debugPrint('Ad was loaded.');
          _interstitialAd = ad;
        },
        onAdFailedToLoad: (LoadAdError error) {
          debugPrint('Ad failed to load with error: $error');
        },
      ),
    );
  }

  void showInterAd() {
    if (_interstitialAd != null) {
      print("ad ada");
      _interstitialAd!.show();
    }
    print("ad ga ada");
  }
}
