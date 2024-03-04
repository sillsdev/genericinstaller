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

REM build the ONLINE EXE bundle.
(
	candle.exe -arch %Arch% -dApplicationName=%AppName% -dSafeApplicationName=%SafeAppName% -dYear=%CopyrightYear% -dManufacturer=%Manufacturer% -dSafeManufacturer=%SafeManufacturer% -dVersionNumber=%Version% -dUpgradeCode=%UPGRADECODEGUID% -dTruncatedVersion=%TRUNCATEDVERSION% -ext WixFirewallExtension -ext WixUtilExtension -ext WixBalExtension -ext WixUIExtension -ext WixNetFxExtension -ext WixDependencyExtension Bundle.wxs
) && (
	light.exe Bundle.wixobj -ext WixFirewallExtension -ext WixUIExtension -ext WixBalExtension -ext WixUtilExtension -ext WixNetFxExtension -ext WixDependencyExtension %SuppressICE% -out %SafeAppName%_%Version%_Online.exe
) && (
	@REM build the OFFLINE EXE bundle.
	candle.exe -arch %Arch% -dApplicationName=%AppName% -dSafeApplicationName=%SafeAppName% -dYear=%CopyrightYear% -dManufacturer=%Manufacturer% -dSafeManufacturer=%SafeManufacturer% -dVersionNumber=%Version% -dUpgradeCode=%UPGRADECODEGUID% -dTruncatedVersion=%TRUNCATEDVERSION% -ext WixFirewallExtension -ext WixUtilExtension -ext WixBalExtension -ext WixUIExtension -ext WixNetFxExtension -ext WixDependencyExtension OfflineBundle.wxs
) && (
	light.exe OfflineBundle.wixobj -ext WixFirewallExtension -ext WixUIExtension -ext WixBalExtension -ext WixUtilExtension -ext WixNetFxExtension -ext WixDependencyExtension %SuppressICE% -out %SafeAppName%_%Version%_Offline.exe
) && (
	@REM sign and clean up only if the build succeeded

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
)