# Fix sd card reader using custom  mkinit hook

Create file ``/etc/initcpio/install/fixsdcard`` with this content:
```
#!/bin/bash

build() {

        rmmod sdhci_pci
        rmmod sdhci
        modprobe sdhci debug_quirks2="0x80000000"
        modprobe sdhci_pci

}

help() {}
```

Then add this custom hook to mkinicpio config.
