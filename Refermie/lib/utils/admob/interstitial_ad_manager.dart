import 'dart:developer';
import 'dart:io';

import 'package:ebroker/utils/constant.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

class InterstitialAdManager {
  static int _adCount = 0;
  static InterstitialAd? _interstitialAd;

  Future<void> load({VoidCallback? onAdLoad}) async {
    if (!Constant.isAdmobAdsEnabled) {
      return;
    }

    await InterstitialAd.load(
      adUnitId: (Platform.isAndroid
          ? Constant.admobInterstitialAndroid
          : Constant.admobInterstitialIos),
      request: const AdRequest(),
      adLoadCallback: InterstitialAdLoadCallback(
        onAdLoaded: (InterstitialAd ad) {
          log('$ad loaded.');
          onAdLoad?.call();
          _interstitialAd = ad;
        },
        onAdFailedToLoad: (LoadAdError error) {
          log('InterstitialAd failed to load: $error');
        },
      ),
    );
  }

  Future<void> show() async {
    if (!Constant.isAdmobAdsEnabled) {
      return;
    }
    if (_interstitialAd != null) {
      _adCount++;
      if (_adCount == 4) {
        await _interstitialAd!.show();

        _adCount = 0; // Reset the count after showing the ad
      }
    }
  }
}
