#!/bin/bash

echo "options modprobe sdhci debug_quirks2=0x80000000" > /etc/modprob.d/sdhci-pci.conf
