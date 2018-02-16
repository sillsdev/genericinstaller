@echo off

SET AppName=%1
SHIFT
SET SafeAppName=%1
SHIFT
SET BaseVersion=%1
SHIFT
SET PatchVersion=%1
SHIFT

SET MASTERBUILDDIR=%1
SHIFT
SET UPDATEBUILDDIR=%1
SHIFT

SET MASTERDATADIR=%1
SHIFT
SET UPDATEDATADIR=%1
SHIFT

SET PRODUCTIDGUID=%1
SHIFT
SET UPGRADECODEGUID=%1
SHIFT
SET COMPGGS=%1
SHIFT

SET Manufacturer=%1
SHIFT
SET Arch=%1
if "%Arch%" == "" set Arch=x86

SET Baseline=%SafeAppName%Patch
SET Family=%Baseline%Family

REM Parse version numbers into pieces
for /f "tokens=1,2,3,4 delims=/." %%a in ("%BaseVersion%") do set bmaj=%%a&set bmin=%%b&set bbuild=%%c&set brev=%%d

for /f "tokens=1,2,3,4 delims=/." %%a in ("%PatchVersion%") do set pmaj=%%a&set pmin=%%b&set pbuild=%%c&set prev=%%d

@echo on
@REM Harvest the MASTER application
heat.exe dir %MASTERBUILDDIR% -cg HarvestedAppFiles -ag -scom -sreg -sfrag -srd -sw5150 -sw5151 -dr APPFOLDER -var var.MASTERBUILDDIR -out ./Master/AppHarvest.wxs
heat.exe dir %MASTERDATADIR% -cg HarvestedDataFiles -ag -scom -sreg -sfrag -srd -sw5150 -sw5151 -dr DATAFOLDER -var var.MASTERDATADIR -out ./Master/DataHarvest.wxs

@REM Build the No-UI msi containing the MASTER files
candle.exe -arch %Arch% -dApplicationName=%AppName% -dSafeApplicationName=%SafeAppName% -dMajorVersion=%bmaj% -dMinorVersion=%bmin% -dManufacturer=%Manufacturer% -dVersionNumber=%BaseVersion% -dMASTERBUILDDIR=%MASTERBUILDDIR% -dMASTERDATADIR=%MASTERDATADIR% -dUpgradeCode=%UPGRADECODEGUID% -dProductCode=%PRODUCTIDGUID% -dCompGGS=%COMPGGS% -out ./Master/ ./AppNoUi.wxs ./Master/AppHarvest.wxs ./Master/DataHarvest.wxs
light.exe ./Master/AppNoUi.wixobj ./Master/AppHarvest.wixobj ./Master/DataHarvest.wixobj -ext WixUtilExtension.dll -sw1076 -out ./Master/%SafeAppName%_%BaseVersion%.msi


@REM Harvest the UPDATE application
heat.exe dir %UPDATEBUILDDIR% -cg HarvestedAppFiles -ag -scom -sreg -sfrag -srd -sw5150 -sw5151 -dr APPFOLDER -var var.UPDATEBUILDDIR -out ./Update/AppHarvest.wxs
heat.exe dir %UPDATEDATADIR% -cg HarvestedDataFiles -ag -scom -sreg -sfrag -srd -sw5150 -sw5151 -dr DATAFOLDER -var var.UPDATEDATADIR -out ./Update/DataHarvest.wxs

@REM Build the No-UI msi containing the UPDATE files
candle.exe -arch %Arch% -dApplicationName=%AppName% -dSafeApplicationName=%SafeAppName% -dMajorVersion=%pmaj% -dMinorVersion=%pmin% -dManufacturer=%Manufacturer% -dVersionNumber=%PatchVersion% -dBaseVersionNumber=%BaseVersion% -dUPDATEBUILDDIR=%UPDATEBUILDDIR% -dUPDATEDATADIR=%UPDATEDATADIR% -dUpgradeCode=%UPGRADECODEGUID% -dProductCode=%PRODUCTIDGUID% -dCompGGS=%COMPGGS% -out ./Update/ ./AppNoUi.wxs ./Update/AppHarvest.wxs ./Update/DataHarvest.wxs 
light.exe ./Update/AppNoUi.wixobj ./Update/AppHarvest.wixobj ./Update/DataHarvest.wixobj -ext WixUtilExtension.dll -sw1076 -out ./Update/%SafeAppName%_%PatchVersion%.msi

@REM Create the transform between Master and Update
torch.exe -p -xi .\Master\%SafeAppName%_%BaseVersion%.wixpdb .\Update\%SafeAppName%_%PatchVersion%.wixpdb -out patch.wixmst

@REM Build the patch file
candle.exe -arch %Arch% -dAppName=%AppName% -dVersionNumber=%PatchVersion% -dProductCode=%PRODUCTIDGUID% -dManufacturer=%Manufacturer% -dPatchBaseline=%Baseline% -dPatchFamily=%Family% patch.wxs
light.exe patch.wixobj
pyro.exe patch.wixmsp -out %SafeAppName%_%PatchVersion%.msp -t %Baseline% patch.wixmst

call ..\BaseInstallerBuild\signingProxy %SafeAppName%_%PatchVersion%.msp


REM Cleanup debris from this build
DEL *.wixobj
DEL *.wixpdb
DEL *.wixmst
DEL *.wixmsp
DEL .\Master\*.msi
DEL .\Master\*.wixobj
DEL .\Master\*.wixpdb
DEL .\Master\AppHarvest.wxs
DEL .\Master\DataHarvest.wxs
DEL .\Update\*.msi
DEL .\Update\*.wixobj
DEL .\Update\*.wixpdb
DEL .\Update\AppHarvest.wxs
DEL .\Update\DataHarvest.wxs
