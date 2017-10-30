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
!include "LogicLib.nsh"
!include "StrFunc.nsh"
${StrRep}
${StrTrimNewLines}
!include "WordFunc.nsh"
  !insertmacro VersionCompare
!include "Sections.nsh"
!include WinVer.nsh

!define MUI_HEADERIMAGE
!define MUI_HEADERIMAGE_BITMAP "..\source\HeaderImage_Bitmap.bmp" ; recommended size: 150x57 pixels
!define MUI_WELCOMEFINISHPAGE_BITMAP "..\source\WelcomeScreen.bmp" ;recommended size: 164x314 pixels
!define MUI_ICON p.ico

;--------------------------------
;Config Section
  !define PRODUCT_NAME      "Mbed CLI for Windows"
  !define PRODUCT_VERSION   "0.4.3"
  !define MBED_CLI_EXE      "mbed-cli-win-1.2.2.exe"
  !define MBED_CLI_VERSION  "mbed-cli-1.2.2"
  !define PRODUCT_PUBLISHER "Arm Mbed"
  !define PYTHON_INSTALLER  "python-2.7.13.msi"
  !define GCC_EXE     "gcc-arm-none-eabi-6-2017-q2-update-win32.exe"
  !define GIT_INSTALLER     "Git-2.11.0.3-32-bit.exe"
  !define MERCURIAL_INSTALLER "Mercurial-4.1.1.exe"
  !define MBED_SERIAL_DRIVER  "mbedWinSerial_16466.exe"
  !define UNINST_KEY          "Software\Microsoft\Windows\CurrentVersion\Uninstall\mbed_cli"
  !define MIN_PYTHON_VERSION "2.7.12"

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
  writeUninstaller "$INSTDIR\mbed_uninstall.exe"
SectionEnd

;--------------------------------
;Installer Types

InstType /CUSTOMSTRING=Advanced
InstType /COMPONENTSONLYONCUSTOM
InstType "Default"

;--------------------------------
;Functions from https://www.smartmontools.org/browser/trunk/smartmontools/os_win32/installer.nsi?rev=4110#L636

; StrStr - find substring in a string
;
; Usage:
;   Push "this is some string"
;   Push "some"
;   Call StrStr
;   Pop $0 ; "some string"

!macro StrStr un
Function ${un}StrStr
  Exch $R1 ; $R1=substring, stack=[old$R1,string,...]
  Exch     ;                stack=[string,old$R1,...]
  Exch $R2 ; $R2=string,    stack=[old$R2,old$R1,...]
  Push $R3
  Push $R4
  Push $R5
  StrLen $R3 $R1
  StrCpy $R4 0
  ; $R1=substring, $R2=string, $R3=strlen(substring)
  ; $R4=count, $R5=tmp
  loop:
    StrCpy $R5 $R2 $R3 $R4
    StrCmp $R5 $R1 done
    StrCmp $R5 "" done
    IntOp $R4 $R4 + 1
    Goto loop
done:
  StrCpy $R1 $R2 "" $R4
  Pop $R5
  Pop $R4
  Pop $R3
  Pop $R2
  Exch $R1 ; $R1=old$R1, stack=[result,...]
FunctionEnd
!macroend
!insertmacro StrStr ""

!include "WinMessages.nsh"
!define Environ 'HKCU "Environment"'

Function AddToPath
  Exch $0
  Push $1
  Push $2
  Push $3
  Push $4

  ; NSIS ReadRegStr returns empty string on string overflow
  ; Native calls are used here to check actual length of PATH

  ; $4 = RegOpenKey(HKEY_CURRENT_USER, "Environment", &$3)
  System::Call "advapi32::RegOpenKey(i 0x80000001, t'Environment', *i.r3) i.r4"
  IntCmp $4 0 0 done done
  ; $4 = RegQueryValueEx($3, "PATH", (DWORD*)0, (DWORD*)0, &$1, ($2=NSIS_MAX_STRLEN, &$2))
  ; RegCloseKey($3)
  System::Call "advapi32::RegQueryValueEx(i $3, t'PATH', i 0, i 0, t.r1, *i ${NSIS_MAX_STRLEN} r2) i.r4"
  System::Call "advapi32::RegCloseKey(i $3)"

  IntCmp $4 234 0 +4 +4 ; $4 == ERROR_MORE_DATA
    DetailPrint "AddToPath: original length $2 > ${NSIS_MAX_STRLEN}"
    MessageBox MB_OK "PATH not updated, original length $2 > ${NSIS_MAX_STRLEN}"
    Goto done

  IntCmp $4 0 +5 ; $4 != NO_ERROR
    IntCmp $4 2 +3 ; $4 != ERROR_FILE_NOT_FOUND
      DetailPrint "AddToPath: unexpected error code $4"
      Goto done
    StrCpy $1 ""

  ; Check if already in PATH
  Push "$1;"
  Push "$0;"
  Call StrStr
  Pop $2
  StrCmp $2 "" 0 done
  Push "$1;"
  Push "$0\;"
  Call StrStr
  Pop $2
  StrCmp $2 "" 0 done

  ; Prevent NSIS string overflow
  StrLen $2 $0
  StrLen $3 $1
  IntOp $2 $2 + $3
  IntOp $2 $2 + 2 ; $2 = strlen(dir) + strlen(PATH) + sizeof(";")
  IntCmp $2 ${NSIS_MAX_STRLEN} +4 +4 0
    DetailPrint "AddToPath: new length $2 > ${NSIS_MAX_STRLEN}"
    MessageBox MB_OK "PATH not updated, new length $2 > ${NSIS_MAX_STRLEN}."
    Goto done

  ; Append dir to PATH
  DetailPrint "Add to PATH: $0"
  StrCpy $2 $1 1 -1
  StrCmp $2 ";" 0 +2
    StrCpy $1 $1 -1 ; remove trailing ';'
  StrCmp $1 "" +2   ; no leading ';'
    StrCpy $0 "$1;$0"
  WriteRegExpandStr ${Environ} "PATH" $0
  SendMessage ${HWND_BROADCAST} ${WM_WININICHANGE} 0 "STR:Environment" /TIMEOUT=5000

done:
  Pop $4
  Pop $3
  Pop $2
  Pop $1
  Pop $0
FunctionEnd

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
    Delete $INSTDIR\${PYTHON_INSTALLER}
  pythonExit:
SectionEnd

Section "mbed" SecMbed
  SectionIn 1
  ; --- install Mbed CLI ---
  File "..\prerequisites\${MBED_CLI_EXE}"
  Rename "$INSTDIR\${MBED_CLI_EXE}" "$INSTDIR\mbed.exe"
  ; --- add shortcut and batch script to windows ---
  File "..\source\p.ico"
  ; --- add to PATH ---
  Push "$INSTDIR"
  Call AddToPath
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
	  ExecWait "$INSTDIR\${MERCURIAL_INSTALLER} /VERYSILENT /SUPPRESSMSGBOXES"
	  Delete $INSTDIR\${MERCURIAL_INSTALLER}
  ${endif}
SectionEnd

Section "gcc" SecGCC
  SectionIn 1
  ; --- unzip gcc release ---
  File "..\prerequisites\${GCC_EXE}"
  ; --- install silently add to path and registry
  ExecWait "$INSTDIR\${GCC_EXE} /S /P /R /SUPPRESSMSGBOXES"
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
  RMDir /r "$INSTDIR\mbed-cli"
  Delete "$INSTDIR\${MBED_SERIAL_DRIVER}"
  Delete "$INSTDIR\p.ico"
  Delete "$INSTDIR\mbed_uninstall.exe"
  Delete "$INSTDIR\mbed.exe"
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
functionEnd

;--------------------------------
;onInstSuccess
Function .onInstSuccess
   Delete $INSTDIR\${GCC_EXE}
FunctionEnd

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
