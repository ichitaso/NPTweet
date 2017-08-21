ARCHS = armv7 arm64
GO_EASY_ON_ME = 1

BUNDLE_NAME = NPTweetSettings
NPTweetSettings_FILES = NPTweetSettings.mm
NPTweetSettings_INSTALL_PATH = /Library/PreferenceBundles
NPTweetSettings_FRAMEWORKS = UIKit SafariServices
NPTweetSettings_PRIVATE_FRAMEWORKS = Preferences

include $(THEOS)/makefiles/common.mk
include $(THEOS_MAKE_PATH)/bundle.mk

internal-stage::
	$(ECHO_NOTHING)mkdir -p $(THEOS_STAGING_DIR)/Library/PreferenceLoader/Preferences$(ECHO_END)
	$(ECHO_NOTHING)cp entry.plist $(THEOS_STAGING_DIR)/Library/PreferenceLoader/Preferences/NPTweetSettings.plist$(ECHO_END)
