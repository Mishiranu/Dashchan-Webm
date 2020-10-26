# Dashchan Video Player Libraries Extension

This extension actually contains only prebuilt static libraries without any code.

Follow these instructions to build this extension.

## Building Guide

1. Install JDK 7 or higher
2. Install Android SDK, define `ANDROID_HOME` environment variable or set `sdk.dir` in `local.properties`
3. Run `./gradlew assembleRelease`

The resulting APK file will appear in `build/outputs/apk` directory.

Additional files to be used by client will appear in `build/outputs/external` directory.

### Build Signed Binary

You can create `keystore.properties` in the source code directory with the following properties:

```properties
store.file=%PATH_TO_KEYSTORE_FILE%
store.password=%KEYSTORE_PASSWORD%
key.alias=%KEY_ALIAS%
key.password=%KEY_PASSWORD%
```
