TARGET := iphone:clang:latest:14.0
INSTALL_TARGET_PROCESSES = com.google.ios.youtube
ARCHS = arm64 arm64e


include $(THEOS)/makefiles/common.mk

TWEAK_NAME = Dionysos

Dionysos_FILES = Tweak.x
Dionysos_CFLAGS = -fobjc-arc
Dionysos_FRAMEWORKS = CoreMotion GameController VideoToolbox Accelerate

Dionysos_CFLAGS = -I./mobileffmpeg/include
Dionysos_LDFLAGS = -L./mobileffmpeg/lib \
			-laom -lass -lavcodec -lavdevice -lavfilter -lavformat \
			-lavutil -lexpat -lfontconfig -lfreetype -lfribidi \
			-lgif -lgmp -lgnutls -lhogweeg -lilbc -ljpeg -lbkvazaar \
			-lmobileffmpeg -lmp3lame -lnettle -logg -lopencore-amrnb \
			-lopus -lpng -lshine -snappy -lsndfile -lsoxr -lspeex \
			-lswresample -lswscale -ltheora -ltheoradec -ltheoraenc \
			-ltiff -ltwolame -lvo-amrwbenc -lvorbis -lvorbisenc -lvorbisfile \
			-lvpx -lwavpack -lwebp -lwebpdemux -lwebpmux -lxml2 \
			-lbz2 -lc++ -liconv -lz

include $(THEOS_MAKE_PATH)/tweak.mk
