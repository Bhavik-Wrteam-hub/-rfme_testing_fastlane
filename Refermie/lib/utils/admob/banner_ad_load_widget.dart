import 'dart:developer';

import 'package:ebroker/exports/main_export.dart';

class BannerAdWidget extends StatefulWidget {
  const BannerAdWidget({super.key, this.bannerSize = AdSize.largeBanner});
  final AdSize bannerSize;

  @override
  State<BannerAdWidget> createState() => _BannerAdWidgetState();
}

class _BannerAdWidgetState extends State<BannerAdWidget> {
  BannerAd? _bannerAd;
  late String adUnitId;

  /// Loads a banner ad.
  Future<void> loadAd() async {
    if (!Constant.isAdmobAdsEnabled) {
      return;
    }
    _bannerAd = BannerAd(
      adUnitId: adUnitId,
      request: const AdRequest(),
      size: widget.bannerSize,
      listener: BannerAdListener(
        onAdLoaded: (ad) {
          log('$ad loaded.');
          setState(() {});
        },
        // Called when an ad request failed.
        onAdFailedToLoad: (ad, err) async {
          _bannerAd = null;
          setState(() {});

          await ad.dispose();
        },
      ),
    );
    await _bannerAd?.load();
  }

  @override
  void initState() {
    adUnitId = Platform.isAndroid
        ? Constant.admobBannerAndroid
        : Constant.admobBannerIos;
    unawaited(loadAd());
    super.initState();
  }

  @override
  void dispose() {
    if (_bannerAd != null) {
      unawaited(_bannerAd!.dispose());
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return (_bannerAd != null)
        ? SizedBox(
            width: _bannerAd!.size.width.toDouble(),
            height: _bannerAd!.size.height.toDouble(),
            child: AdWidget(ad: _bannerAd!),
          )
        : const SizedBox.shrink();
  }
}
