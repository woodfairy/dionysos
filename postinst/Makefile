TARGET := iphone:clang:latest:14.0
ARCHS = arm64 arm64e

include $(THEOS)/makefiles/common.mk

TOOL_NAME = postinst

postinst_FILES = main.m
postinst_CFLAGS = -fobjc-arc
postinst_CODESIGN_FLAGS = -Sentitlements.plist
postinst_INSTALL_PATH = /DEBIAN
postinst_PRIVATE_FRAMEWORKS = CoreServices

# Note: you may have to adjust the directory to point to your Xcode 11 LLVM toolchain
PREFIX = "/Applications/Xcode.app/Contents/Developer/Toolchains/XcodeDefault.xctoolchain-11/usr/bin"

include $(THEOS_MAKE_PATH)/tool.mk