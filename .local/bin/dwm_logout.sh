#!/bin/sh
options="Lock\nSleep\nLogout\nReboot\nShutdown"
chosen=$(echo "$options" | rofi -dmenu -p "Power:")

case "$chosen" in
Logout) pkill -u $USER dwm ;;
Reboot) systemctl reboot ;;
Shutdown) systemctl poweroff ;;
Sleep) ~/.local/bin/lock.sh; systemctl suspend ;;
Lock) ~/.local/bin/lock.sh ;;
esac
