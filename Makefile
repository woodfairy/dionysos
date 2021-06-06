TARGET := iphone:clang:latest:14.0
ARCHS = arm64 arm64e

include $(THEOS)/makefiles/common.mk

TWEAK_NAME = Dionysos
Dionysos_CFLAGS = -fobjc-arc

SUBPROJECTS += DionysosYT DionysosSB
SUBPROJECTS += postinst
include $(THEOS_MAKE_PATH)/aggregate.mk

# Note: you may have to adjust the directory to point to your Xcode 11 LLVM toolchain
PREFIX = "/Applications/Xcode.app/Contents/Developer/Toolchains/XcodeDefault.xctoolchain-11/usr/bin"
