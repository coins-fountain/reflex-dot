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
