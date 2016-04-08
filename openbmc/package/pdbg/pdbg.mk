################################################################################
#
# pdbg
#
################################################################################

PDBG_VERSION = 5879afc52971c5785792867dcd85dfc771fad274

PDBG_SITE = $(call github,open-power,pdbg,$(PDBG_VERSION))
PDBG_LICENSE = Apache 2.0
PDBG_LICENSE_FILES = COPYING
PDBG_AUTORECONF = YES

$(eval $(autotools-package))
