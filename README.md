# Dashchan Video Player Libraries Extension

This extension actually contains only prebuilt static libraries without any code.

Follow these instructions to build this extension.

# Building Guide

1. Install JDK 7 or higher
2. Install Android SDK, define `ANDROID_HOME` environment variable or set `sdk.dir` in `local.properties`
3. Install Android NDK, define `ANDROID_NDK_HOME` environment variable or set `ndk.dir` in `local.properties`
4. Install Gradle
5. Build FFmpeg shared libraries and copy them to `jni/src/ffmpeg/shared`
6. Build LibYuv shared libraries and copy them to `jni/src/yuv/shared`
7. Run `gradle assembleRelease`

The resulting APK file will appear in `build/outputs/apk` directory.

### Build Signed Binary

You can create `keystore.properties` in the source code directory with the following properties:

```properties
store.file=%PATH_TO_KEYSTORE_FILE%
store.password=%KEYSTORE_PASSWORD%
key.alias=%KEY_ALIAS%
key.password=%KEY_PASSWORD%
```

### Build Shared Libraries

1. Install Android NDK, define `ANDROID_NDK_HOME` environment variable
2. Run `./shared.sh`

The resulting shared libraries and `*.h` files will appear in `output` directory.
