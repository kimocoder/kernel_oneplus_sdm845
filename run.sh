#!/bin/bash

# Bash Color
green='\033[01;32m'
red='\033[01;31m'
blink_red='\033[05;31m'
restore='\033[0m'

export ARCH=arm64
export SUBARCH=arm64

################################################################
### Single run script for NetHunter Kernel (based on HolyDragon)
################################################################

# This is a cleanup and single run build script for testing purposes.
# This does not zip anything for you, only executes a normal build. 

# Minimum requirements to build:
# cd /opt/Android
# mkdir toolchains && cd toolchains
# git clone https://gitlab.com/HDTC/gclang.git
# git clone https://bitbucket.org/xanaxdroid/aarch64-8.0.git
#
# In this script:
# You will need to change the 'Source Path to kernel tree' to match your current path to this source.
# You will need to change the 'Compile Path to out' to match your current path to this source.
# You will also need to edit the '-j32' under 'Start Compile' section and adjust that to match the amount of cores you want to use to build.
#
# In Makefile:
# You will need to edit the 'CROSS_COMPILE=' line to match your current path to this source.
#
############################################################
# Build Script Variables
############################################################ 

# Kernel version
        ver=1

# Toolchain location used to build
	CC_DIR=/root/toolchains/gclang/bin

# Source defconfig used to build
	dc=nethunter_defconfig

# Source Path to kernel tree
	k=/root/kernel_oneplus_sdm845

# Compile Path to out
	o="O=/root/kernel_oneplus_sdm845/out"

# Source Path to clean(empty) out folder
	co=$k/out

# Destination path to modules
        zm=$k/build/system/lib/modules

# CPU threads
	th="-j$(grep -c ^processor /proc/cpuinfo)"

############################################################
# Cleanup
############################################################

	echo "	Cleaning up out directory"
	rm -Rf out/
	echo "	Out directory removed!"

############################################################
# Make out folder
############################################################

	echo "	Making new out directory"
	mkdir -p "$co"
	((ver = $ver -1))
	echo $ver > $co\/\.version
	echo "	Created new out directory"

############################################################
# Establish defconfig
############################################################

	echo "	Establishing build environment.."
	cp $k/arch/arm64/configs/nethunter_defconfig $k/.config
	make "$o" CC=${CC_DIR}/clang CLANG_TRIPLE=aarch64-linux-gnu- menuconfig
	cp $k/.config arch/arm64/configs/nethunter_defconfig
	rm -rf .config
	echo "** DEFCONFIG saved!"

############################################################
# Start Compile
############################################################

	echo "	Starting first build.."
	make "$o" CC=${CC_DIR}/clang CLANG_TRIPLE=aarch64-linux-gnu- CONFIG_DEBUG_SECTION_MISMATCH=y $th
	make "$o" CC=${CC_DIR}/clang CLANG_TRIPLE=aarch64-linux-gnu- modules_install
	make "$o" CC=${CC_DIR}/clang CLANG_TRIPLE=aarch64-linux-gnu- firmware_install
	echo "	Build complete!"

# Move files and folders to correct place
	rm -rf $k/build/modules/system/lib/firmware
	rm -rf $k/build/modules/system/lib/modules/*
	cp $k/out/arch/arm64/boot/Image.gz-dtb $k/build/Image.gz-dtb
	cp -a $k/out/firmware $k/build/modules/system/lib/firmware
	cp -a /usr/lib/modules/4.9.212-kimocoder $k/build/modules/system/lib/modules/
	rm -rf $k/build/modules/system/lib/modules/4.9.212-kimocoder/build
	rm -rf $k/build/modules/system/lib/modules/4.9.212-kimocoder/source
	echo "  Files and folders moved to build/ directory"

# Build the zip for TWRP flashing
	cd $k/build
	zip -r OP6_NETHUNTER.zip *
	echo "  OP6_NETHUNTER.zip was made. Reboot into TWRP and ADB sideload the zip file!"
