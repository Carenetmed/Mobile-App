import java.io.File
import java.security.KeyStore
import java.security.MessageDigest
import java.security.cert.X509Certificate

plugins {
    id("com.android.application")
    id("kotlin-android")
    // The Flutter Gradle Plugin must be applied after the Android and Kotlin Gradle plugins.
    id("dev.flutter.flutter-gradle-plugin")
}

val uploadStorePath = providers.environmentVariable("CARENET_UPLOAD_KEYSTORE_PATH").orNull
val uploadStorePassword = providers.environmentVariable("CARENET_UPLOAD_STORE_PASSWORD").orNull
val uploadKeyAlias = providers.environmentVariable("CARENET_UPLOAD_KEY_ALIAS").orNull
val uploadKeyPassword = providers.environmentVariable("CARENET_UPLOAD_KEY_PASSWORD").orNull
val uploadCertificateSha256 = providers.environmentVariable("CARENET_UPLOAD_CERT_SHA256").orNull
val uploadSigningConfigured = listOf(uploadStorePath, uploadStorePassword,
    uploadKeyAlias, uploadKeyPassword, uploadCertificateSha256).all { !it.isNullOrBlank() }

val validateReleaseSigning = tasks.register("validateReleaseSigning") {
    doLast {
        check(uploadSigningConfigured) {
            "Release signing is not configured. Supply the protected CARENET_UPLOAD_* environment values."
        }
        val store = file(uploadStorePath!!).canonicalFile
        check(File(uploadStorePath).isAbsolute && store.isFile &&
            !store.toPath().startsWith(rootProject.projectDir.parentFile.canonicalFile.toPath())) {
            "The upload keystore must exist outside the repository."
        }
        try {
            val keyStore = KeyStore.getInstance(store, uploadStorePassword!!.toCharArray())
            check(keyStore.isKeyEntry(uploadKeyAlias)) { "Upload signing alias is not a private key." }
            val certificate = keyStore.getCertificate(uploadKeyAlias) as X509Certificate
            check(!certificate.subjectX500Principal.name.contains("CN=Android Debug", ignoreCase = true)) {
                "Android debug certificates are not allowed for release signing."
            }
            val actual = MessageDigest.getInstance("SHA-256")
                .digest(certificate.encoded).joinToString("") { "%02X".format(it) }
            val expected = uploadCertificateSha256!!.replace(":", "").uppercase()
            check(expected.matches(Regex("[A-F0-9]{64}")) && actual == expected) {
                "Upload signing certificate does not match the approved SHA-256 fingerprint."
            }
        } catch (error: Exception) {
            throw GradleException("Protected release signing validation failed; check the keystore and approved certificate.")
        }
    }
}

// Packaging must fail closed; debug builds and release lint need no signing secrets.
tasks.configureEach {
    if ((name.endsWith("Release") && listOf("assemble", "bundle", "package")
        .any { name.startsWith(it) }) || (name.startsWith("sign") && name.contains("Release"))) {
        dependsOn(validateReleaseSigning)
    }
}

android {
    namespace = "com.carenet.app"
    compileSdk = flutter.compileSdkVersion
    ndkVersion =  "27.0.12077973"

    compileOptions {
        isCoreLibraryDesugaringEnabled = true
        sourceCompatibility = JavaVersion.VERSION_17
        targetCompatibility = JavaVersion.VERSION_17
    }

    kotlinOptions {
        jvmTarget = JavaVersion.VERSION_17.toString()
    }

    defaultConfig {
        applicationId = "com.carenet.app"
        // You can update the following values to match your application needs.
        // For more information, see: https://flutter.dev/to/review-gradle-config.
        minSdk = flutter.minSdkVersion
        targetSdk = flutter.targetSdkVersion
        versionCode = flutter.versionCode
        versionName = flutter.versionName
    }

    flavorDimensions += "environment"
    productFlavors {
        create("staging") {
            dimension = "environment"
            applicationIdSuffix = ".staging"
            resValue("string", "app_name", "CareNet Staging")
        }
        create("production") {
            dimension = "environment"
            resValue("string", "app_name", "CareNet")
        }
    }

    buildTypes {
        release {
            if (uploadSigningConfigured) {
                signingConfig = signingConfigs.create("protectedUpload") {
                    storeFile = file(uploadStorePath!!)
                    storePassword = uploadStorePassword
                    keyAlias = uploadKeyAlias
                    keyPassword = uploadKeyPassword
                }
            }
        }
    }
}

flutter {
    source = "../.."
}

dependencies {
    coreLibraryDesugaring("com.android.tools:desugar_jdk_libs:2.1.4")
}
