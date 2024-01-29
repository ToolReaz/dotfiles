# Install

## Connect to wifi

```
iwctl
device list
station device scan
station device get-networks
station device connect <SSID>
quit
```

## Format disk

``cgdisk /dev/nvme0n1``

```
EFI Partition: Size: 1G, Hex Code: ef00, Name: EFI

ROOT Partition: Size: Remaining, Hex Code: default (8300) Name: ROOT
```

## Encrypt root partition

As of 2024/01/29 the following command uses: luks2, aes-xts-plain64, sha256 hash, 256 bits key size and argon2id as pbkdf.

```bash
cryptsetup luksFormat /dev/nvme0n1p2
cryptsetup luksOpen /dev/nvme0n1p2 cryptroot
```

## Format partitions

```bash
mkfs.fat -F32 /dev/nvme0n1p1
mkfs.ext4 /dev/mapper/cryptroot
```

## Mount filtesystem
```bash
mount /dev/mapper/cryptroot /mnt
mkdir /mnt/boot
mount /dev/nvme0n1p1 /mnt/boot
```

## Install stytem
```bash
pacstrap -K /mnt base linux linux-firmware nano man-db man-pages texinfo amd-ucode bash networkmanager wpa_supplicant git bash-completion sudo
genfstab -U /mnt >> /mnt/etc/fstab
arch-chroot /mnt
ln -sf /usr/share/zoneinfo/Europe/Paris /etc/localtime
hwclock --systohc
```

### Language
Edit ``/etc/locale.gen`` and uncomment ``en_US.UTF-8 UTF-8`` or other locale and then run ``locale-gen``.
Edit ``/etc/locale.conf`` and add ``LANG=en_US.UTF-8``

### Users
```bash
passwd
useradd -m -G wheel -s /bin/bash myuser
passwd myuser
```
Allow myuser with ``EDITOR=nano visudo`` and uncomment line ``%wheel ALL=(ALL) ALL``

### Network
Change hostname ine ``/etc/hostname``

### Initramfs
Add the ``encrypt`` hook before the ``fylesystems`` hook in ``/etc/mkinitcpio.conf``
Then regenerate initramfs with ``mkinitcpio -P``

### Boot loader
Install **systemd-boot** with ``bootctl install``
Edit file ``/boot/loader/loader.conf`` and add line:
```
default  arch.conf
timeout  4
console-mode max
editor   no
```
Then create file ``/boot/loader/entries/arch.conf`` with:
```
title   Arch Linux
linux   /vmlinuz-linux
initrd  /intel-ucode.img
initrd  /initramfs-linux.img
options cryptdevice=UUID=xxxxxxx:cryptroot root=/dev/mapper/cryptroot quiet rw
```
### Finish
```bash
exit
umount -R /mnt
reboot
```
