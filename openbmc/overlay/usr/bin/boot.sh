#!/bin/sh

GPIO_BASE=320

function asciiof {
	printf %d \'$1\'
}

function gpio {
	echo $(( (`asciiof $1` - `asciiof a`) * 8 + $2 + $GPIO_BASE))
}

# GPIOE1
POWER=$(gpio e 1)
PGOOD=$(gpio c 7)
PCIE_RST_N=$(gpio b 5)
PEX_PERST_N=$(gpio b 6)

# Setup GPIO if required
if [ ! -e /sys/class/gpio/gpio${POWER} ]; then
	echo $POWER > /sys/class/gpio/export
	echo out > /sys/class/gpio/gpio${POWER}/direction
	echo $PGOOD > /sys/class/gpio/export
	echo in > /sys/class/gpio/gpio${PGOOD}/direction
	echo $PCIE_RST_N > /sys/class/gpio/export
	echo out > /sys/class/gpio/gpio${PCIE_RST_N}/direction
	echo $PEX_PERST_N > /sys/class/gpio/export
	echo out > /sys/class/gpio/gpio${PEX_PERST_N}/direction
fi

# Turn power off (active low)
echo 1 > /sys/class/gpio/gpio${POWER}/value
echo 0 > /sys/class/gpio/gpio${PCIE_RST_N}/value
echo 0 > /sys/class/gpio/gpio${PEX_PERST_N}/value
sleep 10

# LPC HCR5
#  10: Enable LPC FHW cycles
#   8: Enable LPC to AHB bridge
devmem 0x1e789080 32 0x00000500

# LPC HCR7: LPC to AHB bridge
#  ADRBASE: remapping base address
#  HWMBASE: decoding base address [31:16]
devmem 0x1e789088 32 0x30000E00

# LPC HICR8: LPC to AHB bridge
#  ADDRMASK: remapping mask
#   HWNCARE: adecoding range control bit
devmem 0x1e78908C 32 0xFE0001FF

# LPC SCR0SIO
devmem 0x1e789170 32 0x00000042

# LPC SCR1SIO
devmem 0x1e789174 32 0x00004000

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
