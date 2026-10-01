import java.io.File
import java.net.URI
import java.security.KeyStore
import java.security.MessageDigest
import java.security.cert.X509Certificate
import java.util.Base64

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

fun releaseEnvironmentGate(environment: String, firebaseAppId: String) =
    tasks.register("validate${environment.replaceFirstChar { it.uppercase() }}ReleaseEnvironment") {
        doLast {
            val encoded = providers.gradleProperty("dart-defines").orNull
            check(!encoded.isNullOrBlank()) { "Release runtime configuration is required." }
            val values = mutableMapOf<String, String>()
            try {
                for (entry in encoded.split(',')) {
                    val decoded = String(Base64.getDecoder().decode(entry), Charsets.UTF_8)
                    val separator = decoded.indexOf('=')
                    check(separator > 0) { "Malformed release configuration." }
                    val key = decoded.substring(0, separator)
                    check(!values.containsKey(key)) { "Duplicate release configuration." }
                    values[key] = decoded.substring(separator + 1)
                }
            } catch (error: Exception) {
                throw GradleException("Release runtime configuration encoding is invalid or ambiguous.")
            }
            val required = listOf("CARENET_ENVIRONMENT", "CARENET_API_BASE_URL",
                "CARENET_FIREBASE_PROJECT_ID", "CARENET_FIREBASE_APP_ID",
                "CARENET_FIREBASE_MESSAGING_SENDER_ID", "CARENET_FIREBASE_API_KEY",
                "GOOGLE_SIGN_IN_SERVER_CLIENT_ID")
            for (key in required) {
                val value = values[key]
                check(!value.isNullOrBlank() && value == value.trim()) {
                    "Release configuration requires a nonblank, trimmed $key."
                }
            }
            check(values["CARENET_ENVIRONMENT"] == environment) { "Release environment does not match the Android flavor." }
            check(values["CARENET_FIREBASE_PROJECT_ID"] == "project-a96784ee-811c-46ab-a7b" &&
                values["CARENET_FIREBASE_APP_ID"] == firebaseAppId &&
                values["CARENET_FIREBASE_MESSAGING_SENDER_ID"] == "599365440227") {
                "Release Firebase identity does not match the canonical flavor."
            }
            check(values["CARENET_FIREBASE_API_KEY"]!!.matches(Regex("AIza[A-Za-z0-9_-]{35}")) &&
                values["GOOGLE_SIGN_IN_SERVER_CLIENT_ID"]!!.matches(Regex("[0-9]+-[A-Za-z0-9_-]+\\.apps\\.googleusercontent\\.com"))) {
                "Release provider configuration has an invalid format."
            }
            val api = try { URI(values["CARENET_API_BASE_URL"]!!) } catch (error: Exception) {
                throw GradleException("Release API URL is invalid.")
            }
            check(api.scheme == "https" && !api.host.isNullOrBlank() &&
                api.userInfo == null && api.query == null && api.fragment == null) {
                "Release API URL must be HTTPS without credentials, query, or fragment."
            }
            if (environment == "production") {
                val host = api.host.lowercase()
                check(!host.contains("staging") && host != "localhost" &&
                    host != "127.0.0.1" && host != "0.0.0.0" && host != "::1" &&
                    host != "[::1]" && !host.endsWith(".local")) {
                    "Production cannot use a staging or local API endpoint."
                }
            }
        }
    }

val releaseEnvironmentGates = mapOf(
    "StagingRelease" to releaseEnvironmentGate("staging", "1:599365440227:android:fb589a833cd2e8b251abd6"),
    "ProductionRelease" to releaseEnvironmentGate("production", "1:599365440227:android:7fbb7d5e3784327751abd6"),
)

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
        .any { name.startsWith(it) }) ||
        (name.startsWith("package") && name.endsWith("ReleaseBundle")) ||
        (name.startsWith("sign") && name.contains("Release"))) {
        dependsOn(validateReleaseSigning)
        for ((variant, gate) in releaseEnvironmentGates) {
            if (name.contains(variant)) dependsOn(gate)
        }
    }
    for ((variant, gate) in releaseEnvironmentGates) {
        if (name == "compileFlutterBuild$variant") mustRunAfter(gate)
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
