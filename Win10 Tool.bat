:::::::::::::::::::::::::::::::::::::::::
:: Automatically check & get admin rights
:::::::::::::::::::::::::::::::::::::::::
@echo off
CLS

:checkPrivileges
NET FILE 1>NUL 2>NUL
if '%errorlevel%' == '0' ( goto gotPrivileges ) else ( goto getPrivileges )

:getPrivileges
if '%1'=='ELEV' (shift & goto gotPrivileges)

setlocal DisableDelayedExpansion
set "batchPath=%~0"
setlocal EnableDelayedExpansion
ECHO Set UAC = CreateObject^("Shell.Application"^) > "%temp%\OEgetPrivileges.vbs"
ECHO UAC.ShellExecute "!batchPath!", "ELEV", "", "runas", 1 >> "%temp%\OEgetPrivileges.vbs"
"%temp%\OEgetPrivileges.vbs"
exit /B

:gotPrivileges
::::::::::::::::::::::::::::
::START
::::::::::::::::::::::::::::

@echo off

setlocal enableDelayedExpansion

REM I'm annoyed with having to redo a bunch of .reg shit every time I re-install
REM this should consolidate most of that into one process

REM Initialize variables:

set "useUniversal="
set "useDarkTheme="
set "removeLoginBackground="
set /a windowsTen=0

REM We need to get the OS version too, and only allow certain things on their
REM respective versions so we don't clutter shit up.
REM
call :getWindowsMajorVersion vers
call :getWindowsVersion winVers

if "!vers!"=="" (
	cls
	echo ###     ###
	echo # WARNING #
	echo ###     ###
	echo.
	echo Invalid Windows version -
	echo press any key to quit.
	echo.
	pause > nul
	exit /b
)

if !vers! GEQ 10 set /a windowsTen=1

:main
cls
echo    ###                      ###
echo   # Win10 Tool - by CorpNewt #
echo  ###                      ###
echo [Windows !winVers!]
echo.

REM Here's where we check our reg status - and update
REM our menus accordingly.

REM First - let's check for Universal Time
for /f "tokens=3*" %%i in ('reg.exe query "HKLM\SYSTEM\CurrentControlSet\Control\TimeZoneInformation" /v "RealTimeIsUniversal" 2^> nul') do (
	if NOT "%%i"=="" (
		set useUniversal=%%i
	)
)
if /i "!useUniversal:~-1,1!"=="1" (
	REM We are using Universal Time
	echo 1. [DISABLE] Universal Time
) else (
	echo 1. [ENABLE]  Universal Time
)

REM Now we see if we're on Windows 10 or not
if !vers! LSS 10 (
	echo #. [N/A]     Dark Theme          [Windows 10 ONLY]
	echo #. [N/A]     Login BG Solid Color [Windows 10 ONLY]
) else (
	REM Let's check for Dark Theme
	for /f "tokens=3*" %%i in ('reg.exe query "HKCU\SOFTWARE\Microsoft\Windows\CurrentVersion\Themes\Personalize" /v "AppsUseLightTheme" 2^> nul') do (
		if NOT "%%i"=="" (
			set useDarkTheme=%%i
		)
	)
	if /i "!useDarkTheme:~-1,1!"=="0" (
		REM We are using Dark Theme
		echo 2. [DISABLE] Dark Theme
	) else (
		echo 2. [ENABLE]  Dark Theme
	)
	
	REM Let's check for Login Background
	for /f "tokens=3*" %%i in ('reg.exe query "HKLM\SOFTWARE\Policies\Microsoft\Windows\System" /v "DisableLogonBackgroundImage" 2^> nul') do (
		if NOT "%%i"=="" (
			set removeLoginBackground=%%i
		)
	)
	if /i "!removeLoginBackground:~-1,1!"=="1" (
		REM We are using Login Background
		echo 3. [DISABLE] Login BG Solid Color
	) else (
		echo 3. [ENABLE]  Login BG Solid Color
	)
)
echo.
echo Q. Quit
echo.
set /p "menu=Please select an option to [DISABLE]/[ENABLE]:  "

if "!menu!"=="" goto main
if /i "!menu!"=="q" exit /b

REM Options independent of Windows version
if "!menu!"=="1" goto switchUniversalTime

REM Options DEPENDENT on Windows version 10+
if !vers! GEQ 10 (
	if "!menu!"=="2" goto switchDarkTheme
	if "!menu!"=="3" goto switchLoginBackground
)
goto main

:switchUniversalTime
cls
echo    ###                      ###
echo   # Win10 Tool - by CorpNewt #
echo  ###                      ###
echo [Windows !winVers!]
echo.
if /i "!useUniversal:~-1,1!"=="1" (
	echo [DISABLING] Universal Time
	set "useUniversal=0"
) else (
	echo [ENABLING]  Universal Time
	set "useUniversal=1"
)
call :writeReg "HKLM\SYSTEM\CurrentControlSet\Control\TimeZoneInformation" "RealTimeIsUniversal" "REG_DWORD" "!useUniversal!"
goto main

:switchDarkTheme
cls
echo    ###                      ###
echo   # Win10 Tool - by CorpNewt #
echo  ###                      ###
echo [Windows !winVers!]
echo.
if /i "!useDarkTheme:~-1,1!"=="0" (
	echo [DISABLING]  Dark Theme
	set "useDarkTheme=1"
) else (
	echo [ENABLING]  Dark Theme
	set "useDarkTheme=0"
)
call :writeReg "HKCU\SOFTWARE\Microsoft\Windows\CurrentVersion\Themes\Personalize" "AppsUseLightTheme" "REG_DWORD" "!useDarkTheme!"
goto main

:switchLoginBackground
cls
echo    ###                      ###
echo   # Win10 Tool - by CorpNewt #
echo  ###                      ###
echo [Windows !winVers!]
echo.
if /i "!removeLoginBackground:~-1,1!"=="1" (
	echo [DISABLING] Login BG Solid Color
	set "removeLoginBackground=0"
) else (
	echo [ENABLING]  Login BG Solid Color
	set "removeLoginBackground=1"
)
call :writeReg "HKLM\SOFTWARE\Policies\Microsoft\Windows\System" "DisableLogonBackgroundImage" "REG_DWORD" "!removeLoginBackground!"
goto main

:writeReg <location> <variableName> <variableType> <value>
echo.
echo %~1
echo ----^> %~2 = %~4
echo.
REG ADD "%~1" /V %~2 /T %~3 /D %~4 /F
echo.
echo Done.
echo.
timeout 5 > nul
goto :EOF

pause


REM ###############################################
REM ###             Helper Methods              ###
REM ###############################################

:getWindowsVersion <result>
for /f "tokens=2 delims=[]" %%x in ('ver') do set WINVER=%%x
set %~1=%WINVER:Version =%
goto :EOF

:getWindowsMajorVersion <result>
for /f "tokens=2 delims=[]" %%x in ('ver') do set WINVER=%%x
set WINVER=%WINVER:Version =%
for /f "tokens=1,2,3* delims=." %%a in ("!WINVER!") do set %~1=%%a
goto :EOF

:getWindowsMinorVersion <result>
for /f "tokens=2 delims=[]" %%x in ('ver') do set WINVER=%%x
set WINVER=%WINVER:Version =%
for /f "tokens=1,2,3* delims=." %%a in ("!WINVER!") do set %~1=%%b
goto :EOF

:getWindowsBuildVersion <result>
for /f "tokens=2 delims=[]" %%x in ('ver') do set WINVER=%%x
set WINVER=%WINVER:Version =%
for /f "tokens=1,2,3* delims=." %%a in ("!WINVER!") do set %~1=%%c
goto :EOF