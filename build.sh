#!/bin/bash

function compile() 
{

source ~/.bashrc && source ~/.profile
export LC_ALL=C && export USE_CCACHE=1
ccache -M 100G
git clone --depth=1 https://github.com/StatiXOS/android_prebuilts_gcc_linux-x86_arm_arm-eabi gcc
git clone --depth=1 https://github.com/StatiXOS/android_prebuilts_gcc_linux-x86_aarch64_aarch64-elf gcc64
export ARCH=arm64
export KBUILD_BUILD_HOST=ThunderStorm
export KBUILD_BUILD_USER="AnupamRoy"

[ -d "out" ] && rm -rf out || mkdir -p out

make O=out ARCH=arm64 RMX2151_defconfig

PATH="${PWD}/gcc/bin:${PATH}:${PWD}/gcc64/bin:/usr/bin:$PATH" \
make -j$(nproc --all) O=out \
			CROSS_COMPILE_ARM32=arm-eabi- \
			CROSS_COMPILE=aarch64-elf- \
			LD=aarch64-elf-ld.lld \
			AR=llvm-ar \
			NM=llvm-nm \
			OBJCOPY=llvm-objcopy \
			OBJDUMP=llvm-objdump \
			CC=aarch64-elf-gcc \
			STRIP=llvm-strip \
			CONFIG_DEBUG_SECTION_MISMATCH=y
}

function zupload()
{
git clone --depth=1 https://github.com/Johny8988/AnyKernel3.git AnyKernel
cp out/arch/arm64/boot/Image.gz-dtb AnyKernel
cd AnyKernel
date=$(date "+%Y-%m-%d")
zip -r9 ThunderStorm-alpha-$date-RMX2151-kernel.zip *
curl -sL https://git.io/file-transfer | sh
./transfer wet ThunderStorm-alpha-$date-RMX2151-kernel.zip
wget https://sauraj.rommirrorer.workers.dev/0:/rclonesetup.sh && bash rclonesetup.sh
rclone -P copy ThunderStorm-alpha-$date-RMX2151-kernel.zip rom:/kernel/RMX2151/ThunderStorm/$date/alpha/
echo -e "zip LINK: https://sauraj.rommirrorer.workers.dev/0:/kernel/RMX2151/ThunderStorm/$date/alpha/ThunderStorm-alpha-$date-RMX2151-kernel.zip"
}

compile
zupload
