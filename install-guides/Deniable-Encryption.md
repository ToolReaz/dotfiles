# HOW TO - ArchLinux deniable inscription install

In this guide ``sda`` will refer to the main computer's hard drive on which I install the encrypted system. ``mmcblk0`` will refer to a SD card containing the encryption key and the boot loader (but you can use an USB stick and replace with ``sdb``).

## Summary
- [Prerequistes](#prerequistes)
  + [Prepare installation media](#prepare-installation-media)
  + [Prepare the computer](#prepare-the-computer)
  + [Set keymap](#set-keymap)
  + [Connect to WiFi](#connect-to-wifi)
- [Preparing drives](#preparing-drives)
  + [Format external media](#format-external-media)
  + [Format partitions](#format-partitions)
  + [Create the encryption key](#create-the-encryption-key)
  + [Prepare the main disk](#prepare-the-main-disk)
  + [Mount filesystem tree](#mount-filesystem-tree)
  + [Installation procedure](#installation-procedure)
  + [Encrypt hook](#encrypt-hook)
  + [Boot manager](#boot-manager)
  + [Finish](#finish)
- [Troubleshooting](#troubleshooting)

## Prerequistes
### Prepare installation media
Follow official wiki: https://wiki.archlinux.org/index.php/Installation_guide#Pre-installation

### Prepare the computer
Start the computer, enter in the BIOS menu and ensure those settings are correctly set:
- Secure boot dezsibaled
- UEFI boot mode ena bled
- Legacy boot disabled
- USB  or SD card supports activated

*(Settings names and locations can vary depeding on your hardware)*

Then plug the installalation media and boot your computer on the live image.

### Set keymap
If you are not using the default US keymap you can change the layout liek this:
```loadkeys fr```

### Connect to WiFi
If you use ethernet cable, you should automaticaly have internet connection, otherwise configure wifi:

As explained here: https://wiki.archlinux.org/index.php/Iwd#iwctl
```
iwctl
device list
station device scan
station device get-networks
station device connect <SSID>
quit
```

## Preparing drives  
### Format external media
First, format the external media. Create partition for boot, create the key and even a partition for storage with the remaining space.

```cgdisk /dev/mmcblk0```

Create the partitions as follow:
```
BOOT Partition: Size: 1G, Hex Code: ef00, Name: BOOT

KEY Partition: Size: 200M, Hex Code: default (8300)

(Optional) Storage on remaining space: Hex Code: default (8300), Name: Storage
```

> *WARNING: sometimes you can find tutorial on which they also create an UEFI/EFI partition. I didn't do it here because my BIOS can still detect EFI entries this way. You may need to adapt this setup to your needs.*

### Format partitions
Format the boot loader partition in FAT32
```
mkfs.fat -F32 /dev/mmcblk0p1
```

(Optional) Format the storage partition in FAT32 (you can choose another filesystem)
```
mkfs.fat -F32 /dev/mmcblk0p3
```

### Create the encryption key
We fill the entire key partition with random bits that we will use as the key
```
dd if=/dev/urandom of=/dev/mmcblk0p2 status=progress
```

### Prepare the main disk
This command will encrypt the drive unsing the key we generated before and then create a mapping drive called ``cryptroot``.

Parameters meaning:
- cipher: the algorithm used to encrypt datas
- offset:  the number of bytes to leave at the beginning of the drive before writing encrypted datas
- key-file: the path to the keyfile (you can also use ``/dev/disk/by-id/<diskanme>`` format)
- keyfile-offset: number of byte before starting to read keyfile on the partition
- key-size: size in the key in bits (depends on cipher algorithm)
- type plain: specify using plain dm-crypt instead of luks

```
cryptsetup --cipher=aes-xts-plain64 --offset=0 --key-file=/dev/mmcblk0p2 --keyfile-offset=4096 --key-size=512 open --type plain /dev/sda cryptroot 
```

Then we can format the encrypted drive using the mapped drive:
```
mkfs.ext4 /dev/mapper/cryptroot
```

> *WARNING: remember which parameters you typed in this command ! You will need them later !*

### Mount filesystem tree
Once all partition formated, mount everything
```
mount /dev/mapper/cryptroot /mnt

mkdir /mnt/boot

mount /dev/mmcblk0p1 /mnt/boot
```

> *WARNING: if you create a dedicated EFI partition, create ``/boot/efi`` directory and mount it inside*

### Installation procedure
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

echo "myhostname" > /etc/hostname

nano /etc/hosts
127.0.0.1	localhost
::1		    localhost
127.0.1.1	myhostname.localdomain	myhostname

passwd

useradd -m -G wheel -s /bin/bash myuser
passwd myuser

EDITOR=nano visudo
Uncomment line %wheel ALL=(ALL) ALL
```

### Encrypt hook
Edit file ``/etc/mkinitcpio.conf`` and change the following values:
```
HOOKS=(base udev autodetect keyboard keymap consolefont modconf block encrypt filesystems fsck)
```
Then rebuild initramfs: ``mkinitcpio -P``

### Boot manager
Install grub: ``grub-install --target=x86_64-efi --efi-directory=/boot --bootloader-id="MYGRUB"``

> *WARNING: if you created a dedicated EFI partition use ``/boot/efi`` for efi-directory*

Edit file ``/etc/default/grub`` and setup **GRUB_CMD_LINUX** like this:
```
GRUB_CMD_LINUX="cryptdevice=<path>:<mapper-name> cryptkey=<path>:<keyfile-offset>:<key-size-in-bytes> crypto=<hash>:<cipher>:<key-size-in-bytes>:<offset>:<other> quiet"
```

With the values used before in this guide it's:
```
GRUB_CMD_LINUX="cryptdevice=/dev/sda:cryptroot cryptkey=/dev/mmcblk0p2:4096:64 crypto=:aes-xts-plain64:512:0: quiet"
```

> *WARNING: notice that the key size is in **BYTES** not in **BITS** ! So you need to devide it by **8** !

Then run: ``grub-mkconfig -o /boot/grub/grub.cfg``

### Finish
Now you can exit the chroot, unmount everything and reboot.
Don't forget to remove installation media when rebooting !
```
exit
umount -R /mnt
reboot
```

## Troubleshooting

> TODO