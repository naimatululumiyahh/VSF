plugins {
    id("com.android.application")
    id("org.jetbrains.kotlin.android")
    // The Flutter Gradle Plugin must be applied after the Android and Kotlin Gradle plugins.
    id("dev.flutter.flutter-gradle-plugin")
}

android {
    namespace = "com.example.vsf"
    compileSdk = flutter.compileSdkVersion.toInteger()
    ndkVersion = flutter.ndkVersion

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_17
        targetCompatibility = JavaVersion.VERSION_17
        isCoreLibraryDesugaringEnabled = true
    }

    kotlinOptions {
        jvmTarget = JavaVersion.VERSION_17.toString()
    }

    defaultConfig {
        applicationId = "com.example.vsf"
        minSdk = flutter.minSdkVersion.toInteger()
        targetSdk = flutter.targetSdkVersion.toInteger()
        versionCode = flutter.versionCode.toInteger()
        versionName = flutter.versionName

        javaCompileOptions {
            annotationProcessorOptions {
                // Hati-hati dengan variabel ini, ganti sesuai kebutuhan jika tidak menggunakan ARouter
                arguments(mapOf("AROUTER_MODULE_NAME" to project.name))
            }
        }
    }

    buildTypes {
        release {
            signingConfig = signingConfigs.getByName("debug")
        }
    }
}

flutter {
    source = "../.."
}

dependencies {
    coreLibraryDesugaring("com.android.tools:desugar_jdk_libs:2.0.4")
    // Tambahkan dependencies Flutter, Kotlin, atau AndroidX lainnya di sini
}