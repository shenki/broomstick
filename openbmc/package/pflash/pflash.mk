################################################################################
#
# pflash
#
################################################################################

PFLASH_VERSION = 863ac3c5d2f8a5ea5d471167f3da5cb07aab72fc

PFLASH_SITE = $(call github,open-power,skiboot,$(PFLASH_VERSION))
PFLASH_INSTALL_STAGING = YES
PFLASH_LICENSE = Apache 2.0
PFLASH_LICENSE_FILE = LICENCE

PFLASH_MAKE_OPTS += CROSS_COMPILE="$(TARGET_CROSS)" \
		    PFLASH_VERSION=$(PFLASH_VERSION) \
		    DESTDIR=$(TARGET_DIR)/usr/bin \
		    -C $(@D)/external/pflash

define PFLASH_BUILD_CMDS
	$(TARGET_MAKE_ENV) $(MAKE) $(PFLASH_MAKE_OPTS) all
endef

define PFLASH_INSTALL_TARGET_CMDS
	$(TARGET_MAKE_ENV) $(MAKE) $(PFLASH_MAKE_OPTS) install
endef

$(eval $(generic-package))
