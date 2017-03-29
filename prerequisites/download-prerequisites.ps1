$storageDir = $pwd
$webclient = New-Object System.Net.WebClient
#Download gcc-arm-none-eabi
$url = "https://launchpad.net/gcc-arm-embedded/5.0/5-2016-q3-update/+download/gcc-arm-none-eabi-5_4-2016q3-20160926-win32.zip"
$file = "$storageDir\gcc-arm-none-eabi-5_4-2016q3-20160926-win32.zip"
$webclient.DownloadFile($url,$file)
#Download git-scm
$url = "https://github.com/git-for-windows/git/releases/download/v2.12.2.windows.1/Git-2.12.2-32-bit.exe"
$file = "$storageDir\Git-2.11.0.3-32-bit.exe"
$webclient.DownloadFile($url,$file)
#Download Mercurial
$url = "https://mercurial-scm.org/release/windows/Mercurial-4.1.1.exe"
$file = "$storageDir\Mercurial-4.1.1.exe"
$webclient.DownloadFile($url,$file)
#Download Python 32bit
$url = "https://www.python.org/ftp/python/2.7.13/python-2.7.13.msi"
$file = "$storageDir\python-2.7.13.msi"
$webclient.DownloadFile($url,$file)
#Download Python 64bit
$url = "https://www.python.org/ftp/python/2.7.13/python-2.7.13.amd64.msi"
$file = "$storageDir\python-2.7.13.amd64.msi"
$webclient.DownloadFile($url,$file)
#Download mbedWinSerial
$url = "https://developer.mbed.org/media/downloads/drivers/mbedWinSerial_16466.exe"
$file = "$storageDir\mbedWinSerial_16466.exe"
$webclient.DownloadFile($url,$file)



