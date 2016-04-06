################################################################################
#
# memboot
#
################################################################################

MEMBOOT_VERSION = a56b9aa8e654aa559538694dac539135b942f8e0

MEMBOOT_SITE = $(call github,open-power,skiboot,$(MEMBOOT_VERSION))
MEMBOOT_INSTALL_STAGING = YES
MEMBOOT_LICENSE = Apache 2.0
MEMBOOT_LICENSE_FILE = LICENCE

MEMBOOT_MAKE_OPTS += CC="$(TARGET_CC)" \
		     -C $(@D)/external/memboot

define MEMBOOT_BUILD_CMDS
       $(TARGET_MAKE_ENV) $(MAKE) $(MEMBOOT_MAKE_OPTS) all
endef

define MEMBOOT_INSTALL_TARGET_CMDS
       $(TARGET_MAKE_ENV) install -m 0755 $(@D)/external/memboot/memboot $(TARGET_DIR)/bin
endef

$(eval $(generic-package))
