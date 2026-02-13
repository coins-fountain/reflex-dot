import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../controllers/ad_controller.dart';
import '../../controllers/game_controller.dart';

class HomeBottomSection extends StatelessWidget {
  const HomeBottomSection({super.key});

  @override
  Widget build(BuildContext context) {
    final adController = Get.find<AdController>();
    final gameController = Get.find<GameController>();

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Privacy Policy & Privacy Settings Row
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              TextButton.icon(
                onPressed: () {
                  launchUrl(
                    Uri.parse(
                      'https://coins-fountain.github.io/privacy-policy-games/',
                    ),
                    mode: LaunchMode.externalApplication,
                  );
                },
                icon: const Icon(
                  Icons.description_outlined,
                  size: 16,
                  color: Colors.white38,
                ),
                label: const Text(
                  'Privacy Policy',
                  style: TextStyle(fontSize: 12, color: Colors.white38),
                ),
              ),
              Obx(() {
                if (adController.isPrivacyOptionsRequired.value) {
                  return TextButton.icon(
                    onPressed: () => adController.showPrivacyOptionsForm(),
                    icon: const Icon(
                      Icons.privacy_tip_outlined,
                      size: 16,
                      color: Colors.white38,
                    ),
                    label: const Text(
                      'Privacy Settings',
                      style: TextStyle(fontSize: 12, color: Colors.white38),
                    ),
                  );
                }
                return const SizedBox.shrink();
              }),
            ],
          ),
        ),

        // Banner Ad
        Obx(() {
          if (adController.isBannerAdLoaded.value &&
              adController.bannerAd != null) {
            return Container(
              alignment: Alignment.center,
              width: adController.bannerAd!.size.width.toDouble(),
              height: adController.bannerAd!.size.height.toDouble(),
              child: AdWidget(ad: adController.bannerAd!),
            );
          }
          return const SizedBox.shrink();
        }),

        // App Version
        Obx(
          () => Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: Text(
              gameController.appVersion.value,
              style: const TextStyle(
                fontSize: 10,
                color: Colors.white24,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
      ],
    );
  }
}
