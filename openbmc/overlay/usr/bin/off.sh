#!/bin/sh

GPIO_BASE=292

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

for gpio in $POWER $PCIE_RST_N $PEX_PERST_N;
do
	if [ ! -e /sys/class/gpio/gpio${gpio} ]
	then
		echo $gpio > /sys/class/gpio/export;
	fi
done


# Turn power off (active low)
echo "Turn power off..."
echo 1 > /sys/class/gpio/gpio${POWER}/value
echo 0 > /sys/class/gpio/gpio${PCIE_RST_N}/value
echo 0 > /sys/class/gpio/gpio${PEX_PERST_N}/value
