################################################################################
#
# pdbg
#
################################################################################

PDBG_VERSION = 8af274e57c509807634228c8089ad4001b639925

PDBG_SITE = $(call github,open-power,pdbg,$(PDBG_VERSION))
PDBG_LICENSE = Apache 2.0
PDBG_LICENSE_FILES = COPYING
PDBG_AUTORECONF = YES

$(eval $(autotools-package))
