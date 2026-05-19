# Project-specific Android release shrinker rules.

# Keep Firebase Auth and reCAPTCHA classes to prevent CONFIGURATION_NOT_FOUND errors
-keep class com.google.firebase.auth.** { *; }
-keep class com.google.android.recaptcha.** { *; }
-keep class com.google.android.gms.** { *; }
