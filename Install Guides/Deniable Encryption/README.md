# HOW TO - ArchLinux install with encryptedf LUKS header and boot partition on removable media (UEFI)

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

## Create the partitions as follow:
```
EFI Partition: Size: 100M, Hex Code: ef00, Name: ESP

BOOT Partition: 1G, Hex Code: default (8300), Name: Boot

Storage on remaining space (optional): Hex Code: default (8300), Name: Storage
```

## Format storage partition (optional):
```
mkfs.fat -F32 /dev/mmcblk0p3
```

## Encrypt BOOT partition:
```
cryptsetup luksFormat /dev/mmcblk0p2
cryptsetup open /dev/mmcblk0p2 cryptboot
mkfs.vfat /dev/mapper/cryptboot
```

```
mount /dev/mapper/cryptboot /mnt
dd if=/dev/urandom of=/mnt/key.img bs=64M count=1
cryptsetup luksFormat /mnt/key.img
cryptsetup open /mnt/key.img lukskey
```

## Main drive

```
truncate -s 16M /mnt/header.img
cryptsetup --key-file=/dev/mapper/lukskey --keyfile-offset=offset --keyfile-size=8192 luksFormat /dev/sda --offset 32768 --header /mnt/header.img

Pick an offset and size in bytes (8192 bytes is the maximum keyfile size for cryptsetup).

cryptsetup open --header /mnt/header.img --key-file=/dev/mapper/lukskey --keyfile-offset=offset --keyfile-size=size /dev/sda enc 
cryptsetup close lukskey
umount /mnt
```

```
mkfs.ext4 /dev/mapper/cryptroot
mount /dev/mapper/cryptroot /mnt
mkdir /mnt/boot
mount /dev/mapper/cryptboot /mnt/boot
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
passwrd toolreaz
EDITOR=nano visudo
Uncomment line %wheel ALL=(ALL) ALL
```

## Encrypt hook
```
ls /dev/disk/by-id/sda >> /etc/initcpio/hooks/customencrypthook
ls /dev/disk/by-id/mmcblk0-part2 >> /etc/initcpio/hooks/customencrypthook
nano /etc/initcpio/hooks/customencrypthook
cp /usr/lib/initcpio/install/encrypt /etc/initcpio/install/customencrypthook

nano /etc/mkinitcpio.conf
MODULES=(loop)
HOOKS=(base udev autodetect keyboard keymap modconf block customencrypthook filesystems fsck)

mkinitcpio -P
```

## Boot manager
```
grub-install --target=x86_64-efi --efi-directory=/boot --bootloader-id="MYGRUB"

nano /etc/default/grub
GRUB_ENABLE_CRYPTODISK=y
#GRUB_CMDLINE_LINUX_DEFAULT=...
GRUB_CMDLIN_LINUX="cryptdevice=/dev/sda:cryuptroot root=/dev/mapper/cryptroot quiet"

grub-mkconfig -o /boot/grub/grub.cfg
```

## Finish
```
exit
umount -R /mnt
reboot
```





mount /dev/mmcblk0p1 /mnt
truncate -s 16M /mnt/header.img
dd if=/dev/urandom of=/mnt/key.img bs=64M count=1

cryptsetup --key-file=/mnt/key.img --keyfile-offset=4096 --keyfile-size=8192 luksFormat /dev/sda --header /mnt/header.img

cryptsetup open --header /mnt/header.img --key-file=/mnt/key.img --keyfile-offset=4096 --keyfile-size=8192 /dev/sda cryptroot

umount /mnt
mkfs.ext4 /dev/mapper/cryptroot
mount /dev/mapper/cryptroot /mnt
mkdir /mnt/boot
mount /dev/mmcblk0p1 /mnt/boot

