# Unity Ads Mediation
-keep class com.unity3d.ads.** { *; }
-keep class com.unity3d.services.** { *; }
-keep class com.google.ads.mediation.unity.** { *; }
# Flutter Local Notifications
-keep class com.dexterous.flutterlocalnotifications.** { *; }
-keepclassmembers class **.R$* {
    public static <fields>;
}
