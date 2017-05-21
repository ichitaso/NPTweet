DEBUG = 0
GO_EASY_ON_ME := 1
PACKAGE_VERSION = $(THEOS_PACKAGE_BASE_VERSION)
ARCHS = armv7 arm64

THEOS_DEVICE_IP = localhost -p 2222

BUNDLE_NAME = NPTweet
NPTweet_FILES = Switch.x
NPTweet_FRAMEWORKS = UIKit Social
NPTweet_LIBRARIES = flipswitch substrate
NPTweet_PRIVATE_FRAMEWORKS = SpringBoardServices MediaRemote
NPTweet_INSTALL_PATH = /Library/Switches
NPTweet_ADDITIONAL_CFLAGS = -fobjc-arc

SUBPROJECTS += NPTweetSettings

include $(THEOS)/makefiles/common.mk
include $(THEOS_MAKE_PATH)/bundle.mk
include $(THEOS_MAKE_PATH)/aggregate.mk

before-package::
	sudo chown -R root:wheel $(THEOS_STAGING_DIR)
	sudo chmod -R 755 $(THEOS_STAGING_DIR)
	sudo chmod 666 $(THEOS_STAGING_DIR)/Library/Switches/NPTweet.bundle/*.pdf

after-install::
	install.exec "killall -9 SpringBoard"
	make clean
	sudo mv .theos/_ $(THEOS_PACKAGE_NAME)_$(THEOS_PACKAGE_BASE_VERSION)_iphoneos-arm
	sudo rm -rf .theos/_
	zip -r .theos/$(THEOS_PACKAGE_NAME)_$(THEOS_PACKAGE_BASE_VERSION)_iphoneos-arm.zip $(THEOS_PACKAGE_NAME)_$(THEOS_PACKAGE_BASE_VERSION)_iphoneos-arm
	mv .theos/$(THEOS_PACKAGE_NAME)_$(THEOS_PACKAGE_BASE_VERSION)_iphoneos-arm.zip ./
	sudo rm -rf $(THEOS_PACKAGE_NAME)_$(THEOS_PACKAGE_BASE_VERSION)_iphoneos-arm
	rm -rf .obj
	rm -rf obj
	rm -rf .theos
	rm -rf *.deb