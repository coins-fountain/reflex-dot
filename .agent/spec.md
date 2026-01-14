# Technical Design Document: Reflex Dot (Catch the Dot)

> **SYSTEM INSTRUCTION FOR AI AGENT:**
> This document is the **Single Source of Truth** for the "Reflex Dot" Flutter project.
> When generating code, you MUST strictly adhere to the architecture, stack, and constraints defined below.

## 1. Project Overview
**Name:** Reflex Dot (Catch the Dot)
**Type:** High-performance 2D Hand-Eye Coordination Game.
**Platform:** Android & iOS (Flutter).
**Backend:** None (100% Local / Offline).
**Goal:** Tap the dot before it shrinks to zero.

## 2. Technology Stack
* **Framework:** Flutter (Latest Stable).
* **Language:** Dart (Strict Null Safety).
* **Architecture:** **MVVM (Model-View-ViewModel)**.
* **State Management:** **GetX** (`get` package).
    * *Reasoning:* High-performance state management, dependency injection, and simple reactivity using `.obs`.
* **Local Persistence:** **GetStorage** (`get_storage` package).
    * *Reasoning:* Lightweight, fast, and synchronous key-value storage (alternative to SharedPreferences).
* **Assets:** **NONE**.
    * *Constraint:* Do NOT use image files (png/jpg). All graphics must be drawn programmatically using `Container`, `BoxDecoration`, or `CustomPaint`.

## 3. Game Mechanics (The "Business Logic")

### 3.1. The Game Loop
1.  **Idle State:** Show "Start Game" button and current High Score.
2.  **Spawn:** Upon start, a Target (Dot) appears at a random `(x, y)` coordinate.
    * *Constraint:* The Dot must strictly stay within the `SafeArea` of the device.
3.  **The Threat (Shrinking):**
    * The Dot immediately begins to decrease in size from `InitialSize` to `0`.
    * Implementation: Use an `AnimationController` managed within the logic or a Ticker.
4.  **Interaction:**
    * **Success:** Player taps the Dot > Score +1 > Dot respawns immediately at new `(x, y)` > Shrink timer resets (and gets faster).
    * **Failure (Miss):** Player taps the background > Game Over.
    * **Failure (Timeout):** Dot size reaches 0 before tap > Game Over.
5.  **Difficulty Scaling:**
    * As `Score` increases, the `ShrinkDuration` decreases.
    * Formula concept: `Duration = Max(MinimumLimit, BaseDuration - (Score * DifficultyFactor))`.

### 3.2. Scoring
* **Current Score:** Resets to 0 on game start.
* **High Score:** Persisted locally using `GetStorage`. Updates only if Current Score > High Score at the end of the game.

## 4. Architecture & Data Structures (GetX Pattern)

### 4.1. The Controller (`GameController`)
The logic must be encapsulated in a `GetxController`.
Key Observable Variables (`.obs`):

```dart
class GameController extends GetxController with GetTickerProviderStateMixin {
  // Observables
  var isPlaying = false.obs;
  var isGameOver = false.obs;
  var score = 0.obs;
  var highScore = 0.obs;

  // Dot Properties (Reactive)
  var dotPositionX = 0.0.obs;
  var dotPositionY = 0.0.obs;
  var dotSize = 0.0.obs; 
  
  // Storage
  final box = GetStorage();

  // Methods
  void startGame();
  void handleTapDot();
  void handleTapBackground();
  void _spawnDot();
  void _gameOver();
}