# Custom i3-gaps desktop environment


## Install package
```bash
sudo pacman -S xorg i3-gaps lightdm lightdm-gtk-greeter rofi terminator wget curl unzip lxappearance feh bash-completion
```

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


``` bash

```
``` bash

```
``` bash

```
``` bash

```
``` bash

```
``` bash

```
``` bash

```
``` bash

```
``` bash

```
