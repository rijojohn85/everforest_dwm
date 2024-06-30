#! /bin/bash

#Install Paru
echo "Installing Paru"
sudo pacman -S --needed base-devel
git clone https://aur.archlinux.org/paru.git
cd paru
makepkg -si
cd ..

#install all the packages needed
echo "Installing Packages"
paru -S xorg-server vim xorg-xinit xorg-xrandr xorg-xsetroot librewolf-bin nitrogen picom neovim lazygit git fzf fd ripgrep eza bat zoxide thefuck starship zsh-autosuggestions zsh-syntax-highlighting rofi zsh reflector xclip keyd

# check if font directory exits and copy fonts to it
echo "Copying Fonts"
FONT_DIRECTORY='~/.local/share/fonts/'
if [ -d "$FONT_DIRECTORY" ]; then
	cp ./SFMono-Nerd-Font-Ligaturized/*.otf "$FONT_DIRECTORY"
else
	mkdir "$FONT_DIRECTORY"
	cp ./SFMono-Nerd-Font-Ligaturized/*.otf "$FONT_DIRECTORY"
fi
#refresh font cache
fc-cache

#install DWM
echo "Installing DWM"
cd ./dwm-6.5/
rm -rf config.h
sudo make clean install
cd ..

#install ST
echo "Installing ST"
cd ./st-0.9.2/
rm -rf config.h
sudo make clean install
cd ..
#
#check if config directory exists and copy configs there
echo "Copying Configs"
CONFIG_DIRECTORY='~/.config/'
if [ -d "$CONFIG_DIRECTORY" ]; then
	cp -r ./.config/* "$CONFIG_DIRECTORY"
else
	mkdir "$CONFIG_DIRECTORY"
	cp -r ./.config/* "$CONFIG_DIRECTORY"
fi

#initialing and starting keyd
sudo systemctl enable keyd
sudo systemctl start keyd

#Copying zshrc xinitrc keyd zprofile
cp ./.zprofile ~/
cp ./.zshrc ~/
cp ./.xinitrc ~/
sudo cp ./default.conf /etc/keyd/

echo "Edit xinitrc to updated for xrandr"

chsh -s /bin/zsh
