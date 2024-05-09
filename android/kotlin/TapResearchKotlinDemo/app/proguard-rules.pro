# Add project specific ProGuard rules here.
# You can control the set of applied configuration files using the
# proguardFiles setting in build.gradle.
#
# For more details, see
#   http://developer.android.com/guide/developing/tools/proguard.html

# If your project uses WebView with JS, uncomment the following
# and specify the fully qualified class name to the JavaScript interface
# class:
#-keepclassmembers class fqcn.of.javascript.interface.for.webview {
#   public *;
#}

# Uncomment this to preserve the line number information for
# debugging stack traces.
#-keepattributes SourceFile,LineNumberTable

# If you keep the line number information, uncomment this to
# hide the original source file name.
#-renamesourcefileattribute SourceFile

# ProGuard rules for TapResearch
-keep class com.tapresearch.** {*;}
-keep interface com.tapresearch.** {*;}
-keepattributes Exceptions, MethodParameters
-keepattributes LocalVariableTable,LocalVariableTypeTable
-keepparameternames

# Preserve all annotations.
-keepattributes *Annotation*

-dontwarn android.app.Activity

-keepclassmembers class * {
    @android.webkit.JavascriptInterface <methods>;
}

# Keep filenames and line numbers for stack traces
-keepattributes SourceFile,LineNumberTable

# Keep JavascriptInterface for WebView bridge
-keepattributes JavascriptInterface

# Sometimes keepattributes is not enough to keep annotations
-keep class android.webkit.JavascriptInterface {
   *;
}

-keep class androidx.** {*;}
-keep interface androidx.** {*;}
-dontwarn androidx.**

-keep class com.unity3d.** {*;}
-keep interface com.unity3d.** {*;}

-keepattributes Signature, *Annotation*