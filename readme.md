This repo contains the source files used to build the yotta windows installer .msi

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
2) go to `source/yottaInstall.nsi` <br>
3) right click and select `Compile NSIS Script` (optionally add compression) <br>
4) thats it, you should have a nice .msi to run on windows (unless you have build errors, then sort those out.)

## Using yotta_install_vX.x.x
Run the `yotta_installer_vX.X.X.msi` file, click through with default settings, then open Run_yotta.bat (on the dekstop or in the start menu), use yotta!
Note: on fresh windows systems you will need to open explorer before installing to update your ssl certificates, otherwise you may not be able to download all dependencies properly from pip, resulting in a botched yotta install.

## Updating pre-requisites
When needed, you can update the gcc, cmake, or other dependencies by updating the executables in `/prerequisites/*` and then the equivalent lines in the `Config Section` of `/source/yottaInstall.nsi` .
