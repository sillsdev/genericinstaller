@REM Subroutine to sign, if able
@REM Usage (requires %CERTPATH% and %CERTPASS% to be set ahead of time, if needed)
@REM Will return exit code of 1 unless you set %FAILIFUNSIGNED% to 0
@REM   signingProxy.bat FileToSign


if "%FAILIFUNSIGNED%" == "" set FAILIFUNSIGNED=1

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
		exit /b %FAILIFUNSIGNED%
	)
)
