#!/bin/bash

### GC/LTO ###
# grub2
sed -i 's/no-lto/no-gc-sections no-lto/g' package/boot/grub2/Makefile

### 软件包 ###
## dae ##
# pkg
cp -rf ../umlka_pkg/dae package/new/dae
patch -p1 < ../patch/dae/kernel-add_MODULE_ALLOW_BTF_MISMATCH-option.patch
#mkdir -p package/new/dae/patches
#cp -f ../patch/dae/001-Revert-disable-gso-on-client-by-default.patch package/new/dae/patches/
cp -f ../immortalwrt_23/target/linux/generic/backport-5.15/051-v5.18-bpf-Add-config-to-allow-loading-modules-with-BTF-mismatch.patch target/linux/generic/backport-5.15/
# geodata
rm -rf feeds/packages/net/v2ray-geodata
cp -rf ../umlka_pkg/v2ray-geodata package/new/v2ray-geodata
cp -f ../patch/script/updategeo.sh package/base-files/files/bin/updategeo
# config
cat ../config/x86/dae >> ../config/x86/config.seed

### 配置 ###
if [ -d ../patch/dl ]; then
	[ ! -d dl ] && cp -rf ../patch/dl dl || cp -rf ../patch/dl/* dl/
fi

if [ -d ../patch/files ]; then
	[ ! -d files ] && cp -rf ../patch/files files || cp -rf ../patch/files/* files/
fi

### 清理 ###
chmod -R 755 .
find . -type f -name '*.rej' -o -name '*.orig' -exec rm -f {} +

exit 0
