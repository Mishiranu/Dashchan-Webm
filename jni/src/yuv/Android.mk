LOCAL_PATH := $(call my-dir)

include $(CLEAR_VARS)
LOCAL_MODULE := yuv
LOCAL_SRC_FILES := shared/$(TARGET_ARCH_ABI)/libyuv.so
include $(PREBUILT_SHARED_LIBRARY)