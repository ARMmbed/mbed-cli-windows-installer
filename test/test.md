# Test mbed cli windows installer

## Supported Platforms
platforms: Windows 7(32, 64 bit), Windows 8(32, 64 bit), Windows 8.1(32, 64 bit), Windows 10(32, 64 bit)

## Test scenarios
### Install on a fresh system.

Initial setup:
- no python, no mercurial, no git, no mbed-cli, no serial drivers
Steps: 
1. Install mbed-cli with all default extras and FRDM-k64F board. 
2. Test mbed-cli by running blinky on k64f board.
3. Uninstall mbed-cli using uninstaller.

### Run installation with mbed-cli already installed using manual steps.

Initial setup:
- Install mbed-cli manually using official steps.
Steps: 
1. Install mbed-cli with all default extras and FRDM-k64F board. 
2. Test mbed-cli by running blinky on k64f board.
3. Uninstall mbed-cli using uninstaller.

### Run installation on machine with mercurial and git already installed

Steps: 
1. Install mbed-cli with all default extras and FRDM-k64F board. 
2. Test mbed-cli by running blinky on k64f board.
3. Uninstall mbed-cli using uninstaller.

### Run installation on Windows with UAC set to “Always notify me and wait for my response.”
1. Install mbed-cli with all default extras and FRDM-k64F board. 
2. Test mbed-cli by running blinky on K64F board.
3. Uninstall mbed-cli using uninstaller.

### Test update
1. Install mbed-cli version 0.3.5
2. Install mbed-cli version 0.3.6

### Test Advanced component functionality
1. Install subset of components.

### Install mbed-cli on machine with python version lower than 2.7
1. Install python 2.6
2. Run mbed-cli windows installer

### Install mbed-cli on machine with python version equals to 2.7.12
1. Install python 2.7.12
2. Run mbed-cli windows installer

### Install mbed-cli on machine with python version 3.6
1. Install python 3.6
2. Run mbed-cli windows installer
