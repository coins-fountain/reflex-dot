import 'dart:io';
import 'package:flutter/foundation.dart';

import 'package:get/get.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

class AdController extends GetxController {
  BannerAd? bannerAd;
  var isBannerAdLoaded = false.obs;

  InterstitialAd? interstitialAd;
  var isInterstitialAdLoaded = false.obs;

  RewardedAd? rewardedAd;
  var isRewardedAdLoaded = false.obs;

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

  String get rewardedAdUnitId {
    if (Platform.isAndroid) {
      return 'ca-app-pub-3940256099942544/5224354917';
    } else if (Platform.isIOS) {
      return 'ca-app-pub-3940256099942544/1712485313';
    }
    return '';
  }

  final _consentParams = ConsentRequestParameters();
  var isPrivacyOptionsRequired = false.obs;

  @override
  void onInit() {
    super.onInit();
    _loadConsent();
  }

  Future<void> _loadConsent() async {
    ConsentInformation.instance.requestConsentInfoUpdate(
      _consentParams,
      () async {
        if (await ConsentInformation.instance.isConsentFormAvailable()) {
          _loadConsentForm();
        } else {
          _initializeAndLoadAds();
        }
      },
      (FormError error) {
        debugPrint('Error updating consent info: ${error.message}');
        _initializeAndLoadAds();
      },
    );
  }

  void _loadConsentForm() {
    ConsentForm.loadAndShowConsentFormIfRequired((FormError? error) {
      if (error != null) {
        debugPrint('Error showing consent form: ${error.message}');
      }

      _checkPrivacyOptionsRequired();

      _initializeAndLoadAds();
    });
  }

  Future<void> _checkPrivacyOptionsRequired() async {
    if (await ConsentInformation.instance
            .getPrivacyOptionsRequirementStatus() ==
        PrivacyOptionsRequirementStatus.required) {
      isPrivacyOptionsRequired.value = true;
    } else {
      isPrivacyOptionsRequired.value = false;
    }
  }

  void showPrivacyOptionsForm() {
    ConsentForm.showPrivacyOptionsForm((FormError? error) {
      if (error != null) {
        debugPrint('Error showing privacy options form: ${error.message}');
      }
    });
  }

  void _initializeAndLoadAds() {
    MobileAds.instance.initialize();

    _loadBannerAd();
    _loadInterstitialAd();
    _loadRewardedAd();
  }

  @override
  void onClose() {
    bannerAd?.dispose();
    interstitialAd?.dispose();
    rewardedAd?.dispose();
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

  void _loadRewardedAd() {
    RewardedAd.load(
      adUnitId: rewardedAdUnitId,
      request: const AdRequest(),
      rewardedAdLoadCallback: RewardedAdLoadCallback(
        onAdLoaded: (ad) {
          rewardedAd = ad;
          isRewardedAdLoaded.value = true;
        },
        onAdFailedToLoad: (error) {
          isRewardedAdLoaded.value = false;
          // Retry loading after a delay
          Future.delayed(const Duration(seconds: 30), _loadRewardedAd);
        },
      ),
    );
  }

  void showInterstitialAd() {
    if (interstitialAd != null && isInterstitialAdLoaded.value) {
      interstitialAd!.show();
      interstitialAd = null;
      isInterstitialAdLoaded.value = false;
    }
  }

  void showRewardedAd({required Function onRewardEarned}) {
    if (rewardedAd != null && isRewardedAdLoaded.value) {
      rewardedAd!.fullScreenContentCallback = FullScreenContentCallback(
        onAdDismissedFullScreenContent: (ad) {
          ad.dispose();
          _loadRewardedAd(); // Preload next ad
        },
        onAdFailedToShowFullScreenContent: (ad, error) {
          ad.dispose();
          _loadRewardedAd();
        },
      );

      rewardedAd!.show(
        onUserEarnedReward: (ad, reward) {
          onRewardEarned();
        },
      );

      rewardedAd = null;
      isRewardedAdLoaded.value = false;
    }
  }
}
