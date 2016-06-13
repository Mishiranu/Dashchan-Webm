# Dashchan Video Player Libraries Extension

### Building FFmpeg

Download FFmpeg: `git clone git://source.ffmpeg.org/ffmpeg.git ffmpeg`

Variables:

`PREFIX` — Output directory  
`ANDROID_NDK_HOME` — Android NDK path

General `.configure` script arguments:

```
ARGUMENTS='--disable-static \
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
    --enable-decoder=opus'
```

#### Building FFmpeg for arm

```
SYSROOT=$ANDROID_NDK_HOME/platforms/android-16/arch-arm
TOOLCHAIN=$ANDROID_NDK_HOME/toolchains/arm-linux-androideabi-4.9/prebuilt/linux-x86_64

./configure \
	--prefix=$PREFIX \
	--enable-cross-compile \
	--target-os=android \
	--arch=arm \
	--cross-prefix=$TOOLCHAIN/bin/arm-linux-androideabi- \
	--sysroot=$SYSROOT \
	$ARGUMENTS
```

#### Building FFmpeg for arm64

```
SYSROOT=$ANDROID_NDK_HOME/platforms/android-21/arch-arm64
TOOLCHAIN=$ANDROID_NDK_HOME/toolchains/aarch64-linux-androideabi-4.9/prebuilt/linux-x86_64

./configure \
	--prefix=$PREFIX \
	--enable-cross-compile \
	--target-os=android \
	--arch=arm \
	--cross-prefix=$TOOLCHAIN/bin/aarch64-linux-android- \
	--sysroot=$SYSROOT \
	$ARGUMENTS
```

#### Building FFmpeg for x86

```
SYSROOT=$ANDROID_NDK_HOME/platforms/android-16/arch-x86
TOOLCHAIN=$ANDROID_NDK_HOME/toolchains/x86-4.9/prebuilt/linux-x86_64

./configure \
	--prefix=$PREFIX \
	--enable-cross-compile \
	--target-os=android \
	--arch=x86 \
	--cross-prefix=$TOOLCHAIN/bin/i686-linux-android- \
	--sysroot=$SYSROOT \
	--extra-cflags="-fpic" \
	$ARGUMENTS
```