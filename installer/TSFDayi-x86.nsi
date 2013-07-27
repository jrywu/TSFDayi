; Script generated by the HM NIS Edit Script Wizard.

!include "Registry.nsh"
!include x64.nsh

; HM NIS Edit Wizard helper defines
!define PRODUCT_NAME "TSFDayi"
!define PRODUCT_VERSION "1.0"
!define PRODUCT_PUBLISHER "Jeremy Wu"
!define PRODUCT_WEB_SITE "http://github.com/jrywu/TSFDayi"
!define PRODUCT_UNINST_KEY "Software\Microsoft\Windows\CurrentVersion\Uninstall\${PRODUCT_NAME}"
; ## HKLM = HKEY_LOCAL_MACHINE
!define PRODUCT_UNINST_ROOT_KEY "HKLM"

; ## HKCU = HKEY_CURRENT_USER

SetCompressor lzma

; MUI 1.67 compatible ------
!include "MUI.nsh"

; MUI Settings
!define MUI_ABORTWARNING
!define MUI_ICON "${NSISDIR}\Contrib\Graphics\Icons\modern-install.ico"
!define MUI_UNICON "${NSISDIR}\Contrib\Graphics\Icons\modern-uninstall.ico"
!define MUI_HEADERIMAGE 
!define MUI_HEADERIMAGE_NOSTRETCH
;!define MUI_HEADERIMAGE_BITMAP "ov-installer2.bmp"
;!define MUI_WELCOMEFINISHPAGE_BITMAP_NOSTRETCH
;!define MUI_WELCOMEFINISHPAGE_BITMAP "ov-installer.bmp"

; Language Selection Dialog Settings
!define MUI_LANGDLL_REGISTRY_ROOT "${PRODUCT_UNINST_ROOT_KEY}"
!define MUI_LANGDLL_REGISTRY_KEY "${PRODUCT_UNINST_KEY}"
!define MUI_LANGDLL_REGISTRY_VALUENAME "NSIS:Language"

; Welcome page
!insertmacro MUI_PAGE_WELCOME
; License page
;!insertmacro MUI_PAGE_LICENSE "LICENSE-zh-Hant.rtf"
; Directory page
;!insertmacro MUI_PAGE_DIRECTORY
; Instfiles page
!insertmacro MUI_PAGE_INSTFILES
; Finish page
!insertmacro MUI_PAGE_FINISH

; Uninstaller pages
!insertmacro MUI_UNPAGE_INSTFILES

; Language files
;!insertmacro MUI_LANGUAGE "English"
!insertmacro MUI_LANGUAGE "TradChinese"

; Reserve files
!insertmacro MUI_RESERVEFILE_INSTALLOPTIONS

; MUI end ------

Name "${PRODUCT_NAME} ${PRODUCT_VERSION}"
OutFile "TSFDayi-x86.exe"
InstallDir "$PROGRAMFILES\TSFDayi"
ShowInstDetails show
ShowUnInstDetails show
/*
Function uninstOld
  ExecWait '"$INSTDIR\uninst.exe" /S _?=$INSTDIR'
  ClearErrors
  ;Ensure the old IME is deleted
  IfFileExists "$SYSDIR\TSFDayi.dll" 0 ContinueUnist
  Call onInstError
ContinueUnist:      
FunctionEnd 

Function onInstError
   MessageBox MB_ICONSTOP|MB_OK "�w�˥��ѡA�нT�w�z���޲z���v���C"
   Abort
FunctionEnd
*/

Function .onInit
  ${If} ${RunningX64}
        MessageBox MB_OK "���w���ɬ�32bit����, �Э��s�U��64bit����"
        Abort
  ${EndIf}
  
  ReadRegStr $0 ${PRODUCT_UNINST_ROOT_KEY} "${PRODUCT_UNINST_KEY}" "DisplayVersion"
  StrCmp $0 "" StartInstall 0
  ;MessageBox MB_OK  "�������ª� $0�A�����������~��w�˷s���C"
  MessageBox MB_OKCANCEL|MB_ICONQUESTION "�������ª� $0�A�����������~��w�˷s���C�O�_�n�{�b�i��H" IDOK +2
  	Abort
  ExecWait '"$INSTDIR\uninst.exe" /S _?=$INSTDIR'
  IfFileExists "$SYSDIR\TSFDayi.dll"  0 RemoveFinished     ;�N���Ϧw�˥��� 
        Abort
  RemoveFinished:     
    	MessageBox MB_ICONINFORMATION|MB_OK "�ª��w�����C"       
StartInstall:     
;!insertmacro MUI_LANGDLL_DISPLAY


FunctionEnd


Function checkVCRedist
  Push $R0
  ;{3D6AD258-61EA-35F5-812C-B7A02152996E} for x86 VC 2012 Upate3
  ;{2EDC2FA3-1F34-34E5-9085-588C9EFD1CC6} for x64 VC 2012 Upate3
 ClearErrors
  ReadRegDword $R0 HKLM "SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall\{3D6AD258-61EA-35F5-812C-B7A02152996E}" "Version"
  IfErrors 0 VCRedistInstalled
  MessageBox MB_ICONQUESTION|MB_YESNO "�ݭn MS VC++ 2012 x86 Redistributable�A�z�n�~��o���w�˶�?" IDNO VCRedistInstalledAbort
  File "VCRedist\vcredist_x86.exe"
  ExecWait '"$INSTDIR\vcredist_x86.exe" /q' # silent install
  Goto VCRedistInstalled
VCRedistInstalledAbort:
  Quit
VCRedistInstalled:
  Exch $R0
FunctionEnd


Section "CheckVCRedist" VCR
  	call checkVCRedist
SectionEnd


Section "MainSection" SEC01
  SetOutPath "$SYSDIR"
  SetOverwrite ifnewer
  File "system32.x86\TSFDayi.dll"
  ExecWait '"$SYSDIR\regsvr32.exe" /s $SYSDIR\TSFDayi.dll'
  File "system32.x86\*.dll"
  
SectionEnd

Section "Modules" SEC02
SetOutPath $PROGRAMFILES
  SetOVerwrite ifnewer
  Delete "$INSTDIR\vcredist_x86.exe"

SectionEnd

Section -AdditionalIcons
  SetOutPath $SMPROGRAMS\TSFDayi
  CreateDirectory "$SMPROGRAMS\TSFDayi"
  CreateShortCut "$SMPROGRAMS\TSFDayi\Uninstall.lnk" "$PROGRAMFILES\TSFDayi\uninst.exe"
SectionEnd

Section -Post
  CreateDirectory "$PROGRAMFILES\TSFDayi"
  WriteUninstaller "$PROGRAMFILES\TSFDayi\uninst.exe"
  WriteRegStr ${PRODUCT_UNINST_ROOT_KEY} "${PRODUCT_UNINST_KEY}" "UninstallString" "$PROGRAMFILES\TSFDayi\uninst.exe"
  WriteRegStr ${PRODUCT_UNINST_ROOT_KEY} "${PRODUCT_UNINST_KEY}" "DisplayName" "${PRODUCT_NAME}"
  WriteRegStr ${PRODUCT_UNINST_ROOT_KEY} "${PRODUCT_UNINST_KEY}" "DisplayVersion" "${PRODUCT_VERSION}"
  WriteRegStr ${PRODUCT_UNINST_ROOT_KEY} "${PRODUCT_UNINST_KEY}" "URLInfoAbout" "${PRODUCT_WEB_SITE}"
  WriteRegStr ${PRODUCT_UNINST_ROOT_KEY} "${PRODUCT_UNINST_KEY}" "Publisher" "${PRODUCT_PUBLISHER}"
SectionEnd

Function un.onUninstSuccess  
  MessageBox MB_ICONINFORMATION|MB_OK "$(^Name)�w�������\�C" /SD IDOK
FunctionEnd

Function un.onInit
;!insertmacro MUI_UNGETLANGUAGE
  MessageBox MB_ICONQUESTION|MB_YESNO|MB_DEFBUTTON2 "�T�w�n��������$(^Name)�H" /SD IDYES IDYES +2
  Abort
FunctionEnd

Section Uninstall
  
  ExecWait '"$SYSDIR\regsvr32.exe" /u /s $SYSDIR\TSFDayi.dll'
  ClearErrors
  IfFileExists "$SYSDIR\OVIME.ime"  0 lbContinueUninstall
  Delete "$SYSDIR\TSFDayi.dll"
  IfErrors lbNeedReboot lbContinueUninstall

  lbNeedReboot:
  MessageBox MB_ICONSTOP|MB_YESNO "�����즳�{�����b�ϥο�J�k�A�Э��s�}���H�~�򲾰��ª��C�O�_�n�ߧY���s�}���H" IDNO lbNoReboot
  Reboot

  lbNoReboot:
  MessageBox MB_ICONSTOP|MB_OK "�бN�Ҧ��{�������A�A���հ��楻�w�˵{���C�Y���ݨ즹�e���A�Э��s�}���C" IDOK +1
  Quit
  lbContinueUninstall:
  Delete "$PROGRAMFILES\TSFDayi\uninst.exe"
  RMDir /r "$PROGRAMFILES\TSFDayi"
  Delete "$SMPROGRAMS\TSFDayi\Uninstall.lnk"
  DeleteRegKey ${PRODUCT_UNINST_ROOT_KEY} "${PRODUCT_UNINST_KEY}"
  SetAutoClose true
SectionEnd