#!/bin/sh

GEO_DIR="/usr/share/v2ray"
GEOIP_URL="https://cdn.jsdelivr.net/gh/umlka/v2ray-rules-dat@release/geoip.dat"
GEOIP_SHA256_URL="https://cdn.jsdelivr.net/gh/umlka/v2ray-rules-dat@release/geoip.dat.sha256sum"
GEOSITE_URL="https://cdn.jsdelivr.net/gh/umlka/v2ray-rules-dat@release/geosite.dat"
GEOSITE_SHA256_URL="https://cdn.jsdelivr.net/gh/umlka/v2ray-rules-dat@release/geosite.dat.sha256sum"

trap 'rm -rf "$TMP_DIR"' 0 1 2 3
TMP_DIR="$(mktemp -d)" || exit 1

mkdir -p "$GEO_DIR"

wget -O "$TMP_DIR/geoip.dat.sha256sum" "$GEOIP_SHA256_URL" && wget -O "$TMP_DIR/geoip.dat" "$GEOIP_URL" && [ "$(cat "$TMP_DIR/geoip.dat.sha256sum" | awk '{print $1}')" = "$(sha256sum "$TMP_DIR/geoip.dat" | awk '{print $1}')" ]
RET="$?"
if [ "$RET" -ne 0 ]; then
	echo -e "\e[34mGeoIP List\e[0m updated \e[31mfailed\e[0m."
else
	mv -f "$TMP_DIR/geoip.dat" "$GEO_DIR"
	echo -e "\e[34mGeoIP List\e[0m updated \e[92msuccessfully\e[0m."
fi

wget -O "$TMP_DIR/geosite.dat.sha256sum" "$GEOSITE_SHA256_URL" && wget -O "$TMP_DIR/geosite.dat" "$GEOSITE_URL" && [ "$(cat "$TMP_DIR/geosite.dat.sha256sum" | awk '{print $1}')" = "$(sha256sum "$TMP_DIR/geosite.dat" | awk '{print $1}')" ]
if [ "$?" -ne 0 ]; then
	echo -e "\e[34mGeoSite List\e[0m updated \e[31mfailed\e[0m."
	[ "$RET" -eq 0 ] || exit 1
else
	mv -f "$TMP_DIR/geosite.dat" "$GEO_DIR"
	echo -e "\e[34mGeoSite List\e[0m updated \e[92msuccessfully\e[0m."
fi

exit 0
