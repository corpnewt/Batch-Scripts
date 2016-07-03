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
setlocal enableExtensions
setlocal enableDelayedExpansion

set "defDest="

:main
set menu=1
cls
echo ### SymLink Creator ###
echo.
echo [Default is: 1]
if "!defDest!"=="" (
	echo [Default Destination Folder: PROMPT]
) else (
	call :getLastPathComponent "!defDest!" defName
	echo [Default Destination Folder: !defName!]
)
echo.
echo 1. Create New Hard Symbolic Link
echo 2. Create New Soft Symbolic Link ^(Files Only^)
echo 3. Default Destination Folder
echo.
echo Q. Quit
echo.
set /p "menu=Please select an option:  "

if "!menu!"=="" goto main
if /i "!menu!"=="q" exit /b
if /i "!menu!"=="1" goto createHardSource
if /i "!menu!"=="2" goto createSoftSource
if /i "!menu!"=="3" goto defaultDestination
goto main

:defaultDestination
cls
echo ### Default Destination Folder ###
echo.
if "!defDest!"=="" (
	echo [Default Destination Folder: PROMPT]
) else (
	call :getLastPathComponent "!defDest!" defName
	echo [Default Destination Folder: !defName!]
	echo [Path: "!defDest!"]
)
echo.
echo Please copy ^& paste/type new default destination folder
echo or leave blank to PROMPT each time:
echo.
set /p "newDef= "
set newDef=!newDef:"=!

if "!newDef!"=="" (
	set "defDest="
	goto main
)
call :checkDropped "!newDef!" ret
if "!ret!"=="0" (
	cls
	echo ### WARNING ###
	echo.
	echo "!newDef!"
	echo Does not exist...
	echo.
	timeout 5 > nul
	goto defaultDestination
) else if "!ret!"=="1" (
	cls
	echo ### WARNING ###
	echo.
	echo "!newDef!"
	echo Is a file, not a folder...
	timetout 5 > nul
	goto defaultDestination
)
set "defDest=!newDef!"
goto main

:createHardSource
cls
set source=
set type=
echo ### Create Hard SymLink ###
echo.
echo Please copy ^& paste/type your source file/folder:
echo.
set /p "source="
REM Remove quotes from source...
set source=!source:"=!

if "!source!"=="" goto createHardSource
set "ret="
call :checkDropped "!source!" ret
if "!ret!"=="0" (
	cls
	echo ### WARNING ###
	echo.
	echo "!source!"
	echo Does not exist...
	echo.
	timeout 5 > nul
	goto createHardSource
) else if "!ret!"=="1" (
	set "type=/H"
) else if "!ret!"=="2" (
	set "type=/J"
) else (
	REM Unexpected result... Error and return
	cls
	echo ### WARNING ###
	echo.
	echo Unexpected error when processing:
	echo "!source!"
	echo.
	timeout 5 > nul
	goto createHardSource
)
REM If we made it this far, source is good.
goto createHardDest
:createHardDest
cls
set "dest=!defDest!"
if "!dest!"=="" (
	echo ### Create Hard SymLink ###
	echo.
	echo Please copy ^& paste/type your destination file/folder:
	echo.
	set /p "dest="
	REM Removing quotes from dest...
	set dest=!dest:"=!
	if "!dest!"=="" goto createHardDest
)

set "ret="
call :checkDropped "!dest!" ret

echo Checked Dropped.

if "!ret!"=="2" (
	REM We've got a directory, let's append the source
	REM name to the end of it if it doesn't exist already
	call :getLastPathComponent "!source!" lastPath
	if "!dest:-1,1!"=="\" (
		set "newDest=!dest!!lastPath!
	) else (
		set "newDest=!dest!\!lastPath!"
	)
	IF NOT EXIST "!newDest!" (
		REM It doesn't exist, let's make it...
		set "dest=!newDest!"
	) else (
		REM Already exists...
		cls
		echo ### WARNING ###
		echo.
		echo "!newDest!"
		echo Already exists.  Please select a new destination...
		echo.
		timeout 5 > nul
		goto createHardDest
	)
) else if "!ret!"=="1" (
	cls
	echo ### WARNING ###
	echo.
	echo "!dest!"
	echo Already exists...
	echo.
	timeout 5 > nul
	goto createHardDest
)
REM If we made it here, we're good to go... creating link...
cls
echo ### Create Hard SymLink ###
echo.
echo Creating Link...
echo Source:      "!source!"
echo Destination: "!dest!"
echo.
echo MKLINK !type! "!dest!" "!source!"
MKLINK !type! "!dest!" "!source!"
echo.
echo Done.
echo.
timeout 5 > nul
goto main

:createSoftSource
cls
set source=
set type=
echo ### Create Soft SymLink ###
echo.
echo Please copy ^& paste/type your source file/folder:
echo.
set /p "source= "
REM Remove quotes from source...
set source=!source:"=!

if "!source!"=="" goto createSoftSource
set "ret="
echo About to check...
call :checkDropped "!source!" ret
echo Checked.
if "!ret!"=="0" (
	cls
	echo ### WARNING ###
	echo.
	echo "!source!"
	echo Does not exist...
	echo.
	timeout 5 > nul
	goto createSoftSource
) else if "!ret!"=="2" (
	cls
	echo ### WARNING ###
	echo.
	echo Soft SymLink only works with FILES, not DIRECTORIES.
	echo Please select Hard SymLink from the main menu to
	echo continue...
	echo.
	timeout 5 > nul
	goto main
)
REM If we made it this far, source is good.
goto createHardDest
:createSoftDest
cls
set "dest=!defDest!"
if "!dest!"=="" (
echo ### Create Soft SymLink ###
echo.
echo Please copy ^& paste/type your destination file/folder:
echo.
set /p "dest="
REM Removing quotes from dest...
set dest=!dest:"=!
if "!dest!"=="" goto createSoftDest
)

set "ret="
call :checkDropped "!dest!" ret
if "!ret!"=="2" (
	REM We've got a directory, let's append the source
	REM name to the end of it if it doesn't exist already
	call :getLastPathComponent "!source!" lastPath
	if "!dest:-1,1!"=="\" (
		set "newDest=!dest!!lastPath!
	) else (
		set "newDest=!dest!\!lastPath!"
	)
	IF NOT EXIST "!newDest!" (
		REM It doesn't exist, let's make it...
		set "dest=!newDest!"
	) else (
		REM Already exists...
		cls
		echo ### WARNING ###
		echo.
		echo "!newDest!"
		echo Already exists.  Please select a new destination...
		echo.
		timeout 5 > nul
		goto createSoftDest
	)
) else if "!ret!"=="1" (
	cls
	echo ### WARNING ###
	echo.
	echo "!dest!"
	echo Already exists...
	echo.
	timeout 5 > nul
	goto createSoftDest
)
REM If we made it here, we're good to go... creating link...
cls
echo ### Create Soft SymLink ###
echo.
echo Creating Link...
echo Source:      "!source!"
echo Destination: "!dest!"
echo.
echo MKLINK /D "!dest!" "!source!"
MKLINK /D "!dest!" "!source!"
echo.
echo Done.
echo.
timeout 5 > nul
goto main

:getLastPathComponent <file/folder> <return>
set "%~2=%~n1"
goto :EOF

:checkDropped <file/folder> <return>
IF NOT EXIST "%~1" (
	set %~2=0
	goto :EOF
)
set "ATTR=%~a1"
set "DIRATTR=!ATTR:~0,1!"
if /i "!DIRATTR!"=="d" (
	set "%~2=2"
) else (
	set "%~2=1"
)
goto :EOF