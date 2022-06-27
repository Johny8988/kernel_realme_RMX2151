#!/bin/bash

function compile() 
{

source ~/.bashrc && source ~/.profile
export LC_ALL=C && export USE_CCACHE=1
ccache -M 100G
export ARCH=arm64
export KBUILD_BUILD_HOST=ThunderStorm
export KBUILD_BUILD_USER="AnupamRoy"
git clone --depth=1 https://github.com/Kdrag0n/proton-clang.git clang

[ -d "out" ] && rm -rf out || mkdir -p out

make O=out ARCH=arm64 RMX2151_defconfig

PATH="${PWD}/clang/bin:${PATH}:${PWD}/clang/bin:${PATH}:${PWD}/clang/bin:${PATH}" \
make -j$(nproc --all) O=out \
                      ARCH=arm64 \
                      CC="clang" \
                      LD=ld.lld \
                      CLANG_TRIPLE=aarch64-linux-gnu- \
		      CROSS_COMPILE="${PWD}/clang/bin/aarch64-linux-gnu-" \
                      CROSS_COMPILE_ARM32="${PWD}/clang/bin/arm-linux-gnueabi-" \
                      CONFIG_NO_ERROR_ON_MISMATCH=y
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
