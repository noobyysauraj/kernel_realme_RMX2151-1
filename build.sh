#!/bin/bash

function compile() 
{

source ~/.bashrc && source ~/.profile
export LC_ALL=C && export USE_CCACHE=1
ccache -M 100G
export ARCH=arm64
export KBUILD_BUILD_HOST=ThunderStorm
export KBUILD_BUILD_USER="AnupamRoy"
git clone --depth=1 https://github.com/sarthakroy2002/android_prebuilts_clang_host_linux-x86_clang-6443078 clang
git clone --depth=1 https://github.com/LineageOS/android_prebuilts_gcc_linux-x86_aarch64_aarch64-linux-android-4.9 los-4.9-64
git clone --depth=1 https://github.com/LineageOS/android_prebuilts_gcc_linux-x86_arm_arm-linux-androideabi-4.9 los-4.9-32

[ -d "out" ] && rm -rf out || mkdir -p out

make O=out ARCH=arm64 RMX2151_defconfig

PATH="${PWD}/clang/bin:${PATH}:${PWD}/los-4.9-32/bin:${PATH}:${PWD}/los-4.9-64/bin:${PATH}" \
make -j$(nproc --all) O=out \
                      ARCH=arm64 \
                      CC="clang" \
                      CLANG_TRIPLE=aarch64-linux-gnu- \
                      CROSS_COMPILE="${PWD}/los-4.9-64/bin/aarch64-linux-android-" \
                      CROSS_COMPILE_ARM32="${PWD}/los-4.9-32/bin/arm-linux-androideabi-" \
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
