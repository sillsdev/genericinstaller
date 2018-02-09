@echo off

REM Command line arguments and defined properties.
SET AppName=%1
SHIFT
SET SafeAppName=%1
SHIFT
SET Version=%1
SHIFT

REM Parse version numbers into pieces
for /f "tokens=1,2,3,4 delims=/." %%a in ("%Version%") do set Major=%%a&set Minor=%%b&set Build=%%c&set Revision=%%d
REM Truncated version is the first three parts of the version number
SET TRUNCATEDVERSION=%Major%.%Minor%.%Build%

REM The Product Id Guid should be changed to a new guid whenever the third (build) number of the version changes.  Also, when the product number changes you should create a new base installer.
SET PRODUCTIDGUID=%1
SHIFT
SET UPGRADECODEGUID=%1
SHIFT

SET APPBUILDDIR=%1
SHIFT
SET APPDATADIR=%1
SHIFT

REM File to be invoked by desktop shortcut.
SET ShortcutTargetName=%SafeAppName%.exe

REM To protect the password for the certfile, you can configure your build process to read the password from an unversioned file and pass it into the CERTPASS variable.
SET CopyrightYear=%1
SHIFT
SET Manufacturer=%1
SHIFT
SET CERTPATH=%1
SHIFT
SET CERTPASS=%1

@echo on
@REM Harvest (heat) the application and data files.
heat.exe dir %APPBUILDDIR% -cg HarvestedAppFiles -gg -scom -sreg -sfrag -srd -sw5150 -sw5151 -dr APPFOLDER -var var.APPBUILDDIR -t KeyPathFix.xsl -out AppHarvest.wxs
heat.exe dir %APPDATADIR% -cg HarvestedDataFiles -gg -scom -sreg -sfrag -srd -sw5150 -sw5151 -dr DATAFOLDER -var var.APPDATADIR -t KeyPathFix.xsl -out DataHarvest.wxs

@REM Compile (candle) and Link (light) the MSI file.
candle.exe -dApplicationName=%AppName% -dSafeApplicationName=%SafeAppName% -dManufacturer=%Manufacturer% -dVersionNumber=%Version% -dMajorVersion=%Major% -dMinorVersion=%Minor% -dAPPBUILDDIR=%APPBUILDDIR% -dAPPDATADIR=%APPDATADIR% -dUpgradeCode=%UPGRADECODEGUID% -dProductCode=%PRODUCTIDGUID% -dShortcutTargetName=%ShortcutTargetName% Framework.wxs AppHarvest.wxs DataHarvest.wxs WixUI_DialogFlow.wxs GIInstallDirDlg.wxs GIProgressDlg.wxs GIWelcomeDlg.wxs GICustomizeDlg.wxs GISetupTypeDlg.wxs

light.exe Framework.wixobj AppHarvest.wixobj DataHarvest.wixobj WixUI_DialogFlow.wixobj GIInstallDirDlg.wixobj GIProgressDlg.wixobj GIWelcomeDlg.wixobj GICustomizeDlg.wixobj GISetupTypeDlg.wixobj -ext WixUIExtension -ext WixUtilExtension.dll -cultures:en-us -loc WixUI_en-us.wxl -sw1076 -out %SafeAppName%_%Version%.msi

call signingProxy %SafeAppName%_%Version%.msi

@REM build the ONLINE EXE bundle.
candle.exe -dApplicationName=%AppName% -dSafeApplicationName=%SafeAppName% -dYear=%CopyrightYear% -dManufacturer=%Manufacturer% -dVersionNumber=%Version% -dUpgradeCode=%UPGRADECODEGUID% -dTruncatedVersion=%TRUNCATEDVERSION% -ext WixUtilExtension -ext WixBalExtension -ext WixUIExtension -ext WixNetFxExtension -ext WixDependencyExtension Bundle.wxs

light.exe Bundle.wixobj -ext WixUIExtension -ext WixBalExtension -ext WixUtilExtension -ext WixNetFxExtension -ext WixDependencyExtension -out %SafeAppName%_%Version%_Online.exe

@REM build the OFFLINE EXE bundle.
candle.exe -dApplicationName=%AppName% -dSafeApplicationName=%SafeAppName% -dYear=%CopyrightYear% -dManufacturer=%Manufacturer% -dVersionNumber=%Version% -dUpgradeCode=%UPGRADECODEGUID% -dTruncatedVersion=%TRUNCATEDVERSION% -ext WixUtilExtension -ext WixBalExtension -ext WixUIExtension -ext WixNetFxExtension -ext WixDependencyExtension OfflineBundle.wxs

light.exe OfflineBundle.wixobj -ext WixUIExtension -ext WixBalExtension -ext WixUtilExtension -ext WixNetFxExtension -ext WixDependencyExtension -out %SafeAppName%_%Version%_Offline.exe

@REM Sign the standard installer.
insignia -ib %SafeAppName%_%Version%_Online.exe -o engine.exe
call signingProxy engine.exe
insignia -ab engine.exe %SafeAppName%_%Version%_Online.exe -o %SafeAppName%_%Version%_Online.exe
call signingProxy %SafeAppName%_%Version%_Online.exe

@REM Sign the offline installer.
insignia -ib %SafeAppName%_%Version%_Offline.exe -o engine.exe
call signingProxy engine.exe
insignia -ab engine.exe %SafeAppName%_%Version%_Offline.exe -o %SafeAppName%_%Version%_Offline.exe
call signingProxy %SafeAppName%_%Version%_Offline.exe

@REM Cleanup debris from this build
DEL *.wixobj
DEL *.wixpdb
DEL engine.exe
DEL AppHarvest.wxs
DEL DataHarvest.wxs