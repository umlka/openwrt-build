#
# Copyright (C) 2016-2017 GitHub
#
# This is free software, licensed under the GNU General Public License v3.
# See /LICENSE for more information.

include $(TOPDIR)/rules.mk

PKG_NAME:=addition-trans-zh
PKG_VERSION:=1.1
PKG_RELEASE:=52
PKG_LICENSE:=GPLv3
PKG_LICENSE_FILES:=LICENSE

include $(INCLUDE_DIR)/package.mk

define Package/$(PKG_NAME)
	SECTION:=luci
	CATEGORY:=LuCI
	TITLE:=LuCI support for Default Settings
	PKGARCH:=all
	DEPENDS:=+luci +@LUCI_LANG_zh_Hans
endef

define Package/$(PKG_NAME)/description
	Language Support Packages.
endef

define Build/Compile
endef

define Package/$(PKG_NAME)/install
	$(INSTALL_DIR) $(1)/etc/uci-defaults
	$(INSTALL_BIN) ./files/zzz-default-settings $(1)/etc/uci-defaults/99-default-settings

	$(INSTALL_DIR) $(1)/usr/lib/lua/luci/i18n
	po2lmo ./i18n/default.zh_Hans.po $(1)/usr/lib/lua/luci/i18n/default.zh-cn.lmo
	po2lmo ./i18n/more.zh_Hans.po $(1)/usr/lib/lua/luci/i18n/more.zh-cn.lmo
endef

$(eval $(call BuildPackage,$(PKG_NAME)))
