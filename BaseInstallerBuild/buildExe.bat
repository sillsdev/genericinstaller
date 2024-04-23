@echo off
call setVars.bat %*

SET HASSIGNEDMSI=%1
SHIFT

REM build the ONLINE EXE bundle.
(
    candle.exe -arch %Arch% -dApplicationName=%AppName% -dSafeApplicationName=%SafeAppName% -dYear=%CopyrightYear% -dManufacturer=%Manufacturer% -dSafeManufacturer=%SafeManufacturer% -dVersionNumber=%Version% -dUpgradeCode=%UPGRADECODEGUID% -dTruncatedVersion=%TRUNCATEDVERSION% -ext WixFirewallExtension -ext WixUtilExtension -ext WixBalExtension -ext WixUIExtension -ext WixNetFxExtension -ext WixDependencyExtension Bundle.wxs
) && (
    light.exe Bundle.wixobj -ext WixFirewallExtension -ext WixUIExtension -ext WixBalExtension -ext WixUtilExtension -ext WixNetFxExtension -ext WixDependencyExtension %SuppressICE% -out %SafeAppName%_%Version%_Online.exe
) && (
    REM build the OFFLINE EXE bundle.
    candle.exe -arch %Arch% -dApplicationName=%AppName% -dSafeApplicationName=%SafeAppName% -dYear=%CopyrightYear% -dManufacturer=%Manufacturer% -dSafeManufacturer=%SafeManufacturer% -dVersionNumber=%Version% -dUpgradeCode=%UPGRADECODEGUID% -dTruncatedVersion=%TRUNCATEDVERSION% -ext WixFirewallExtension -ext WixUtilExtension -ext WixBalExtension -ext WixUIExtension -ext WixNetFxExtension -ext WixDependencyExtension OfflineBundle.wxs
) && (
    light.exe OfflineBundle.wixobj -ext WixFirewallExtension -ext WixUIExtension -ext WixBalExtension -ext WixUtilExtension -ext WixNetFxExtension -ext WixDependencyExtension %SuppressICE% -out %SafeAppName%_%Version%_Offline.exe
) && (
    REM sign and clean up only if the build succeeded

    REM Extract and sign the msi from the bundled exe if HASSIGNEDMSI is not set.
    if not defined HASSIGNEDMSI (
        insignia -ib %SafeAppName%_%Version%_Online.exe -o engine.exe
        call signingProxy engine.exe
        insignia -ab engine.exe %SafeAppName%_%Version%_Online.exe -o %SafeAppName%_%Version%_Online.exe
    )
    call signingProxy %SafeAppName%_%Version%_Online.exe

    REM Extract and sign the msi from the bundled offline exe if HASSIGNEDMSI is not set.
    if not defined HASSIGNEDMSI (
        insignia -ib %SafeAppName%_%Version%_Offline.exe -o engine.exe
        call signingProxy engine.exe
        insignia -ab engine.exe %SafeAppName%_%Version%_Offline.exe -o %SafeAppName%_%Version%_Offline.exe
    )
    call signingProxy %SafeAppName%_%Version%_Offline.exe

    REM Cleanup debris from this build
    DEL *.wixobj
    DEL *.wixpdb
    DEL engine.exe
    DEL AppHarvest.wxs
    DEL DataHarvest.wxs
)
