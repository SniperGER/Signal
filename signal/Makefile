include $(THEOS)/makefiles/common.mk

BUNDLE_NAME = signal
signal_FILES = SGNRootListController.m
signal_INSTALL_PATH = /Library/PreferenceBundles
signal_FRAMEWORKS = UIKit
signal_PRIVATE_FRAMEWORKS = Preferences

include $(THEOS_MAKE_PATH)/bundle.mk

internal-stage::
	$(ECHO_NOTHING)mkdir -p $(THEOS_STAGING_DIR)/Library/PreferenceLoader/Preferences$(ECHO_END)
	$(ECHO_NOTHING)cp entry.plist $(THEOS_STAGING_DIR)/Library/PreferenceLoader/Preferences/signal.plist$(ECHO_END)
