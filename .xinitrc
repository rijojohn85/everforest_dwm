#!/bin/sh

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
  --output eDP-1 --off \
  --output DP-2 --primary --mode 3840x2160 --pos 0x1440 \
  --output HDMI-1 --mode 3440x1440 --pos 200x0
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

# -------------------------------------------------
# Status bar (dwmblocks + signal-driven volume updates)
# -------------------------------------------------
dwmblocks &
~/everforest_dwm/dwmblocks/daemons/pulse_daemon.sh &

# -------------------------------------------------
# Launch DWM
# -------------------------------------------------
exec ~/bin/startdwm
