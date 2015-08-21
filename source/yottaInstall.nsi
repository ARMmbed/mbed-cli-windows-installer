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
!insertmacro MUI_PAGE_WELCOME
!insertmacro MUI_PAGE_LICENSE "..\source\license.txt"
!insertmacro MUI_PAGE_DIRECTORY
!insertmacro MUI_PAGE_COMPONENTS
!insertmacro MUI_PAGE_INSTFILES
!insertmacro MUI_PAGE_FINISH

;--------------------------------
;Languages
!insertmacro MUI_LANGUAGE "English"

Section -SETTINGS
  SetOutPath "$INSTDIR"
  SetOverwrite ifnewer
SectionEnd

;--------------------------------
;Installer Sections

Section "Dummy Section" SecDummy

  SetOutPath "$INSTDIR"
  
  ;ADD YOUR OWN FILES HERE...
  

SectionEnd

;--------------------------------
; yotta dependencies
Section -prerequisites
  SetOutPath $INSTDIR\prerequisites
  
  ; install python with pip
  MessageBox MB_YESNO "python 2.7.10 with pip" /SD IDYES IDNO endpython
    File "..\prerequisites\python-2.7.10.msi"
    ExecWait '"msiexec" /i "$INSTDIR\prerequisites\python-2.7.10.msi"'
    Goto endpython
  endpython:

  ; install cmake
  MessageBox MB_YESNO "Install Cmake?" /SD IDYES IDNO endCmake
    File "..\prerequisites\cmake-3.2.1-win32-x86.exe"
    ExecWait "$INSTDIR\prerequisites\cmake-3.2.1-win32-x86.exe"
  endCmake:
  
  ; install gcc
  MessageBox MB_YESNO "Install GCC?" /SD IDYES IDNO endgcc
    File "..\prerequisites\gcc-arm-none-eabi-4_9-2015q2-20150609-win32.exe"
    ExecWait "$INSTDIR\prerequisites\gcc-arm-none-eabi-4_9-2015q2-20150609-win32.exe"
  endgcc:

  ; install ninja
  MessageBox MB_YESNO "Install Ninja?" /SD IDYES IDNO endninja
    File "..\prerequisites\ninja.exe"
    
    ; TODO: Copy Ninja to folder and add to path here
  endninja:

SectionEnd