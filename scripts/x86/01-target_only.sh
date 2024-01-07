#!/bin/bash

### GC/LTO ###
# grub2
patch -p1 < ../patch/lto/grub2-opt-out-of-gc-sections-usage.patch
# openssl
patch -p1 < ../patch/lto/openssl-enable-lto-optimized-build.patch

### Boot partition ###
patch -p1 < ../patch/x86-increase-bios-boot-partition-to-1-MiB.patch

### 内核版本 ###
#sed -i 's/^\(KERNEL_PATCHVER:=\)[0-9]\+\.[0-9]\+$/\15.15/' target/linux/x86/Makefile

### 平台补丁 ###
# x86_csum
cp -f ../patch/net/x86_csum/* target/linux/generic/backport-5.15/
# cloudflare
cp -f ../patch/cloudflare/999-0001-audit-check-syscall-bitmap-on-entry-to-avoid-extra-w.patch target/linux/x86/patches-5.15/

### 翻译优化 ###
cp -rf ../patch/duplicate/addition-trans-zh-x86 package/new/addition-trans-zh
cp -rf ../immortalwrt_23/package/emortal/default-settings/i18n package/new/addition-trans-zh/

### Disable mitigations ###
sed -i 's/noinitrd/noinitrd mitigations=off/g' target/linux/x86/image/grub-efi.cfg
sed -i 's/noinitrd/noinitrd mitigations=off/g' target/linux/x86/image/grub-iso.cfg
sed -i 's/noinitrd/noinitrd mitigations=off/g' target/linux/x86/image/grub-pc.cfg

### Match vermagic ###
latest_tag="$(git describe --tags --abbrev=0 | sed 's/^v//i')"
wget -qO - https://downloads.openwrt.org/releases/${latest_tag}/targets/x86/64/packages/Packages | awk -F '[- =)]+' '/^Depends: kernel/{for(i=3;i<=NF;i++){if(length($i)==32){print $i;exit}}}' | tee .vermagic
sed -ie 's/^\(.\).*vermagic$/\1cp $(TOPDIR)\/.vermagic $(LINUX_DIR)\/.vermagic/' include/kernel-defaults.mk

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
# update source
if [ "$1" == "true" ]; then
	pushd package/new/dae >/dev/null
	git init >/dev/null 2>&1
	git remote add -f origin https://github.com/daeuniverse/dae >/dev/null 2>&1
	latest_commit="$(git log -1 --format='%H' remotes/origin/main)"
	if [ -n "${latest_commit}" ]; then
		latest_tag="$(git describe --tags --abbrev=0 "${latest_commit}" | sed 's/^v//i')"
		if [ -n "${latest_tag}" ]; then
			pkg_version="${latest_tag}-${latest_commit:0:7}"
		else
			pkg_version="$(git log -1 --format='%ad' --date=short ${latest_commit})-${latest_commit:0:7}"
		fi
		sed -i "s/^\(PKG_VERSION:=\).*/\1${pkg_version}/" Makefile
		sed -i "s/^\(PKG_SOURCE_VERSION:=\).*/\1${latest_commit}/" Makefile
		sed -i 's/^\(PKG_MIRROR_HASH:=\).*/\1skip/' Makefile
		echo -e "\e[31mdae\e[0m \e[33mhas been updated to the latest commit.\e[0m(\e[92mhttps://github.com/daeuniverse/dae/commit/${latest_commit}\e[0m)"
	fi
	rm -rf .git
	popd >/dev/null
fi
# config
echo '
CONFIG_DEVEL=y
CONFIG_KERNEL_DEBUG_INFO=y
CONFIG_KERNEL_DEBUG_INFO_BTF=y
CONFIG_KERNEL_MODULE_ALLOW_BTF_MISMATCH=y
# CONFIG_KERNEL_DEBUG_INFO_REDUCED is not set
CONFIG_KERNEL_BPF_EVENTS=y
CONFIG_KERNEL_CGROUPS=y
CONFIG_KERNEL_CGROUP_BPF=y
CONFIG_KERNEL_XDP_SOCKETS=y
CONFIG_BPF_TOOLCHAIN_HOST=y
CONFIG_PACKAGE_dae=y
CONFIG_PACKAGE_dae-geoip=y
CONFIG_PACKAGE_dae-geosite=y
' >> ../seed/x86/config.seed
sed -i '/CONFIG_BPF_STREAM_PARSER/d' target/linux/x86/64/config-5.15
echo '
CONFIG_BPF_STREAM_PARSER=y
' >> target/linux/x86/64/config-5.15
#sed -i 's/# CONFIG_BPF_STREAM_PARSER is not set/CONFIG_BPF_STREAM_PARSER=y/g' target/linux/generic/config-5.15

### 配置 ###
[ -d ../patch/dl ] && cp -rf ../patch/dl dl
[ -d ../patch/files ] && cp -rf ../patch/files files

### 清理 ###
chmod -R 755 .
find . -type f -name '*.rej' -o -name '*.orig' -exec rm -f {} +

exit 0
