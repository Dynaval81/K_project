plugins {
    id("com.android.application")
    id("kotlin-android")
    // The Flutter Gradle Plugin must be applied after the Android and Kotlin Gradle plugins.
    id("dev.flutter.flutter-gradle-plugin")
}
android {
    namespace = "com.example.vtalk_app"
    compileSdk = flutter.compileSdkVersion
    ndkVersion = flutter.ndkVersion
    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_17
        targetCompatibility = JavaVersion.VERSION_17
    }
    kotlinOptions {
        jvmTarget = JavaVersion.VERSION_17.toString()
    }
    defaultConfig {
        applicationId = "com.example.vtalk_app"
        minSdk = flutter.minSdkVersion
        targetSdk = flutter.targetSdkVersion
        versionCode = flutter.versionCode
        versionName = flutter.versionName
    }
    flavorDimensions += "locale"
    productFlavors {
        create("ru") {
            dimension = "locale"
            applicationIdSuffix = ".ru"
            versionNameSuffix = "-ru"
            resValue("string", "app_name", "VTalk")
            buildConfigField("String", "APP_LOCALE", "\"ru\"")
        }
        create("en") {
            dimension = "locale"
            applicationIdSuffix = ".en"
            versionNameSuffix = "-en"
            resValue("string", "app_name", "VTalk")
            buildConfigField("String", "APP_LOCALE", "\"en\"")
        }
        create("de") {
            dimension = "locale"
            applicationIdSuffix = ".de"
            versionNameSuffix = "-de"
            resValue("string", "app_name", "VTalk")
            buildConfigField("String", "APP_LOCALE", "\"de\"")
        }
    }
    buildTypes {
        release {
            signingConfig = signingConfigs.getByName("debug")
        }
    }
    buildFeatures {
        buildConfig = true
    }
}
flutter {
    source = "../.."
}
