TARGET := iphone:clang:latest:14.0
INSTALL_TARGET_PROCESSES = YouTube
ARCHS = arm64 arm64e


include $(THEOS)/makefiles/common.mk

TWEAK_NAME = DionysosYT

DionysosYT_FILES = DionysosYT.xm 
DionysosYT_LIBRARIES = mryipc
DionysosYT_CFLAGS = -fobjc-arc
DionysosYT_FRAMEWORKS = Foundation

include $(THEOS_MAKE_PATH)/tweak.mk
