import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../controllers/game_controller.dart';
import 'game_view.dart';
import 'widgets/action_button_widget.dart';
import 'widgets/home_bottom_section.dart';
import 'widgets/score_card_widget.dart';
import 'widgets/title_widget.dart';

class HomeView extends StatelessWidget {
  const HomeView({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<GameController>();
    // AdController used in sub-widgets now

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFF1a1a2e), Color(0xFF16213e), Color(0xFF0f3460)],
          ),
        ),
        child: SafeArea(
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
                                // Left Side: Title & Tagline
                                Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    const TitleWidget(),
                                    const SizedBox(height: 16),
                                    const Text(
                                      'Catch the dot before it vanishes!',
                                      style: TextStyle(
                                        fontSize: 16,
                                        color: Colors.white54,
                                      ),
                                    ),
                                  ],
                                ),
                                // Right Side: Score & Start
                                Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Obx(
                                      () => ScoreCardWidget(
                                        label: 'HIGH SCORE',
                                        score: controller.highScore.value,
                                      ),
                                    ),
                                    const SizedBox(height: 20),
                                    ActionButtonWidget(
                                      text: 'START GAME',
                                      onTap: () {
                                        controller.startGame();
                                        Get.to(() => const GameView());
                                      },
                                    ),
                                  ],
                                ),
                              ],
                            )
                          : Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const TitleWidget(),
                                const SizedBox(height: 16),
                                const Text(
                                  'Catch the dot before it vanishes!',
                                  style: TextStyle(
                                    fontSize: 16,
                                    color: Colors.white54,
                                  ),
                                ),
                                const SizedBox(height: 60),

                                // High Score
                                Obx(
                                  () => ScoreCardWidget(
                                    label: 'HIGH SCORE',
                                    score: controller.highScore.value,
                                  ),
                                ),
                                const SizedBox(height: 40),

                                // Start Button
                                ActionButtonWidget(
                                  text: 'START GAME',
                                  onTap: () {
                                    controller.startGame();
                                    Get.to(() => const GameView());
                                  },
                                ),
                                const SizedBox(height: 20),
                              ],
                            ),
                    ),
                  ),

                  // Bottom section: Privacy Policy & Ad
                  const HomeBottomSection(),
                ],
              );
            },
          ),
        ),
      ),
    );
  }
}
