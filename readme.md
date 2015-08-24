This repo contains the source files used to build the yotta windows installer .msi

## System Details
The system uses the NSIS system, which can be found at [nsis.sourceforge.net](http://nsis.sourceforge.net/Download)

## Purpose
To make installing yotta on windows easier

## Process
* The install process installs the yotta dependencies and then yotta itself. 
* A new environment variable called `YOTTA_PATH` is added, this contains the path to `c:\program files\yotta\` where all the dependency source files live.
* A shortcut is added to the desktop that sets `PATH = YOTTA_PATH + PATH` and then runs the command line. This was the easiest  way to install yotta without clobbering the users PATH variable.

## How to use
1) install nsis <br>
2) go to source/yottaInstall.nsi <br>
3) right click and select `Compile NSIS Script` (optionally add compression) <br>
4) thats it, you should have a nice .msi to run on windows (unless you have build errors, then sort those out.)

## Updating pre-requisites
When needed, you can update the gcc, cmake, or other dependencies by updating the executables in `/prerequisites/` and then the equivalent lines in the `Config Section` of yottaInstall.nsi .
