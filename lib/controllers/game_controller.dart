import 'dart:math';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:package_info_plus/package_info_plus.dart';

class GameController extends GetxController with GetTickerProviderStateMixin {
  //  Observable Variables
  var isPlaying = false.obs;
  var isGameOver = false.obs;
  var showRevivePopup = false.obs;
  var hasRevived = false.obs;
  var isResuming = false.obs;
  var resumeCountdown = 3.obs;
  var score = 0.obs;
  var highScore = 0.obs;
  var appVersion = ''.obs;

  // Ad Logic
  DateTime? lastAdTime;
  static const int adCooldownSeconds = 60;

  // Dot Properties
  var dotPositionX = 0.0.obs;
  var dotPositionY = 0.0.obs;
  var dotSize = 0.0.obs;

  //  Constants
  static const double initialDotSize = 80.0;
  static const double minDotSize = 0.0;
  static const int baseShrinkDurationMs = 2000;
  static const int minShrinkDurationMs = 600;
  static const int difficultyFactor = 40;

  //  Internal
  final _storage = GetStorage();
  late AnimationController _shrinkController;
  late Animation<double> _shrinkAnimation;
  final Random _random = Random();

  Size _screenSize = Size.zero;
  EdgeInsets _safeAreaPadding = EdgeInsets.zero;

  @override
  void onInit() {
    super.onInit();
    _loadHighScore();
    _initShrinkAnimation();
    _loadAppVersion();
  }

  @override
  void onClose() {
    _shrinkController.dispose();
    super.onClose();
  }

  void setScreenConstraints(Size screenSize, EdgeInsets safeAreaPadding) {
    _screenSize = screenSize;
    _safeAreaPadding = safeAreaPadding;
  }

  void _loadHighScore() {
    highScore.value = _storage.read<int>('highScore') ?? 0;
  }

  Future<void> _loadAppVersion() async {
    final packageInfo = await PackageInfo.fromPlatform();
    appVersion.value = 'v${packageInfo.version}';
  }

  void _saveHighScore() {
    _storage.write('highScore', highScore.value);
  }

  void _initShrinkAnimation() {
    _shrinkController = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: baseShrinkDurationMs),
    );

    _shrinkAnimation = Tween<double>(begin: initialDotSize, end: minDotSize)
        .animate(
          CurvedAnimation(parent: _shrinkController, curve: Curves.easeInOut),
        );

    _shrinkAnimation.addListener(() {
      dotSize.value = _shrinkAnimation.value;
    });

    _shrinkController.addStatusListener((status) {
      if (status == AnimationStatus.completed && isPlaying.value) {
        _gameOver();
      }
    });
  }

  void _updateShrinkDuration() {
    final newDuration = max(
      minShrinkDurationMs,
      baseShrinkDurationMs - (score.value * difficultyFactor),
    );
    _shrinkController.duration = Duration(milliseconds: newDuration);
  }

  void startGame() {
    score.value = 0;
    isPlaying.value = true;
    isGameOver.value = false;
    showRevivePopup.value = false;
    hasRevived.value = false;
    isResuming.value = false;
    _spawnDot();
  }

  void _spawnDot() {
    // Calculate safe bounds
    final double padding = initialDotSize;
    final double minX = _safeAreaPadding.left + padding;
    final double maxX = _screenSize.width - _safeAreaPadding.right - padding;
    final double minY =
        _safeAreaPadding.top + padding + 60; // Extra space for score
    final double maxY = _screenSize.height - _safeAreaPadding.bottom - padding;

    // Random position within safe area
    dotPositionX.value = minX + _random.nextDouble() * (maxX - minX);
    dotPositionY.value = minY + _random.nextDouble() * (maxY - minY);

    // Reset and start shrink animation
    dotSize.value = initialDotSize;
    _updateShrinkDuration();
    _shrinkController.reset();
    _shrinkController.forward();
  }

  void handleTapDot() {
    if (!isPlaying.value || isGameOver.value) return;

    score.value++;
    _spawnDot();
  }

  void handleTapBackground() {
    if (!isPlaying.value || isGameOver.value) return;

    _gameOver();
  }

  void _gameOver() {
    isPlaying.value = false;
    _shrinkController.stop();

    if (!hasRevived.value) {
      showRevivePopup.value = true;
    } else {
      confirmGameOver();
    }
  }

  void startResumeCountdown() {
    showRevivePopup.value = false;
    isResuming.value = true;
    resumeCountdown.value = 5; // 5 seconds countdown

    // Start timer
    Future.doWhile(() async {
      await Future.delayed(const Duration(seconds: 1));
      if (!isResuming.value) return false; // Cancel if something else happens

      resumeCountdown.value--;
      if (resumeCountdown.value <= 0) {
        resumeGame();
        return false;
      }
      return true;
    });
  }

  void resumeGame() {
    isResuming.value = false;
    hasRevived.value = true;
    isPlaying.value = true;
    isGameOver.value = false;

    // Give a fresh dot to continue
    _spawnDot();
  }

  void confirmGameOver() {
    showRevivePopup.value = false;
    isGameOver.value = true;
    isGameOver.value = true;

    if (score.value > highScore.value) {
      highScore.value = score.value;
      _saveHighScore();
    }
  }

  void playAgain() {
    startGame();
  }

  bool canShowAd() {
    if (lastAdTime == null) {
      return true;
    }
    final difference = DateTime.now().difference(lastAdTime!);
    return difference.inSeconds >= adCooldownSeconds;
  }

  void markAdShown() {
    lastAdTime = DateTime.now();
  }
}
