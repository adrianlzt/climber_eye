plugins {
    id("com.android.application")
    id("kotlin-android")
    id("dev.flutter.flutter-gradle-plugin")
}

android {
    namespace = "com.adrianlzt.crux_sync"
    compileSdk = 35

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_1_8
        targetCompatibility = JavaVersion.VERSION_1_8
    }

    kotlinOptions {
        jvmTarget = "1.8"
    }

    sourceSets {
        getByName("main").java.srcDirs("src/main/kotlin")
    }

    defaultConfig {
        applicationId = "com.adrianlzt.crux_sync"
        minSdk = 24
        targetSdk = 35
        versionCode = 70
        versionName = "0.7.0"
    }

    buildTypes {
        getByName("release") {
            // No signing config needed - F-Droid handles signing
        }
    }
}

dependencies {
    // No changes needed here *yet*, but double-check all dependencies
    // are FOSS when you add them.  For now, it's empty, which is fine.
}
