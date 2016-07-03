@echo off
setlocal enableDelayedExpansion

set "thisScript=%0"
set "thisDir=%~dp0"
set "settingsFile=startup.txt"
REM The number of seconds to give the user time to cancel
set /a userTimeWait=10
REM The number of seconds to wait between starting each app
set /a timeWait=3

REM Placeholder variables will be:
REM
REM name[#]
REM path[#]
REM batc[#] this is used for launching only - NO LONGER USED
REM exec[#]
REM args[#]
REM webs[#] this is for a web address
REM mult[#] yes/no - do we allow multiple instances?
REM mini[#] yes/no - do we start with the /min argument?
REM dela[#] number of seconds to delay before running
REM
REM The settingsFile will be organized like so:
REM
REM name=READABLE_NAME;path=PROCESS_PATH;exec=EXE_NAME;args=-WHATEVER -ARGUMENTS

:mainMenu
cls
REM Give the user a chance to cancel
echo   ###                            ###
echo  # Startup Launcher - By CorpNewt #
echo ###                            ###
echo.
echo Press [enter] to cancel...

call :userTimeout !userTimeWait! 0 didBreak

if !didBreak! GTR 0 goto exit
goto checkSettings

:checkSettings
REM Let's check for our startup.txt file, and search for values
if NOT EXIST "%thisDir%%settingsFile%" (
	REM No settings file, throw an error and exit.
	cls
	echo   ###     ###
	echo  # WARNING #
	echo ###     ###
	echo.
	echo "%settingsFile%" does not exist.
	echo.
	echo Exiting...
	echo.
	timeout 5 > nul
	goto exit
)

REM File exists, let's iterate
REM We need to keep it organized though - and include some basic
REM error checking.  Formatting of the text file should be:
REM
REM name=READABLE_NAME;path=PROCESS_PATH;exec=EXE_NAME;args=-WHATEVER -ARGUMENTS
REM
REM name=READABLE_NAME;webs=http://www.website.com;exec=EXE_NAME
REM 
REM In the event that any of the values are missing, then we need to
REM react to this by subbing in information.  If all we have is a path,
REM then we can gather the process name and name from that.
REM
REM Path is the ONLY necessary item though - UNLESS you are opening a web
REM url.  Path will supercede Webs though.

set /a itemCount=0
pushd "%thisDir%"
for /f "tokens=1,2,3,4,5,6,7,8* delims=;" %%a in (%settingsFile%) do (
	REM Break the string by ";"
	set "alpha=%%a"
	set "beta=%%b"
	set "charlie=%%c"
	set "delta=%%d"
	set "ech=%%e"
	set "foxtrot=%%f"
	set "golf=%%g"
	set "hotel=%%h"
	
	REM Check first value
	if NOT "!alpha!"=="" (
		call :setValueForPrefix alpha "!itemCount!"
	)
	REM Check second value
	if NOT "!beta!"=="" (
		call :setValueForPrefix beta "!itemCount!"
	)
	REM Check third value
	if NOT "!charlie!"=="" (
		call :setValueForPrefix charlie "!itemCount!"
	)
	REM Check fourth value
	if NOT "!delta!"=="" (
		call :setValueForPrefix delta "!itemCount!"
	)
	REM Check fifth value
	if NOT "!ech!"=="" (
		call :setValueForPrefix ech "!itemCount!"
	)
	REM Check sixth value
	if NOT "!foxtrot!"=="" (
		call :setValueForPrefix foxtrot "!itemCount!"
	)
	REM Check seventh value
	if NOT "!golf!"=="" (
		call :setValueForPrefix golf "!itemCount!"
	)
	REM Check eighth value
	if NOT "!hotel!"=="" (
		call :setValueForPrefix hotel "!itemCount!"
	)
	REM Increment counter
	set /a itemCount=!itemCount!+1
)
popd

goto startApps

:startApps
cls
echo   ###                   ###
echo  # Starting Applications #
echo ###                   ###
echo.

for /l %%a in (0, 1, %itemCount%) do (
	set "currPath="
	set "currName="
	set "currExec="
	set "currArgs="
	set "currWebs="
	set "currMult="
	set "currMini="
	set "currDela="
	
	if NOT "!dela[%%a]!"=="" (
		REM - we have a delay
		set /a currDela=!dela[%%a]!
		echo Pre-Delay for !currDela! seconds...
		timeout !currDela! > nul
		echo.
	)
	
	if NOT "!path[%%a]!"=="" (
		REM We have a path, let's get the rest of the vars
		set "currPath=!path[%%a]!"
		if "!name[%%a]!"=="" (
			REM Set name to last path component sans extension
			call :getName "!currPath!" "currName"
		) else (
			REM Set name to name value
			set "currName=!name[%%a]!"
		)
		if "!exec[%%a]!"=="" (
			REM Set exec to last path component with extension
			call :getNameWithExtension "!currPath!" "currExec"
		) else (
			REM Set name to name value
			set "currExec=!exec[%%a]!"
		)
		if NOT "!args[%%a]!"=="" (
			REM Set args
			set "currArgs=!args[%%a]!"
		)
		if /i NOT "!mult[%%a]:~0,1!"=="y" (
			set "currMult=n"
		) else (
			set "currMult=y"
		)
		if /i NOT "!mini[%%a]:~0,1!"=="y" (
			set "currMini="
		) else (
			set "currMini=/min "
		)

		if /i "!currMult!"=="n" (
			REM Now we check if exec is running - then start from path.
			REM Output will use name.
			echo Checking for !currName!...
			call :checkRunning "!currExec!" running
		
			if "!running!"=="0" (
				echo      !currName! is already running, bypassing...
			) else (
				echo      !currName! not running.
				echo      Starting !currName!...
				start !currMini!"" "!currPath!" !currArgs!
			)
		) else (
			REM Just start it up...
			echo Multiple instances allowed...
			echo      Starting !currName!...
			start !currMini!"" "!currPath!" !currArgs!
		)
		REM Wait for the designated wait time, then continue.
		timeout !timeWait! > nul
		echo.
	) else if NOT "!webs[%%a]!"=="" (
		set "currWebs=!webs[%%a]!"
		if NOT "!exec[%%a]!"=="" (
			REM Set exe value
			REM Only necessary if we want to limit whether we load webs
			REM when an exe hasn't been launched
			REM
			REM i.e. - load this website if chrome.exe is NOT running
			REM
			set "currExec=!exec[%%a]!"
		)
		if "!name[%%a]!"=="" (
			if "!currExec!"=="" (
				set "currName=!webs[%%a]!"
			) else (
				call :getName "!currExec!" "currName"
			)
		) else (
			set "currName=!name[%%a]!"
		)
		if /i NOT "!mult[%%a]:~0,1!"=="y" (
			set "currMult=n"
		) else (
			set "currMult=y"
		)
		if /i NOT "!mini[%%a]:~0,1!"=="y" (
			set "currMini="
		) else (
			set "currMini=/min "
		)
		
		if /i "!currMult!"=="y" (
			echo Opening web page ^(multiple instances allowed^)...
			echo      Starting !currName!...
			start !currMini!"" !currWebs!
		) else (
			echo Checking for !currName!...
			call :checkRunning "!currExec!" running
			if "!running!"=="0" (
				echo      !currName! is already running, bypassing...
			) else (
				echo      !currName! not running.
				echo      Starting !currName!...
				start !currMini!"" !currWebs!
			)
		)
		REM Wait for the designated wait time, then continue.
		timeout !timeWait! > nul
		echo.
	)
)
echo Done.
echo.
echo Exiting in !timeWait! seconds...
timeout !timeWait! > nul
goto exit

:getName <path> <return>
set "%~2=%~n1"
goto :EOF

:getNameWithExtension <path> <return>
set "%~2=%~nx1"
goto :EOF

:setValueForPrefix <prefix> <index>
set "theValue=!%1!"

set "thePre=!theValue:~0,4!"
set "theSuf=!theValue:~5!"

if /i "!thePre!"=="name" (
	set "name[%~2]=!theSuf!"
) else if /i "!thePre!"=="path" (
	set "path[%~2]=!theSuf!"
) else if /i "!thePre!"=="exec" (
	set "exec[%~2]=!theSuf!"
) else if /i "!thePre!"=="args" (
	set "args[%~2]=!theSuf!"
) else if /i "!thePre!"=="webs" (
	set "webs[%~2]=!theSuf!"
) else if /i "!thePre!"=="mult" (
	set "mult[%~2]=!theSuf!"
) else if /i "!thePre!"=="mini" (
	set "mini[%~2]=!theSuf!"
) else if /i "!thePre!"=="dela" (
	set "dela[%~2]=!theSuf!"
)
goto :EOF

:checkRunning <exec> <result>
REM Check if exe is running - and return a result
REM
REM 0 = Running
REM 1 = Not Running
REM

set "theExec=%~1"
call :strlen result !theExec!
		
REM tasklist has a 25 character limit - let's only check the first
REM 25 characters if our theExec variable is longer.
if !result! GTR 25 (
	tasklist /FI "IMAGENAME eq !theExec!" 2>NUL | find /I /N "!theExec:~0,25!">NUL
) else (
	tasklist /FI "IMAGENAME eq !theExec!" 2>NUL | find /I /N "!theExec!">NUL
)
if "!ERRORLEVEL!"=="0" (
	set /a %~2=0
) else (
	set /a %~2=1
)
goto :EOF

:exit
exit /b
goto :EOF

:strlen <resultVar> <stringVar>
(   
    setlocal EnableDelayedExpansion
    set "s=%~2#"
    set "len=0"
    for %%P in (4096 2048 1024 512 256 128 64 32 16 8 4 2 1) do (
        if "!s:~%%P,1!" NEQ "" ( 
            set /a "len+=%%P"
            set "s=!s:~%%P!"
        )
    )
)
( 
    endlocal
    set "%~1=%len%"
    exit /b
)

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