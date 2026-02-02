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

// Ensure library modules provided by plugins have a namespace for newer AGP
// Ensure library modules provided by plugins have a namespace for newer AGP
subprojects {
    // Use plugins.withId to configure library modules safely during configuration
    plugins.withId("com.android.library") {
        try {
            val libExt = extensions.findByName("android") as? com.android.build.gradle.LibraryExtension
            libExt?.namespace = "com.kakasey.superreminder"
        } catch (e: Exception) {
            // ignore
        }
    }
}

tasks.register<Delete>("clean") {
    delete(rootProject.layout.buildDirectory)
}
