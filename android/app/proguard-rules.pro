# Flutter Wrapper
-keep class io.flutter.app.** { *; }
-keep class io.flutter.plugin.**  { *; }
-keep class io.flutter.util.**  { *; }
-keep class io.flutter.view.**  { *; }
-keep class io.flutter.**  { *; }
-keep class io.flutter.plugins.**  { *; }

# Google Mobile Ads
-keep class com.google.android.gms.ads.** { *; }
-keep class com.google.ads.** { *; }

# GetX
-keep class get.** { *; }
-keepnames class * extends get.GetxController

# Prevent obfuscating generic types
-keepattributes Signature
-keepattributes *Annotation*
-keepattributes EnclosingMethod

# Flutter Embedder
-keep class io.flutter.embedding.engine.** { *; }

# Google Play Core
-keep class com.google.android.play.core.splitcompat.** { *; }
-keep class com.google.android.play.core.splitinstall.** { *; }
-keep class com.google.android.play.core.tasks.** { *; }
-keep class com.google.android.play.core.assetpacks.** { *; }
-keep class com.google.android.play.core.review.** { *; }
-keep class com.google.android.play.core.appupdate.** { *; }
-dontwarn com.google.android.play.core.**
