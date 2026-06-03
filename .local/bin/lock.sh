#!/bin/sh
# Lock the screen with i3lock using a blurred, per-monitor wallpaper.
# Each connected output gets its own wallpaper composited into its region of
# the X canvas; the result is blurred, cached, and only regenerated when a
# wallpaper or the monitor layout changes, so locking stays instant.
set -eu

cache="$HOME/.cache/i3lock-bg.png"
bg="#2d353b" # everforest bg, fills any off-screen corners

# --- per-monitor lock wallpapers (xrandr output name -> image) -------------
# Edit these to set each screen's lock wallpaper. Add more lines as
# wall_<OUTPUT> with dashes replaced by underscores (e.g. DP-2 -> wall_DP_2).
wall_DP_2="$HOME/Pictures/Wallpapers/21_9/Astronaut_Watercolor-2.jpg"
wall_HDMI_1="$HOME/Pictures/Wallpapers/21_9/Astronaut_Watercolor-7.jpg"
default_wall="$HOME/Pictures/Wallpapers/21_9/Astronaut_Watercolor-2.jpg"
# ---------------------------------------------------------------------------

# Resolve an output name (e.g. "HDMI-1") to its configured wallpaper.
wall_for() {
	var="wall_$(echo "$1" | tr '-' '_')"
	eval "path=\${$var:-}"
	[ -n "${path:-}" ] && [ -f "$path" ] && { printf '%s' "$path"; return; }
	printf '%s' "$default_wall"
}

# Full X canvas size (covers all monitors, including any dead space).
geo=$(xrandr --current | sed -n 's/.*current \([0-9]\+\) x \([0-9]\+\).*/\1x\2/p')

regen() {
	tmp=$(mktemp --suffix=.png)
	convert -size "$geo" "xc:$bg" "$tmp"

	# Zoom-fill each active output's own wallpaper into its region.
	xrandr --listmonitors | tail -n +2 | while read -r _idx _tag mgeo name; do
		g=$(printf '%s' "$mgeo" | sed 's#/[0-9]*##g') # e.g. 3840x2160+0+1440
		mw=${g%%x*}; r=${g#*x}; mh=${r%%+*}; r=${r#*+}; mx=${r%%+*}; my=${r#*+}
		w=$(wall_for "$name")
		convert "$tmp" \
			\( "$w" -resize "${mw}x${mh}^" -gravity center \
			   -extent "${mw}x${mh}" \) \
			-gravity NorthWest -geometry "+${mx}+${my}" -composite "$tmp"
	done

	# Fast gaussian blur (downscale, blur, upscale) + slight dim for contrast.
	convert "$tmp" -resize 25% -blur 0x8 -resize 400% \
		-brightness-contrast -12x0 "$cache"
	rm -f "$tmp"
}

cached_size=$(identify -format '%wx%h' "$cache" 2>/dev/null || echo "")
if [ ! -f "$cache" ] || [ "$cached_size" != "$geo" ]; then
	regen
else
	for w in "$wall_DP_2" "$wall_HDMI_1" "$default_wall"; do
		if [ -f "$w" ] && [ "$w" -nt "$cache" ]; then regen; break; fi
	done
fi

# -e ignore empty password, -f show failed attempts, -c fallback fill colour.
exec i3lock -i "$cache" -e -f -c 2d353b
