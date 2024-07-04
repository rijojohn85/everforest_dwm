#!/bin/sh

userresources=$HOME/.Xresources
usermodmap=$HOME/.Xmodmap
sysresources=/etc/X11/xinit/.Xresources
sysmodmap=/etc/X11/xinit/.Xmodmap

# merge in defaults and keymaps

if [ -f $sysresources ]; then

  xrdb -merge $sysresources

fi

if [ -f $sysmodmap ]; then
  xmodmap $sysmodmap
fi

if [ -f "$userresources" ]; then

  xrdb -merge "$userresources"

fi

if [ -f "$usermodmap" ]; then
  xmodmap "$usermodmap"
fi

# start some nice programs

if [ -d /etc/X11/xinit/xinitrc.d ]; then
  for f in /etc/X11/xinit/xinitrc.d/?*.sh; do
    [ -x "$f" ] && . "$f"
  done
  unset f
fi
#keyboard layout
#setxkbmap ch &

#Display Resolution
xrandr --output HDMI-2 --primary --mode 1920x1080 --output HDMI-1 --mode 1920x1080 --rotate right --right-of HDMI-2 &
while true; do
  xsetroot -name "$(ip -o route get to 8.8.8.8 | sed -n 's/.*src \([0-9.]\+\).*/\1/p') | $(date +"%F %R")"
  sleep 60s
done &
#Compositor
picom --config ~/.config/picom/picom.conf &
#dwm status
# dwmstatus 2>&1 >/dev/null &
# exec dwmblocks &
# exec rsblocks &
##nitrogen
nitrogen --restore
#loop
exec ~/bin/startdwm
#Execute DWM
exec dwm
