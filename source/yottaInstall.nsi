; Yotta Windows Installer
;
; This script installs the yotta dependencies and then yotta itself
; pip is installed as part of python, it is assumed to exist on the user system
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
  !define PRODUCT_VERSION   "0.0.1"
  !define PRODUCT_PUBLISHER "ARM®mbed™"
  !define PYTHON_INSTALLER  "python-2.7.10.msi"
  !define GCC_INSTALLER     "gcc-arm-none-eabi-4_9-2015q2-20150609-win32.exe"
  !define CMAKE_INSTALLER   "cmake-3.2.1-win32-x86.exe"
  !define NINJA_INSTALLER   "ninja.exe"

  Name "${PRODUCT_NAME} ${PRODUCT_VERSION}"
  OutFile "yotta_install_v${PRODUCT_VERSION}.exe"
  InstallDir "$PROGRAMFILES\yotta"
  ShowInstDetails show


  ;Request application privileges
  RequestExecutionLevel admin

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
;Ensure Admin Rights for runtime
Function .onInit
UserInfo::GetAccountType
pop $0
${If} $0 != "admin" ;Require admin rights on NT4+
        MessageBox mb_iconstop "Administrator rights required!"
        SetErrorLevel 740 ;ERROR_ELEVATION_REQUIRED
        Quit
${EndIf}
FunctionEnd

;--------------------------------
;Installer Sections

Section "python 2.7.10" SecPython
  SetOutPath $INSTDIR
  MessageBox MB_OK "Installing python: make sure to select check box to add to path."
  File "..\prerequisites\${PYTHON_INSTALLER}"
  ExecWait '"msiexec" /i "$INSTDIR\${PYTHON_INSTALLER}"'
SectionEnd

Section "gcc" SecGCC
  MessageBox MB_OK "Installing GCC: make sure to select check box to add to path."
  File "..\prerequisites\${GCC_INSTALLER}"
  ExecWait "$INSTDIR\${GCC_INSTALLER}"
SectionEnd

Section "cMake" SecCmake
  MessageBox MB_OK "Installing Cmake: make sure to select check box to add to path." 
  File "..\prerequisites\${CMAKE_INSTALLER}"
  ExecWait "$INSTDIR\${CMAKE_INSTALLER}"
SectionEnd

Section "ninja" SecNinja
  File "..\prerequisites\${NINJA_INSTALLER}"
  ExecWait '"setx" PATH "%PATH%;$INSTDIR"' ; setx is a windows vista,7,8,10 command to modify the path, here we are adding the yotta directory to the path
  ; note: this will fail on XP, XP users are not covered and will need to add ninja to their path manually
SectionEnd

Section "yotta (requires pip)" SecYotta
  File "..\source\pip_install_yotta.bat"
  ExecWait "$INSTDIR\pip_install_yotta.bat"
SectionEnd

