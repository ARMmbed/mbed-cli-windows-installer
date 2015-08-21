; Yotta Windows Installer
;
; This script installs the yotta dependencies and then yotta itself
; pip is installed as part of python, it is assumed to exist on the user system
;--------------------------------

;--------------------------------
;Include Modern UI
!include MUI2.nsh

;--------------------------------
;General
  !define PRODUCT_NAME "yotta"
  !define PRODUCT_VERSION "0.0.1"
  !define PRODUCT_PUBLISHER "ARMmbed"

  Name "${PRODUCT_NAME} ${PRODUCT_VERSION}"
  OutFile "yotta_install_v${PRODUCT_VERSION}.exe"
  InstallDir "$PROGRAMFILES\yotta"
  ShowInstDetails show


  ;Request application privileges for Windows Vista
  RequestExecutionLevel user

;--------------------------------
;Pages
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
BrandingText "next gen build system from ARMmbed"
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
  File "..\prerequisites\python-2.7.10.msi"
  ExecWait '"msiexec" /i "$INSTDIR\python-2.7.10.msi"'
SectionEnd

Section "gcc" SecGCC
  File "..\prerequisites\gcc-arm-none-eabi-4_9-2015q2-20150609-win32.exe"
  ExecWait "$INSTDIR\prerequisites\gcc-arm-none-eabi-4_9-2015q2-20150609-win32.exe"
SectionEnd

Section "cMake" section_index_output
  File "..\prerequisites\cmake-3.2.1-win32-x86.exe"
  ExecWait "$INSTDIR\prerequisites\cmake-3.2.1-win32-x86.exe"
SectionEnd

Section "ninja" SecNinja
  File "..\prerequisites\ninja.exe"
    
    ; TODO: Copy Ninja to folder and add to path here
SectionEnd

Section "yotta (requires pip)" SecYotta
   ExecWait '"pip_install_yotta.bat"'
SectionEnd

