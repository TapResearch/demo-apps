# Add project specific ProGuard rules here.
# You can control the set of applied configuration files using the
# proguardFiles setting in build.gradle.
#
# For more details, see
#   http://developer.android.com/guide/developing/tools/proguard.html

-keep class * extends androidx.room.RoomDatabase { void <init>(); }

# Only applies to unity games
-keep class com.unity3d.** { *; }
-dontwarn com.unity3d.**
