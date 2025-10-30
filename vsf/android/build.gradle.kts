buildscript {
    ext.kotlin_version = '1.9.0' // Perbarui ke 1.9.0
    repositories {
        google()
        mavenCentral()
    }
    dependencies {
        // Perbarui ke versi 8.1.4 atau yang terbaru (saat ini)
        classpath 'com.android.tools.build:gradle:8.1.4' 
        classpath "org.jetbrains.kotlin:kotlin-gradle-plugin:$kotlin_version"
    }
}

allprojects {
    repositories {
        google()
        mavenCentral()
    }
}

val newBuildDir: Directory =
    rootProject.layout.buildDirectory
        .dir("../../build")
        .get()
rootProject.layout.buildDirectory.value(newBuildDir)

subprojects {
    val newSubprojectBuildDir: Directory = newBuildDir.dir(project.name)
    project.layout.buildDirectory.value(newSubprojectBuildDir)
}
subprojects {
    project.evaluationDependsOn(":app")
}

tasks.register<Delete>("clean") {
    delete(rootProject.layout.buildDirectory)
}
