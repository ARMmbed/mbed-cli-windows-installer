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

; mbed CLI Windows Installer
;
; This script installs the mbed CLI dependencies and then mbed CLI itself
; pip is installed as part of python, it is assumed to exist on the user system
; All dependencies use NSIS for their installers, See http://nsis.sourceforge.net/Docs/Chapter4.html#4.12
;  for a full list of NSIS install parameters
;--------------------------------

;--------------------------------
!addplugindir "..\plugins"

;--------------------------------
;Include Modern UI
!include MUI2.nsh
!define MUI_HEADERIMAGE
!define MUI_HEADERIMAGE_BITMAP "..\source\HeaderImage_Bitmap.bmp" ; recommended size: 150x57 pixels
!define MUI_WELCOMEFINISHPAGE_BITMAP "..\source\WelcomeScreen.bmp" ;recommended size: 164x314 pixels
;!define MUI_WELCOMEFINISHPAGE_BITMAP_NOSTRETCH
!define MUI_ICON p.ico

;--------------------------------
;Init
function un.onInit
  MessageBox MB_OKCANCEL "Uninstalling mbed CLI will also remove your mbed CLI workspace (c:\mbed-cli\workspace), please make sure to back up all programs before un-installing. $\n Would you like to continue removing mbed CLI?" IDOK next
    Abort
  next:
functionEnd

;--------------------------------
;Config Section
  !define PRODUCT_NAME      "mbed CLI windows installer"
  !define PRODUCT_VERSION   "0.3.1"
  !define PRODUCT_PUBLISHER "ARM mbed"
  !define PYTHON_INSTALLER  "python-2.7.10.msi"
  !define GCC_INSTALLER     "gcc-arm-none-eabi-4_9-2015q2-20150609-win32.exe"
  !define GCC_ZIP           "gcc-arm-none-eabi-4_9-2015q3-20150921-win32.zip"
  !define GIT_INSTALLER     "Git-2.5.3-32-bit.exe"
  !define MERCURIAL_INSTALLER "Mercurial-3.5.1.exe"
  !define MBED_SERIAL_DRIVER  "mbedWinSerial_16466.exe"
  !define UNINST_KEY          "Software\Microsoft\Windows\CurrentVersion\Uninstall\mbed_cli"

  Name "${PRODUCT_NAME} ${PRODUCT_VERSION}"
  OutFile "mbed_install_v${PRODUCT_VERSION}.exe"
  InstallDir "C:\mbed-cli"
  ShowInstDetails show

;--------------------------------
;Pages
!define MUI_ABORTWARNING
!define MUI_WELCOMEPAGE_TITLE 'Install mbed CLI'
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
  WriteRegStr SHCTX "${UNINST_KEY}" "DisplayName" "${PRODUCT_NAME}"
  WriteRegStr SHCTX "${UNINST_KEY}" "UninstallString" "$\"$INSTDIR\mbed_uninstall.exe$\""
  WriteRegDWORD SHCTX "${UNINST_KEY}" "NoModify" "1"
  WriteRegDWORD SHCTX "${UNINST_KEY}" "NoRepair" "1"
  WriteRegStr SHCTX "${UNINST_KEY}" "DisplayIcon" "$INSTDIR\p.ico"
  WriteRegStr SHCTX "${UNINST_KEY}" "Publisher" "${PRODUCT_PUBLISHER}"
  WriteRegStr SHCTX "${UNINST_KEY}" "DisplayVersion" "${PRODUCT_VERSION}"
  WriteRegStr SHCTX "${UNINST_KEY}" "InstallLocation" "$\"$INSTDIR$\""
  writeUninstaller "$INSTDIR\mbed_uninstall.exe"
SectionEnd

;--------------------------------
;Installer Sections

Section "python" SecPython
  SectionIn RO
  SetOutPath $INSTDIR
  ;Check if python is installed
  nsExec::ExecToStack 'python --version'
  Pop $0
  ${if} $0 == 0
    MessageBox MB_OKCANCEL "Python is already installed on this system, would you like to overwrite this installation?" IDOK pythonCont IDCANCEL pythonCancel
  pythonCancel:
    Return
  pythonCont:
  ${endif}
  File "..\prerequisites\${PYTHON_INSTALLER}"
  ; Install options for python taken from https://www.python.org/download/releases/2.5/msi/
  ; This gets python to add itsself to the path.
  nsExec::ExecToStack '"msiexec" TARGETDIR="$INSTDIR\python" /i "$INSTDIR\${PYTHON_INSTALLER}" ALLUSERS=1 ADDLOCAL=ALL /q'
;  ExecWait '"msiexec" /i "$INSTDIR\${PYTHON_INSTALLER}" ADDLOCAL=ALL /qb!'
  ; for logging msiexec /i python-2.7.10.msi /qb /l*v "c:\mbed-cli\install.log.txt"
;; debug here
;ExecWait '"msiexec" TARGETDIR="$INSTDIR\python" /i "$INSTDIR\${PYTHON_INSTALLER}" /qn /l*v "C:\mbed-cli\pythonlog.txt"'
  
SectionEnd

Section "mbed" SecMbed
  ; --- install mbed CLI ---
  SectionIn RO
  File "..\source\pip_install_mbed.bat"
  nsExec::ExecToStack '"$INSTDIR\pip_install_mbed.bat" "$INSTDIR"'
  ; --- add shortcut and batch script to windows ---
  File "..\source\run_mbed.bat"
  File "..\source\p.ico"
  CreateShortCut "$SMPROGRAMS\Run mbed CLI.lnk" "$INSTDIR\run_mbed.bat"  ""  "$INSTDIR\p.ico"
  CreateShortCut "$DESKTOP\Run mbed CLI.lnk"    "$INSTDIR\run_mbed.bat"  ""  "$INSTDIR\p.ico"
SectionEnd

Section "git-scm" SecGit
  ; --- git-scm is a Inno Setup installer, requires different options
  SectionIn RO
  ;Check if git is installed
  nsExec::ExecToStack 'git --version'
  Pop $0
  ${if} $0 != 0
	File "..\prerequisites\${GIT_INSTALLER}"
	ExecWait "$INSTDIR\${GIT_INSTALLER} /VERYSILENT /SUPPRESSMSGBOXES /DIR=$PROGRAMFILES"
  ${endif}
SectionEnd

Section "mercurial" SecMercurial
  ; --- mercurial is a Inno Setup installer, requires different options
  SectionIn RO
  ;Check if mercurial is installed
  nsExec::ExecToStack 'hg --version'
  Pop $0
  ${if} $0 != 0
	File "..\prerequisites\${MERCURIAL_INSTALLER}"
	ExecWait "$INSTDIR\${MERCURIAL_INSTALLER} /VERYSILENT /SUPPRESSMSGBOXES /DIR=$PROGRAMFILES"
  ${endif}
SectionEnd

Section "gcc" SecGCC
  ; --- unzip gcc release ---
  File "..\prerequisites\${GCC_ZIP}"
  nsisunz::Unzip "$INSTDIR\${GCC_ZIP}" "$INSTDIR\gcc"
SectionEnd

Section "mbed serial driver" SecMbedSerialDriver
  File "..\prerequisites\${MBED_SERIAL_DRIVER}"
  MessageBox MB_OKCANCEL "Installing the mbed Windows serial driver. Please make sure to have a mbed enabled board plugged into your computer." IDOK install_mbed_driver IDCANCEL dont_install_mbed_driver
  install_mbed_driver:
    ExecWait "$INSTDIR\${MBED_SERIAL_DRIVER}"
    Goto end_mbed_serial_driver
  dont_install_mbed_driver:
    MessageBox MB_OK "If you would like to install the mbed Windows serial driver in the future you can find it at $INSTDIR\${MBED_SERIAL_DRIVER}"
  end_mbed_serial_driver:
SectionEnd

Section "Uninstall"
  Delete "$DESKTOP\Run mbed CLI.lnk"                ;delete desktop shortcut
  Delete "$SMPROGRAMS\Run mbed CLI.lnk"             ;delete startmenu shortcut
  RMDir /r "$INSTDIR\"                              ;delete c:\mbed-cli folder 
  nsExec::ExecToStack 'setx MBED_PATH ""'                      ;remove environment variables
  nsExec::ExecToStack 'setx MBED_INSTALL_LOCATION ""'
  DeleteRegKey SHCTX "${UNINST_KEY}"
SectionEnd

;--------------------------------
;Descriptions of Installer options
LangString DESC_SecPython     ${LANG_ENGLISH} "Install python and pip. pip is required to install mbed CLI."
LangString DESC_SecGCC        ${LANG_ENGLISH} "Install arm-none-eabi-gcc as default compiler. If you have armcc you can use that instead."
LangString DESC_SecMbed       ${LANG_ENGLISH} "Install mbed CLI using pip, requires an internet connection, requires Python and pip to be installed"
LangString DESC_SecGit        ${LANG_ENGLISH} "Install git-scm, used to access git based repositories."
LangString DESC_SecMercurial  ${LANG_ENGLISH} "Install mercurial, used to access mercurial (hg) based repositories"
LangString DESC_SecMbedSerialDriver ${LANG_ENGLISH} "Install the Windows mbed serial driver. Make sure you have an mbed board plugged into your computer."

;--------------------------------
;Add descriptions to installer menu
!insertmacro MUI_FUNCTION_DESCRIPTION_BEGIN
  !insertmacro MUI_DESCRIPTION_TEXT ${SecPython}      $(DESC_SecPython)
  !insertmacro MUI_DESCRIPTION_TEXT ${SecGCC}         $(DESC_SecGCC)
  !insertmacro MUI_DESCRIPTION_TEXT ${SecMbed}        $(DESC_SecMbed)
  !insertmacro MUI_DESCRIPTION_TEXT ${SecGit}         $(DESC_SecGit)
  !insertmacro MUI_DESCRIPTION_TEXT ${SecMercurial}   $(DESC_SecMercurial)
  !insertmacro MUI_DESCRIPTION_TEXT ${SecMbedSerialDriver} $(DESC_SecMbedSerialDriver)
!insertmacro MUI_FUNCTION_DESCRIPTION_END
