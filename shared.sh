#!/bin/bash

ffmpeg_version='n3.0.9'
libyuv_version='cb9a58f25fbdf8382d68680f022959022f746ef2'

[ -n "$ANDROID_NDK_HOME" ] || {
	echo "ANDROID_NDK_HOME is not defined" 1>&2
	exit 1
}

output="`pwd`/output"
output_ffmpeg="$output/ffmpeg"
output_yuv="$output/yuv"
temp_ffmpeg="$output/temp/ffmpeg"
temp_yuv="$output/temp/yuv"

rm -rf "$output_ffmpeg"
rm -rf "$output_yuv"
[ -d "$output" ] || mkdir "$output"
[ -d "$output/temp" ] || mkdir "$output/temp"

[ -d "$temp_ffmpeg" ] || {
	git clone 'git://source.ffmpeg.org/ffmpeg.git' "$temp_ffmpeg" || {
		rm -rf "$temp_ffmpeg"
		exit 1
	}
	cd "$temp_ffmpeg"
	git checkout "$ffmpeg_version" || {
		rm -rf "$temp_ffmpeg"
		exit 1
	}
	git checkout "$ffmpeg_version"
}

[ -d "$temp_yuv" ] || {
	git clone 'https://chromium.googlesource.com/libyuv/libyuv' "$temp_yuv" || {
		rm -rf "$temp_yuv"
		exit 1
	}
	cd "$temp_yuv"
	git checkout "$libyuv_version" || {
		rm -rf "$temp_yuv"
		exit 1
	}
}

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
	--enable-demuxer=mov \
	--enable-decoder=vp8 \
	--enable-decoder=vp9 \
	--enable-decoder=h264 \
	--enable-decoder=vorbis \
	--enable-decoder=opus \
	--enable-decoder=aac"

ffmpeg_build() {
	./configure \
		--prefix="$output_ffmpeg/$1" \
		--arch="$2" \
		--cross-prefix="$ANDROID_NDK_HOME/toolchains/$3" \
		--sysroot="$ANDROID_NDK_HOME/platforms/$4" \
		$5 \
		$ffmpeg_options || return 1
	make install
	result=$?
	make clean
	find . -name "*.o" -delete
	[ "$result" -eq 0 ] && {
		mkdir "$output_ffmpeg/include/$1"
		mv "$output_ffmpeg/$1/include/"* "$output_ffmpeg/include/$1"
		mkdir "$output_ffmpeg/shared/$1"
		mv "$output_ffmpeg/$1/lib/"*.so "$output_ffmpeg/shared/$1"
		rm -rf "$output_ffmpeg/$1"
	}
	return $result
}

cd "$temp_ffmpeg"
mkdir "$output_ffmpeg"
mkdir "$output_ffmpeg/include"
mkdir "$output_ffmpeg/shared"

ffmpeg_build \
	'armeabi-v7a' \
	'arm' \
	'arm-linux-androideabi-4.9/prebuilt/linux-x86_64/bin/arm-linux-androideabi-' \
	'android-16/arch-arm' \
	'--cpu=armv7-a' || exit 1

ffmpeg_build \
	'arm64-v8a' \
	'arm64' \
	'aarch64-linux-android-4.9/prebuilt/linux-x86_64/bin/aarch64-linux-android-' \
	'android-21/arch-arm64' \
	'' || exit 1

ffmpeg_build \
	'x86' \
	'x86' \
	'x86-4.9/prebuilt/linux-x86_64/bin/i686-linux-android-' \
	'android-16/arch-x86' \
	'--enable-pic --disable-asm' || exit 1

cd "$temp_yuv"
"$ANDROID_NDK_HOME/ndk-build" \
	APP_BUILD_SCRIPT=Android.mk \
	NDK_PROJECT_PATH=. \
	APP_ABI='armeabi-v7a arm64-v8a x86' \
	LIBYUV_DISABLE_JPEG='"yes"' || exit 1

mkdir "$output_yuv"
mkdir "$output_yuv/shared"
cp -R include "$output_yuv"
cp -R libs/* "$output_yuv/shared"
"$ANDROID_NDK_HOME/ndk-build" \
	APP_BUILD_SCRIPT=Android.mk \
	NDK_PROJECT_PATH=. \
	LIBYUV_DISABLE_JPEG='"yes"' \
	clean

[ "$1" != "--keep-temp" ] && {
	cd "$output"
	rm -rf "$output/temp"
}
