LOCAL_PATH := $(call my-dir)

LOCAL_PATH_SRC := $(LOCAL_PATH)
include $(LOCAL_PATH_SRC)/ffmpeg/Android.mk
include $(LOCAL_PATH_SRC)/yuv/Android.mk
