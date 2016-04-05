################################################################################
#
# obmc-console
#
################################################################################

OBMC_CONSOLE_VERSION = 54e9569d14b127806e45e1c17ec4a1f5f7271d3f

OBMC_CONSOLE_SITE = $(call github,openbmc,obmc-console,$(OBMC_CONSOLE_VERSION))
OBMC_CONSOLE_LICENSE = Apache 2.0
OBMC_CONSOLE_LICENSE_FILES = LICENSE
OBMC_CONSOLE_AUTORECONF = YES

$(eval $(autotools-package))
