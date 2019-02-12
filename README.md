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

4. Run makensis on the `source/install.nsi` with an output file.
```
$ makensis "/XOutFile Mbed_installer.exe" source/install.nsi
```
5. Test the installer that was just generated


## Sign installer using Arm license server

1. Set sign credentials, get url ID to upload installer

```
$ curl -H "Content-Type: application/json" -X POST -d "{\"username\": \"arkzal01\",\"vendor-url\":\"www.mbed.com\",\"description\":\"Mbed CLI Windows Installer\",\"cross-sign\":true,\"digest-algorithm\":\"sha2\"}" http://authenticode.euhpc.arm.com:8087/signed-items
```

2. Use url ID to upload installer exe and receive signed installer. This operation may take few minutes. Replace {url_id} in the following with the guid output by the above command.l ID to upload installer

```
$ curl -H "Content-Type: application/octet-stream" http://authenticode.euhpc.arm.com:8087/signed-items/{url_id}/sign --upload-file Mbed_installer_v0.0.1.exe > Mbed_installer_signed_v0.0.1.exe
```

## Release

1. Login on `www.mbed.com` as an admin.
2. Navigate to django administration console: `https://www.mbed.com/admin`
3. Go into `django filer->Folders->mbed-cli->Windows`
4. Upload installer
5. Get direct url to the installer

The same release should also be created on github in releases.

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


