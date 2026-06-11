allprojects {
    repositories {
        // Google Maven mirror (workaround for SSL download issues against dl.google.com).
        maven(url = "https://maven.aliyun.com/repository/google")
        // Maven Central mirror (workaround for SSL "Tag mismatch" errors on repo.maven.apache.org).
        maven(url = "https://maven.aliyun.com/repository/central")
    }
}

val newBuildDir: Directory = rootProject.layout.buildDirectory.dir("../../build").get()
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
