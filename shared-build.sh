#!/bin/bash

set -e
sources="$1"
libraries="$2"
external="$3"
{ [ -n "$sources" ] && [ -n "$libraries" ] && [ -n "$external" ]; } || {
	echo 'Invalid usage' >&2
	exit 1
}
[ -n "$ANDROID_NDK_HOME" ] || {
	echo 'ANDROID_NDK_HOME is not defined' >&2
	exit 1
}
[ -x "$ANDROID_NDK_HOME/ndk-build" ] || {
	echo 'ndk-build is missing in ANDROID_NDK_HOME' >&2
	exit 1
}
toolchain="$ANDROID_NDK_HOME/toolchains/llvm/prebuilt/linux-x86_64"

cores="$EXTERNAL_CORES"
[ -z "$cores" ] && cores="$(python -c 'import multiprocessing as m; print(m.cpu_count())' || true)"
[ -z "$cores" ] && cores="$(nproc || true)"
makeflags=
[ -n "$cores" ] && makeflags="-j$((cores + 1))"

sources_ffmpeg="$sources/ffmpeg"
sources_yuv="$sources/yuv"
libraries_ffmpeg="$libraries/ffmpeg"
libraries_yuv="$libraries/yuv"
external_ffmpeg="$external/ffmpeg"
external_yuv="$external/yuv"

prepare_sources() {
	cd "$libraries"
	rm -rf '.src'
	[ -z "$1" ] || {
		cp -rp "$1" '.src'
		cd '.src'
	}
}

ffmpeg_options=(
	'--enable-cross-compile'
	'--target-os=android'
	'--disable-static'
	'--enable-shared'
	'--disable-symver'
	'--disable-debug'
	'--disable-doc'
	'--disable-everything'
	'--disable-programs'
	'--disable-avfilter'
	'--disable-avdevice'
	'--disable-postproc'
	'--enable-avcodec'
	'--enable-avformat'
	'--enable-swresample'
	'--enable-swscale'
	'--enable-demuxer=matroska'
	'--enable-demuxer=mov'
	'--enable-decoder=vp8'
	'--enable-decoder=vp9'
	'--enable-decoder=h264'
	'--enable-decoder=vorbis'
	'--enable-decoder=opus'
	'--enable-decoder=aac'
)

ffmpeg_build() {
	local ndk_arch="$1"
	local arch="$2"
	local build="$3"
	local build_cc="$4"
	local target="$5"
	local android="$6"
	shift 6
	local prefix="$toolchain/bin/$build-linux-$target-"
	local cc="$toolchain/bin/$build_cc-linux-$target$android-clang"
	prepare_sources "$sources_ffmpeg"
	./configure \
		--prefix='.prefix' \
		--arch="$arch" --cross-prefix="$prefix" \
		--sysroot="$toolchain/sysroot" \
		--cc="$cc" --ld="$cc" \
		"$@" "${ffmpeg_options[@]}"
	make $makeflags
	make install
	mkdir -p "$external_ffmpeg/include"
	mv '.prefix/include' "$external_ffmpeg/include/$ndk_arch"
	mkdir -p "$libraries_ffmpeg/$ndk_arch"
	mv '.prefix/lib/'*.so "$libraries_ffmpeg/$ndk_arch"
}

rm -rf "$libraries_ffmpeg" "$external_ffmpeg"
mkdir -p "$libraries_ffmpeg" "$external_ffmpeg"
ffmpeg_build 'armeabi-v7a' 'arm' 'arm' 'armv7a' 'androideabi' 16 --cpu=armv7-a
ffmpeg_build 'arm64-v8a' 'arm64' 'aarch64' 'aarch64' 'android' 21
ffmpeg_build 'x86' 'x86' 'i686' 'i686' 'android' 16 --enable-pic --disable-asm

prepare_sources "$sources_yuv"
"$ANDROID_NDK_HOME/ndk-build" \
	APP_PLATFORM=android-16 \
	APP_BUILD_SCRIPT=Android.mk \
	NDK_PROJECT_PATH=. \
	APP_ABI='armeabi-v7a arm64-v8a x86' \
	LIBYUV_DISABLE_JPEG='"yes"' $makeflags
rm -rf "$libraries_yuv" "$external_yuv"
mkdir -p "$libraries_yuv" "$external_yuv"
cp -R libs/* "$libraries_yuv"
cp -R include "$external_yuv"

make_symbols() {
	pushd "$1"
	for so in */*.so; do
		local name="${so%.so}.c"
		local out="$2/symbols/$name"
		local dir="${out%/*}"
		mkdir -p "$dir"
		build=
		target=
		case "${dir##*/}" in
			armeabi-v7a)
				build=arm
				target=androideabi
				;;
			arm64-v8a)
				build=aarch64
				target=android
				;;
			x86)
				build=i686
				target=android
				;;
		esac
		echo "GEN $name"
		echo "/* generated from ${so##*/} */" > "$out"
		"$toolchain/bin/$build-linux-$target-readelf" -Ws "$so" |
		grep -v ' UND ' | grep -v ' WEAK ' | grep ' \(FUNC\|OBJECT\) ' |
		sed -e 's/@.*//' -e 's/.* \(FUNC\|OBJECT\).* \(.*\)/\1 \2/' \
		-e 's/^FUNC \(.*\)$/void \1() {};/' -e 's/^OBJECT \(.*\)$/int \1;/' |
		sort -u >> "$out"
	done
	popd
}

prepare_sources
make_symbols "$libraries_ffmpeg" "$external_ffmpeg"
make_symbols "$libraries_yuv" "$external_yuv"
