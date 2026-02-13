import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

import '../controllers/ad_controller.dart';
import '../controllers/game_controller.dart';
import 'widgets/action_button_widget.dart';
import 'widgets/game_dot.dart';
import 'widgets/revive_popup_widget.dart';
import 'widgets/score_card_widget.dart';
import 'widgets/secondary_button_widget.dart';

class GameView extends StatelessWidget {
  const GameView({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<GameController>();

    return Scaffold(
      body: LayoutBuilder(
        builder: (context, constraints) {
          // Pass screen size and safe area to controller
          WidgetsBinding.instance.addPostFrameCallback((_) {
            final padding = MediaQuery.of(context).padding;
            controller.setScreenConstraints(
              Size(constraints.maxWidth, constraints.maxHeight),
              padding,
            );
          });

          return Stack(
            children: [
              // Background gradient
              Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      Color(0xFF1a1a2e),
                      Color(0xFF16213e),
                      Color(0xFF0f3460),
                    ],
                  ),
                ),
              ),

              // Game area (tap to miss)
              Obx(() {
                if (controller.isPlaying.value &&
                    !controller.isGameOver.value) {
                  return GestureDetector(
                    behavior: HitTestBehavior.opaque,
                    onTap: controller.handleTapBackground,
                    child: const SizedBox.expand(),
                  );
                }
                return const SizedBox.shrink();
              }),

              // Score display during game
              Obx(() {
                if ((controller.isPlaying.value ||
                        controller.isResuming.value) &&
                    !controller.isGameOver.value) {
                  return SafeArea(
                    child: Padding(
                      padding: const EdgeInsets.all(20),
                      child: Text(
                        'Score: ${controller.score.value}',
                        style: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Colors.white70,
                        ),
                      ),
                    ),
                  );
                }
                return const SizedBox.shrink();
              }),

              // The Dot
              Obx(() {
                if (controller.isPlaying.value &&
                    !controller.isGameOver.value &&
                    controller.dotSize.value > 0) {
                  return Positioned(
                    left:
                        controller.dotPositionX.value -
                        controller.dotSize.value / 2,
                    top:
                        controller.dotPositionY.value -
                        controller.dotSize.value / 2,
                    child: GestureDetector(
                      onTap: controller.handleTapDot,
                      child: GameDot(size: controller.dotSize.value),
                    ),
                  );
                }
                return const SizedBox.shrink();
              }),

              // Game Over Screen
              Obx(() {
                if (controller.isGameOver.value) {
                  return _buildGameOverScreen(controller);
                }
                return const SizedBox.shrink();
              }),

              // Revive Popup
              Obx(() {
                if (controller.showRevivePopup.value) {
                  return RevivePopupWidget(gameController: controller);
                }
                return const SizedBox.shrink();
              }),

              // Resume Countdown Overlay
              Obx(() {
                if (controller.isResuming.value) {
                  return Container(
                    color: Colors.black54,
                    child: Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Text(
                            'RESUMING IN',
                            style: TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                              letterSpacing: 2,
                            ),
                          ),
                          const SizedBox(height: 20),
                          Text(
                            controller.resumeCountdown.value.toString(),
                            style: const TextStyle(
                              fontSize: 80,
                              fontWeight: FontWeight.w900,
                              color: Colors.orange,
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                }
                return const SizedBox.shrink();
              }),
            ],
          );
        },
      ),
    );
  }

  Widget _buildGameOverScreen(GameController controller) {
    final adController = Get.find<AdController>();
    final isNewHighScore =
        controller.score.value >= controller.highScore.value &&
        controller.score.value > 0;

    // Show interstitial ad when game over screen is displayed
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (controller.canShowAd()) {
        adController.showInterstitialAd();
        controller.markAdShown();
      }
    });

    return SafeArea(
      child: OrientationBuilder(
        builder: (context, orientation) {
          final isLandscape = orientation == Orientation.landscape;

          return Column(
            children: [
              Expanded(
                child: Center(
                  child: isLandscape
                      ? Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            // Left Side: Title & Score
                            Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const Text(
                                  'GAME OVER',
                                  style: TextStyle(
                                    fontSize: 42,
                                    fontWeight: FontWeight.w900,
                                    color: Colors.redAccent,
                                    letterSpacing: 4,
                                  ),
                                ),
                                const SizedBox(height: 20),
                                ScoreCardWidget(
                                  label: 'YOUR SCORE',
                                  score: controller.score.value,
                                ),
                              ],
                            ),
                            // Right Side: High Score & Buttons
                            Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                if (isNewHighScore)
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 20,
                                      vertical: 8,
                                    ),
                                    decoration: BoxDecoration(
                                      gradient: const LinearGradient(
                                        colors: [Colors.amber, Colors.orange],
                                      ),
                                      borderRadius: BorderRadius.circular(20),
                                    ),
                                    child: const Text(
                                      '🎉 NEW HIGH SCORE! 🎉',
                                      style: TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.black87,
                                      ),
                                    ),
                                  )
                                else
                                  ScoreCardWidget(
                                    label: 'HIGH SCORE',
                                    score: controller.highScore.value,
                                  ),
                                const SizedBox(height: 30),
                                ActionButtonWidget(
                                  text: 'PLAY AGAIN',
                                  onTap: controller.playAgain,
                                ),
                                const SizedBox(height: 12),
                                SecondaryButtonWidget(
                                  text: 'HOME',
                                  onTap: () => Get.back(),
                                ),
                              ],
                            ),
                          ],
                        )
                      : Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            // Game Over Title
                            const Text(
                              'GAME OVER',
                              style: TextStyle(
                                fontSize: 42,
                                fontWeight: FontWeight.w900,
                                color: Colors.redAccent,
                                letterSpacing: 4,
                              ),
                            ),
                            const SizedBox(height: 40),

                            // Score
                            ScoreCardWidget(
                              label: 'YOUR SCORE',
                              score: controller.score.value,
                            ),
                            const SizedBox(height: 16),

                            // High Score
                            if (isNewHighScore)
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 20,
                                  vertical: 8,
                                ),
                                decoration: BoxDecoration(
                                  gradient: const LinearGradient(
                                    colors: [Colors.amber, Colors.orange],
                                  ),
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                child: const Text(
                                  '🎉 NEW HIGH SCORE! 🎉',
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.black87,
                                  ),
                                ),
                              )
                            else
                              ScoreCardWidget(
                                label: 'HIGH SCORE',
                                score: controller.highScore.value,
                              ),

                            const SizedBox(height: 50),

                            // Play Again Button
                            ActionButtonWidget(
                              text: 'PLAY AGAIN',
                              onTap: controller.playAgain,
                            ),
                            const SizedBox(height: 16),

                            // Home Button
                            SecondaryButtonWidget(
                              text: 'HOME',
                              onTap: () => Get.back(),
                            ),
                          ],
                        ),
                ),
              ),
              // Banner Ad at bottom
              Obx(() {
                if (adController.isGameBannerAdLoaded.value &&
                    adController.gameBannerAd != null) {
                  return Container(
                    alignment: Alignment.center,
                    width: adController.gameBannerAd!.size.width.toDouble(),
                    height: adController.gameBannerAd!.size.height.toDouble(),
                    child: AdWidget(ad: adController.gameBannerAd!),
                  );
                }
                return const SizedBox.shrink();
              }),
            ],
          );
        },
      ),
    );
  }
}
