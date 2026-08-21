#!/bin/sh

export XDG_CURRENT_DESKTOP=dwm
export XDG_SESSION_TYPE=x11

echo "xinitrc executed at $(date)" >>~/xinitrc.log
userresources=$HOME/.Xresources
usermodmap=$HOME/.Xmodmap
sysresources=/etc/X11/xinit/.Xresources
sysmodmap=/etc/X11/xinit/.Xmodmap

# Merge system/user X resources
[ -f "$sysresources" ] && xrdb -merge "$sysresources"
[ -f "$sysmodmap" ] && xmodmap "$sysmodmap"
[ -f "$userresources" ] && xrdb -merge "$userresources"
[ -f "$usermodmap" ] && xmodmap "$usermodmap"

# Load scripts in /etc/X11/xinit/xinitrc.d
if [ -d /etc/X11/xinit/xinitrc.d ]; then
  for f in /etc/X11/xinit/xinitrc.d/?*.sh; do
    [ -x "$f" ] && . "$f"
  done
  unset f
fi

# -------------------------------------------------
# Display configuration  (EDIT PER LAPTOP: output names / resolutions)
# -------------------------------------------------
# DP-2 (4K) primary at the bottom; HDMI-1 (ultrawide) directly above it,
# horizontally centered ((3840-3440)/2 = 200); laptop panel eDP-1 is off.
xrandr \
  --output DP-2 --primary --mode 3840x2160 --pos 0x1440 \
  --output HDMI-1 --off \
  --output eDP-1 --off \
  --output DP-1-8 --off

xset s off
xset s noblank
xset -dpms

# -------------------------------------------------
# Startup utilities
# -------------------------------------------------
# Refresh wallpaper (after xrandr so it matches the final geometry)
nitrogen --restore &

# Compositor
picom --config ~/.config/picom/picom.conf &

dunst &
copyq &
# kdeconnectd isn't on PATH — the kdeconnect package installs it under
# /usr/lib (Arch) or /usr/lib/<triplet>/libexec (Debian), not /usr/bin.
kdeconnectd=$(command -v kdeconnectd 2>/dev/null || find /usr/lib -maxdepth 3 -name kdeconnectd 2>/dev/null | head -n1)
[ -n "$kdeconnectd" ] && "$kdeconnectd" &

# -------------------------------------------------
# Status bar (dwmblocks + signal-driven volume updates)
# -------------------------------------------------
dwmblocks &
~/everforest_dwm/dwmblocks/daemons/pulse_daemon.sh &

# -------------------------------------------------
# Launch DWM
# -------------------------------------------------
exec ~/bin/startdwm
