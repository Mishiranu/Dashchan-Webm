#!/bin/bash

set -e
sources="$1"
[ -n "$sources" ] || {
	echo 'Invalid usage' >&2
	exit 1
}
[ -n "$DAV1D_VERSION" ] || {
	echo 'DAV1D_VERSION is not defined' >&2
	exit 1
}
[ -n "$FFMPEG_VERSION" ] || {
	echo 'FFMPEG_VERSION is not defined' >&2
	exit 1
}
[ -n "$YUV_VERSION" ] || {
	echo 'YUV_VERSION is not defined' >&2
	exit 1
}
sources_dav1d="$sources/dav1d"
sources_ffmpeg="$sources/ffmpeg"
sources_yuv="$sources/yuv"
rm -rf "$sources_dav1d"
mkdir -p "$sources_dav1d"
curl -L "https://downloads.videolan.org/videolan/dav1d/$DAV1D_VERSION/dav1d-$DAV1D_VERSION.tar.xz" |
	tar -C "$sources_dav1d" -xJ --strip-components=1 || {
	rm -rf "$sources_dav1d"
	exit 1
}
rm -rf "$sources_ffmpeg"
mkdir -p "$sources_ffmpeg"
curl -L "https://ffmpeg.org/releases/ffmpeg-$FFMPEG_VERSION.tar.bz2" |
	tar -C "$sources_ffmpeg" -xj --strip-components=1 || {
	rm -rf "$sources_ffmpeg"
	exit 1
}
rm -rf "$sources_yuv"
mkdir -p "$sources_yuv"
curl -L "https://chromium.googlesource.com/libyuv/libyuv/+archive/$YUV_VERSION.tar.gz" |
	tar -C "$sources_yuv" -xz || {
	rm -rf "$sources_yuv"
	exit 1
}
