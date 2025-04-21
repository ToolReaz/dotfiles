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

Don't forget to choose `hyprland (uwsm-managed)` entry in sddm selection menu.

## Must have

### Notification daemon

```bash
sudo pacman -S dunst
mkdir -p .conifg/dunst
cp /etc/dunst/dunstrc ~/.config/dunst/dunstrc
```

Then add `exec-once = /usr/bin/dunst` to your Hyprland's config.

```bash

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

```bash

```

```bash

```

```bash

```

## TODO: Other

```bash
sudo pacman -S pipewire wireplumber xdg-desktop-portal-hyprland discord

# bash completion with sudo
# in .basch:
if [ -f /etc/bash_completion ]; then
    . /etc/bash_completion
fi

# fonts
sudo pacman -S noto-fonts-emoji noto-fonts-cjk
```
