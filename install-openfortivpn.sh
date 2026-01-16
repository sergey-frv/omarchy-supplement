#!/bin/sh

# Install forti client vpn
yay -S --noconfirm --needed openfortivpn

CURRENT_DIR=$(pwd)
APP_NAME="OpenFrotiVPN"
APP_ICON_URL="https://cdn.jsdelivr.net/gh/homarr-labs/dashboard-icons/png/fortinet.png"

sudo rm -rf /usr/bin/openfortivpn-tui
sudo ln -s "$CURRENT_DIR/openfortivpn-tui" "/usr/bin/openfortivpn-tui"

omarchy-tui-remove $APP_NAME
omarchy-tui-install $APP_NAME openfortivpn-tui float $APP_ICON_URL
