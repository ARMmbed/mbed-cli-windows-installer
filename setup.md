# mbed CLI for Windows Installer

mbed CLI for Windows installs [mbed CLI](https://github.com/ARMmbed/mbed-cli) with all requirements on Windows 7 and above.

## Supported platforms

* Windows 7 and above (both version 32 and 64 bit)

## List of Components
mbed CLI for Windows installs following components:

* **Python** - mbed CLI is a Python script, so you'll need Python to use it. Installers installs [version 2.7.13 of Python](https://www.python.org/downloads/release/python-2713/). It is not compatible with Python 3.

* **mbed CLI version 1.1.1** - [mbed CLI](https://github.com/ARMmbed/mbed-cli)  

* **Git and Mercurial** - mbed CLI supports both Git and Mercurial repositories. Both Git and Mercurial are being installed. (`git` and `hg`) are added to system's PATH
    * [Git](https://git-scm.com/) - version 2.12.2.
    * [Mercurial](https://www.mercurial-scm.org/) - version 4.1.1.

* **GNU ARM Embedded Toolchain** - [GNU Embedded Toolchain for ARM](https://developer.arm.com/open-source/gnu-toolchain/gnu-rm/downloads)
    
* **mbed Windows serial port driver** - [serial port driver](https://developer.mbed.org/handbook/Windows-serial-configuration)

## Installation
1. Download the latest executable from : [mbed-windows-installer v0.4.1](https://mbed-media.mbed.com/filer_public/7f/46/7f46e205-52f5-48e2-be64-8f30d52f6d75/mbed_installer_v041.exe)
2. Run mbed_installer_v041.exe.
3. Set installation path.
4. Choose installation type:
  * Default: Installs all components.
  * Advanced: Allows to select components.
5. Installer installs all selected components. Close it after it finishes. 

### Silent Install

Installer can be executed silently without user interaction. Add `/S` flag in windows command prompt during installation. 

```
$ mbed_installer_{version}.exe /S
```
## Usage
1. Open Windows command prompt.
2. Run: 

```
$ mbed
```

3. To see help:

```
$ mbed --help
```

4. Check [mbed CLI](https://github.com/ARMmbed/mbed-cli) for more examples.

## Uninstallation
* mbed CLI for Windows can be uninstalled either from `Programs and Features` or directly by running `mbed_uninstall.exe` located in istallation folder.
* **Important** Uninstaller uninstalls only mbed CLI and mbed Windows serial port driver. Python, Git, Mercurial and GNU ARM Embedded Toolchain have seperate uninstallers and can be uninstalled seperately.
