#!/bin/bash

# Fix SDcard mmcblk I/O error in ArchLinux live ISO

rmmod sdhci_pci
rmmod sdhci
modprobe sdhci debug_quirks2="0x80000000"
modprobe sdhci_pci
