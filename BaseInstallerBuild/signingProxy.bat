@REM Subroutine to sign, if able
@REM Usage (requires %CERTPATH% and %CERTPASS% to be set ahead of time, if needed):
@REM   signingProxy.bat FileToSign

where sign >nul 2>nul
if %errorlevel%==0 (
	sign %1
	exit /b
)
@REM silently skip signing if no certificate has been specified (two checks are needed because an empty path may be passed as a pair of quotes)
if '%CERTPATH%'=='' exit /b
if %CERTPATH%=="" exit /b
where signtool.exe >nul 2>nul
if %errorlevel%==0 (
	echo Signing with specified code signing certificate ...
	signtool.exe sign /f %CERTPATH% /p %CERTPASS% %1
) else (
	echo Unable to sign; skipping: %1
)
