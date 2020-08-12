# HOW TO - ArchLinux install with encryptedf LUKS header and boot partition on removable media (UEFI)

## Prepare installation media
Follow official wiki: https://wiki.archlinux.org/index.php/Installation_guide#Pre-installation

## Format external media
In my case i use an SDcard (mmcblkX) but you can use USB drive (sdX)

```cgdisk /dev/mmcblk0```

Create the partitions as follow:
```
EFI Partition: Size: 100M, Hex Code: ef00, Name: ESP

Boot Partition: 1G, Hex Code: default (8300), Name: Boot

Storage on remaining space (optional): Hex Code: default (8300), Name: Storage
```

Format storage partition (optional):
```mkfs.fat -F32 /dev/mmcblk0p3```