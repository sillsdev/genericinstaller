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

SET MASTERBUILDDIR=%1
SHIFT
SET MASTERDATADIR=%1
SHIFT

REM To protect the password for the certfile, you can configure your build process to read the password from an unversioned file and pass it into the CERTPASS variable.
SET CopyrightYear=%1
SHIFT
SET Manufacturer=%1
SHIFT
SET SafeManufacturer=%1
SHIFT
SET Arch=%1
if "%Arch%" == "" set Arch=x86

REM ICE validation must be run with admin privileges. The jenkins user is not an admin. Suppress ICE validation so it doesn't fail.
REM For some reason, ICE08 works without admin, and the quickest way to suppress everything else on the command line is to specify one ICE to run.
C:\Windows\System32\whoami /groups | find "BUILTIN\Administrators" > nul 2> nul
if errorlevel 1 set SuppressICE=-ice:ICE08

REM Ensure WiX tools are on the PATH
where heat >nul 2>nul
if not %errorlevel% == 0 set PATH=%WIX%/bin;%PATH%

REM single quotes, since we expect %msbuild% is already double giquoted
if  '%msbuild%' == '' set msbuild=msbuild

(
	@echo on
	@REM CustomActions are built by WiX magic; ProcRunner must be built normally.
	@REM Although there are no NuGet packages to restore, the Restore target is required to generate project.assets.json
	%msbuild% ../ProcRunner/ProcRunner.sln /p:Configuration=Release /t:Restore;Rebuild

) && (
	@REM Harvest (heat) the application and data files.
	heat.exe dir %MASTERBUILDDIR% -cg HarvestedAppFiles -gg -scom -sreg -sfrag -srd -sw5150 -sw5151 -dr APPFOLDER -var var.MASTERBUILDDIR -t KeyPathFix.xsl -out AppHarvest.wxs
	heat.exe dir %MASTERDATADIR% -cg HarvestedDataFiles -gg -scom -sreg -sfrag -srd -sw5150 -sw5151 -dr HARVESTDATAFOLDER -var var.MASTERDATADIR -t KeyPathFix.xsl -out DataHarvest.wxs
) && (
	@REM Compile (candle) and Link (light) the MSI file.
	candle.exe -arch %Arch% -dApplicationName=%AppName% -dSafeApplicationName=%SafeAppName% -dManufacturer=%Manufacturer% -dSafeManufacturer=%SafeManufacturer% -dVersionNumber=%Version% -dMajorVersion=%Major% -dMinorVersion=%Minor% -dMASTERBUILDDIR=%MASTERBUILDDIR% -dMASTERDATADIR=%MASTERDATADIR% -dUpgradeCode=%UPGRADECODEGUID% -dProductCode=%PRODUCTIDGUID% Framework.wxs AppHarvest.wxs DataHarvest.wxs WixUI_DialogFlow.wxs GIInstallDirDlg.wxs GIProgressDlg.wxs GIWelcomeDlg.wxs GICustomizeDlg.wxs GISetupTypeDlg.wxs -ext WixFirewallExtension -ext WixUtilExtension
) && (
	light.exe Framework.wixobj AppHarvest.wixobj DataHarvest.wixobj WixUI_DialogFlow.wixobj GIInstallDirDlg.wixobj GIProgressDlg.wixobj GIWelcomeDlg.wixobj GICustomizeDlg.wixobj GISetupTypeDlg.wixobj -ext WixFirewallExtension -ext WixUIExtension -ext WixUtilExtension -cultures:en-us -loc WixUI_en-us.wxl %SuppressICE% -sw1076 -out %SafeAppName%_%Version%.msi
) && (
	call signingProxy %SafeAppName%_%Version%.msi
)