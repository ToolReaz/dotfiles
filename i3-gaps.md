# Custom i3-gaps desktop environment


## Install package
```bash
sudo pacman -S xorg i3-gaps lightdm lightdm-gtk-greeter rofi terminator wget curl unzip lxappearance feh bash-completion git base-devel
```

## Yay package manager
If you need package from AUR i recommend using [Yay](https://github.com/Jguer/yay).

## Display manager
// Lightdm

## Xorg
### Keyboard
```
# /etc/X11/xorg.conf.d/10-keyboard.conf
Section "InputClass"
        Identifier "system-keyboard"
        MatchIsKeyboard "on"
        Option "XkbLayout" "fr"
        Option "XkbModel" "pc105"
EndSection
```
### Touchpad
```
# /etc/X11/xorg.conf.d/30-touchpad.conf
Section "InputClass"
    Identifier "AlpsPS/2 ALPS GlidePoint"
    MatchIsTouchpad "on"
    Driver "libinput"
    Option "Tapping" "on"
    Option "ClickMethod" "clickfinger"
EndSection
```

## Window manager

## Terminal

## Rofi
// Use Dracula theme

## Theme
I'm using [Dracula](https://draculatheme.com/) theme.

Installing the GTK theme
``` bash
wget https://github.com/dracula/gtk/archive/master.zip
sudo unzip master.zip -d /usr/share/themes
sudo mv /usr/share/themes/gtk-master /usr/share/themes/Dracula
```

Installing the icon theme
``` bash
wget https://github.com/dracula/gtk/files/5214870/Dracula.zip
sudo unzip Dracula.zip -d /usr/share/icons
```

Then I use ``lxappearance`` to set the theme for both the user and root.

## Wallpaper
I use feh to display an image as wallpaper. I put this command in my i3 config file:
``` bash
feh --bg-scale /path/to/image
```

## File explorer
I use Thunar.
``` bash
sudo pacman -S thunar file-roller thunar-archive-plugin thunar-media-tags-plugin thunar-volman gvfs
```
I had ``thunar --daemon`` at startup to make it open faster afterward and manage automounting USB.

## Fonts
``` bash
sudo pacman -S ttf-dejavu ttf-droid gnu-free-fonts ttf-liberation ttf-linux-libertine noto-fonts ttf-roboto ttf-ubuntu-font-family ttf-hack ttf-jetbrains-mono ttf-opensans noto-fonts-emoji
```

## Status bar
I use Polybar. It require this packages for my setup:
```bash
sudo pacman -S
```

## Audio & Bluetooth
I first add my user in the audio group:
``` bash
sudo gpasswd -a toolreaz audio
```
Then I install requiered packages:
``` bash
sudo pacman -S alsa-utils alsa-plugins pulseaudio pulseaudio-alsa pulseaudio-bluetooth bluez bluez-utils vlc kmix bluedevil pavucontrol
```
Then I copy the default config to my user directory and apply needed changes:
``` bash
cp -r /etc/pulse ~/.config/pulse

# ~/.config/pulse.daemon.conf
daemonize = yes
```
``` bash

```
``` bash

```
``` bash

```
``` bash

```
