# mbed CLI Windows Installer

This repository contains the source files to build the mbed CLI Windows installer. See the [releases page](https://github.com/ARMmbed/mbed-cli-windows-installer/releases/latest) for downloads.

## Setup

1. Install NSIS, which can be found at [nsis.sourceforge.net](http://nsis.sourceforge.net/Download).
2. Download this repository.
3. Download prerequisites all run following powershell script to download them.

```
$ cd prerequisites
$ powershell -ExecutionPolicy ByPass -File download-prerequisites.ps1
```

4. Open NSIS, click 'Compile NSI Scripts'.
5. Click 'File > Load Script' and select `source/cliInstall.nsi`.
6. Click 'Test installer' to build (output directory is `source`).

## Process

* Install the mbed CLI dependencies - Python, GCC, Mercurial, Git and the mbed Serial Driver - and then mbed CLI itself.
* A new environment variable called `MBED_PATH` is added. This environment variable contains the path to `c:\mbed-cli\*` where all the dependencies are installed.
* A shortcut is added to the desktop that sets `PATH = MBED_PATH + PATH` and then runs the command line. This was the easiest way to install mbed CLI without clobbering the users PATH variable and is based on how GCC installes on Windows.

## Using mbed_install_vX.x.x

1. Download the [latest release of the mbed CLI Windows installer](https://github.com/ARMmbed/mbed-cli-windows-installer/releases/latest). 
1. Run `mbed_installer_vX.X.X.exe` - and click through the wizard.
1. Click the 'Run mbed CLI' icon on your desktop or from the start menu.
1. A command prompt opens which has mbed CLI instantiated. Use `mbed import mbed-os-example-blinky` to import an example program.

**Note on fresh Windows systems:** When installing mbed CLI on a fresh Windows machine, you will need to open Windows Explorer once to upgrade your SSL certificates. If you fail to do so, pip - the Python package manager - cannot install dependencies properly.

**Note when you experience issues:** If you experience issues using mbed CLI, try re-installing with administrator permissions. If you still run into problems,  please [submit an issue](https://github.com/armmbed/mbed-cli-windows-installer/issues) with details on your OS version, and a a listing of what files are in the `c:\mbed-cli\` folder. 

**Manual installation:** You can install mbed CLI also by hand. See the [mbed CLI repository](https://github.com/ARMmbed/mbed-cli#installing-mbed-cli).

## Updating pre-requisites

When needed, you can update the gcc, cmake, or other dependencies by updating the executables in `/prerequisites/*` and then the equivalent lines in the `Config Section` of `/source/mbedInstall.nsi` . 

## License

mbed CLI Windows Installer is licensed under Apache-2.0

## Contributions / Pull Requests

All contributions are Apache 2.0. Only submit contributions where you have authored all of the code. If you do this on work time make sure your employer is OK with this.

