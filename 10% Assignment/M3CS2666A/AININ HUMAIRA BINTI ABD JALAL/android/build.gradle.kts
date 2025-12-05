buildscript {
    repositories {
        google()
        mavenCentral()
    }

    dependencies {
        // Android Gradle plugin
        classpath 'com.android.tools.build:gradle:8.1.1'
        // Kotlin Gradle plugin
        classpath "org.jetbrains.kotlin:kotlin-gradle-plugin:1.9.10"
        // Google Services plugin for Firebase
        classpath 'com.google.gms:google-services:4.4.4'
    }
}

allprojects {
    repositories {
        google()
        mavenCentral()
    }
}

tasks.register<Delete>("clean") {
    delete(rootProject.buildDir)
}
