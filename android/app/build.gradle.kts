plugins {
    id("com.android.application")
    id("kotlin-android")
    // O Flutter Gradle Plugin deve vir após o Android e Kotlin
    id("dev.flutter.flutter-gradle-plugin")
    // O erro estava aqui: a linha repetida do com.android.application foi removida
    
    // Plugin do Google Services para o Firebase
    id("com.google.gms.google-services")
}

dependencies {
    // Importa o Firebase BoM
    implementation(platform("com.google.firebase:firebase-bom:34.12.0"))

    // Adicione as dependências do Firebase aqui
    implementation("com.google.firebase:firebase-analytics")
}

android {
    namespace = "com.example.ethos"
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
        applicationId = "com.example.ethos"
        minSdk = flutter.minSdkVersion
        targetSdk = flutter.targetSdkVersion
        versionCode = flutter.versionCode
        versionName = flutter.versionName
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