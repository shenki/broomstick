# OpenBMC Broomstick

Broomstick is a proof of concept BMC distribution that is focused on
simplicity, security and usefulness for developers and sysadmins.

This repository is a buildroot overlay that contains the platform specific
projects that are required to build the BMC image.

## Building

```
. obmc-env
obmc-build palmetto_defconfig
obmc-build
```
