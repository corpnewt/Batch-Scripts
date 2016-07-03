@set @junk=1 /*
@echo off
setlocal enableDelayedExpansion

set thisScript=%0

set /a min=1
set /a max=10

:mainMenu
cls
set menu=
echo ### Random Number Generator ###
echo.
echo Current range is !min!-!max!
echo.
echo 1. Pick new min
echo 2. Pick new max
echo.
echo Q. Quit
echo.
echo Press ^[enter^] to generate with current settings
echo.
set /p menu="What would you like to do?  "

if !menu!==1 goto pickMin
if !menu!==2 goto pickMax
if !menu!==q goto quit
if !menu!==Q goto quit
if "!menu!"=="" goto generate
goto mainMenu

:pickMin
cls
set /a newMin=!min!
echo ### Pick New Min ###
echo.
echo.
set /p newMin="Please enter the new min value:  "
if "!newMin!"=="" goto mainMenu
set /a min=!newMin!
if !min! GTR !max! set /a max=!min!
goto mainMenu

:pickMax
cls
set /a newMax=!max!
echo ### Pick New Max ###
echo.
echo.
set /p newMax="Please enter the new max value:  "
if "!newMax!"=="" goto mainMenu
set /a max=!newMax!
if !max! LSS !min! set /a min=!max!
goto mainMenu

:generate
call :animate

cls

set menu=
echo ### Random number from !min!-!max! ###
echo.
echo.
set /a rand=!RANDOM! * (!max!-(!min!-1)) / 32768 + !min!
echo Your number is: !rand!
echo.
echo.
echo M. Main Menu
echo.
echo Press ^[enter^] to generate another number
echo.
set /p menu="What would you like to do?  "

if !menu!==m goto mainMenu
if !menu!==M goto mainMenu

goto generate

:animate
set frame="|"
call :displayAnimation "!min! |                     !max!"
call :displayAnimation "!min!  /                    !max!"
call :displayAnimation "!min!   -                   !max!"
call :displayAnimation "!min!    \                  !max!"
call :displayAnimation "!min!     |                 !max!"
call :displayAnimation "!min!      /                !max!"
call :displayAnimation "!min!       -               !max!"
call :displayAnimation "!min!        \              !max!"
call :displayAnimation "!min!         |             !max!"
call :displayAnimation "!min!          /            !max!"
call :displayAnimation "!min!           -           !max!"
call :displayAnimation "!min!            \          !max!"
call :displayAnimation "!min!             |         !max!"
call :displayAnimation "!min!              /        !max!"
call :displayAnimation "!min!               -       !max!"
call :displayAnimation "!min!                \      !max!"
call :displayAnimation "!min!                 |     !max!"
call :displayAnimation "!min!                  /    !max!"
call :displayAnimation "!min!                   -   !max!"
call :displayAnimation "!min!                    \  !max!"
call :displayAnimation "!min!                     | !max!"
goto :EOF


:displayAnimation anim
set "animation=%~1"
cls
if NOT "!animation!"=="" (
	echo ##########################
	echo ###     Generating     ###
	echo ##########################
	echo.
	echo !animation!
	cscript //nologo //E:jscript !thisScript! %* "25"
	REM pause
)
goto :EOF
	
:quit
exit /b

:: Java */
var x = WScript.Arguments;
var sleepTime = x(1);
//WScript.echo(sleepTime)
WScript.Sleep( sleepTime );