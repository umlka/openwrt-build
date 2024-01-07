#!/bin/bash

### 基础部分 ###
mkdir -p package/new
# 移除 SNAPSHOT 标签
sed -i 's/-SNAPSHOT//g' include/version.mk
sed -i 's/-SNAPSHOT//g' package/base-files/image-config.in

### 通用补丁 ###
# lrng
cp -f ../patch/lrng/* target/linux/generic/hack-5.15/
echo '
CONFIG_LRNG=y
# CONFIG_RANDOM_DEFAULT_IMPL is not set
CONFIG_LRNG_CPU=y
# CONFIG_LRNG_IRQ is not set
CONFIG_LRNG_JENT=y
# CONFIG_LRNG_SCHED is not set
' >> target/linux/generic/config-5.15
# tcp
cp -f ../patch/net/tcp/* target/linux/generic/backport-5.15/
# bbr3
cp -rf ../patch/net/bbr3/* target/linux/generic/backport-5.15/
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
mkdir -p package/network/ipv6/odhcp6c/patches
cp -f ../patch/odhcp6c/999-fix-odhcp6c-deamon-raw-buffer-inc.patch package/network/ipv6/odhcp6c/patches/
cp -f ../patch/odhcp6c/1003-Check-nat46-kernel-module-exists-before-requesting-Softwire46-options.patch package/network/ipv6/odhcp6c/patches/
cp -f ../patch/odhcp6c/1004-odhcp6c-sync-and-accumulate-RA-DHCPv6-events-as-fast-as-possible.patch package/network/ipv6/odhcp6c/patches/
# fstools
wget -qO - https://github.com/immortalwrt/immortalwrt/commit/19f355ea0196ec04241cae57215c364c0c1fbb16.patch | patch -p1
# multiple registrant兼容性补丁 (nlbwmon, flow offloading) from wongsyrone/lede-1
cp -f ../patch/net/952-add-net-conntrack-events-support-multiple-registrant.patch target/linux/generic/hack-5.15/

### kmod ###
# hwmon-pwmfan
patch -p1 < ../patch/hwmon-pwmfan/hwmon-pwmfan-remove-thermal-dependency.patch
# nvme
sed -i 's/# CONFIG_NVME_HWMON is not set/CONFIG_NVME_HWMON=y/g' target/linux/x86/64/config-5.15

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
# bridger
rm -rf package/libs/libbpf
cp -rf ../openwrt_ma/package/libs/libbpf package/libs/libbpf
rm -rf package/network/services/bridger
cp -rf ../openwrt_ma/package/network/services/bridger package/network/services/bridger
# NIC drivers
cp -rf ../immortalwrt_23/package/kernel/r8125 package/new/r8125
cp -rf ../immortalwrt_23/package/kernel/r8152 package/new/r8152
cp -rf ../immortalwrt_23/package/kernel/r8168 package/new/r8168
cp -f ../lean_lede/target/linux/x86/patches-5.15/996-intel-igc-i225-i226-disable-eee.patch target/linux/x86/patches-5.15/
# Intel firmware
sed -i '/CONFIG_DRM_I915/d' target/linux/x86/64/config-5.15
wget -qO - https://github.com/openwrt/openwrt/commit/c21a357093afc1ffeec11b6bb63d241899c1cf68.patch | patch -p1
wget -qO - https://github.com/openwrt/openwrt/commit/9c58addc0bbeb27049ec3f994bcb0846a6a35b1c.patch | patch -p1
wget -qO - https://github.com/openwrt/openwrt/commit/64f1a65736a0c265b764071bf3ee6224438ac400.patch | patch -p1
# ppp
rm -rf package/network/services/ppp
git clone -b main --depth 1 https://github.com/sbwml/package_network_services_ppp package/network/services/ppp

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
#sed -i 's/services/network/g' feeds/luci/applications/luci-app-nlbwmon/root/usr/share/luci/menu.d/luci-app-nlbwmon.json
#sed -i 's/services/network/g' feeds/luci/applications/luci-app-nlbwmon/htdocs/luci-static/resources/view/nlbw/config.js
# upnp
rm -rf feeds/packages/net/miniupnpd
cp -rf ../openwrt_pkg_ma/net/miniupnpd feeds/packages/net/miniupnpd
#sed -i 's/services/network/g' feeds/luci/applications/luci-app-upnp/root/usr/share/luci/menu.d/luci-app-upnp.json
patch -p1 -d feeds/packages < ../patch/miniupnpd/01-set-presentation_url.patch
patch -p1 -d feeds/packages < ../patch/miniupnpd/02-force_forwarding.patch
patch -p1 -d feeds/packages < ../patch/miniupnpd/03-Update-301-options-force_forwarding-support.patch.patch
patch -p1 -d feeds/packages < ../patch/miniupnpd/04-enable-force_forwarding-by-default.patch
patch -p1 -d feeds/luci < ../patch/miniupnpd/luci/luci-app-upnp-support-force-forwarding-flag.patch
# watchcat
true > feeds/packages/utils/watchcat/files/watchcat.config

### 修改默认配置 ###
rm -f .config
sed -i 's/CONFIG_WERROR=y/# CONFIG_WERROR is not set/g' target/linux/generic/config-5.15
