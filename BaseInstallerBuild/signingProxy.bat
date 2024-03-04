@REM Subroutine to sign, if able
@REM Usage (requires %CERTPATH% and %CERTPASS% to be set ahead of time, if needed):
@REM   signingProxy.bat FileToSign

if "%UNSIGNEDISOK%" == "" set UNSIGNEDISOK=1

where sign >nul 2>nul
if %errorlevel%==0 (
	sign %*
) else (
	where signtool.exe >nul 2>nul
	if %errorlevel%==0 (
		echo Signing with specified code signing certificate ...
		signtool.exe sign /fd sha256 /f %CERTPATH% /p %CERTPASS% /t http://timestamp.comodoca.com/authenticode %*
	)
	if not %errorlevel%==0 (
		echo Unable to sign %1; skipping.
		exit /b %UNSIGNEDISOK%
	)
)
