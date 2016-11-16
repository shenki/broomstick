include $(sort $(wildcard $(BR2_EXTERNAL_OPENBMC_PATH)/package/*.mk))
include $(sort $(wildcard $(BR2_EXTERNAL_OPENBMC_PATH)/package/*/*.mk))

# Utilize user-defined custom directory.
include $(sort $(wildcard $(BR2_EXTERNAL_OPENBMC_PATH)/custom/*.mk))
BR2_GLOBAL_PATCH_DIR += "$(BR2_EXTERNAL_OPENBMC_PATH)/custom/patches"
