import java.util.Properties
import java.io.FileInputStream

plugins {
    id("com.android.application")
    id("kotlin-android")
    id("dev.flutter.flutter-gradle-plugin")
}

// ✅ تحميل key.properties للتوقيع
val keyPropertiesFile = rootProject.file("key.properties")
val keyProperties = Properties()
if (keyPropertiesFile.exists()) {
    keyProperties.load(FileInputStream(keyPropertiesFile))
}

android {
    namespace = "com.pyramic.samsungsmarttv"
    compileSdk = flutter.compileSdkVersion
    ndkVersion = flutter.ndkVersion

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_17
        targetCompatibility = JavaVersion.VERSION_17
    }

    kotlinOptions {
        jvmTarget = JavaVersion.VERSION_17.toString()
    }

    // ✅ إعداد التوقيع
    signingConfigs {
        create("release") {
            keyAlias = keyProperties["keyAlias"] as String? ?: System.getenv("CM_KEY_ALIAS")
            keyPassword = keyProperties["keyPassword"] as String? ?: System.getenv("CM_KEY_PASSWORD")
            storeFile = if (keyProperties["storeFile"] != null)
                file(keyProperties["storeFile"] as String)
            else if (System.getenv("CM_KEYSTORE_PATH") != null)
                file(System.getenv("CM_KEYSTORE_PATH")!!)
            else null
            storePassword = keyProperties["storePassword"] as String? ?: System.getenv("CM_KEYSTORE_PASSWORD")
        }
    }

    defaultConfig {
        applicationId = "com.pyramic.samsungsmarttv"
        minSdk = 21
        targetSdk = flutter.targetSdkVersion
        versionCode = flutter.versionCode
        versionName = flutter.versionName
    }

    buildTypes {
        release {
            // ✅ التوقيع بـ release key
            signingConfig = signingConfigs.getByName("release")
            isMinifyEnabled = false
            isShrinkResources = false
        }
    }
}

flutter {
    source = "../.."
}
