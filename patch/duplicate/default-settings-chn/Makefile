#
# Copyright (C) 2016-2017 GitHub
#
# This is free software, licensed under the GNU General Public License v3.
# See /LICENSE for more information.

include $(TOPDIR)/rules.mk

PKG_NAME:=default-settings-chn
PKG_VERSION:=1.0.0
PKG_RELEASE:=r1
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
	Default Settings & Language Support Packages.
endef

define Build/Compile
endef

define Package/$(PKG_NAME)/install
	$(INSTALL_DIR) $(1)/etc/uci-defaults
	$(INSTALL_BIN) ./files/zzz-default-settings $(1)/etc/uci-defaults/99-default-settings
endef

$(eval $(call BuildPackage,$(PKG_NAME)))
