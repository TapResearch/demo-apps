# Add project specific ProGuard rules here.
# You can control the set of applied configuration files using the
# proguardFiles setting in build.gradle.
#
# For more details, see
#   http://developer.android.com/guide/developing/tools/proguard.html

# Keep AndroidX Startup components
-keep class androidx.startup.InitializationProvider { *; }
-keep class * implements androidx.startup.Initializer { *; }

# -----------------------------------------------------------------------------------------
# General Demo App Rules (to ensure stability across common libraries)
# -----------------------------------------------------------------------------------------

-keep class androidx.work.** { *; }
-dontwarn androidx.work.**



