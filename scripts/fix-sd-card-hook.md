# Fix sd card reader using custom  mkinit hook

Create file ``/etc/initcpio/install/fixsdcard`` with this content:
```
#!/bin/bash

build() {

        add_module sdhci debug_quirks2="0x80000000"
        add_module sdhci_pci

}

help() {
        cat <<HELPEOF
This custom hook fix sd card reader on some laptop.
HELPEOF
}
```

Then add this custom hook to mkinicpio config.
