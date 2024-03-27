#!/bin/bash

# x86 kernel 6.6 patch
wget -qO - https://github.com/openwrt/openwrt/commit/77853e86f2728cc039032a2ad7661b05ff74bcbe.patch | patch -p1
wget -qO - https://github.com/openwrt/openwrt/commit/526a0d4b8dc6bf45b7eca23171265ac1ba9ea425.patch | patch -p1
wget -qO - https://github.com/openwrt/openwrt/commit/a9af4b0999fcb7de36f9f4bb7ca159a56598bdbe.patch | patch -p1
wget -qO - https://github.com/openwrt/openwrt/commit/f4dd2aa2d3667c8cec2f29d2f758808b18ab51c8.patch | patch -p1
wget -qO - https://github.com/openwrt/openwrt/commit/d21f8a1bbcf2de6712798697dd3521e3036bebb0.patch | patch -p1
wget -qO - https://github.com/openwrt/openwrt/commit/ae16860518d25b99000d9a87b144d19b4ec7f4e6.patch | patch -p1
wget -qO - https://github.com/openwrt/openwrt/commit/df827ce99fd7998433e3df8e613920c1280656f1.patch | patch -p1
wget -qO - https://github.com/openwrt/openwrt/commit/3d1e7c14c8b3c55aea20652e876aac496dcd1ed8.patch | patch -p1
wget -qO - https://github.com/openwrt/openwrt/commit/b92fc54596484eda87042082219c5cbcb766251a.patch | patch -p1
wget -qO - https://github.com/openwrt/openwrt/commit/82edadae5ce603bcedc48a5f8f20574e5f85bbde.patch | patch -p1
wget -qO - https://github.com/openwrt/openwrt/commit/4a7a719df00f6f19e3d1820d089e1c6b15e510f5.patch | patch -p1
wget -qO - https://github.com/openwrt/openwrt/commit/a55f7581eba21f87390fc69e662fc894fc2ce994.patch | patch -p1

### 基础部分 ###
mkdir -p package/new

### 通用补丁 ###
# lrng
cp -f ../patch/lrng/* target/linux/generic/hack-6.6/
cat ../config/x86/lrng >> target/linux/generic/config-6.6
# wireguard
cp -f ../patch/wireguard/950-wireguard-support-hotplug.patch target/linux/generic/hack-6.6/
# odhcpd
mkdir -p package/network/services/odhcpd/patches
#cp -f ../patch/odhcpd/001-odhcpd-RFC-9096-compliance.patch package/network/services/odhcpd/patches/
cp -f ../immortalwrt_ma/package/network/services/odhcpd/patches/001-odhcpd-RFC-9096-compliance.patch package/network/services/odhcpd/patches/
patch -p1 -d feeds/luci < ../patch/odhcpd/luci/Revert-luci-network-interfaces-Add-IPv6-lifetime-options.patch
patch -p1 -d feeds/luci < ../patch/odhcpd/luci/luci-mod-network-add-option-for-ipv6-max-plt-vlt.patch
# odhcp6c
patch -p1 < ../patch/odhcp6c/1002-odhcp6c-support-dhcpv6-hotplug.patch
# multiple registrant兼容性补丁 (nlbwmon, flow offloading)
cp -f ../lean_lede/target/linux/generic/hack-6.6/952-add-net-conntrack-events-support-multiple-registrant.patch target/linux/generic/hack-6.6/
# threaded network backlog processing
rm -f target/linux/generic/pending-6.6/760-net-core-add-optional-threading-for-backlog-processi.patch

### firewall4/fullcone ###
# firewall4
mkdir -p package/network/config/firewall4/patches
cp -f ../patch/firewall/001-firewall4-add-support-for-fullcone-nat.patch package/network/config/firewall4/patches/
cp -f ../patch/firewall/002-fix-adding-offloading-device.patch package/network/config/firewall4/patches/
cp -f ../patch/firewall/990-unconditionally-allow-ct-status-dnat.patch package/network/config/firewall4/patches/
#cp -f ../immortalwrt_ma/package/network/config/firewall4/patches/002-fix-adding-offloading-device.patch package/network/config/firewall4/patches/
# libnftnl
mkdir -p package/libs/libnftnl/patches
sed -i '/^PKG_INSTALL:=/i\PKG_FIXUP:=autoreconf' package/libs/libnftnl/Makefile
#cp -f ../patch/firewall/libnftnl/001-libnftnl-add-fullcone-expression-support.patch package/libs/libnftnl/patches/
cp -f ../immortalwrt_ma/package/libs/libnftnl/patches/001-libnftnl-add-fullcone-expression-support.patch package/libs/libnftnl/patches/
# nftables
mkdir -p package/network/utils/nftables/patches
#cp -f ../patch/firewall/nftables/002-nftables-add-fullcone-expression-support.patch package/network/utils/nftables/patches/
cp -f ../immortalwrt_ma/package/network/utils/nftables/patches/002-nftables-add-fullcone-expression-support.patch package/network/utils/nftables/patches/
# package
#git clone -b master --depth 1 https://github.com/fullcone-nat-nftables/nft-fullcone.git package/new/nft-fullcone
cp -rf ../immortalwrt_ma/package/network/utils/fullconenat-nft package/new/fullconenat-nft
# luci
patch -p1 -d feeds/luci < ../patch/firewall/luci/luci-app-firewall-add-fullcone.patch

### 基础包 ###
# autocore
cp -rf ../immortalwrt_ma/package/emortal/autocore package/new/autocore
# default-settings-chn
cp -rf ../patch/duplicate/default-settings-chn package/new/default-settings-chn
# NIC drivers
cp -rf ../immortalwrt_ma/package/kernel/r8125 package/new/r8125
cp -rf ../immortalwrt_ma/package/kernel/r8152 package/new/r8152
cp -rf ../immortalwrt_ma/package/kernel/r8168 package/new/r8168
cp -f ../lean_lede/target/linux/x86/patches-6.1/996-intel-igc-i225-i226-disable-eee.patch target/linux/x86/patches-6.1/

### LuCI ###
# modules (autocore, fullcone)
rm -rf feeds/luci/modules/luci-base
cp -rf ../immortalwrt_luci_ma/modules/luci-base feeds/luci/modules/luci-base
rm -rf feeds/luci/modules/luci-mod-status
cp -rf ../immortalwrt_luci_ma/modules/luci-mod-status feeds/luci/modules/luci-mod-status

### 软件包 ###
# ddns
cp -rf ../sbwml_pkg/ddns-scripts-aliyun package/new/ddns-scripts-aliyun
sed -i '/boot()/,+2d' feeds/packages/net/ddns-scripts/files/etc/init.d/ddns
# nlbwmon
sed -i 's/services/network/g' feeds/luci/applications/luci-app-nlbwmon/root/usr/share/luci/menu.d/luci-app-nlbwmon.json
sed -i 's/services/network/g' feeds/luci/applications/luci-app-nlbwmon/htdocs/luci-static/resources/view/nlbw/config.js
# watchcat
true > feeds/packages/utils/watchcat/files/watchcat.config

### 修改默认配置 ###
rm -f .config
#sed -i 's/CONFIG_WERROR=y/# CONFIG_WERROR is not set/g' target/linux/generic/config-6.6
#wget -qO - https://github.com/openwrt/openwrt/commit/c21a357093afc1ffeec11b6bb63d241899c1cf68.patch | patch -p1
