import com.android.build.gradle.LibraryExtension

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
    plugins.withId("com.android.library") {
        extensions.configure<LibraryExtension>("android") {
            if (namespace == null) {
                namespace = if (project.name == "isar_flutter_libs") {
                    "dev.isar.isar_flutter_libs"
                } else {
                    "com.neuralreach.zoro.${project.name.replace('-', '_')}"
                }
            }
        }

        if (project.name == "isar_flutter_libs") {
            val manifestFile = project.layout.projectDirectory
                .file("src/main/AndroidManifest.xml")
                .asFile

            tasks.matching {
                it.name.startsWith("process") && it.name.endsWith("Manifest")
            }.configureEach {
                doFirst {
                    if (manifestFile.exists()) {
                        val original = manifestFile.readText()
                        val patched = original.replace(
                            " package=\"dev.isar.isar_flutter_libs\"",
                            "",
                        )
                        if (patched != original) {
                            manifestFile.writeText(patched)
                        }
                    }
                }
            }
        }
    }
}
subprojects {
    project.evaluationDependsOn(":app")
}

tasks.register<Delete>("clean") {
    delete(rootProject.layout.buildDirectory)
}
