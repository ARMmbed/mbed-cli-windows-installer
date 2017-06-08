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
;include Modern UI
!include MUI2.nsh
!include "LogicLib.nsh"
!include "StrFunc.nsh"
${StrRep}
${StrTrimNewLines}
!include "WordFunc.nsh"
  !insertmacro VersionCompare
!include "Sections.nsh"
!include WinVer.nsh
!include "..\include\EnvVarUpdate.nsh"

!define MUI_HEADERIMAGE
!define MUI_HEADERIMAGE_BITMAP "..\source\HeaderImage_Bitmap.bmp" ; recommended size: 150x57 pixels
!define MUI_WELCOMEFINISHPAGE_BITMAP "..\source\WelcomeScreen.bmp" ;recommended size: 164x314 pixels
!define MUI_ICON p.ico

;--------------------------------
;Config Section
  !define PRODUCT_NAME      "mbed CLI for Windows"
  !define PRODUCT_VERSION   "0.4.0"
  !define MBED_CLI_ZIP      "mbed-cli-1.1.1.zip"
  !define MBED_CLI_VERSION  "mbed-cli-1.1.1"
  !define PRODUCT_PUBLISHER "ARM mbed"
  !define PYTHON_INSTALLER  "python-2.7.13.msi"
  !define GCC_ZIP     "gcc-arm-none-eabi-6-2017-q1-update-win32.zip"
  !define GIT_INSTALLER     "Git-2.11.0.3-32-bit.exe"
  !define MERCURIAL_INSTALLER "Mercurial-4.1.1.exe"
  !define MBED_SERIAL_DRIVER  "mbedWinSerial_16466.exe"
  !define UNINST_KEY          "Software\Microsoft\Windows\CurrentVersion\Uninstall\mbed_cli"
  !define MIN_PYTHON_VERSION "2.7.12"

  Name "${PRODUCT_NAME} ${PRODUCT_VERSION}"
  OutFile "mbed_installer_v${PRODUCT_VERSION}.exe"
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
!insertmacro MUI_UNPAGE_INSTFILES
!insertmacro MUI_UNPAGE_FINISH

;--------------------------------
;Branding
BrandingText "next gen build system from ${PRODUCT_PUBLISHER}"

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
;Installer Types

InstType /CUSTOMSTRING=Advanced
InstType /COMPONENTSONLYONCUSTOM
InstType "Default"

;--------------------------------
;Installer Sections

Section "python" SecPython
  SectionIn 1
  SetOutPath $INSTDIR
  ClearErrors
  EnumRegKey $0 HKLM "SOFTWARE\Python\PythonCore\2.7" 0
  ${If} ${Errors}
    Goto pythonInstall
  ${Else}
    nsExec::ExecToStack 'python --version'
    Pop $0
    Pop $1
    ${if} $0 != 0
      goto pythonInstall
    ${EndIf}
    ;get python 2 version
    ${StrRep} $0 $1 "Python " ""
    ${StrTrimNewLines} $0 $0
    ;compare version
    ${VersionCompare} $0  ${MIN_PYTHON_VERSION} $1
    ${if} $1 == 2
      MessageBox MB_YESNO "${PRODUCT_NAME} requires Python version ${MIN_PYTHON_VERSION} or higher to work properly (Python 3 is not supported). Python $0 is already installed on this system, would you like to overwrite this installation?" IDYES pythonInstall IDNO pythonExit
    ${Else}
      goto pythonExit
    ${endif}
  ${EndIf}
  pythonInstall:
    File "..\prerequisites\${PYTHON_INSTALLER}"
    ; Install options for python taken from https://www.python.org/download/releases/2.5/msi/
    ; This gets python to add itsself to the path.
    nsExec::ExecToStack '"msiexec" /i "$INSTDIR\${PYTHON_INSTALLER}" ALLUSERS=1 ADDLOCAL=ALL /qn'
  pythonExit:
SectionEnd

Section "mbed" SecMbed
  SectionIn 1
  ; --- install mbed CLI ---
  ReadRegStr $0 HKLM "SOFTWARE\Python\PythonCore\2.7\InstallPath" ""
  File "..\prerequisites\${MBED_CLI_ZIP}"
  nsisunz::Unzip "$INSTDIR\${MBED_CLI_ZIP}" "$INSTDIR\mbed-cli"
  File "..\source\pip_install_mbed.bat"
  nsExec::ExecToStack '$INSTDIR\pip_install_mbed.bat $0 $INSTDIR\mbed-cli\${MBED_CLI_VERSION}'
  ; --- add shortcut and batch script to windows ---
  File "..\source\p.ico"
SectionEnd

Section "git-scm" SecGit
  SectionIn 1
  ; --- git-scm is a Inno Setup installer, requires different options
  ;Check if git is installed
  nsExec::ExecToStack 'git --version'
  Pop $0
  ${if} $0 != 0
	  File "..\prerequisites\${GIT_INSTALLER}"
	  ExecWait "$INSTDIR\${GIT_INSTALLER} /VERYSILENT /SUPPRESSMSGBOXES"
  ${endif}
SectionEnd

Section "mercurial" SecMercurial
  SectionIn 1
  ; --- mercurial is a Inno Setup installer, requires different options
  ;Check if mercurial is installed
  nsExec::ExecToStack 'hg --version'
  Pop $0
  ${if} $0 != 0
	  File "..\prerequisites\${MERCURIAL_INSTALLER}"
	  ExecWait "$INSTDIR\${MERCURIAL_INSTALLER} /VERYSILENT /SUPPRESSMSGBOXES"
  ${endif}
SectionEnd

Section "gcc" SecGCC
  SectionIn 1
  ; --- unzip gcc release ---
  File "..\prerequisites\${GCC_ZIP}"
  nsisunz::Unzip "$INSTDIR\${GCC_ZIP}" "$INSTDIR\gcc"
  ${EnvVarUpdate} $0 "PATH" "A" "HKLM" "$INSTDIR\gcc\bin"
SectionEnd

Section "mbed serial driver" SecMbedSerialDriver
  SectionIn 1
  File "..\prerequisites\${MBED_SERIAL_DRIVER}"
  MessageBox MB_OKCANCEL "Installing the mbed Windows serial driver. Please make sure to have a mbed enabled board plugged into your computer." IDOK install_mbed_driver IDCANCEL dont_install_mbed_driver
  install_mbed_driver:
    ExecWait "$INSTDIR\${MBED_SERIAL_DRIVER}"
    Goto end_mbed_serial_driver
  dont_install_mbed_driver:
    MessageBox MB_OK "If you would like to install the mbed Windows serial driver in the future you can find it at $INSTDIR\${MBED_SERIAL_DRIVER}"
  end_mbed_serial_driver:
SectionEnd

;--------------------------------

Section "Uninstall"
  RMDir /r "$INSTDIR\"                              ;delete c:\mbed-cli folder
  ${un.EnvVarUpdate} $0 "PATH" "R" "HKLM" "$INSTDIR\gcc\bin"
  nsExec::ExecToStack 'pip uninstall -y mbed-cli'           ;uninstall mbed-cli
  DeleteRegKey SHCTX "${UNINST_KEY}"
SectionEnd

;--------------------------------
;Init
Function .onInit
   ;Check Windows version. Windows 7 or above is required
   ${IfNot} ${AtLeastWin7}
     MessageBox MB_OK "Windows 7 and above is required"
     Quit
   ${EndIf}
functionEnd

;--------------------------------
;un Init
function un.onInit
  MessageBox MB_OKCANCEL "Uninstalling mbed CLI will also remove your mbed CLI workspace (c:\mbed-cli\workspace), please make sure to back up all programs before un-installing. $\n Would you like to continue removing mbed CLI?" IDOK next
    Abort
  next:
functionEnd

;--------------------------------
;Descriptions of Installer options
LangString DESC_SecPython     ${LANG_ENGLISH} "Install python and pip."
LangString DESC_SecGCC        ${LANG_ENGLISH} "Install arm-none-eabi-gcc as default compiler. If you have armcc you can use that instead."
LangString DESC_SecMbed       ${LANG_ENGLISH} "Install mbed CLI, requires Python to be installed"
LangString DESC_SecGit        ${LANG_ENGLISH} "Install git-scm, used to access git based repositories."
LangString DESC_SecMercurial  ${LANG_ENGLISH} "Install mercurial, used to access mercurial (hg) based repositories"
LangString DESC_SecMbedSerialDriver ${LANG_ENGLISH} "Installing Windows mbed serial driver requires an mbed board. Make sure you have an mbed board plugged into your computer."

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
