:::::::::::::::::::::::::::::::::::::::::
:: Automatically check & get admin rights
:::::::::::::::::::::::::::::::::::::::::
@echo off
CLS
ECHO.
ECHO =============================
ECHO Running Admin shell
ECHO =============================

:checkPrivileges
NET FILE 1>NUL 2>NUL
if '%errorlevel%' == '0' ( goto gotPrivileges ) else ( goto getPrivileges )

:getPrivileges
if '%1'=='ELEV' (shift & goto gotPrivileges)
ECHO.
ECHO **************************************
ECHO Invoking UAC for Privilege Escalation
ECHO **************************************

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
setlocal enabledelayedexpansion
set myIP=

:mainMenu
cls
call :color 08 "Current interfaces:"
echo.
echo.

REM netsh interface show interface
set interfaceName=
set interfaceEnabled=
set interfaceConnected=
set /a interfaceCount=-1

if "%myIP%"=="" (
	REM We're going to get our external IP next
	REM We only want to get it once because it takes a second or 2 for the dns lookup
	for /f "delims=: skip=4 tokens=1,2*" %%i in ('nslookup myip.opendns.com resolver1.opendns.com 2^>^&1') do (
		set myIP=%%j
	)
	set "myIP=!myIP: =!"
)

REM Holy shit, this is some crazy stuff...
REM This section performs the command 'Netsh Interface Show Interface'
REM which lists all current interfaces as well as their admin state,
REM state, type, and etc, then it breaks that down to organize 2 variables.
REM interfaceName is an array of the interface names, designated by %%c
REM interfaceConnect is an array of Enabled or Disabled strings.
REM To get these values, we use a For loop.
REM The "skip=2 tokens=1,2,3*" part means that we are going to skip the first
REM 2 lines of the Netsh output, then put the first item separated by our
REM delimiters (which are space and tab by default) into the first variable
REM (which starts at %%a and then goes to %%b and etc) and then put the second
REM item into variable 2 (%%b) the third variable into %%c (which we won't use)
REM and everything else into variable 4 (%%d).
REM The output of Netsh leaves the interface name for the very last variable
REM and the Enabled/Disabled state for the first so we will use variables
REM %%a, %%b, and %%d respectively.  Everything else gets stuck in %%c which we
REM won't even need to touch.  It just acts as a place holder so we can
REM easily capture the interface name no matter how many spaces it has.

For /f "skip=2 tokens=1,2,3*" %%a In ('NetSh Interface Show Interface') Do (
  set /a interfaceCount+=1
  if !interfaceCount! GTR 0 (
    set interfaceEnabled[!interfaceCount!]=%%a
    set interfaceConnect[!interfaceCount!]=%%b
    set interfaceName[!interfaceCount!]=%%d
REM echo !interfaceCount!. %%d: 
REM %%a - %%b
    set enabledColor=0c
    set connectedColor=0c
    if "%%a"=="Enabled" set enabledColor=0a
    if "%%b"=="Connected" set connectedColor=0a
    call :color 08 "!interfaceCount!. "
    call :color 07 "%%d"
    call :color 08 ": "
    call :color !enabledColor! %%a
    call :color 08 " - "
    call :color !connectedColor! %%b
    echo.

    REM Let's get the IP address of connected interfaces and display them
    REM below in the color blue... I hope haha

    if "%%b"=="Connected" (
	set theName=%%d
        REM This should ONLY happen if we're connected!

	REM This next part gets our IP Address all by its lonesome
	For /f "tokens=3,*" %%f In ('NetSh Interface IP Show Address ^"!theName!^" ^| FindSTR ^"IP Address:^"') Do (

	    REM So we set our first colors to gray, and then the IP colors
	    REM to light aqua to make them pop a bit and stand out.

	    call :color 08 "     IP Address: "
	    call :color 0b "%%f"

	)

    ) else (

	REM We are not a connected device, so we won't have an IP
	REM Let's show the user this bit of awesome so they know.

	call :color 08 "     IP Address: "
	call :color 0c "Not Connected"

    )
    echo.
    echo.
  )
)
call :color 07 "External IP: "
call :color 0b "%myIP%"
echo.
echo.
call :color 08 "D. Disable All"
echo.
call :color 08 "E. Enable All"
echo.
call :color 08 "T. Toggle All"
echo.
call :color 08 "S. Switch Off and Pause"
echo.
call :color 08 "R. Refresh"
echo.
call :color 08 "Q. Quit"
echo.

echo.
echo.

set /p menu=Which interface would you like to adjust (1-!interfaceCount!): %=%

if "!menu!"=="" goto mainMenu
if /i "!menu!" == "q" goto quit
if /i "!menu!" == "r" (
	REM We're refreshing here, that means we're going to
	REM re-get our external IP too, so let's reset it
	set myIP=
	goto mainMenu
)
if /i "!menu!" == "d" goto allOff
if /i "!menu!" == "e" goto allOn
if /i "!menu!" == "t" goto toggleAll
if /i "!menu!" == "s" goto switchPause

if !menu! GTR !interfaceCount! (
  goto mainMenu
)

if "!interfaceEnabled[%menu%]!" == "Enabled" goto disabled
if "!interfaceEnabled[%menu%]!" == "Disabled" goto enabled

goto mainMenu



:allOff
cls

set "whatSwitch="

for /l %%x in (1, 1, !interfaceCount!) do (
	cls
	call :color 0c "Disabling "
	call :color 08 "all interfaces..."
	echo.
	echo.

	set whatSwitch[%%x]=Disabled

	for /l %%a in (1, 1, %%x) do (
		call :color 08 "%%a. "
		call :color 07 "!interfaceName[%%a]!"
		call :color 08 ": "
		if "!whatSwitch[%%a]!"=="Enabled" (
			call :color 0a "Done."
		) else (
			call :color 0c "Done."
		)
		echo.
	)
	echo.
	echo.
	if "!interfaceEnabled[%%x]!" == "Enabled" (
		call :color 08 "Disabling "
		call :color 07 "!interfaceName[%%x]!"
		call :color 08 "..."
		echo.
		echo.
		echo.
		call :color 08 "Netsh Interface Set Interface '"
		call :color 07 "!interfaceName[%%x]!"
		call :color 08 "' "
		call :color 0c "DISABLED"
		echo.
		netsh interface set interface "!interfaceName[%%x]!" DISABLED
		echo.
	) else (
		call :color 08 "Interface "
		call :color 07 "!interfaceName[%%x]! "
		call :color 08 "already disabled."
		echo.
		echo.
	)
)

call :color 0a "Done."
echo.
echo.
timeout 5

goto mainMenu


:allOn
cls

set "whatSwitch="

for /l %%x in (1, 1, !interfaceCount!) do (
	cls
	call :color 0a "Enabling "
	call :color 08 "all interfaces..."
	echo.
	echo.

	set whatSwitch[%%x]=Enabled

	for /l %%a in (1, 1, %%x) do (
		call :color 08 "%%a. "
		call :color 07 "!interfaceName[%%a]!"
		call :color 08 ": "
		if "!whatSwitch[%%a]!"=="Enabled" (
			call :color 0a "Done."
		) else (
			call :color 0c "Done."
		)
		echo.
	)
	echo.
	echo.
	if "!interfaceEnabled[%%x]!" == "Disabled" (
		call :color 08 "Enabling "
		call :color 07 "!interfaceName[%%x]!"
		call :color 08 "..."
		echo.
		echo.
		echo.
		call :color 08 "Netsh Interface Set Interface '"
		call :color 07 "!interfaceName[%%x]!"
		call :color 08 "' "
		call :color 0a "ENABLED"
		echo.
		netsh interface set interface "!interfaceName[%%x]!" ENABLED
		echo.
	) else (
		call :color 08 "Interface "
		call :color 07 "!interfaceName[%%x]! "
		call :color 08 "already enabled."
		echo.
		echo.
	)
)

call :color 0a "Done."
echo.
echo.
timeout 5

goto mainMenu


:toggleAll
cls

set "whatSwitch="

for /l %%x in (1, 1, !interfaceCount!) do (
	cls
	call :color 0b "Toggling "
	call :color 08 "all interfaces..."
	echo.
	echo.

	if "!interfaceEnabled[%%x]!"=="Disabled" (
		set whatSwitch[%%x]=Enabled
	) else (
		set whatSwitch[%%x]=Disabled
	)

	for /l %%a in (1, 1, %%x) do (
		call :color 08 "%%a. "
		call :color 07 "!interfaceName[%%a]!"
		call :color 08 ": "
		if "!whatSwitch[%%a]!"=="Enabled" (
			call :color 0a "Done."
		) else (
			call :color 0c "Done."
		)
		echo.
	)

	echo.
	echo.

	if "!interfaceEnabled[%%x]!" == "Disabled" (
		call :color 08 "Enabling "
		call :color 07 "!interfaceName[%%x]!"
		call :color 08 "..."
		echo.
		echo.
		echo.
		call :color 08 "Netsh Interface Set Interface '"
		call :color 07 "!interfaceName[%%x]!"
		call :color 08 "' "
		call :color 0a "ENABLED"
		echo.
		netsh interface set interface "!interfaceName[%%x]!" ENABLED
		echo.
	) else (
		call :color 08 "Disabling "
		call :color 07 "!interfaceName[%%x]!"
		call :color 08 "..."
		echo.
		echo.
		echo.
		call :color 08 "Netsh Interface Set Interface '"
		call :color 07 "!interfaceName[%%x]!"
		call :color 08 "' "
		call :color 0c "DISABLED"
		echo.
		netsh interface set interface "!interfaceName[%%x]!" DISABLED
		echo.
	)
)

call :color 0a "Done."
echo.
echo.
timeout 5


goto mainMenu


:switchPause
cls
set delayTime=
call :color 08 "Please enter the delay time before switching back on in seconds:"
echo.
call :color 08 "Or just press ["
call :color 07 "Enter"
call :color 08 "] to wait for user input before continuing..."
echo.
echo.
echo.

set /p delayTime=!=!

cls

set "whatSwitch="
set "toggled="
set /a theIndex=0

for /l %%x in (1, 1, !interfaceCount!) do (
	cls
	call :color 0c "Disabling "
	call :color 08 "all interfaces, and Pausing..."
	echo.
	echo.


	if "!interfaceEnabled[%%x]!" == "Enabled" (
		set /a theIndex+=1
		set toggled[!theIndex!]=!interfaceName[%%x]!
		for /l %%a in (1, 1, !theIndex!) do (
			call :color 08 "%%a. "
			call :color 07 "!toggled[%%a]!"
			call :color 08 ": "
			call :color 0c "Done."
			echo.
		)
		echo.
		echo.
		call :color 08 "Disabling "
		call :color 07 "!interfaceName[%%x]!"
		call :color 08 "..."
		echo.
		echo.
		echo.
		call :color 08 "Netsh Interface Set Interface '"
		call :color 07 "!interfaceName[%%x]!"
		call :color 08 "' "
		call :color 0c "DISABLED"
		echo.
		netsh interface set interface "!interfaceName[%%x]!" DISABLED
		echo.
	)
)

call :color 0a "Done."
echo.
echo.
set paused=false
if "!delayTime!"=="" (
	pause
	set paused=true
)
if !paused!==false (
	timeout !delayTime!
)
cls


for /l %%x in (1, 1, !theIndex!) do (
	cls
	call :color 0a "Enabling "
	call :color 08 "toggled interfaces..."
	echo.
	echo.

	for /l %%a in (1, 1, %%x) do (
		call :color 08 "%%a. "
		call :color 07 "!toggled[%%a]!"
		call :color 08 ": "
		call :color 0a "Done."
		echo.
	)
	echo.
	echo.
	call :color 08 "Enabling "
	call :color 07 "!toggled[%%x]!"
	call :color 08 "..."
	echo.
	echo.
	echo.
	call :color 08 "Netsh Interface Set Interface '"
	call :color 07 "!toggled[%%x]!"
	call :color 08 "' "
	call :color 0a "ENABLED"
	echo.
	netsh interface set interface "!toggled[%%x]!" ENABLED
	echo.

)
timeout 5


goto mainMenu

:Disabled
cls
call :color 08 "Disabling "
call :color 07 "!interfaceName[%menu%]!"
call :color 08 "..."
echo.
echo.
echo.
call :color 08 "Netsh Interface Set Interface '"
call :color 07 "!interfaceName[%menu%]!"
call :color 08 "' "
call :color 0c "DISABLED"
echo.
netsh interface set interface "!interfaceName[%menu%]!" DISABLED
echo.
timeout 5
cls
goto mainMenu

:Enabled
cls
call :color 08 "Enabling "
call :color 07 "!interfaceName[%menu%]!"
call :color 08 "..."
echo.
echo.
echo.
call :color 08 "Netsh Interface Set Interface '"
call :color 07 "!interfaceName[%menu%]!"
call :color 08 "' "
call :color 0a "ENABLED"
netsh interface set interface "!interfaceName[%menu%]!" ENABLED
echo.
timeout 5
cls
goto mainMenu

:quit
call :cleanupColor
exit /b

:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::

:color Color  Str  [/n]
setlocal
set "str=%~2"
call :colorVar %1 str %3
exit /b

:colorVar  Color  StrVar  [/n]
if not defined DEL call :initColor
if not defined %~2 exit /b
setlocal enableDelayedExpansion
set "str=a%DEL%!%~2:\=a%DEL%\..\%DEL%%DEL%%DEL%!"
set "str=!str:/=a%DEL%/..\%DEL%%DEL%%DEL%!"
set "str=!str:"=\"!"
pushd "%temp%"
findstr /p /A:%1 "." "!str!\..\x" nul
if /i "%~3"=="/n" echo(
exit /b

:initColor
for /F "tokens=1,2 delims=#" %%a in ('"prompt #$H#$E# & echo on & for %%b in (1) do rem"') do set "DEL=%%a"
<nul >"%temp%\x" set /p "=%DEL%%DEL%%DEL%%DEL%%DEL%%DEL%.%DEL%"
exit /b

:cleanupColor
del "%temp%\x"
exit /b