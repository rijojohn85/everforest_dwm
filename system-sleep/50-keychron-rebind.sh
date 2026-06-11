#!/bin/sh
# Force-rebind Keychron K2 Max after resume to fix partial HID reinit.
# Symptom: space key not registering until physical disconnect/reconnect.
# Must live in /usr/lib/systemd/system-sleep/ (only dir systemd-sleep scans).

case "$1" in
    post)
        sleep 1  # let kernel finish waking USB

        for dev_path in /sys/bus/usb/devices/*/; do
            vid=$(cat "$dev_path/idVendor" 2>/dev/null)
            pid=$(cat "$dev_path/idProduct" 2>/dev/null)
            if [ "$vid" = "3434" ] && [ "$pid" = "0a20" ]; then
                dev=$(basename "$dev_path")
                echo "$dev" > /sys/bus/usb/drivers/usb/unbind
                sleep 1
                echo "$dev" > /sys/bus/usb/drivers/usb/bind
            fi
        done
        ;;
esac
