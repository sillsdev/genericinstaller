@echo off

REM cause Environment variable changes to be lost after this process dies:
if not "%OS%"=="" setlocal

REM TODO: find and run VSVars

(
	MSBuild Sample.targets /t:DownloadBuildTasks
) && (
	MSBuild Sample.targets /t:BuildRelease
)