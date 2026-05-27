plugins {
    id("com.android.application")
    id("com.google.gms.google-services")
    id("com.google.firebase.firebase-perf")
    id("com.google.firebase.crashlytics")
    id("kotlin-android")
    id("dev.flutter.flutter-gradle-plugin")
}

android {
    namespace = "com.mozmusic.app"
    compileSdk = flutter.compileSdkVersion
    ndkVersion = "27.0.12077973"

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_1_8
        targetCompatibility = JavaVersion.VERSION_1_8
    }

    kotlinOptions {
        jvmTarget = "17"
    }

    defaultConfig {
    
        applicationId = "com.mozmusic.app"
        targetSdk = 34 
        minSdk = flutter.minSdkVersion
        versionCode = flutter.versionCode
        versionName = flutter.versionName
    }

    flavorDimensions += "device"

    productFlavors {
        create("phone") {
            dimension = "device"
            versionNameSuffix = "-phone"
        }

        create("tv") {
            dimension = "device"
            versionNameSuffix = "-tv"
            minSdk = 28
        }
    }


   buildTypes {
    release {
        signingConfig = signingConfigs.getByName("debug")
        isMinifyEnabled = true
        isShrinkResources = true
    }
  }
}

flutter {
    source = "../.."
}
dependencies {
    implementation("androidx.multidex:multidex:2.0.1")
    implementation("org.jetbrains.kotlin:kotlin-stdlib:1.8.10")
    implementation("com.google.android.material:material:1.8.0")
    implementation("com.google.gms:google-services:4.4.4")

    
    val lifecycleVersion = "2.4.0"
    implementation("androidx.lifecycle:lifecycle-viewmodel:$lifecycleVersion")
    implementation("androidx.lifecycle:lifecycle-viewmodel-ktx:$lifecycleVersion")
    
}

