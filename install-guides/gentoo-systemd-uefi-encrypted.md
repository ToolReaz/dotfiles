# Gentoo Systemd UEFI Encrypted

![WIP logo](https://img.shields.io/badge/STAUS-ABANDONED-red?style=for-the-badge&logo=gentoo)

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

## Preparations
### Installation media
I actually prefer installing Gentoo using the Archlinux live CD because it's more convinient and provided useful tools such as: genfstab, arch-root, systemd.
First download the live installation CD.
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
Otherwise if you are using WiFi you can use ``net-setup`` on Gentoo CD.
On Archlinux CD use:
```bash
iwctl
device list
station <device> scan
station <device> get-networks
station <device> connect <SSID>
quit
```

### *TIPS SSH*
You can do the installation remotely. It can be usefull for copy/pasting the commands from this tutorial.
Simply configure the root password with ``passwd`` command then print the IP address with ``ip a`` and finaly start the ssh daemon ``/etc/init.d/sshd start``.
Now you can connect from your remote machine.

## Paritionning
### Removable device
```bash
cgdisk /dev/mmcblk0
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

## Install system

### Get the stage3
```bash
cd /mnt
```

```bash
wget <your desired stage3 archive>

tar xJvpf stage3-*.tar.xz --xattrs
```

### Configure portage
```bash
nano -w /mnt/etc/portage/make.conf
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
ACCEPT_LICENSE="*"
```

### Select mirrors
```bash
mirrorselect -i -o >> /mnt/etc/portage/make.conf
```
Then copy Gentoo repo list
```bash
mkdir -p /mnt/etc/portage/repos.conf
cp /mnt/usr/share/portage/config/repos.conf /mnt/etc/portage/repos.conf/gentoo.conf
```

### Generate fstab
```bash
genfstab -U /mnt >> /mnt/etc/fstab
```

### Chroot
Chroot in the new system
```bash
arch-chroot /mnt
source /etc/profile
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
echo "KEYMAP=fr-latin1" >> /etc/vconsole.conf
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

### Crypttab
Install cryptsetup
```bash
emerge --ask sys-fs/cryptsetup
```

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
# Mount /dev/mmcblk0p2 as /dev/mapper/boot using LUKS, with a passphrase stored in a file.
boot /dev/mmcblk0p2 /root/boot.key luks
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

Then save and compile (adapt the numbrer of jobs depending on your number of cores and RAM size)
```bash
make -j4
```

Install modules
```bash
make modules_install
```

Install kernel
```bash
make install
```

### Initramfs

// TODO

```bash
emerge --ask sys-kernel/genkernel
genkernel --install --keymap --luks --mountboot --kernel-config=/usr/src/linux/.config initramfs

```

### Users

```bash
passwd

useradd -m -G wheel -s /bin/bash myuser
passwd myuser

emerge --ask app-admin/sudo
EDITOR=nano visudo
Uncomment line %wheel ALL=(ALL) ALL
```

### Network
```bash
echo "myhostname" > /etc/hostname

nano /etc/hosts
127.0.0.1	localhost
::1		    localhost
127.0.1.1	myhostname.localdomain	myhostname
```

### Grub

```bash
echo 'GRUB_PLATFORMS="efi-64"' >> /etc/portage/make.conf
echo "sys-boot/grub:2 device-mapper fonts efiemu mount themes" > /etc/portage/package.use/custom.use
emerge --ask --verbose sys-boot/grub:2
```

Edit file ``/etc/default/grub``
```bash
GRUB_CMD_LINUX="cryptdevice=/dev/sda:cryptroot cryptkey=/dev/mmcblk0p3:<keyfile-offset>:64 crypto=:aes-xts-plain64:512:0: quiet"
GRUB_ENABLE_CRYPTODISK=y
```
Then
```bash
grub-mkconfig -o /boot/grub/grub.cfg
grub-install --target=x86_64-efi --efi-directory=/boot/efi --bootloader-id="MYGRUB"
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
