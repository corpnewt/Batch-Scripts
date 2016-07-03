@echo off

REM This variable should contain the name of the executable you are trying
REM to start.  So if this is Outlaws, it will be OLWIN.EXE

set startEXE="Warcraft II BNE.exe"
set autoExit=true

REM Let's populate our variable for our default resolution
set gameRes[1]=1024
set gameRes[2]=768
set gameRes[3]=32
set gameRes[4]=60

setlocal enableDelayedExpansion

REM We'll start by getting our original resolution and then delimiting
REM it until we have the components separated.

set currentRes=
REM Let's set a default error message (it gives more flexibility for later)
set unsupportedMessage="WARNING - Your monitor doesn't appear to support 1024x768x32@60Hz"

REM Now we grab our current resolution and store it into the array "currentRes"
For /f "skip=2 tokens=1,2,3,4,5* delims=<tab><space>x,@ " %%a In ('#Win7Start#\QRes.exe /s /v') Do (
  set currentRes[1]=%%a
  set currentRes[2]=%%b
  set currentRes[3]=%%c
  set currentRes[4]=%%e
)

:mainMenu
set menu=y
cls
call :color 0c "WARNING - This script will quit Explorer prior to starting:"
echo.
call :color 0c "!startEXE:"=!"
echo.
echo Please finish any file copying or other Explorer related tasks prior to
echo running this script.
echo.
echo.
call :color 08 "Current Resolution: "
call :color 07 "!currentRes[1]! "
call :color 08 "x "
call :color 07 "!currentRes[2]! "
call :color 08 "x "
call :color 07 "!currentRes[3]! "
call :color 08 "@ "
call :color 07 "!currentRes[4]! "
call :color 08 "Hz"
echo.
call :color 08 "Default Resolution: "
call :color 07 "!gameRes[1]! "
call :Color 08 "x "
call :color 07 "!gameRes[2]! "
call :color 08 "x "
call :color 07 "!gameRes[3]! "
call :color 08 "@ "
call :color 07 "!gameRes[4]! "
call :color 08 "Hz"
echo.
echo.
echo.
call :color 08 "Press C to pick a custom resolution."
echo.
echo.
set /p menu=Would you like to proceed? (y/n/c - default is y):  !=!

if /i !menu!==n goto exit
if /i !menu!==y goto checkRes
if /i !menu!==c (
	set unsupportedMessage="Please select your custom resolution..."
	goto unsupported
)

REM If we get to this point, something is wrong so swing back up to the main menu
goto mainMenu


:checkRes
REM Let's first check to see if we have a monitor that can support the standard
REM 1024x768x32@60 resolution and throw an error if we can't.

set /a foundRes=0

for /f "delims=" %%i in ('#Win7Start#\QRes.exe /L') do (
	REM echo %%i
	if "%%i"=="1024x768, 32 bits @ 60 Hz." (
		set /a foundRes=1
	)
)

if !foundRes!==0 (
	goto unsupported
)

goto startGame


:unsupported
set "newRes=!gameRes[1]! !gameRes[2]! !gameRes[3]! !gameRes[4]!"
cls
call :color 0c !unsupportedMessage!
echo.
echo This will be the resolution you will run the game at.
call :color 08 "Default is: "
call :color 07 "!gameRes[1]! "
call :Color 08 "x "
call :color 07 "!gameRes[2]! "
call :color 08 "x "
call :color 07 "!gameRes[3]! "
call :color 08 "@ "
call :color 07 "!gameRes[4]! "
call :color 08 "Hz"
echo.
echo.
echo.
call :color 08 "Please type the desired resolution in the format:"
echo.
call :color 07 "Width "
call :color 07 "Height "
call :color 07 "Bits "
call :color 07 "Hertz"
echo.
echo.
call :color 08 "For example:  "
echo.
call :color 07 "1024 "
call :color 07 "768 "
call :color 07 "32 "
call :color 07 "60"
echo.
echo.
echo.
call :color 08 "Most common older games can also use "
call :color 07 "640 "
call :color 08 "x "
call :color 07 "480"
call :color 08 " or "
call :color 07 "800 "
call :color 08 "x "
call :color 07 "600 "
call :color 08 " at "
call :color 07 "60 "
call :color 08 "Hz"
echo.
echo.
echo.
set /p newRes=Or press M to return to the main menu:  !=!

if /i !newRes!==m goto mainMenu

set /a countRes=0
for /f "tokens=1,2,3,4,5* delims=<space>,@x " %%i in ('echo !newRes!') do (
	if "%%i"=="" (
		set unsupportedMessage="WARNING - That resolution is not formatted correctly."
		goto unsupported
	) else (
		set gameRes[1]=%%i
	)
	if "%%j"=="" (
		set unsupportedMessage="WARNING - That resolution is not formatted correctly."
		goto unsupported
	) else (
		set gameRes[2]=%%j
	)
	if "%%k"=="" (
		set gameRes[3]=32
	) else (
		set gameRes[3]=%%k
	)
	if "%%l"=="" (
		set gameRes[4]=60
	) else (
		set gameRes[4]=%%l
	)

)

goto startGame


:startGame

cls
REM echo Your resolution will be changed to: !gameRes[1]!x!gameRes[2]!x!gameRes[3]!@!gameRes[4]!Hz
REM echo.
REM echo.
REM echo.

REM Let's change our resolution, kill explorer, and then start our app

.\#Win7Start#\Qres.exe /X !gameRes[1]! /Y !gameRes[2]! /C !gameRes[3]! /R !gameRes[4]!
taskkill /f /im explorer.exe
timeout 4
if /i "!autoExit!"=="true" (
	REM Start the exe and wait for it to quit
	start /WAIT "" "!startEXE:"=!"
) else (
	start "" "!startEXE:"=!"
	cls
	REM Now we wait for the use to press enter and we'll restore everything
	call :color 0c "NOTE! "
	call :color 08 "- When you are done playing the game, press return to reset"
	echo.
	call :color 08 "your screen resolution and restart explorer."
	echo.
	echo.
	echo.
	echo.
	pause
)


REM Let's reset our resolution and restart Explorer
.\#Win7Start#\Qres.exe /X !currentRes[1]! /Y !currentRes[2]! /C !currentRes[3]! /R !currentRes[4]!
start "" explorer.exe

REM We're all done here, let's clean up and exit
goto exit


:exit
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