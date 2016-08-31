################################################################################
#
# obmc-console
#
################################################################################

OBMC_CONSOLE_VERSION = 87e344cd6bd848f886e226c8d58ffe4da77ce4bc

OBMC_CONSOLE_SITE = $(call github,openbmc,obmc-console,$(OBMC_CONSOLE_VERSION))
OBMC_CONSOLE_LICENSE = Apache 2.0
OBMC_CONSOLE_LICENSE_FILES = LICENSE
OBMC_CONSOLE_AUTORECONF = YES

$(eval $(autotools-package))
