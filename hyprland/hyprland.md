# Hyprland

## Launching Hyprland (Session Manager)

I chose `SDDM` instead of the recommended `uwsm` because it should work flawlessly. It avoid passing by the TTY tologin which looks fancier (also as I setup Plymouth later)

```bash
sudo pacman -S sddm uwsm
sudo systemctl enable sddm

# if using another keyboard layout than 'us'
sudo echo 'setxkbmap <code>' >> /usr/share/sddm/scripts/Xsetup
reboot
```

Then for the theme
Download theme zip here: https://github.com/catppuccin/sddm/releases 

```bash
pacman -Syu qt6-svg qt6-declarative qt5-quickcontrols2
unzip catpuccin-theme.zip
mv catpuccin-theme/ /usr/share/sddm/themes/
```

And add the folowing in the file ``/etc/sddm.conf`` (crete if not exist):
```
[Theme]
Current=catppuccin-flavour
```

Don't forget to choose `hyprland (uwsm-managed)` entry in sddm selection menu.

## Must have

### Notification daemon

```bash
sudo pacman -S dunst
mkdir -p .conifg/dunst
cp /etc/dunst/dunstrc ~/.config/dunst/dunstrc
```

Then add `exec-once = /usr/bin/dunst` to your Hyprland's config.

### Waybar

```bash
sudo pacman -S waybar

systemctl --user enable --now waybar.service
```

### App launchers

```bash
sudo pacman -S wofi

```

### hyprpolkitagent

```bash
sudo pacman -S hyprpolkitagent

# Because Hyprland is started with uwsm we can start it with
systemctl --user enable --now hyprpolkitagent.service
```

### Yay + VS Codium
```bash
sudo pacman -S --needed git base-devel && git clone https://aur.archlinux.org/yay.git && cd yay && makepkg -si
sudo pacman -S less # for Yay PKGBUILD check if not already installed
yay -S vscodium-bin
```

### Kitty (terminal)
```bash
sudo pacman -S kitty # already installed by Hyprland
nano .config/kitty/kitty.conf # paste config from dotfiles
```

```bash

```

## TODO: Other

```bash
sudo pacman -S pipewire wireplumber xdg-desktop-portal-hyprland discord hyprpaper git zip unzip

# bash completion with sudo
# in .basch:
if [ -f /etc/bash_completion ]; then
    . /etc/bash_completion
fi

# fonts
sudo pacman -S noto-fonts-emoji noto-fonts-cjk
```
