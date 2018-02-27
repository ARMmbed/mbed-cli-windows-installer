; Copyright (c) 2017 Arm Limited. All rights reserved.
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

; Mbed CLI Windows Installer
;
; This script installs the Mbed CLI dependencies and then Mbed CLI itself
; pip is installed as part of python, it is assumed to exist on the user system
; All dependencies use NSIS for their installers, See http://nsis.sourceforge.net/Docs/Chapter4.html#4.12
;  for a full list of NSIS install parameters
;--------------------------------

;--------------------------------
!addplugindir "..\plugins"

;--------------------------------
;include Modern UI
!include MUI2.nsh
!addincludedir ..\include
!include "LogicLib.nsh"
!include "StrFunc.nsh"
${StrRep}
${StrTrimNewLines}
!include "Sections.nsh"
!include "FileFunc.nsh"
!include "EnvVarUpdate.nsh"
!include PathUpdate.nsh
!include WinVer.nsh

!define MUI_HEADERIMAGE
!define MUI_HEADERIMAGE_BITMAP "..\source\HeaderImage_Bitmap.bmp" ; recommended size: 150x57 pixels
!define MUI_WELCOMEFINISHPAGE_BITMAP "..\source\WelcomeScreen.bmp" ;recommended size: 164x314 pixels
!define MUI_ICON p.ico

;--------------------------------
;Config Section
  !define PRODUCT_NAME        "Mbed CLI for Windows"
  !define PRODUCT_VERSION     "0.5.0"
  !define MBED_CLI_ZIP        "mbed-cli-1.4.0.zip"
  !define MBED_CLI_VERSION    "mbed-cli-1.4.0"
  !define PRODUCT_PUBLISHER   "Arm Mbed"
  !define PYTHON_ZIP          "python-2.7.13.zip"
  !define GCC_ZIP             "gcc-arm-none-eabi-6-2017-q2-update-win32.zip"
  !define GCC_ENV_VARIABLE    "MBED_GCC_ARM_PATH"
  !define GIT_INSTALLER       "Git-2.16.2-32-bit.exe"
  !define MERCURIAL_INSTALLER "Mercurial-4.1.1.exe"
  !define MBED_SERIAL_DRIVER  "mbedWinSerial_16466.exe"
  !define UNINST_KEY          "Software\Microsoft\Windows\CurrentVersion\Uninstall\mbed_cli"

  Name "${PRODUCT_NAME} ${PRODUCT_VERSION}"
  OutFile "Mbed_installer_v${PRODUCT_VERSION}.exe"
  InstallDir "C:\mbed-cli"
  ShowInstDetails show

;--------------------------------
;Pages
!define MUI_ABORTWARNING
!define MUI_WELCOMEPAGE_TITLE 'Install Mbed CLI'
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
  File "..\prerequisites\${PYTHON_ZIP}"
  nsisunz::Unzip "$INSTDIR\${PYTHON_ZIP}" "$INSTDIR"
  Delete $INSTDIR\${PYTHON_ZIP}
SectionEnd

Section "mbed" SecMbed
  SectionIn 1
  ; --- install Mbed CLI ---
  ReadRegStr $0 HKLM "SOFTWARE\Python\PythonCore\2.7\InstallPath" ""
  File "..\prerequisites\${MBED_CLI_ZIP}"
  nsisunz::Unzip "$INSTDIR\${MBED_CLI_ZIP}" "$INSTDIR\mbed-cli"
  DELETE "$INSTDIR\${MBED_CLI_ZIP}"
  File "..\source\install_mbed.bat"
  nsExec::ExecToStack '$INSTDIR\install_mbed.bat $INSTDIR\python\ $INSTDIR\mbed-cli\${MBED_CLI_VERSION}'
  DELETE "$INSTDIR\install_mbed.bat"
  ; --- add shortcut and batch script to windows ---
  File "..\source\p.ico"
  ; make sure windows knows about the change in env variables
  ; --- add mbed-cli to path
  Push "$INSTDIR\python\Scripts"
  Call AddToPathSafe
  ; make sure windows knows about the change in env variables
  SendMessage ${HWND_BROADCAST} ${WM_WININICHANGE} 0 "STR:Environment" /TIMEOUT=5000
  ; --- Set estimated installation size ---
  ${GetSize} "$INSTDIR" "/S=0K" $0 $1 $2
  IntFmt $0 "0x%08X" $0
  WriteRegDWORD SHCTX "${UNINST_KEY}" "EstimatedSize" "$0"
  ; --- Create uninstaller ---
  writeUninstaller "$INSTDIR\mbed_uninstall.exe"
SectionEnd

Section "git-scm" SecGit
  SectionIn 1
  ; --- git-scm is a Inno Setup installer, requires different options
  ;Check if git is installed
  nsExec::ExecToStack 'git --version'
  Pop $0
  ${if} $0 != 0
	  File "..\prerequisites\${GIT_INSTALLER}"
	  ExecWait "$INSTDIR\${GIT_INSTALLER} /VERYSILENT /SUPPRESSMSGBOXES /DIR=$INSTDIR\git"
	  Delete $INSTDIR\${GIT_INSTALLER}
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
	  ExecWait "$INSTDIR\${MERCURIAL_INSTALLER} /VERYSILENT /SUPPRESSMSGBOXES /DIR=$INSTDIR\mercurial"
	  Delete $INSTDIR\${MERCURIAL_INSTALLER}
  ${endif}
SectionEnd

Section "gcc" SecGCC
  SectionIn 1
  ; --- unzip gcc release ---
  File "..\prerequisites\${GCC_ZIP}"
  ; --- unzip gcc
  nsisunz::Unzip "$INSTDIR\${GCC_ZIP}" "$INSTDIR\gcc"
  ; --- add gcc to env variable
  Push "${GCC_ENV_VARIABLE}"
  Push "$INSTDIR\gcc\bin"
  Call AddToEnvVar
  Delete $INSTDIR\${GCC_ZIP}
  ; make sure windows knows about the change in env variables
  SendMessage ${HWND_BROADCAST} ${WM_SETTINGCHANGE} 0 "STR:Environment" /TIMEOUT=5000
SectionEnd

Section "mbed serial driver" SecMbedSerialDriver
  SectionIn 1
  File "..\prerequisites\${MBED_SERIAL_DRIVER}"
  MessageBox MB_OKCANCEL "Installing the Mbed Windows serial driver. Please make sure to have a Mbed enabled board plugged into your computer." IDOK install_mbed_driver IDCANCEL dont_install_mbed_driver
  install_mbed_driver:
    ExecWait "$INSTDIR\${MBED_SERIAL_DRIVER}"
    Goto end_mbed_serial_driver
  dont_install_mbed_driver:
    MessageBox MB_OK "If you would like to install the Mbed Windows serial driver in the future you can find it at $INSTDIR\${MBED_SERIAL_DRIVER}"
  end_mbed_serial_driver:
SectionEnd

;--------------------------------

Section "Uninstall"
  nsExec::ExecToStack 'pip uninstall -y mbed-cli'           ;uninstall mbed-cli
  RMDir /r "$INSTDIR\mbed-cli"
  RMDir /r "$INSTDIR\python"
  RMDir /r "$INSTDIR\gcc"
  ;uninstall git if installed by this installer
  IfFileExists "$INSTDIR\git\unins000.exe" git_uninstall git_continue
  git_uninstall:
    ExecWait "$INSTDIR\git\unins000.exe /VERYSILENT /SUPPRESSMSGBOXES"
    Delete "$INSTDIR\git\unins000.exe"
    RMDir /r "$INSTDIR\git"
  git_continue:
  ;uninstall hg if installed by this installer
  IfFileExists "$INSTDIR\mercurial\unins000.exe" hg_uninstall hg_continue
  hg_uninstall:
    ExecWait "$INSTDIR\mercurial\unins000.exe /VERYSILENT /SUPPRESSMSGBOXES"
    Delete "$INSTDIR\mercurial\unins000.exe"
    RMDir /r "$INSTDIR\hg"
  hg_continue:
  Delete "$INSTDIR\${MBED_SERIAL_DRIVER}"
  Delete "$INSTDIR\p.ico"
  Delete "$INSTDIR\mbed_uninstall.exe"
  ; --- Remove env variables
  Push "${GCC_ENV_VARIABLE}"
  Push "$INSTDIR\gcc\bin"
  Call un.RemoveFromEnvVar
  ; remove mbed-cli from path
  Push "$INSTDIR\python\Scripts"
  Call un.RemoveFromPathSafe
  ; make sure windows knows about the change in env variables
  SendMessage ${HWND_BROADCAST} ${WM_WININICHANGE} 0 "STR:Environment" /TIMEOUT=5000
  ; ---
  RMDir "$INSTDIR\"					    ;remove install folder(only if empty)
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
  ReadRegStr $R0 SHCTX "${UNINST_KEY}" "UninstallString"
  StrCmp $R0 "" done

  MessageBox MB_YESNO|MB_ICONEXCLAMATION \
    "${PRODUCT_NAME} has been detected on this system. It will be removed during this installation process. Would you like to continue?" \
  IDYES uninst
  Abort

  ;Run the uninstaller
  uninst:
    ClearErrors
    Exec '$R0' ;Run uninstaller
  done:
functionEnd

;--------------------------------
;un Init
function un.onInit
  MessageBox MB_OKCANCEL "Uninstalling Mbed CLI will also remove your Mbed CLI workspace, please make sure to back up all programs before un-installing. $\n Would you like to continue removing Mbed CLI?" IDOK next
    Abort
  next:
functionEnd

;--------------------------------
;Descriptions of Installer options
LangString DESC_SecPython     ${LANG_ENGLISH} "Install python and pip."
LangString DESC_SecGCC        ${LANG_ENGLISH} "Install arm-none-eabi-gcc as default compiler. If you have armcc you can use that instead."
LangString DESC_SecMbed       ${LANG_ENGLISH} "Install Mbed CLI, requires Python to be installed"
LangString DESC_SecGit        ${LANG_ENGLISH} "Install git-scm, used to access git based repositories."
LangString DESC_SecMercurial  ${LANG_ENGLISH} "Install mercurial, used to access mercurial (hg) based repositories"
LangString DESC_SecMbedSerialDriver ${LANG_ENGLISH} "Installing Windows Mbed serial driver requires an Mbed board. Make sure you have an Mbed board plugged into your computer."

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
