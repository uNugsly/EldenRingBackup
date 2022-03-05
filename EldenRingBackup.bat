@echo off
setlocal EnableDelayedExpansion

echo "Elden Ring Backup Tool"
echo "Version 1.0"
echo "/u/Nugsly"

echo "This tool will set a scheduled task that will"
echo "back up the Elden Ring save files on a daily basis."
echo "This will help ease the potential pain of a save"
echo "file getting corrupted and will allow you to go back"
echo "to any day's save and continue where you left off." 

set "isFirstRun="
set "baseDir=%appdata%\EldenRing"

:get_game_subdirectory
	for /f "tokens=* delims=" %%a in ('dir /b /ad "%baseDir%"') do (
		set "subDir=%%~a"
		goto create_directory_structure
	)

:create_directory_structure
	set "fullPath=%baseDir%\%subDir%"
	set "backupsPath=%fullPath%\Backups"
	
	if not exist "%backupsPath%" (
		set "isFirstRun=y"
		goto scheduled_task
	)
	
	mkdir %backupsPath%
	
	set "hr=%time:~0,2%"
	if "%hr:~0,1%" equ " " (
		set hr=0%hr:~1,1%
	)
	
	set "backupFolderName=%date:~-4,4%%date:~-10,2%%date:~-7,2%_%hr%%time:~3,2%%time:~6,2%"
	set "destination=%backupsPath%\%backupFolderName%"
	
	mkdir %destination%

:do_backup
	for /f %%a in ('dir /b /a-d "%fullPath%"') do (
		copy "%fullPath%\%%a" "%destination%" >nul
	)

	if defined "%isFirstRun%" (
		goto exit
	)

:scheduled_task
	net session >nul 2>&1
	if not %errorLevel% == 0 (
		echo.
		echo.
		echo "First off, it looks like this is your first time running this script."
		echo "In order to create the scheduled tasks that this script needs"
		echo "to run at each logon/daily, the script needs to be run as Adminstrator."
		echo.
		echo "Right-click the script and select Run as Administrator."
		echo.
		pause
		exit
	)
	
	if not "%~dp0" == "%baseDir%" (
		echo "%~f0"
		copy "%~f0" "%baseDir%"
	)
	
	schtasks /create /sc onlogon /tn "Elden Ring Backup - Logon" /tr "%baseDir%\%~n0%~x0"
	schtasks /create /sc daily /tn "Elden Ring Backup - Daily" /tr "%baseDir%\%~n0%~x0"
