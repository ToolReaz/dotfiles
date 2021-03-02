# Archlinux UEFI Encrypted with Secure Boot

![WIP logo](https://img.shields.io/badge/STAUS-WIP-red?style=for-the-badge&logo=gentoo)

## Features
- UEFI
- plain dm-crypt encryption on main drive
- main disk encryption keyfile on removable device
- encrypted boot partition on removable device
- secure boot with signed kernel and boot loader

## Drives layout used in this guide
```
+-------------------------+ +----------------+-----------------------+-----------------+------------------+
| Root partition          | | EFI partition  | Boot partition        | Key of /dev/sda | Optional storage |
|                         | |                |                       |                 |                  |
| /                       | | /boot/efi      | /boot                 |                 |                  |
|                         | |                |                       |                 |                  |
| /dev/mapper/cryptroot   | | /dev/mmcblk0p1 | /dev/mapper/cryptboot | /dev/mmcblk0p3  | /dev/mmcblk0p4   |
|-------------------------| |----------------------+----------------------+-------------------------------|
| /dev/sda dm-crypt plain | | Removable SD card /dev/mmcblk0                                              |
+-------------------------+ +-----------------------------------------------------------------------------+
```
*If you use an USB stick as removable device you will probably see it under ``/dev/sdb``.*

## Preparations

### General steps
[Refer to this general tips](https://github.com/ToolReaz/dotfiles/master/install-guides/general-tips)

### Disk
For security reason it is advise to fill your main drive (that will be encrypted) with random data. This way it won't be possible to recover any data from your previous installation.

```bash
dd if=/dev/urandom of=/dev/sda bs=4M status=progress
```

***/!\ This will permanently erase all your data /!\


## Paritionning
### Removable device
```bash
cgdisk /dev/mmcblk0
```
Create the partition as follow:
```
/dev/mmcblk0p1    size 100M, type ef00, name EFI
/dev/mmcblk0p2    size 1G, type default, name BOOT
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
cryptsetup --cipher=aes-xts-plain64 --offset=<number> --key-file=/dev/mmcblk0p3 --keyfile-offset=<number> --key-size=512 open --type plain /dev/sda cryptroot
```

```bash
mkfs.ext4 /dev/mapper/cryptroot
```

## Mount filesystem tree
```bash
mount /dev/mapper/cryptroot /mnt

mkdir /mnt/boot
mount /dev/mapper/cryptboot /mnt/boot

mkdir /mnt/boot/efi
mount /dev/mmcblk0p1 /mnt/boot/efi
```

## Install the system


Select mirrors: ``nano /etc/pacman.d/mirrorlist``

### Download base system and packages
```bash
pacstrap /mnt base linux linux-firmware nano sudo grub efibootmgr git
```

### Generate fstab
```bash
genfstab -U /mnt >> /mnt/etc/fstab
```

### Chroot into new system
```bash
arch-chroot /mnt
```

### Set clock
Choose your Region and City
```bash
ln -sf /usr/share/zoneinfo/Region/City /etc/localtime
```
Update hardware clock
```bash
hwclock --systohc
```

### Configure locale
Edit the file ``nano /etc/locale.gen`` and uncomment your language (in UTF8)
```bash
nano /etc/locale.gen
locale-gen
```
Then set language in other configuration files (update the example with your language)
```bash
echo "LANG=fr_FR.UTF-8" >> /etc/locale.conf
echo "LANGUAGE=fr_FR" >> /etc/locale.conf
echo "KEYMAP=fr-latin1" >> /etc/vconsole.conf
```

### Network
Set the hostname
```bash
echo "myhostname" > /etc/hostname
```
Configure local address by editing ``/etc/hosts`` and put this content
```bash
127.0.0.1	localhost
::1		    localhost
```

### User
Change the root password
```bash
passwd
```
Add a new user and change his password
```bash
useradd -m -G wheel -s /bin/bash myuser
passwd myuser
```
Add it in the sudoer file
```bash
EDITOR=nano visudo
Uncomment line %wheel ALL=(ALL) ALL
```


### Crypttab
Generate a new keyfile for boot partition
```bash
dd if=/dev/urandom of=/root/boot.key bs=1M count=1
cryptsetup luksAddKey /dev/mmcblk0p2 /root/boot.key
chmod 400 /root/boot.key
```

Edit crypttab
```bash
nano -w /etc/crypttab
```
And put the following
```
# Mount /dev/mmcblk0p2 as /dev/mapper/cryptboot using LUKS, with a passphrase stored in a file.
cryptboot /dev/mmcblk0p2 /root/boot.key luks
```


### Encrypt hook
Edit file ``/etc/mkinitcpio.conf`` and change the following values:
```
HOOKS=(base udev autodetect keyboard keymap consolefont modconf block encrypt filesystems fsck)
```
Then rebuild initramfs: ``mkinitcpio -p linux``

### Boot manager
Configure grub by editing ``/etc/default/grub``
```
GRUB_CMD_LINUX="cryptdevice=/dev/sda:cryptroot cryptkey=/dev/mmcblk0p3:<key-offset>:64 crypto=:aes-xts-plain64:512:0: quiet"

GRUB_ENABLE_CRYPTODISK=y
```

Then generate the configuration
```bash
grub-mkconfig -o /boot/grub/grub.cfg
```

Then install Grub
```bash
grub-install --target=x86_64-efi --efi-directory=/boot/efi --bootloader-id="MYGRUB"
```

### Finish
Now you can exit the chroot, unmount everything and reboot.
Don't forget to remove installation media when rebooting !
```
exit
umount -R /mnt
reboot
```

```bash

```
