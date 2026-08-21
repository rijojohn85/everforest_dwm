#!/usr/bin/env bash
# Portable installer for the everforest_dwm rice.
#
# Supports Arch (paru/pacman) and Ubuntu/Debian (apt). Packages missing from
# Debian repos (keyd, starship, lazygit) are built/installed from source.
#
# Deployment is symlink-based: live files point at the copies in this repo, so
# editing a live file edits the repo. Existing real files are backed up first.
set -euo pipefail

REPO_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "$REPO_DIR"

# ------------------------------------------------------------ distro detect -
if command -v pacman >/dev/null 2>&1; then
	DISTRO=arch
elif command -v apt-get >/dev/null 2>&1; then
	DISTRO=debian
else
	echo "Unsupported distro: need pacman or apt-get." >&2
	exit 1
fi
echo ">> Detected distro: $DISTRO"

# Is /home on the root filesystem? Decides whether /etc files can be symlinked
# into this repo (safe at boot) or must be copied (separate /home mount).
if findmnt -no SOURCE /home >/dev/null 2>&1; then HOME_ON_ROOT_FS=0; else HOME_ON_ROOT_FS=1; fi

# ----------------------------------------------------------- package lists --
arch_pkgs=(
	xorg-server xorg-xinit xorg-xrandr xorg-xsetroot
	librewolf-bin nitrogen picom rofi neovim vim git curl
	fzf fd ripgrep eza bat zoxide thefuck xclip zsh
	zsh-autosuggestions zsh-syntax-highlighting
	i3lock imagemagick
	lazygit starship keyd reflector
	base-devel libx11 libxft libxinerama fontconfig pkgconf
	alacritty dunst copyq kdeconnect playerctl alsa-utils
	pipewire pipewire-pulse zathura zathura-pdf-mupdf htop
)
debian_pkgs=(
	xorg xinit x11-xserver-utils
	firefox nitrogen picom rofi neovim vim git curl tar
	fzf fd-find ripgrep eza bat zoxide thefuck xclip zsh
	zsh-autosuggestions zsh-syntax-highlighting
	i3lock imagemagick
	build-essential libx11-dev libxft-dev libxinerama-dev libxext-dev fontconfig pkg-config
	alacritty dunst copyq kdeconnect playerctl alsa-utils
	pipewire pipewire-pulse zathura zathura-pdf-poppler htop
)

install_packages() {
	if [ "$DISTRO" = arch ]; then
		if ! command -v paru >/dev/null 2>&1; then
			echo ">> Installing paru (AUR helper)"
			sudo pacman -S --needed --noconfirm base-devel git
			local t; t=$(mktemp -d)
			git clone https://aur.archlinux.org/paru.git "$t/paru"
			( cd "$t/paru" && makepkg -si --noconfirm )
		fi
		paru -S --needed --noconfirm "${arch_pkgs[@]}"
	else
		sudo apt-get update
		sudo apt-get install -y "${debian_pkgs[@]}"
		install_debian_extras
	fi
}

install_debian_extras() {
	# keyd is not packaged for Debian/Ubuntu -> build from source.
	if ! command -v keyd >/dev/null 2>&1; then
		echo ">> Building keyd from source"
		local t; t=$(mktemp -d)
		git clone https://github.com/rvaiya/keyd "$t/keyd"
		( cd "$t/keyd" && make && sudo make install )
	fi
	if ! command -v starship >/dev/null 2>&1; then
		echo ">> Installing starship"
		curl -sS https://starship.rs/install.sh | sh -s -- -y
	fi
	if ! command -v lazygit >/dev/null 2>&1; then
		echo ">> Installing lazygit"
		local ver
		ver=$(curl -s https://api.github.com/repos/jesseduffield/lazygit/releases/latest \
			| grep -Po '"tag_name": *"v\K[^"]*')
		curl -Lo /tmp/lazygit.tar.gz \
			"https://github.com/jesseduffield/lazygit/releases/download/v${ver}/lazygit_${ver}_Linux_x86_64.tar.gz"
		tar -xf /tmp/lazygit.tar.gz -C /tmp lazygit
		sudo install /tmp/lazygit /usr/local/bin
	fi
	# Debian names these binaries differently; add the expected names on PATH.
	mkdir -p "$HOME/.local/bin"
	command -v fdfind >/dev/null 2>&1 && ln -sfn "$(command -v fdfind)" "$HOME/.local/bin/fd"
	command -v batcat >/dev/null 2>&1 && ln -sfn "$(command -v batcat)" "$HOME/.local/bin/bat"
}

# ------------------------------------------------------------- symlink helper
# link <repo-relative-path> <absolute-dest>  (backs up an existing real file)
link() {
	local src="$REPO_DIR/$1" dest="$2"
	[ -e "$src" ] || { echo "  skip (missing in repo): $1"; return 0; }
	mkdir -p "$(dirname "$dest")"
	if [ -L "$dest" ] && [ "$(readlink -f "$dest")" = "$(readlink -f "$src")" ]; then
		return 0
	fi
	if [ -e "$dest" ] && [ ! -L "$dest" ]; then
		mv "$dest" "$dest.bak.$(date +%s)"
		echo "  backed up $dest -> $dest.bak.*"
	fi
	ln -sfn "$src" "$dest"
	echo "  linked $dest -> $src"
}

# link_system <repo-relative-path> <absolute-dest>  (root; symlink or copy)
link_system() {
	local src="$REPO_DIR/$1" dest="$2"
	sudo mkdir -p "$(dirname "$dest")"
	if [ "$HOME_ON_ROOT_FS" = 1 ]; then
		sudo ln -sfn "$src" "$dest"
		echo "  linked (root) $dest -> $src"
	else
		sudo install -m 0644 "$src" "$dest"
		echo "  copied (root, /home is separate) $dest"
	fi
}

install_fonts() {
	echo ">> Installing fonts"
	mkdir -p "$HOME/.local/share/fonts"
	cp -n ./SFMono-Nerd-Font-Ligaturized/*.otf "$HOME/.local/share/fonts/" 2>/dev/null || true
	fc-cache -f >/dev/null
}

build_suckless() {
	# Builds with the config.h committed in this repo (does NOT regenerate it).
	for d in dwm-6.5 st-0.9.2 dwmblocks; do
		if [ -d "./$d" ]; then
			echo ">> Building $d"
			( cd "./$d" && sudo make clean install )
		fi
	done
}

deploy_links() {
	echo ">> Linking dotfiles and scripts"
	link .xinitrc  "$HOME/.xinitrc"
	link .zprofile "$HOME/.zprofile"
	link .zshrc    "$HOME/.zshrc"
	link .local/bin/lock.sh       "$HOME/.local/bin/lock.sh"
	link .local/bin/dwm_logout.sh "$HOME/.local/bin/dwm_logout.sh"
	link startdwm  "$HOME/bin/startdwm"

	echo ">> Linking ~/.config subdirectories"
	for d in ./.config/*/; do
		link ".config/$(basename "$d")" "$HOME/.config/$(basename "$d")"
	done

	echo ">> Linking wallpapers"
	for w in ./wallpapers/*; do
		[ -e "$w" ] || continue
		link "wallpapers/$(basename "$w")" "$HOME/Pictures/Wallpapers/21_9/$(basename "$w")"
	done
}

setup_keyd() {
	echo ">> Configuring keyd"
	link_system default.conf /etc/keyd/default.conf
	sudo systemctl enable --now keyd
	sudo keyd reload || true
}

setup_udev() {
	echo ">> Installing USB-wake udev rule"
	link_system udev/90-usb-wakeup.rules /etc/udev/rules.d/90-usb-wakeup.rules
	sudo udevadm control --reload-rules
	sudo udevadm trigger --subsystem-match=usb --action=add
	echo "   NOTE: edit udev/90-usb-wakeup.rules with this laptop's keyboard/mouse VID:PID."
}

setup_sleep_hooks() {
	echo ">> Installing systemd sleep hooks"
	# Must go to /usr/lib/systemd/system-sleep/ — systemd-sleep only scans that dir.
	link_system system-sleep/50-keychron-rebind.sh /usr/lib/systemd/system-sleep/50-keychron-rebind.sh
	sudo chmod +x /usr/lib/systemd/system-sleep/50-keychron-rebind.sh
}

set_shell() {
	if [ "$(getent passwd "$USER" | cut -d: -f7)" != "$(command -v zsh)" ]; then
		echo ">> Setting default shell to zsh"
		chsh -s "$(command -v zsh)" || true
	fi
}

main() {
	install_packages
	install_fonts
	build_suckless
	deploy_links
	setup_keyd
	setup_udev
	setup_sleep_hooks
	set_shell
	echo
	echo "Done. Log out and startx."
	echo "Per-laptop edits still needed:"
	echo "  - ~/.xinitrc  : xrandr line (monitor names/resolutions/layout)"
	echo "  - udev/90-usb-wakeup.rules : keyboard/mouse VID:PID, then: keyd reload"
}
main "$@"
