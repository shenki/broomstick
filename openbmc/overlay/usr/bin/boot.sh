#!/bin/sh

GPIO_BASE=320

POWER=$(($GPIO_BASE+33))
PGOOD=$(($GPIO_BASE+23))
PCIE_RST_N=$(($GPIO_BASE+13))
PEX_PERST_N=$(($GPIO_BASE+14))

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

# Setup LPC registers, etc.
devmem 0x1e789080 32 0x00000500
devmem 0x1e789088 32 0x30000E00
devmem 0x1e78908C 32 0xFE0001FF

devmem 0x1e630000 32 0x00000003
devmem 0x1e630004 32 0x00002404

devmem 0x1e6e2084 32 0x00fff0c0

devmem 0x1E78909C 32 0x00000000

devmem 0x1e6e2080 32 0xCB000000
devmem 0x1e6e2088 32 0x01C000FF
devmem 0x1e6e208c 32 0xC1C000FF
devmem 0x1e6e2090 32 0x003FA009

devmem 0x1E780000 32 0x13008CE7
devmem 0x1E780004 32 0x0370E677
devmem 0x1E780020 32 0xDF48F7FF
devmem 0x1E780024 32 0xC738F202
devmem 0x1e789170 32 0x00000042
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
./pdbg getcfam 0x281c
./pdbg putcfam 0x281c 0x30000000 && ./pdbg putcfam 0x281c 0xb0000000
