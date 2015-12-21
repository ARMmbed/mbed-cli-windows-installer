This repo contains the source files used to build the yotta windows installer .exe. For Downloads please see the [releases page](https://github.com/ARMmbed/yotta_windows_installer/releases/latest).

## System Details
This yotta installer is built using the NSIS system, which can be found at [nsis.sourceforge.net](http://nsis.sourceforge.net/Download)

## Purpose
The goal of this project is to make yotta install on windows a single step process.

## Process
* Install the yotta dependencies and then yotta itself. 
* A new environment variable called `YOTTA_PATH` is added, this contains the path to `c:\yotta\*` where all the dependencies are installed.
* A shortcut is added to the desktop that sets `PATH = YOTTA_PATH + PATH` and then runs the command line. This was the easiest  way to install yotta without clobbering the users PATH variable and is based on how GCC installes on windows.

## How to build installer
1) [install nsis](http://nsis.sourceforge.net/Download) <br>
    * Uses the [Nsisunz](http://nsis.sourceforge.net/Nsisunz_plug-in) plugin to handle unzipping prerequisites <br>
2) go to `source/yottaInstall.nsi` <br>
3) right click and select `Compile NSIS Script` (optionally add compression) <br>
4) thats it, you should have a nice .msi to run on windows (unless you have build errors, then sort those out.)

## Using yotta_install_vX.x.x
Download the [latest release of the yotta windows installer](https://github.com/ARMmbed/yotta_windows_installer/releases/latest). Run the `yotta_installer_vX.X.X.exe` file, click through with default settings, then open Run_yotta.bat (on the dekstop or in the start menu), use yotta!

- *QuickFix #1*: on fresh windows systems you will need to open explorer before installing to update your ssl certificates, otherwise you may not be able to download all dependencies properly from pip, resulting in a botched yotta install.

- *QuickFix #2*: If you yotta install has issues please try re-installing with admin permissions. If that fails please [submit an issue](https://github.com/armmbed/yotta_windows_installer/issues) with details on your OS version, and a a listing of what files are in the `c:\yotta\` folder. 

- *QuickFix #3*: If all else fails follow the [manual install instructions](http://yottadocs.mbed.com/#installing-on-windows).

## Updating pre-requisites
When needed, you can update the gcc, cmake, or other dependencies by updating the executables in `/prerequisites/*` and then the equivalent lines in the `Config Section` of `/source/yottaInstall.nsi` . 

## License
Yotta Windows Installer is licensed under Apache-2.0

## Contributions / Pull Requests
All contributions are Apache 2.0. Only submit contributions where you have authored all of the code. If you do this on work time make sure your employer is cool with this.

