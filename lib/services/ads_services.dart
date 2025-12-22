import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

class AdsServices {
  final String InterAdId = 'ca-app-pub-3940256099942544/1033173712';
  final String rewardedAdId = 'ca-app-pub-3940256099942544/5224354917';
  InterstitialAd? _interstitialAd;
  RewardedAd? _rewardedAd;

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
    } else {
      print("ad ga ada");
    }
  }

  void loadRewardedAd() {
    RewardedAd.load(
      adUnitId: rewardedAdId,
      request: const AdRequest(),
      rewardedAdLoadCallback: RewardedAdLoadCallback(
        onAdLoaded: (RewardedAd ad) {
          debugPrint('Rewarded ad loaded.');
          _rewardedAd = ad;
        },
        onAdFailedToLoad: (LoadAdError error) {
          debugPrint('Rewarded ad failed to load: $error');
          _rewardedAd = null;
        },
      ),
    );
  }

  void showRewardedAd(VoidCallback onRewarded) {
    if (_rewardedAd != null) {
      _rewardedAd!.fullScreenContentCallback = FullScreenContentCallback(
        onAdDismissedFullScreenContent: (RewardedAd ad) {
          ad.dispose();
          loadRewardedAd();
        },
        onAdFailedToShowFullScreenContent: (RewardedAd ad, AdError error) {
          ad.dispose();
          loadRewardedAd();
        },
      );

      _rewardedAd!.show(
        onUserEarnedReward: (AdWithoutView ad, RewardItem reward) {
          debugPrint('User earned reward: ${reward.amount}');
          onRewarded();
        },
      );
      _rewardedAd = null;
    } else {
      debugPrint('Rewarded ad is not ready yet.');
      // Optionally, you can show a snackbar or toast to the user.
    }
  }
}
