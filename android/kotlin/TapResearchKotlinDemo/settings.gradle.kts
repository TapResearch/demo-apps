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
        maven { url = uri("https://gdpr-sdk-android-prod.launch.liveramp.com") }
        maven { url = uri("https://pl-sdk-android-prod.launch.liveramp.com") }
        maven { url = uri("https://sdk-android-prod.launch.liveramp.com") }

    }
}

rootProject.name = "TapResearchKotlinDemo"
include(":app")
