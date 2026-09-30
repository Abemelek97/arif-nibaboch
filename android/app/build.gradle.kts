plugins {
    alias(libs.plugins.android.application)
}

android {
    namespace = "et.netale.litloop"
    compileSdk {
        version = release(36) {
            minorApiLevel = 1
        }
    }

    defaultConfig {
        applicationId = "et.netale.litloop"
        minSdk = 28
        targetSdk = 36
        versionCode = 1
        versionName = "1.0"

        testInstrumentationRunner = "androidx.test.runner.AndroidJUnitRunner"
    }

    val uploadKeystore = System.getenv("LITLOOP_UPLOAD_KEYSTORE")

    signingConfigs {
        create("release") {
            storeFile = uploadKeystore?.let { file(it) }
            storePassword = System.getenv("LITLOOP_UPLOAD_KEYSTORE_PASSWORD")
            keyAlias = System.getenv("LITLOOP_UPLOAD_KEY_ALIAS")
            keyPassword = System.getenv("LITLOOP_UPLOAD_KEY_PASSWORD")
        }
    }

    buildTypes {
        release {
            if (uploadKeystore != null) {
                signingConfig = signingConfigs.getByName("release")
            }
            isMinifyEnabled = false
            proguardFiles(
                getDefaultProguardFile("proguard-android-optimize.txt"),
                "proguard-rules.pro"
            )
        }
    }
    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_11
        targetCompatibility = JavaVersion.VERSION_11
    }
}

dependencies {
    implementation(libs.androidx.activity.ktx)
    implementation(libs.androidx.appcompat)
    implementation(libs.androidx.constraintlayout)
    implementation("dev.hotwire:core:1.2.0")
    implementation("dev.hotwire:navigation-fragments:1.2.0")
    implementation("androidx.core:core-splashscreen:1.0.1")
    implementation(libs.androidx.core.ktx)
    implementation(libs.material)
    testImplementation(libs.junit)
    androidTestImplementation(libs.androidx.espresso.core)
    androidTestImplementation(libs.androidx.junit)
}
