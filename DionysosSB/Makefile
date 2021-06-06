TARGET := iphone:clang:latest:14.0
ARCHS = arm64 arm64e


include $(THEOS)/makefiles/common.mk

TWEAK_NAME = DionysosSB

DionysosSB_FILES = DionysosSB.xm $(wildcard Controller/*xm) \
                                 $(wildcard Converter/*.xm) \
								 $(wildcard Downloader/*.xm) \
								 $(wildcard FakeNotifier/*.xm) \
								 $(wildcard Queue/*.xm)

DionysosSB_LIBRARIES = mryipc
DionysosSB_CFLAGS = -fobjc-arc -I./mobileffmpeg/include
DionysosSB_FRAMEWORKS = Foundation CoreMotion GameController VideoToolbox Accelerate AudioToolbox CoreAudio
DionysosSB_LDFLAGS = -L./mobileffmpeg/lib \
			-laom -lass -lavcodec -lavdevice -lavfilter -lavformat \
			-lavutil -lcharset -lexpat -lfontconfig -lfreetype -lfribidi \
			-lgif -lgmp -lgnutls -lhogweed -liconv -lilbc -ljpeg -lkvazaar \
			-lmobileffmpeg -lmp3lame -lnettle -logg -lopencore-amrnb -lopencore-amrwb \
			-lopus -lpng -lshine -lsnappy -lsndfile -lsoxr -lspeex \
			-lswresample -lswscale -ltheora -ltheoradec -ltheoraenc \
			-ltiff -ltwolame -luuid -lvidstab  -lvorbis -lvorbisenc -lvorbisfile \
			-lvpx -lwavpack -lwebp -lwebpdecoder -lwebpdemux -lx264 -lx265 -lxml2 \
			-lxvidcore -lbz2 -lc++ -liconv -lz

include $(THEOS_MAKE_PATH)/tweak.mk
