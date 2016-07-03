@echo off
setlocal enabledelayedexpansion

set name=Chip

:mainMenu

cls

REM This script uses a function to check for user input or set
REM a default based on timeout.

echo "%TIME%"
echo "%DATE%"

Echo ### Pause Break Check ###
echo.
echo Press enter to input a name, or
echo wait for the timer to run down to
echo have the name default to %name%.

set /a hidden=0

call :userTimeout 10 !hidden! didBreak

if !didBreak! GTR 0 (
	REM User interrupted.
	goto inputName
) else (
	REM Timeout succeeded.
	goto sayHello
)

:inputName
set name=
cls
echo ### Pause Break Check ###
echo.
echo You chose to enter your own name.
echo.
set /p "name=Please type a new name:  "
if "%name%"=="" goto inputName
goto sayHello

:sayHello
cls
echo ### Pause Break Check ###
echo.
echo Hello, %name%.  It's nice to meet you.
echo.
echo Press [enter] to return to the main menu...
pause > nul
goto mainMenu

REM ############################################################
REM ### For use in other scripts copy the text starting here ###
REM ############################################################

:userTimeout
REM Let's wait, and see if we waited the full
REM amount, or if the user interrupted.
set waitTime=%~1
call :getTime %TIME% firstTime
call :getJulianDate "%DATE%" firstDate
if %~2 GTR 0 (
	timeout !waitTime! > nul
) else (
	timeout !waitTime!
)
call :getTime %TIME% secondTime
call :getJulianDate "%DATE%" secondDate
REM Find out if the days are different and add
REM seconds accordingly.
set /a diff=(!secondTime!-!firstTime!)+(!secondDate!-!firstDate!)*86400
if !diff! LSS !waitTime! (
	set %~3=1
) else (
	set %~3=0
)
goto :EOF

:getTime <TIME> <TIME-AS-SECONDS-RETURNED>
set "var=%~1"
REM pad with leading 0 for hour to drop the space
set var=!var: =0!
REM Initialize variables.
set hour=
set min=
set sec=
REM Break apart our time into components.
REM Also drops the .XX on the seconds.
For /f "tokens=1-3 delims=/:." %%a in ("%~1") do (
	set hour=%%a
	set min=%%b
	set sec=%%c
)
REM Get safe numbers so batch doesn't think they
REM are octals or whatever with the leading zeros
REM then get the number of seconds for each part
REM and add them together.
REM
REM 86400 seconds in a day.
call :getSafeNumber !hour! hour
set /a hour=%hour%*3600
call :getSafeNumber !min! min
set /a min=%min%*60
call :getSafeNumber !sec! sec
set /a sec=%sec%
set /a total=!hour!+!min!+!sec!
set %~2=!total!
goto :EOF

:getSafeNumber <INPUT> <SAFE-NUMBER>
REM If number has a leading zero, drop it.
set "getSafeNum=%~1"
if "%getSafeNum:~0,1%" == "0" set getSafeNum=%getSafeNum:~1,1%
set %~2=%getSafeNum%
goto :EOF

:getJulianDate <GDATE> <JDate>
REM Conversion code pulled from: http://www.robvanderwoude.com/datetimentmath.php
REM Convert the standard %DATE% into the Julian date.
REM First we break our date into it's components.
set "theDate=%~1"
set month=
set day=
set year=
if "!theDate:~2,1!"=="/" (
	REM Our date is formatted like: 01/01/2000
	REM Let's pad a word in there to pretend we have
	REM a Mon, Tue, Wed, Thu, Fri, Sat, or Sun
	set "theDate=Mon !theDate!"
)
For /f "tokens=2-4 delims=/ " %%a in ("!theDate!") do (
	set month=%%a
	set day=%%b
	set year=%%c
)
call :getSafeNumber !month! month
call :getSafeNumber !day! day
call :getSafeNumber !year! year
set /a month1=(!month!-14)/12
set /a year1=!year!+4800
set /a JDate=1461*(!year1!+!month1!)/4+367*(!month!-2-12*!month1!)/12-(3*((!year1!+!month1!+100)/100))/4+!day!-32075
set /a %~2=!JDate!
goto :EOF

REM ############################################################
REM ###                       To Here                        ###
REM ############################################################

REM This next part is optional for converting from Julian to Gregorian.
REM Copy it as well if you need readable output from Julian dates.
:getGregorianDate <JDate> <GDATE>
REM Conversion code pulled from: http://www.robvanderwoude.com/datetimentmath.php
REM Converts back from Julian date to Gregorian.
SET /A P      = %1 + 68569
SET /A Q      = 4 * %P% / 146097
SET /A R      = %P% - ( 146097 * %Q% +3 ) / 4
SET /A S      = 4000 * ( %R% + 1 ) / 1461001
SET /A T      = %R% - 1461 * %S% / 4 + 31
SET /A U      = 80 * %T% / 2447
SET /A V      = %U% / 11
SET /A GYear  = 100 * ( %Q% - 49 ) + %S% + %V%
SET /A GMonth = %U% + 2 - 12 * %V%
SET /A GDay   = %T% - 2447 * %U% / 80
FOR %%A IN (P Q R S T U V) DO SET %%A=
IF 1%GMonth% LSS 20 SET GMonth=0%GMonth%
IF 1%GDay%   LSS 20 SET GDay=0%GDay%
SET "%~2=%GMonth%/%GDay%/%GYear%"
goto :EOF