import 'dart:io';

import 'package:get/get.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

class AdController extends GetxController {
  BannerAd? bannerAd;
  var isBannerAdLoaded = false.obs;

  InterstitialAd? interstitialAd;
  var isInterstitialAdLoaded = false.obs;

  // Test Ad Unit IDs
  String get bannerAdUnitId {
    if (Platform.isAndroid) {
      return 'ca-app-pub-3940256099942544/6300978111';
    } else if (Platform.isIOS) {
      return 'ca-app-pub-3940256099942544/2934735716';
    }
    return '';
  }

  String get interstitialAdUnitId {
    if (Platform.isAndroid) {
      return 'ca-app-pub-3940256099942544/1033173712';
    } else if (Platform.isIOS) {
      return 'ca-app-pub-3940256099942544/4411468910';
    }
    return '';
  }

  @override
  void onInit() {
    super.onInit();
    _loadBannerAd();
    _loadInterstitialAd();
  }

  @override
  void onClose() {
    bannerAd?.dispose();
    interstitialAd?.dispose();
    super.onClose();
  }

  void _loadBannerAd() {
    bannerAd = BannerAd(
      adUnitId: bannerAdUnitId,
      size: AdSize.banner,
      request: const AdRequest(),
      listener: BannerAdListener(
        onAdLoaded: (ad) {
          isBannerAdLoaded.value = true;
        },
        onAdFailedToLoad: (ad, error) {
          ad.dispose();
          isBannerAdLoaded.value = false;
          // Retry loading after a delay
          Future.delayed(const Duration(seconds: 30), _loadBannerAd);
        },
      ),
    );
    bannerAd!.load();
  }

  void _loadInterstitialAd() {
    InterstitialAd.load(
      adUnitId: interstitialAdUnitId,
      request: const AdRequest(),
      adLoadCallback: InterstitialAdLoadCallback(
        onAdLoaded: (ad) {
          interstitialAd = ad;
          isInterstitialAdLoaded.value = true;

          interstitialAd!.fullScreenContentCallback = FullScreenContentCallback(
            onAdDismissedFullScreenContent: (ad) {
              ad.dispose();
              _loadInterstitialAd(); // Preload next ad
            },
            onAdFailedToShowFullScreenContent: (ad, error) {
              ad.dispose();
              _loadInterstitialAd();
            },
          );
        },
        onAdFailedToLoad: (error) {
          isInterstitialAdLoaded.value = false;
          // Retry loading after a delay
          Future.delayed(const Duration(seconds: 30), _loadInterstitialAd);
        },
      ),
    );
  }

  void showInterstitialAd() {
    if (interstitialAd != null && isInterstitialAdLoaded.value) {
      interstitialAd!.show();
      isInterstitialAdLoaded.value = false;
    }
  }
}
