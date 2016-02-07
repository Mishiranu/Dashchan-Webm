# Dashchan Video Player Libraries Extension

### Building FFMPEG

Download FFMPEG: `git clone git://source.ffmpeg.org/ffmpeg.git ffmpeg`

Variables:

`PREFIX` — Output directory  
`NDK` — Android NDK path

#### Building FFMPEG for arm

```
SYSROOT=$NDK/platforms/android-14/arch-arm
TOOLCHAIN=$NDK/toolchains/arm-linux-androideabi-4.9/prebuilt/linux-x86_64

./configure \
	--prefix=$PREFIX \
	--enable-cross-compile \
	--target-os=android \
	--arch=arm \
	--cross-prefix=$TOOLCHAIN/bin/arm-linux-androideabi- \
	--sysroot=$SYSROOT \
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
	--enable-decoder=opus
```

#### Building FFMPEG for x86

```
SYSROOT=$NDK/platforms/android-14/arch-x86
TOOLCHAIN=$NDK/toolchains/x86-4.9/prebuilt/linux-x86_64

./configure \
	--prefix=$PREFIX \
	--enable-cross-compile \
	--target-os=android \
	--arch=x86 \
	--cross-prefix=$TOOLCHAIN/bin/i686-linux-android- \
	--sysroot=$SYSROOT \
	--extra-cflags="-fpic" \
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
	--enable-decoder=opus
```