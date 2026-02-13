import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../controllers/ad_controller.dart';
import '../../controllers/game_controller.dart';

class RevivePopupWidget extends StatelessWidget {
  final GameController gameController;

  const RevivePopupWidget({super.key, required this.gameController});

  @override
  Widget build(BuildContext context) {
    final adController = Get.find<AdController>();

    // Auto-dismiss after 15 seconds
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 15.0, end: 0.0),
      duration: const Duration(seconds: 15),
      onEnd: () {
        if (gameController.showRevivePopup.value) {
          gameController.confirmGameOver();
        }
      },
      builder: (context, value, child) {
        return Container(
          color: Colors.black54,
          child: Center(
            child: SingleChildScrollView(
              child: Container(
                margin: const EdgeInsets.symmetric(horizontal: 32),
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: const Color(0xFF16213e),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: Colors.orange, width: 2),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.5),
                      blurRadius: 20,
                      spreadRadius: 5,
                    ),
                  ],
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Text(
                      'CONTINUE?',
                      style: TextStyle(
                        fontSize: 32,
                        fontWeight: FontWeight.w900,
                        color: Colors.white,
                        letterSpacing: 2,
                      ),
                    ),
                    const SizedBox(height: 20),

                    // Countdown
                    Stack(
                      alignment: Alignment.center,
                      children: [
                        CircularProgressIndicator(
                          value: value / 5,
                          strokeWidth: 6,
                          color: Colors.orange,
                          backgroundColor: Colors.white10,
                        ),
                        Text(
                          value.ceil().toString(),
                          style: const TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 30),

                    // Watch Ad Button
                    Obx(() {
                      final isAdReady = adController.isRewardedAdLoaded.value;
                      return GestureDetector(
                        onTap: isAdReady
                            ? () {
                                adController.showRewardedAd(
                                  onRewardEarned: () {
                                    gameController.startResumeCountdown();
                                  },
                                );
                              }
                            : null,
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 24,
                            vertical: 16,
                          ),
                          decoration: BoxDecoration(
                            gradient: isAdReady
                                ? const LinearGradient(
                                    colors: [Colors.blue, Colors.blueAccent],
                                  )
                                : LinearGradient(
                                    colors: [Colors.grey, Colors.grey.shade700],
                                  ),
                            borderRadius: BorderRadius.circular(15),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.play_circle_fill,
                                color: isAdReady
                                    ? Colors.white
                                    : Colors.white38,
                              ),
                              const SizedBox(width: 12),
                              Text(
                                isAdReady ? 'WATCH AD' : 'LOADING AD...',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: isAdReady
                                      ? Colors.white
                                      : Colors.white38,
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    }),
                    const SizedBox(height: 16),

                    // No Thanks Button
                    TextButton(
                      onPressed: gameController.confirmGameOver,
                      child: const Text(
                        'NO THANKS',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.white54,
                          letterSpacing: 1,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
