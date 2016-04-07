#!/bin/bash

set -ex
set -eo pipefail

DEFCONFIGS=`(cd openbmc/configs; ls -1 *_defconfig)`

if [ -z "$1" or ! -d "$1" ]; then
	echo "No output directory specified"
	exit 1;
fi

if [ -z "$CCACHE_DIR" ]; then
	CCACHE_DIR=`pwd`/.obmc-build_ccache
fi

shopt -s expand_aliases
source obmc-env

for i in $DEFCONFIGS; do
        obmc-build $i
        echo 'BR2_CCACHE=y' >> output/.config
        echo "BR2_CCACHE_DIR=\"$CCACHE_DIR\"" >> output/.config
        echo 'BR2_CCACHE_INITIAL_SETUP=""' >> output/.config

        obmc-build olddefconfig
        obmc-build
        r=$?
        mkdir $1/$i-images
        mv output/images/* $1/$i-images/
        rm -rf output/*
        if [ $r -ne 0 ]; then
        	exit $r
        fi
done

