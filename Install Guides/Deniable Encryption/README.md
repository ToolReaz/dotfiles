# HOW TO - ArchLinux install with plain dm-crypt and boot partition with key on removable media (UEFI)

## Prepare installation media
Follow official wiki: https://wiki.archlinux.org/index.php/Installation_guide#Pre-installation

## Connect to WiFi
As explained here: https://wiki.archlinux.org/index.php/Iwd#iwctl
```
iwctl
device list
station device scan
station device get-networks
station device connect SSID
quit
```

## Format external media
In my case i use an SDcard (mmcblkX) but you can use USB drive (sdX)

```cgdisk /dev/mmcblk0```

Create the partitions as follow:
```
BOOT Partition: Size: 1G, Hex Code: ef00, Name: BOOT

KEY Partition: Size: 200M, Hex Code: default (8300), Name: <name or nothing>

Storage on remaining space (optional): Hex Code: default (8300), Name: Storage
```

## Format storage partition (optional)
```
mkfs.fat -F32 /dev/mmcblk0p3
```

## Format BOOT partition
```
mkfs.fat -F32 /dev/mmcblk0p1
```

## Prepare KEY partition
```
dd if=/dev/urandom of=/dev/mmcblk0p2 status=progress
```

## Prepare the main disk
```
cryptsetup --cipher=aes-xts-plain64 --offset=0 --key-file=/dev/mmcblk0p2 --keyfile-offset=4096 --key-size=512 open --type plain /dev/sda cryptroot 

mkfs.ext4 /dev/mapper/cryptroot
```

## Mount filesystem tree
```
mount /dev/mapper/cryptroot /mnt

mkdir /mnt/boot

mount /dev/mmcblk0p1 /mnt/boot
```

## Installation procedure
Follow steps as explained here: https://wiki.archlinux.org/index.php/Installation_guide#Installation

Select mirrors: ``nano /etc/pacman.d/mirrorlist``

```
pacstrap /mnt base linux linux-firmware nano sudo grub efibootmgr git

genfstab -U /mnt >> /mnt/etc/fstab

arch-root /mnt

ln -sf /usr/share/zoneinfo/Region/City /etc/localtime
hwclock --systohc

nano /etc/locale.gen
locale-gen
echo "LANG=fr_FR.UTF-8" >> /etc/locale.conf
echo "LANGUAGE=fr_FR" >> /etc/locale.conf
echo "KEYMAP=fr-latin1" >> /etc/vconsole.conf

echo "hostname" > /etc/hostname

nano /etc/hosts
127.0.0.1	localhost
::1		    localhost
127.0.1.1	myhostname.localdomain	myhostname

passwd

useradd -m -G wheel -s /bin/bash username
passwd toolreaz

EDITOR=nano visudo
Uncomment line %wheel ALL=(ALL) ALL
```

## Encrypt hook
Edit file ``/etc/mkinitcpio.conf`` and et the following values:
```
HOOKS=(base udev autodetect keyboard keymap consolefont modconf block encrypt filesystems fsck)
```
Then rebuild initramfs: ``mkinitcpio -P``

## Boot manager
Install grub: ``grub-install --target=x86_64-efi --efi-directory=/boot --bootloader-id="GRUB"``

Edit file ``/etc/default/grub`` and et the following values:
```
GRUB_CMD_LINUX="cryptdevice=/dev/sda:cryptroot cryptkey=/dev/mmcblk0p2:4096:64 crypto=:aes-xts-plain64:512:0: quiet"
```
Then run: ``grub-mkconfig -o /boot/grub/grub.cfg``

## Finish
```
exit
umount -R /mnt
reboot
```