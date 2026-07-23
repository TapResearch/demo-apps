# Add project specific ProGuard rules here.
# You can control the set of applied configuration files using the
# proguardFiles setting in build.gradle.
#
# For more details, see
#   http://developer.android.com/guide/developing/tools/proguard.html

# -----------------------------------------------------------------------------------------
# TapResearch Specific Rules
# -----------------------------------------------------------------------------------------

# Preserve all classes and interfaces in the TapResearch package
-keep class com.tapresearch.** { *; }
-dontwarn com.tapresearch.**

# Preserve necessary attributes for the SDK
-keepattributes Exceptions, InnerClasses, Signature, Deprecated, SourceFile, LineNumberTable, *Annotation*, EnclosingMethod, MethodParameters, LocalVariableTable, LocalVariableTypeTable

# Preserve parameter names
-keepparameternames

# -----------------------------------------------------------------------------------------
# WebView / JavaScript Rules
# -----------------------------------------------------------------------------------------

# Preserve JavascriptInterface for WebView bridge
-keepclassmembers class * {
    @android.webkit.JavascriptInterface <methods>;
}

# Preserve the JavascriptInterface annotation itself
-keep class android.webkit.JavascriptInterface { *; }

# -----------------------------------------------------------------------------------------
# General Demo App Rules (to ensure stability across common libraries)
# -----------------------------------------------------------------------------------------

-keep class androidx.** { *; }
-dontwarn androidx.**

-keep class kotlinx.** { *; }
-dontwarn kotlinx.**

-keep class com.google.** { *; }
-dontwarn com.google.**

-keep class com.unity3d.** { *; }
-dontwarn com.unity3d.**

# Optional: Preserve line numbers and source file names for debugging stack traces
-renamesourcefileattribute SourceFile
