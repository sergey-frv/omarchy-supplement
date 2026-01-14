#!/bin/sh

# Remove 1Password, i'am using keepassxc
yay -R --noconfirm 1password-beta
yay -R --noconfirm 1password-cli

# Remove webapps
omarchy-webapp-remove 'Basecamp'
omarchy-webapp-remove 'Discord'
omarchy-webapp-remove 'HEY'
omarchy-webapp-remove 'WhatsApp'
omarchy-webapp-remove 'X'
omarchy-webapp-remove 'Google Contacts'
omarchy-webapp-remove 'Google Messages'
omarchy-webapp-remove 'Google Photos'
omarchy-webapp-remove 'Figma'
