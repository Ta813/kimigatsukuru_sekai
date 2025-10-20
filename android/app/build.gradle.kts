import java.util.Properties
import java.io.FileInputStream

plugins {
    id("com.android.application")
    // START: FlutterFire Configuration
    id("com.google.gms.google-services")
    // END: FlutterFire Configuration
    id("kotlin-android")
    // The Flutter Gradle Plugin must be applied after the Android and Kotlin Gradle plugins.
    id("dev.flutter.flutter-gradle-plugin")
    id("com.google.firebase.crashlytics")
}

android {
    namespace = "com.kotoapp.kimigatsukuru_sekai"
    compileSdk = flutter.compileSdkVersion
    ndkVersion = flutter.ndkVersion

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_11
        targetCompatibility = JavaVersion.VERSION_11
    }

    kotlinOptions {
        jvmTarget = JavaVersion.VERSION_11.toString()
    }

    defaultConfig {
        // TODO: Specify your own unique Application ID (https://developer.android.com/studio/build/application-id.html).
        applicationId = "com.kotoapp.kimigatsukuru_sekai"
        // You can update the following values to match your application needs.
        // For more information, see: https://flutter.dev/to/review-gradle-config.
        minSdk = flutter.minSdkVersion
        targetSdk = flutter.targetSdkVersion
        versionCode = flutter.versionCode
        versionName = flutter.versionName
    }

    val keyPropertiesFile = rootProject.file("key.properties")
    val keyProperties = Properties()
    keyProperties.load(FileInputStream(keyPropertiesFile))

    signingConfigs {
        create("release") {
            keyAlias = keyProperties.getProperty("keyAlias")
            keyPassword = keyProperties.getProperty("keyPassword")
            storeFile = file(keyProperties.getProperty("storeFile"))
            storePassword = keyProperties.getProperty("storePassword")
        }
    }

    buildTypes {
        getByName("release") {
            signingConfig = signingConfigs.getByName("release")

            isMinifyEnabled = true // R8を有効にする（すでにある場合はそのままでOK）
            proguardFiles(getDefaultProguardFile("proguard-android-optimize.txt"), "proguard-rules.pro")
        }
    }
}

dependencies {
    // Kotlinの標準ライブラリ（念のため追加）
    implementation(kotlin("stdlib-jdk7"))

    // AdMob Unity Ads メディエーションアダプタ
    implementation("com.google.ads.mediation:unity:4.13.1.0")

    // Unity Ads SDK本体を明示的に追加する
    implementation("com.unity3d.ads:unity-ads:4.13.1")

    // ironSource Mediation Adapter
    implementation("com.google.ads.mediation:ironsource:9.0.0.0")
}

flutter {
    source = "../.."
}
