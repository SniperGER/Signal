export PACKAGE_VERSION=1.3
export THEOS_DEVICE_IP=169.254.216.133

include $(THEOS)/makefiles/common.mk

TWEAK_NAME = Signal
Signal_CFLAGS = -fobjc-arc -I./headers -I ./
Signal_FILES = Tweak.xm SignalManager.m

include $(THEOS)/makefiles/tweak.mk

after-install::
	install.exec "killall -9 SpringBoard"

ifeq ($(THEOS_TARGET_NAME),iphone_simulator)
after-all::
	@echo Copying .dylib to /opt/simject
	@cp $(THEOS_OBJ_DIR)/$(PROJECT_NAME).dylib /opt/simject
	@cp $(PROJECT_NAME).plist /opt/simject
	@ldid -S /opt/simject/$(PROJECT_NAME).dylib
#@~/Documents/Xcode/simject/bin/respring_simulator
endif

SUBPROJECTS += signal
include $(THEOS_MAKE_PATH)/aggregate.mk
