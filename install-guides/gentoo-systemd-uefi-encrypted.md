# Gentoo Systemd UEFI Encrypted

## Features
- UEFI partition
- Systemd as init system
- plain dm-crypt encryption on main drive
- main disk encryption keyfile on removable device
- boot partition on removable device
- encrypted boot partition with passphrase

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
```
```bash

```

## System installation

```bash
cd /mnt/gentoo
```

```bash
wget https://bouncer.gentoo.org/fetch/root/all/releases/amd64/autobuilds/20210221T214504Z/stage3-amd64-systemd-20210221T214504Z.tar.xz
```
*Update the link with a more recent version*

```bash

```

```bash

```
