# HOW TO - Install Office 2016 with wine

Working guide: https://appdb.winehq.org/objectManager.php?sClass=version&iId=35527

First, get the OfficeSetup.exe in 32 bits format.

Requiered packages:
```bash
sudo pacman -S cabextract zenity
```
Setup wine:
```bash
WINEPREFIX=win32 wine winecfg

WINEPREFIX=win32 winetricks -q riched20 riched 30 msxml6 msxml3

WINEPREFIX=win32 wine regedit
```

Modify the following registry keys:
HKCU/Software/Wine/ Right click add Key Direct2D and Direct3D
In Direct2D right click, add DWORD value name it max_version_factory set it to 0 
In Direct3D add DWORD value name it MaxVersionGL and set it to 30002

Installation:
```bash
WINEPREFIX=win32 wine OfficeSetup.exe
```

Post install fixs:
```bash
cp .wine/drive_c/Program\ Files/Common\ Files/Microsoft\ Shared/ClickToRun/* .wine/drive_c/Program\ Files/Microsoft\ Office/root/Office16/

cp .wine/drive_c/Program\ Files/Common\ Files/Microsoft\ Shared/ClickToRun/* .wine/drive_c/Program\ Files/Microsoft\ Office/root/Client/

```
