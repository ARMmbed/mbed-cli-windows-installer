# mbed CLI Windows Installer

This repository contains the source files to build the mbed CLI Windows installer. See the [releases page](https://github.com/ARMmbed/mbed-cli-windows-installer/releases/latest) for downloads.

## Supported platforms

* Windows 7 and above

## Setup

1. Install NSIS, which can be found at [nsis.sourceforge.net](http://nsis.sourceforge.net/Download).
2. Download this repository.
3. Download prerequisites manually or run following powershell script.

```
$ cd prerequisites
$ powershell -ExecutionPolicy ByPass -File download-prerequisites.ps1
```

4. Open NSIS, click 'Compile NSI Scripts'.
5. Click 'File > Load Script' and select `source/cliInstall.nsi`.
6. Click 'Test installer' to build (output directory is `source`).

## Process

* Install the mbed CLI dependencies - Python, GCC, Mercurial, Git and the mbed Serial Driver - and then mbed CLI 1.4.0 from source.
* Contains two installer types:
  * Default: Installs all dependencies.
  * Advanced: Allows to select dependencies.

## Silent Install

```
$ cd source
$ mbed_installer_{version}.exe /S
```

## Using mbed_install_vX.x.x

1. Download the [latest release of the mbed CLI Windows installer](https://github.com/ARMmbed/mbed-cli-windows-installer/releases/latest). 
2. Run `mbed_installer_vX.X.X.exe` - and click through the wizard.
3. Open windows command prompt.
4. Use `mbed import mbed-os-example-blinky` to import an example program.


**Manual installation:** You can install mbed CLI also by hand. See the [mbed CLI repository](https://github.com/ARMmbed/mbed-cli#installing-mbed-cli).

## Updating pre-requisites

When needed, you can update the gcc, cmake, or other dependencies by updating the executables in `/prerequisites/*` and then the equivalent lines in the `Config Section` of `/source/mbedInstall.nsi` . 

## License

mbed CLI Windows Installer is licensed under Apache-2.0


