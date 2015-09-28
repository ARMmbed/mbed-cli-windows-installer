; Copyright (c) 2015 ARM Limited. All rights reserved.
;
; SPDX-License-Identifier: Apache-2.0
;
; Licensed under the Apache License, Version 2.0 (the License); you may
; not use this file except in compliance with the License.
; You may obtain a copy of the License at
;
; http://www.apache.org/licenses/LICENSE-2.0
;
; Unless required by applicable law or agreed to in writing, software
; distributed under the License is distributed on an AS IS BASIS, WITHOUT
; WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
; See the License for the specific language governing permissions and
; limitations under the License.

; Yotta Windows Installer
;
; This script installs the yotta dependencies and then yotta itself
; pip is installed as part of python, it is assumed to exist on the user system
; All dependencies use NSIS for their installers, See http://nsis.sourceforge.net/Docs/Chapter4.html#4.12
;  for a full list of NSIS install parameters
;--------------------------------

;--------------------------------
;Include Modern UI
!include MUI2.nsh
!define MUI_HEADERIMAGE
!define MUI_HEADERIMAGE_BITMAP "..\source\HeaderImage_Bitmap.bmp" ; recommended size: 150x57 pixels
!define MUI_WELCOMEFINISHPAGE_BITMAP "..\source\WelcomeScreen.bmp" ;recommended size: 164x314 pixels
;!define MUI_WELCOMEFINISHPAGE_BITMAP_NOSTRETCH
!define MUI_ICON p.ico

;--------------------------------
;Config Section
  !define PRODUCT_NAME      "yotta"
  !define PRODUCT_VERSION   "0.1.2"
  !define PRODUCT_PUBLISHER "ARM®mbed™"
  !define PYTHON_INSTALLER  "python-2.7.10.msi"
  !define GCC_INSTALLER     "gcc-arm-none-eabi-4_9-2015q2-20150609-win32.exe"
  !define CMAKE_INSTALLER   "cmake-3.2.1-win32-x86.exe"
  !define NINJA_INSTALLER   "ninja.exe"
  !define GIT_INSTALLER     "Git-2.5.3-32-bit.exe"
  !define MBED_SERIAL_DRIVER "mbedWinSerial_16466.exe"

  Name "${PRODUCT_NAME} ${PRODUCT_VERSION}"
  OutFile "yotta_install_v${PRODUCT_VERSION}.exe"
  InstallDir "C:\yotta"
  ShowInstDetails show

;--------------------------------
;Pages
!define MUI_ABORTWARNING
!define MUI_WELCOMEPAGE_TITLE 'yotta - it means build awesome'
!insertmacro MUI_PAGE_WELCOME
!insertmacro MUI_PAGE_LICENSE "..\source\license.txt"
!insertmacro MUI_PAGE_DIRECTORY
!insertmacro MUI_PAGE_COMPONENTS
!insertmacro MUI_PAGE_INSTFILES
!define MUI_FINISHPAGE_TITLE 'Now, go build awesome!'
!insertmacro MUI_PAGE_FINISH

;--------------------------------
;Branding
BrandingText "next gen build system from ${PRODUCT_PUBLISHER}"

;!define MUI_WELCOMEFINISHPAGE_BITMAP "mbed-enabled-logo.bmp"
;BGGradient 00699d 0079b4  cc2020

;--------------------------------
;Languages
!insertmacro MUI_LANGUAGE "English"

Section -SETTINGS
  SetOutPath "$INSTDIR"
  SetOverwrite ifnewer
SectionEnd

;--------------------------------
;Installer Sections

Section "python 2.7.10" SecPython
  SetOutPath $INSTDIR
  File "..\prerequisites\${PYTHON_INSTALLER}"
  ; Install options for python taken from https://www.python.org/download/releases/2.5/msi/
  ; This gets python to add itsself to the path.
  ExecWait '"msiexec" TARGETDIR="$INSTDIR\python" /i "$INSTDIR\${PYTHON_INSTALLER}" /qb!'
;  ExecWait '"msiexec" /i "$INSTDIR\${PYTHON_INSTALLER}" ADDLOCAL=ALL /qb!'
  ; for logging msiexec /i python-2.7.10.msi /qb /l*v "c:\Program Files\yotta\install.log.txt"
SectionEnd

Section "gcc" SecGCC
  File "..\prerequisites\${GCC_INSTALLER}"
  ExecWait "$INSTDIR\${GCC_INSTALLER} /S /D=$INSTDIR\gcc"
SectionEnd

Section "cMake" SecCmake
  File "..\prerequisites\${CMAKE_INSTALLER}"
  ; TODO: get cmake to add itself to the path via command line install options
  ExecWait "$INSTDIR\${CMAKE_INSTALLER} /S /D=$INSTDIR\cmake"
SectionEnd

Section "ninja" SecNinja
  File "..\prerequisites\${NINJA_INSTALLER}"
  ;ExecWait '"setx" PATH "%PATH%;$INSTDIR"' ; setx is a windows vista,7,8,10 command to modify the path, here we are adding the yotta directory to the path
  ; note: this will fail on XP, XP users are not covered and will need to add ninja to their path manually
SectionEnd

Section "yotta" SecYotta
  ; --- install yotta ---
  File "..\source\pip_install_yotta.bat"
  ExecWait '"$INSTDIR\pip_install_yotta.bat" "$INSTDIR"'
  ; --- add shortcut and batch script to windows ---
  File "..\source\run_yotta.bat"
  File "..\source\p.ico"
  CreateShortCut "$SMPROGRAMS\Run Yotta.lnk" "$INSTDIR\run_yotta.bat"  ""  "$INSTDIR\p.ico"
  CreateShortCut "$DESKTOP\Run Yotta.lnk"    "$INSTDIR\run_yotta.bat"  ""  "$INSTDIR\p.ico"
SectionEnd

Section /o "git-scm" SecGit
  File "..\prerequisites\${GIT_INSTALLER}"
  ExecWait "$INSTDIR\${GIT_INSTALLER} /S /D=$INSTDIR\git-scm"
SectionEnd

Section /o "mercurial" SecMercurial
  File "..\source\pip_install_mercurial.bat"
  ExecWait "$INSTDIR\pip_install_mercurial.bat" "$INSTDIR"
SectionEnd

Section /o "mbed serial driver" SecMbedSerialDriver
  File "..\prerequisites\${MBED_SERIAL_DRIVER}"
  MessageBox MB_OKCANCEL "Installing the mbed Windows serial driver. Please make sure to have a mbed enabled board plugged into your computer." IDOK install_mbed_driver IDCANCEL dont_install_mbed_driver
  install_mbed_driver:
    Exec "$INSTDIR\${MBED_SERIAL_DRIVER}"
    Goto end_mbed_serial_driver
  dont_install_mbed_driver:
    MessageBox MB_OK "If you would like to install the mbed Windows serial driver in the future you can find it at $INSTDIR\${MBED_SERIAL_DRIVER}"
  end_mbed_serial_driver:
SectionEnd

;--------------------------------
;Descriptions of Installer options
LangString DESC_SecPython ${LANG_ENGLISH} "Install python and pip. pip is required to install yotta."
LangString DESC_SecGCC    ${LANG_ENGLISH} "Install arm-none-eabi-gcc as default compiler. If you have armcc you can use that instead."
LangString DESC_SecCmake  ${LANG_ENGLISH} "Install Cmake for the build system"
LangString DESC_SecNinja  ${LANG_ENGLISH} "Install ninja to manage the Cmake system"
LangString DESC_SecYotta  ${LANG_ENGLISH} "Install yotta, required Python and pip to be installed first"
LangString DESC_SecGit    ${LANG_ENGLISH} "Install git-scm, you can skip this if you already have git installed."
LangString DESC_SecMbedSerialDriver ${LANG_ENGLISH} "Install the Windows mbed serial driver. Maker sure you have an mbed board plugged into your computer."

;--------------------------------
;Add descriptions to installer menu
!insertmacro MUI_FUNCTION_DESCRIPTION_BEGIN
  !insertmacro MUI_DESCRIPTION_TEXT ${SecPython} $(DESC_SecPython)
  !insertmacro MUI_DESCRIPTION_TEXT ${SecGCC}    $(DESC_SecGCC)
  !insertmacro MUI_DESCRIPTION_TEXT ${SecCmake}  $(DESC_SecCmake)
  !insertmacro MUI_DESCRIPTION_TEXT ${SecNinja}  $(DESC_SecNinja)
  !insertmacro MUI_DESCRIPTION_TEXT ${SecYotta}  $(DESC_SecYotta)
  !insertmacro MUI_DESCRIPTION_TEXT ${SecGit}    $(DESC_SecGit)
  !insertmacro MUI_DESCRIPTION_TEXT ${SecMbedSerialDriver} $(DESC_SecMbedSerialDriver)
!insertmacro MUI_FUNCTION_DESCRIPTION_END
