#!/bin/bash

### 基础部分 ###
mkdir -p package/new
# 移除 SNAPSHOT 标签
sed -i 's/-SNAPSHOT//g' include/version.mk
sed -i 's/-SNAPSHOT//g' package/base-files/image-config.in

### 通用补丁 ###
# lrng
cp -f ../patch/lrng/* target/linux/generic/hack-5.15/
cat ../config/x86/lrng >> target/linux/generic/config-5.15
# wireguard
cp -f ../patch/wireguard/950-wireguard-support-hotplug.patch target/linux/generic/hack-5.15/
# odhcpd
mkdir -p package/network/services/odhcpd/patches
#cp -f ../patch/odhcpd/001-odhcpd-RFC-9096-compliance.patch package/network/services/odhcpd/patches/
cp -f ../immortalwrt_23/package/network/services/odhcpd/patches/001-odhcpd-RFC-9096-compliance.patch package/network/services/odhcpd/patches/
patch -p1 -d feeds/luci < ../patch/odhcpd/luci/Revert-luci-network-interfaces-Add-IPv6-lifetime-options.patch
patch -p1 -d feeds/luci < ../patch/odhcpd/luci/luci-mod-network-add-option-for-ipv6-max-plt-vlt.patch
# odhcp6c
patch -p1 < ../patch/odhcp6c/1002-odhcp6c-support-dhcpv6-hotplug.patch
# multiple registrant兼容性补丁 (nlbwmon, flow offloading)
cp -f ../patch/net/952-add-net-conntrack-events-support-multiple-registrant.patch target/linux/generic/hack-5.15/
# threaded network backlog processing
rm -f target/linux/generic/pending-5.15/760-net-core-add-optional-threading-for-backlog-processi.patch

### firewall4/fullcone ###
# firewall4
mkdir -p package/network/config/firewall4/patches
cp -f ../patch/firewall/001-firewall4-add-support-for-fullcone-nat.patch package/network/config/firewall4/patches/
#cp -f ../patch/firewall/002-fix-adding-offloading-device.patch package/network/config/firewall4/patches/
cp -f ../immortalwrt_23/package/network/config/firewall4/patches/002-fix-adding-offloading-device.patch package/network/config/firewall4/patches/
# libnftnl
mkdir -p package/libs/libnftnl/patches
sed -i '/^PKG_INSTALL:=/i\PKG_FIXUP:=autoreconf' package/libs/libnftnl/Makefile
#cp -f ../patch/firewall/libnftnl/001-libnftnl-add-fullcone-expression-support.patch package/libs/libnftnl/patches/
cp -f ../immortalwrt_23/package/libs/libnftnl/patches/001-libnftnl-add-fullcone-expression-support.patch package/libs/libnftnl/patches/
# nftables
mkdir -p package/network/utils/nftables/patches
#cp -f ../patch/firewall/nftables/002-nftables-add-fullcone-expression-support.patch package/network/utils/nftables/patches/
cp -f ../immortalwrt_23/package/network/utils/nftables/patches/002-nftables-add-fullcone-expression-support.patch package/network/utils/nftables/patches/
# package
#git clone -b master --depth 1 https://github.com/fullcone-nat-nftables/nft-fullcone.git package/new/nft-fullcone
cp -rf ../immortalwrt_23/package/network/utils/fullconenat-nft package/new/fullconenat-nft
# luci
patch -p1 -d feeds/luci < ../patch/firewall/luci/luci-app-firewall-add-fullcone.patch

### 基础包 ###
# autocore
cp -rf ../immortalwrt_23/package/emortal/autocore package/new/autocore
# default-settings-chn
cp -rf ../patch/duplicate/default-settings-chn package/new/default-settings-chn
# NIC drivers
cp -rf ../immortalwrt_23/package/kernel/r8125 package/new/r8125
cp -rf ../immortalwrt_23/package/kernel/r8152 package/new/r8152
cp -rf ../immortalwrt_23/package/kernel/r8168 package/new/r8168
cp -f ../lean_lede/target/linux/x86/patches-5.15/996-intel-igc-i225-i226-disable-eee.patch target/linux/x86/patches-5.15/

### LuCI ###
# modules (autocore, fullcone)
rm -rf feeds/luci/modules/luci-base
cp -rf ../immortalwrt_luci_23/modules/luci-base feeds/luci/modules/luci-base
rm -rf feeds/luci/modules/luci-mod-status
cp -rf ../immortalwrt_luci_23/modules/luci-mod-status feeds/luci/modules/luci-mod-status

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
echo '
net.netfilter.nf_conntrack_helper=1
' >> package/kernel/linux/files/sysctl-nf-conntrack.conf
#sed -i 's/CONFIG_WERROR=y/# CONFIG_WERROR is not set/g' target/linux/generic/config-5.15