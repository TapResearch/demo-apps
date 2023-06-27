pluginManagement {
    repositories {
        google()
        mavenCentral()
        gradlePluginPortal()
    }
}
dependencyResolutionManagement {
    repositoriesMode.set(RepositoriesMode.FAIL_ON_PROJECT_REPOS)
    repositories {
        google()
        mavenCentral()
        maven("https://artifactory.tools.tapresearch.io/artifactory/tapresearch-android-sdk/")
        flatDir {
            dirs("libs")
        }
    }
}

rootProject.name = "TapResearchKotlinDemo"
include(":app")
