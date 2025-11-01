plugins {
    id("com.android.application")
    id("org.jetbrains.kotlin.android")
    // Flutter Gradle Plugin harus diterapkan setelah Android dan Kotlin Gradle plugins
    id("dev.flutter.flutter-gradle-plugin")
}

android {
    namespace = "com.example.vsf"
    compileSdk = flutter.compileSdkVersion.toInt()  // ✅ pakai toInt()
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
        minSdk = flutter.minSdkVersion.toInt()       // ✅
        targetSdk = flutter.targetSdkVersion.toInt() // ✅
        versionCode = flutter.versionCode.toInt()    // ✅
        versionName = flutter.versionName

        javaCompileOptions {
            annotationProcessorOptions {
                // Ganti sesuai kebutuhan (hapus jika tidak pakai ARouter)
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