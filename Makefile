TARGET := iphone:clang:latest:14.0
INSTALL_TARGET_PROCESSES = com.google.ios.youtube
ARCHS = arm64 arm64e


include $(THEOS)/makefiles/common.mk

TWEAK_NAME = Dionysos

Dionysos_FILES = Tweak.xm $(wildcard Dionysos/*.xm)
Dionysos_CFLAGS = -fobjc-arc -I./mobileffmpeg/include
Dionysos_FRAMEWORKS = CoreMotion GameController VideoToolbox Accelerate AudioToolbox CoreAudio
Dionysos_LDFLAGS = -L./mobileffmpeg/lib \
			-laom -lass -lavcodec -lavdevice -lavfilter -lavformat \
			-lavutil -lcharset -lexpat -lfontconfig -lfreetype -lfribidi \
			-lgif -lgmp -lgnutls -lhogweed -liconv -lilbc -ljpeg -lkvazaar \
			-lmobileffmpeg -lmp3lame -lnettle -logg -lopencore-amrnb -lopencore-amrwb \
			-lopus -lpng -lshine -lsnappy -lsndfile -lsoxr -lspeex \
			-lswresample -lswscale -ltheora -ltheoradec -ltheoraenc \
			-ltiff -ltwolame -luuid  -lvorbis -lvorbisenc -lvorbisfile \
			-lvpx -lwavpack -lwebp -lwebpdecoder -lwebpdemux -lxml2 \
			-lbz2 -lc++ -liconv -lz

include $(THEOS_MAKE_PATH)/tweak.mk
