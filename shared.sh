#!/bin/bash

output=`pwd`/output
output_ffmpeg=$output/ffmpeg
output_libyuv=$output/yuv
temp_ffmpeg=$output/temp/ffmpeg
temp_libyuv=$output/temp/yuv

rm -R $output_ffmpeg 2> /dev/null
rm -R $output_libyuv 2> /dev/null
mkdir $output 2> /dev/null
mkdir $output/temp 2> /dev/null

if [ ! -d $temp_ffmpeg ]; then
	git clone -b n3.1.1 git://source.ffmpeg.org/ffmpeg.git $temp_ffmpeg \
		|| { rm -R $temp_ffmpeg 2> /dev/null; exit 1; }
fi

if [ ! -d $temp_libyuv ]; then
	git clone https://chromium.googlesource.com/libyuv/libyuv $temp_libyuv \
		|| { rm -R $temp_libyuv 2> /dev/null; exit 1; }
	cd $temp_libyuv
	result=0
	sed -i -- 's/LOCAL_MODULE := libyuv_static/LOCAL_MODULE := yuv/g' Android.mk
	result= [ $result -o $? ]
	sed -i -- 's/include $(BUILD_STATIC_LIBRARY)/include $(BUILD_SHARED_LIBRARY)/g' Android.mk
	result= [ $result -o $? ]
	if [ ! $result -eq 0 ]; then cd ..; rm -R $temp_libyuv; exit 1; fi
fi

ffmpeg_options="--enable-cross-compile \
	--target-os=android \
	--disable-static \
	--enable-shared \
	--disable-symver \
	--disable-debug \
	--disable-doc \
	--disable-everything \
	--disable-programs \
	--disable-avfilter \
	--disable-avdevice \
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

ffmpeg_build()
{
	./configure --prefix=$output_ffmpeg/$1 --arch=$2 --cross-prefix=$ANDROID_NDK_HOME/toolchains/$3 \
		--sysroot=$ANDROID_NDK_HOME/platforms/$4 $5 $ffmpeg_options || return 1
	make install
	result=$?
	make clean
	find . -name "*.o" -delete
	if [ $result -eq 0 ]; then
		mkdir $output_ffmpeg/include/$1
		mv $output_ffmpeg/$1/include/* $output_ffmpeg/include/$1
		mkdir $output_ffmpeg/shared/$1
		mv $output_ffmpeg/$1/lib/*.so $output_ffmpeg/shared/$1
		rm -R $output_ffmpeg/$1
	fi
	return $result
}

cd $temp_ffmpeg
mkdir $output_ffmpeg
mkdir $output_ffmpeg/include
mkdir $output_ffmpeg/shared
ffmpeg_build armeabi-v7a arm arm-linux-androideabi-4.9/prebuilt/linux-x86_64/bin/arm-linux-androideabi- \
	android-16/arch-arm "--cpu=armv7-a" || exit 1
ffmpeg_build arm64-v8a arm64 aarch64-linux-android-4.9/prebuilt/linux-x86_64/bin/aarch64-linux-android- \
	android-21/arch-arm64 || exit 1
ffmpeg_build x86 x86 x86-4.9/prebuilt/linux-x86_64/bin/i686-linux-android- \
	android-16/arch-x86 "--enable-pic --disable-asm" || exit 1

cd $temp_libyuv
$ANDROID_NDK_HOME/ndk-build APP_BUILD_SCRIPT=Android.mk NDK_PROJECT_PATH=. \
	APP_ABI="armeabi-v7a arm64-v8a x86" || exit 1
mkdir $output_libyuv
mkdir $output_libyuv/shared
cp -R include $output_libyuv
cp -R libs/* $output_libyuv/shared
$ANDROID_NDK_HOME/ndk-build APP_BUILD_SCRIPT=Android.mk NDK_PROJECT_PATH=. clean

if [ "$1" != "--keep-temp" ]; then cd $output; rm -R $output/temp 2> /dev/null; fi