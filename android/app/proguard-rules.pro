# Unity Ads Mediation
-keep class com.unity3d.ads.** { *; }
-keep class com.unity3d.services.** { *; }
-keep class com.google.ads.mediation.unity.** { *; }

# Flutter Local Notifications
-keep class com.dexterous.flutterlocalnotifications.** { *; }
-keepclassmembers class **.R$* {
    public static <fields>;
}

# -------------------------------------------------------
# Google Play Billing Library
# ProxyBillingActivity が PendingIntent を null 参照する
# クラッシュを防ぐため、Billing 関連クラスを難読化から保護する
# -------------------------------------------------------
-keep class com.android.billingclient.** { *; }
-keep interface com.android.billingclient.** { *; }
-keepnames class com.android.billingclient.** { *; }

# -------------------------------------------------------
# RevenueCat
# -------------------------------------------------------
-keep class com.revenuecat.purchases.** { *; }
-keep interface com.revenuecat.purchases.** { *; }
-keepnames class com.revenuecat.purchases.** { *; }

# -------------------------------------------------------
# Google Play Services (In-App Billing に必要)
# -------------------------------------------------------
-keep class com.google.android.gms.common.** { *; }
-keep class com.google.android.gms.tasks.** { *; }

# PendingIntent / IntentSender はリフレクション経由で参照される場合がある
-keepclassmembers class * {
    android.app.PendingIntent *;
    android.content.IntentSender *;
}
