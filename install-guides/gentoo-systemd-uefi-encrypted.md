# Gentoo Systemd UEFI Encrypted

![WIP logo](https://img.shields.io/badge/STAUS-WORK%20IN%20PROGRESS-red?style=for-the-badge&logo=gentoo)

## Features
- UEFI partition
- Systemd as init system
- plain dm-crypt encryption on main drive
- main disk encryption keyfile on removable device
- boot partition on removable device
- encrypted boot partition with passphrase
- secure boot with signed image

## Drives layout used in this guide
```
/dev/sda        Main drive, encrypted using dm-crypt in plain mode
/dev/mmcblk0    Removable device used for encrypted boot partition and key
```

## Preparations
### Installation media
First download the live installation CD on https://www.gentoo.org/downloads/ .
Flash the iso file onto an USB.
Then boot **in EFI mode** on it.

### Keyboard layout
If you don't have the correct layout you can use ``loadkeys <keymap>`` to change it.

Example for a french AZERTY layout:
```bash
loadkeys fr
```

### Disk
For security reason it is advise to fill your main drive (that will be encrypted) with random data. This way it won't be possible to recover any data from your previous installation.

```bash
dd if=/dev/urandom of=/dev/sda bs=4M status=progress
```

***/!\ This will permanently erase all your data /!\


### Connect to internet
If you use a wired connection it should work out of the box.
Otherwise if you are using WiFi you can use ``net-setup``.

## Paritionning
### Removable device
```bash
cfdisk /dev/mmcblk0
```
Create the partition as follow:
```
/dev/mmcblk0p1    size 100M, type ef00, name EFI
/dev/mmcblk0p2    size 500M, type default, name BOOT
/dev/mmcblk0p3    size 200M, type default, name <none or like you want>
/dev/mmcblk0p4    *OPTIONAL* size <remaining space>, type linux filesystem, name STORAGE
```

Generate encryption key for main drive
```bash
dd if=/dev/urandom of=/dev/mmcblk0p3 status=progress
```

Encrypt boot partition
```bash
cryptsetup luksFormat --type luks1 /dev/mmcblk0p2
cryptsetup open /dev/mmcblk0p2 cryptboot
```

Format partitions
```bash
mkfs.fat -F32 /dev/mmcblk0p1
mkfs.fat -F32 /dev/mapper/cryptboot
```

### Main drive
```bash
cryptsetup --cipher=aes-xts-plain64 --offset=<number> --key-file=/dev/mmcblk0p2 --keyfile-offset=<number> --key-size=512 open --type plain /dev/sda cryptroot
```

```bash
mkfs.ext4 /dev/mapper/cryptroot
```

## Mount filesystem tree
```bash
mount /dev/mapper/cryptroot /mnt/gentoo

mkdir /mnt/gentoo/boot
mount /dev/mapper/cryptboot /mnt/gentoo/boot

mkdir /mnt/gentoo/boot/efi
mount /dev/mmcblk0p1 /mnt/gentoo/boot/efi

mount -t proc /proc /mnt/gentoo/proc
mount --rbind /dev /mnt/gentoo/dev
mount --rbind /sys /mnt/gentoo/sys
```

## Install system

### Get the stage3
```bash
cd /mnt/gentoo
```

```bash
wget https://bouncer.gentoo.org/fetch/root/all/releases/amd64/autobuilds/20210221T214504Z/stage3-amd64-systemd-20210221T214504Z.tar.xz

tar xJvpf stage3-*.tar.xz --xattrs
```
*Update the link with a more recent version*

### Configure portage
```bash
nano -w /mnt/gentoo/etc/portage/make.conf
```

Set the compile flags
```
COMMON_FLAGS="-march=native -O2 -pipe"
CFLAGS="${COMMON_FLAGS}"
CXXFLAGS="${COMMON_FLAGS}"
```

Set USE and other options
You can see all available USE parameters on this [index](https://www.gentoo.org/support/use-flags/).
```
USE="<add flags that you need>"
MAKEOPTS="-j12" # 12 car 12CPU
LINGUAS="fr" #Langue (anciennement)
L10N="fr" #Langue
VIDEO_CARDS="fbdev vesa intel i915 nvidia nouveau radeon amdgpu radeonsi virtualbox vmware" #Adatp with your grafic card. Keep fbdev et vesa.
INPUT_DEVICES="libinput synaptics keyboard mouse evdev wacom"
EMERGE_DEFAULT_OPTS="${EMERGE_DEFAULT_OPTS} --quiet-build=y" # Remove verbose compilation output
```

### Select mirrors
```bash
mirrorselect -i -o >> /mnt/gentoo/etc/portage/make.conf
```
Then copy Gentoo repo list
```bash
mkdir -p /mnt/gentoo/etc/portage/repos.conf
cp /mnt/gentoo/usr/share/portage/config/repos.conf /mnt/gentoo/etc/portage/repos.conf/gentoo.conf
```

### Setup DNS
You can copy the LiveCD DNS settings or just edit ``/etc/resolv.conf`` yourself.
```bash
cp -L /etc/resolv.conf /mnt/gentoo/etc/
```

### Chroot
Chroot in the new system
```bash
chroot /mnt/gentoo /bin/bash
```

Update environment variables
```bash
env-update && source /etc/profile
```

*OPTIONAL* Customize prompt to show that we are chrooted
```bash
export PS1="[chroot] $PS1"
```

### Portage
Configure portage package list
```bash
emerge-webrsync
```

Select profile
```bash
eselect profile list

eselect profile set <choose the correct number>
```

Update @world
```bash
emerge -avuDN @world
```

### Locales
Set and generate system locale (``fr_FR.UTF-8 UTF-8`` in my case)
```bash
nano -w /etc/locale.gen

locale-gen
```

Set portage locale
```bash
eselect locale list

eselect locale set <choose the correct number>
```

Configure keyboard layout for TTY (``keymap="fr"`` in my case)
```bash
nano -w /etc/conf.d/keymaps
```

Update environment
```bash
env-update && source /etc/profile && export PS1="[chroot] $PS1"
```

### Timezone
Setup timezone (for France in my case)
```bash
echo "Europe/Paris" > /etc/timezone
```

Configure timezone package
```bash
emerge --config sys-libs/timezone-data
```

You can check date with the ``date `` command.

### Fstab
```bash
nano -w /etc/fstab
```
And put the following
```
/dev/mapper/cryptroot      /               ext4            defaults,noatime         0 1
/dev/mapper/cryptboot      /boot           vfat            defaults,noatime         0 0
/dev/mmcblk0p1             /boot/EFI       vfat            defaults                 0 0
```

### Crypttab
```bash
nano -w /etc/crypttab
```
And put the following
```
# Mount /dev/mmcblk0p2 as /dev/mapper/boot using LUKS, with a passphrase stored in a file.
boot /dev/mmcblk0p2       /root/boot.key
```

### Kernel
Install kernel sources
```bash
emerge -a gentoo-sources
```

Navigate into sources directory
```bash
cd /usr/src/linux
```

Clean older sources
```bash
make mrproper
```

Configure kernel options
```bash
make menuconfig
```

**IMPORTANT**
The following kernel options are required for this setup:
- ext4 filesystem
- systemd
- dmcrypt
- USB/SD card/removable device support


```bash

```

```bash

```

```bash

```

```bash

```

```bash

```

```bash

```

```bash

```

```bash

```

```bash

```

```bash

```

```bash

```

```bash

```

```bash

```

```bash

```

```bash

```

```bash

```

```bash

```

```bash

```

```bash

```

```bash

```

```bash

```

```bash

```

```bash

```
