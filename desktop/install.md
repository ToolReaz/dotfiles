# Install

## Drives layout used
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
