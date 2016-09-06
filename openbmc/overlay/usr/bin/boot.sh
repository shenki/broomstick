#!/bin/sh

GPIO_BASE=320

function asciiof {
	printf %d \'$1\'
}

function gpio {
	echo $(( (`asciiof $1` - `asciiof a`) * 8 + $2 + $GPIO_BASE))
}

POWER=$(gpio e 1)
PGOOD=$(gpio c 7)
PCIE_RST_N=$(gpio b 5)
PEX_PERST_N=$(gpio b 6)

BMC_FAN_RESERVED_N=$(gpio a 0)
APSS_WDT_N=$(gpio a 1)
APSS_BOOT_MODE=$(gpio b 1)
APSS_RESET_N=$(gpio b 2)
SPIVID_STBY_RESET_N=$(gpio b 7)
BMC_POWER_UP=$(gpio d 1)
BMC_BATTEY_TEST=$(gpio f 1)
AST_HW_FAULT_N=$(gpio f 4)
AST_SYS_FAULT_N=$(gpio f 5)
BMC_FULL_SPEED_N=$(gpio f 7)
BMC_FAN_ERROR_N=$(gpio g 3)
BMC_WDT_RST1_P=$(gpio g 4)
BMC_WDT_RST2_P=$(gpio g 5)
PE_SLOT_TEST_EN_N=$(gpio h 0)
BMC_RTCRST_N=$(gpio h 1)
SYS_POWEROK_BMC=$(gpio h 2)
SCM1_FSI0_DATA_EN=$(gpio h 6)
BMC_TMP_INT_N=$(gpio h 7)

# Setup GPIO
echo $POWER > /sys/class/gpio/export
echo out > /sys/class/gpio/gpio${POWER}/direction
echo $PGOOD > /sys/class/gpio/export
echo in > /sys/class/gpio/gpio${PGOOD}/direction
echo $PCIE_RST_N > /sys/class/gpio/export
echo out > /sys/class/gpio/gpio${PCIE_RST_N}/direction
echo $PEX_PERST_N > /sys/class/gpio/export
echo out > /sys/class/gpio/gpio${PEX_PERST_N}/direction

# Turn power off (active low)
echo 1 > /sys/class/gpio/gpio${POWER}/value
echo 0 > /sys/class/gpio/gpio${PCIE_RST_N}/value
echo 0 > /sys/class/gpio/gpio${PEX_PERST_N}/value
sleep 10

LPC_SCR0SIO=0x1e789170
LPC_SCR1SIO=0x1e789174
LPC_HCR5=0x1e789080
LPC_HCR7=0x1e789088
LPC_HCR8=0x1e78908C

# LPC HCR5
#  10: Enable LPC FHW cycles
#   8: Enable LPC to AHB bridge
devmem $(LPC_HCR5) 32 0x00000500

# LPC HCR7: LPC to AHB bridge
#  ADRBASE: remapping base address
#  HWMBASE: decoding base address [31:16]
devmem $(LPC_HCR7) 32 0x30000E00

# LPC HICR8: LPC to AHB bridge
#  ADDRMASK: remapping mask
#   HWNCARE: decoding range control bit
devmem $(LPC_HCR8) 32 0xFE0001FF

# Scratch registers
devmem $(LPC_SCR0SIO) 32 0x00000042
devmem $(LPC_SCR1SIO) 32 0x00004000

# Make sure flash is functional
pflash -i

# Power on
echo 0 > /sys/class/gpio/gpio${POWER}/value
echo 1 > /sys/class/gpio/gpio${PCIE_RST_N}/value
echo 1 > /sys/class/gpio/gpio${PEX_PERST_N}/value

# Wait for PGOOD
while [ $(cat /sys/class/gpio/gpio${PGOOD}/value) -eq 0 ]; do true; done
sleep 1

# Kick off boot
pdbg getcfam 0x281c
pdbg putcfam 0x281c 0x30000000 && pdbg putcfam 0x281c 0xb0000000
