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

# Building FFmpeg

Download FFmpeg: `git clone git://source.ffmpeg.org/ffmpeg.git`.

Variables:

`OUTPUT` — Output directory  
`ANDROID_NDK_HOME` — Android NDK path

General `configure` script arguments:

```bash
ARGUMENTS="--prefix=$OUTPUT \
    --enable-cross-compile \
    --target-os=android \
    --disable-static \
    --enable-shared \
    --disable-symver \
    --disable-debug \
    --disable-doc \
    --disable-everything \
    --disable-programs \
    --disable-avfilter \
    --disable-postproc \
    --enable-avcodec \
    --enable-avformat \
    --enable-swresample \
    --enable-swscale \
    --enable-demuxer=matroska \
    --enable-decoder=vp8 \
    --enable-decoder=vp9 \
    --enable-decoder=vorbis \
    --enable-decoder=opus"
```

Platform-dependent `configure` script commands:

- arm
  ```bash
  SYSROOT=$ANDROID_NDK_HOME/platforms/android-16/arch-arm
  TOOLCHAIN=$ANDROID_NDK_HOME/toolchains/arm-linux-androideabi-4.9/prebuilt/linux-x86_64

  ./configure \
      --arch=arm \
      --cross-prefix=$TOOLCHAIN/bin/arm-linux-androideabi- \
      --sysroot=$SYSROOT \
      $ARGUMENTS
```
- arm64
  ```bash
  SYSROOT=$ANDROID_NDK_HOME/platforms/android-21/arch-arm64
  TOOLCHAIN=$ANDROID_NDK_HOME/toolchains/aarch64-linux-android-4.9/prebuilt/linux-x86_64

  ./configure \
      --arch=arm64 \
      --cross-prefix=$TOOLCHAIN/bin/aarch64-linux-android- \
      --sysroot=$SYSROOT \
      $ARGUMENTS
  ```
- x86
  ```bash
  SYSROOT=$ANDROID_NDK_HOME/platforms/android-16/arch-x86
  TOOLCHAIN=$ANDROID_NDK_HOME/toolchains/x86-4.9/prebuilt/linux-x86_64

  ./configure \
      --arch=x86 \
      --cross-prefix=$TOOLCHAIN/bin/i686-linux-android- \
      --sysroot=$SYSROOT \
      --extra-cflags="-fpic" \
      $ARGUMENTS
```

After configuring the build run `make install`.

The resulting libraries will be available in `$OUTPUT` directory.

After building run `make clean`.

# Building LibYuv

Download LibYuv: `git clone https://chromium.googlesource.com/libyuv/libyuv`.

In `Android.mk` replace:

- `LOCAL_MODULE := libyuv_static` with `LOCAL_MODULE := yuv`
- `include $(BUILD_STATIC_LIBRARY)` with `include $(BUILD_SHARED_LIBRARY)`.

Run `ndk-build APP_BUILD_SCRIPT=Android.mk NDK_PROJECT_PATH=. APP_ABI="armeabi-v7a arm64-v8a x86"`.

The resulting libraries will be available in `libs` directory.