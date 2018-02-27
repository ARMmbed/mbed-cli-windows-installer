$storageDir = $pwd
$webclient = New-Object System.Net.WebClient
#Download gcc-arm-none-eabi
$url = https://developer.arm.com/-/media/Files/downloads/gnu-rm/6-2017q2/gcc-arm-none-eabi-6-2017-q2-update-win32.zip?revision=d8809bf7-a431-49ee-98d5-0475d839f8f1?product=GNU%20Arm%20Embedded%20Toolchain,ZIP,,Windows,6-2017-q2-update"
$file = "$storageDir\gcc-arm-none-eabi-6-2017-q2-update-win32.zip
$webclient.DownloadFile($url,$file)
#Download git-scm
$url = "https://github.com/git-for-windows/git/releases/download/v2.16.2.windows.1/Git-2.16.2-32-bit.exe"
$file = "$storageDir\Git-2.16.2-32-bit.exe"
$webclient.DownloadFile($url,$file)
#Download Mercurial
$url = "https://mercurial-scm.org/release/windows/Mercurial-4.1.1.exe"
$file = "$storageDir\Mercurial-4.1.1.exe"
$webclient.DownloadFile($url,$file)
#Download bundled Python 32 bit
$url = "https://s3-us-west-2.amazonaws.com/mbed-cli-installer/Windows/Python/python.zip"
$file = "$storageDir\python-2.7.13.zip"
$webclient.DownloadFile($url,$file)
#Download mbedWinSerial
$url = "https://developer.mbed.org/media/downloads/drivers/mbedWinSerial_16466.exe"
$file = "$storageDir\mbedWinSerial_16466.exe"
$webclient.DownloadFile($url,$file)
#Download mbed-cli
$url = "https://github.com/ARMmbed/mbed-cli/archive/1.4.0.zip"
$file = "$storageDir\mbed-cli-1.4.0.zip"
$webclient.DownloadFile($url,$file)
