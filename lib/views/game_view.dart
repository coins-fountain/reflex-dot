import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

import '../controllers/ad_controller.dart';
import '../controllers/game_controller.dart';
import 'widgets/game_dot.dart';

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
                if (controller.isPlaying.value &&
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

              // Idle Screen
              Obx(() {
                if (!controller.isPlaying.value &&
                    !controller.isGameOver.value) {
                  return _buildIdleScreen(controller);
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
            ],
          );
        },
      ),
    );
  }

  Widget _buildIdleScreen(GameController controller) {
    final adController = Get.find<AdController>();

    return SafeArea(
      child: Column(
        children: [
          Expanded(
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Title
                  ShaderMask(
                    shaderCallback: (bounds) => const LinearGradient(
                      colors: [Colors.orange, Colors.deepOrange, Colors.red],
                    ).createShader(bounds),
                    child: const Text(
                      'REFLEX DOT',
                      style: TextStyle(
                        fontSize: 48,
                        fontWeight: FontWeight.w900,
                        color: Colors.white,
                        letterSpacing: 4,
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'Catch the dot before it vanishes!',
                    style: TextStyle(fontSize: 16, color: Colors.white54),
                  ),
                  const SizedBox(height: 60),

                  // High Score
                  _buildScoreCard('HIGH SCORE', controller.highScore.value),
                  const SizedBox(height: 40),

                  // Start Button
                  _buildActionButton('START GAME', onTap: controller.startGame),
                ],
              ),
            ),
          ),

          // Banner Ad at bottom
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
        ],
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
      adController.showInterstitialAd();
    });

    return SafeArea(
      child: Column(
        children: [
          Expanded(
            child: Center(
              child: Column(
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
                  _buildScoreCard('YOUR SCORE', controller.score.value),
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
                    _buildScoreCard('HIGH SCORE', controller.highScore.value),

                  const SizedBox(height: 50),

                  // Play Again Button
                  _buildActionButton('PLAY AGAIN', onTap: controller.playAgain),
                ],
              ),
            ),
          ),

          // Banner Ad at bottom
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
        ],
      ),
    );
  }

  Widget _buildScoreCard(String label, int score) {
    return Column(
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 14,
            color: Colors.white38,
            letterSpacing: 2,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          score.toString(),
          style: const TextStyle(
            fontSize: 64,
            fontWeight: FontWeight.w900,
            color: Colors.white,
          ),
        ),
      ],
    );
  }

  Widget _buildActionButton(String text, {required VoidCallback onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 48, vertical: 18),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [Colors.deepOrange, Colors.orange],
          ),
          borderRadius: BorderRadius.circular(30),
          boxShadow: [
            BoxShadow(
              color: Colors.deepOrange.withValues(alpha: 0.4),
              blurRadius: 20,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Text(
          text,
          style: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.white,
            letterSpacing: 2,
          ),
        ),
      ),
    );
  }
}
