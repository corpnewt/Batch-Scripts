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
setlocal enableDelayedExpansion

REM Let's set this up:
REM We're going to use the built in NET SHARE commands to share
REM whatever folder is entered into this batch.

REM I also want this script to be able to list all the available
REM shared folders for a specific server and then disconnect them
REM accordingly.

REM Let's start by getting the currently shared folders and working
REM forward from there.

REM We'll do this by running the NET SHARE command by itself and
REM parsing the output

REM Let's get a tab character saved for later use
set "TAB=	"

set thisDir=%~dp0

REM Let's set up our colors too
set basicColor=08
set highlightColor=07
set infoColor=0a

:mainMenu
cls
set /a shareCount=0
set menu=

REM This little chunk of awesome will actually do a Reg Query to search
REM for shared folders... WAAAAY easier than trying to parse the nasty
REM code generated form NET SHARE

SET vRegQuery=reg query HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Services\LanmanServer\Shares /t REG_MULTI_SZ /se #
FOR /F "skip=2 tokens=*" %%S IN ('%vRegQuery%') DO (
	FOR /F "tokens=3,5,6 delims=#" %%H IN ('ECHO "%%S"') DO (
		set /a shareCount+=1
		
		set ll=%%H
		set ll=!ll:~5!
		
		set sharePath[!shareCount!]=!ll!
		
		REM echo !ll! - the full path, can do something with it
		
		set ii=%%I
		set ii=!ii:~10!
		
		set jj=%%J
		set jj=!jj:~10!
		
		if NOT "!jj!"=="" (
			set shareName[!shareCount!]=!jj!
		) else (
			set shareName[!shareCount!]=!ii!
		)
		REM echo !jj! - the share name, can do something with it
	)
)
call :color 08 "Currently Shared Folders:"
echo.
echo.

for /l %%a in (1, 1, %shareCount%) do (
	call :color !basicColor! "%%a. "
	call :color !highlightColor! "!shareName[%%a]! "
	call :color !basicColor! "- !sharePath[%%a]!"
	echo.

)
echo.
call :color !basicColor! "P. Permissions"
echo.
call :color !basicColor! "N. New Share"
echo.
call :color !basicColor! "R. Reload List"
echo.
call :color !basicColor! "Q. Quit"
echo.
echo.
call :color !basicColor! "Please select a share for more options:  "
set /p menu=!=!

if !menu!==q goto quit
if !menu!==Q goto quit

if !menu!==p goto permissions
if !menu!==P goto permissions

if !menu!==r goto mainMenu
if !menu!==R goto mainMenu

if !menu!==n goto newShare
if !menu!==N goto newShare

if !menu! LSS 1 goto mainMenu
if !menu! GTR !shareCount! goto mainMenu

goto shareOptions

:shareOptions
cls
call :color !highlightColor! "!shareName[%menu%]! "
call :color !basicColor! "- !sharePath[%menu%]!"
echo.
echo.
call :color !basicColor! "Available Options^:"
echo.
echo.
call :color !basicColor! "1. "
call :color !highlightColor! "Show Info"
echo.
call :color !basicColor! "2. "
call :color !highlightColor! "Remove Share"
echo.
echo.
call :color !basicColor! "M. Main Menu"
echo.
echo.
echo.
call :color !basicColor! "Please select an option:  "

set /p aMenu=!=!

if !aMenu!==1 goto showInfo
if !aMenu!==2 goto removeShare
goto mainMenu

:showInfo
cls
echo NET SHARE "!shareName[%menu%]!"
echo.
NET SHARE "!shareName[%menu%]!"
echo.
pause
goto mainMenu

:removeShare
set shareRemove=!shareName[%menu%]!
if "!shareRemove!"=="" (
	set shareRemove=!sharePath[%menu%]!
	if "!shareRemove!"=="" goto mainMenu
)
set shareRemove=!shareRemove:"=!
cls
call :color !basicColor! "Removing "
call :color !highlightColor! "!shareRemove!"
call :color !basicColor! "..."
echo.
echo.
echo NET SHARE "!shareRemove!" /delete
echo.
NET SHARE ^"!shareRemove!^" /delete
echo.
timeout 5

if EXIST "!thisDir!Permissions\!shareRemove!.txt" (
	echo.
	cls
	call :color !basicColor! "Resetting permissions..."
	echo.
	echo.
	
	echo ICACLS "!sharePath[%menu%]!" /RESET /T /C /Q
	ICACLS "!sharePath[%menu%]!" /RESET /T /C /Q
	echo.
	
	call :folder_path_with_drive restoreFolder !sharePath[%menu%]!
	
	IF "!restoreFolder:~-1!"=="\" SET restoreFolder=!restoreFolder:~,-1!
	
	echo ICACLS "!restoreFolder!" /RESTORE "!thisDir!Permissions\!shareRemove!.txt" /T /C /Q
	REM start /wait 
	ICACLS "!restoreFolder!" /RESTORE "!thisDir!Permissions\!shareRemove!.txt" /T /C /Q
	echo.
	
	if NOT "!ERRORLEVEL!"=="0" (
		echo !ERRORLEVEL!
		echo.
		call :color !basicColor! "There were errors restoring permissions, leaving backup intact..."
		echo.
		echo.
	) else (
		call :color !basicColor! "Removing permissions backup..."
		echo.
		echo.
		del "!thisDir!Permissions\!shareRemove!.txt"
		call :color !basicColor! "Done."
		echo.
		echo.
	)
	timeout 5
)
goto mainMenu

cls
set everyNo=
call :color !basicColor! "Would you like to remove the "
call :color !highlightColor! "Everyone "
call :color !basicColor! "permissions from "
call :color !highlightColor! "!sharePath[%menu%]!"
call :color !basicColor! "? ^(y/n^)"
echo.
call :color !basicColor! "Default is: "
call :color !highlightColor! "Y"
echo.
echo.
echo.
set /p everyNo=!=!
	
if "!everyNo!"=="" set everyNo=y

if !everyNo!==y goto removeEveryone
if !everyNo!==Y goto removeEveryone

goto mainMenu 

:removeEveryone
cls
call :color !basicColor! "Removing "
call :color !highlightColor! "Everyone "
call :color !basicColor! "permissions..."
echo.
echo.
echo ICACLS "!sharePath[%menu%]!" /REMOVE "Everyone" /T /C /Q
echo.
ICACLS "!sharePath[%menu%]!" /REMOVE "Everyone" /T /C /Q
echo.
timeout 5
goto mainMenu

:newShare
cls
set tempName=
set thePath=
set tempUser=
set tempPermNum=

REM call :color !highlightColor! "Note: "
REM call :color !basicColor! "If you would like to share an entire drive, make"
REM echo.
REM call :color !basicColor! "sure that you only put the drive letter and a colon."
REM echo.
REM echo.
REM call :color !highlightColor! "For Example: "
REM call :color !basicColor! "To share your "
REM call :color !highlightColor! "C "
REM call :color !basicColor! "drive, you would type "
REM call :color !highlightColor! "C:"
REM echo.
REM call :color !basicColor! "not "
REM call :color !highlightColor! "C:\"
REM echo.
REM echo.
call :color !basicColor! "Please drop a folder to share, or type in the full path:"
echo.
echo.
set /p thePath=!=!
cls
set thePath=!thePath:"=!

REM Remove a trailing slash if one is present.
REM Useful if the dropped folder is a drive
REM If you try to share C:\ it will fail, but
REM C: will succeed.
if !thePath:~-1!==\ SET thePath=!thePath:~0,-1!

if NOT EXIST "!thePath!" (
	cls
	echo WARNING: The path "!thePath!" does not exist...
	echo.
	call :color !basicColor! "Returning to main menu..."
	echo.
	echo.
	timeout 5
	goto mainMenu
)

call :name_without_extension theName "!thePath!"

cls
call :color !basicColor! "Please type a name for your shared folder:"
echo.
call :color !basicColor! "Default is: "
call :color !highlightColor! "!theName!"
echo.
echo.
echo.
set /p tempName=!=!

if not "!tempName!"=="" (
	set theName=!tempName!
)

set shareUsers=
set permUsers=
goto newShareUsers

:newShareUsers
set /a newShareUserCount+=1
set "theUser=Everyone"
set tempUser=

cls
call :color !basicColor! "Please type the user name to grant permissions to:"
echo.
call :color !basicColor! "Default is: "
call :color !highlightColor! "Everyone"
echo.
echo.
echo.
set /p tempUser=!=!

if not "!tempUser!"=="" (
	set theUser=!tempUser!
)

set "thePerm="
set "caclPerm="

cls
call :color !basicColor! "Select the permission level for "
call :color !highlightColor! "!theUser!"
echo.
call :color !basicColor! "Default is: "
call :color !highlightColor! "READ"
echo.
echo.
call :color !basicColor! "1. "
call :color !highlightColor! "READ"
echo.
call :color !basicColor! "2. "
call :color !highlightColor! "CHANGE"
echo.
call :color !basicColor! "3. "
call :color !highlightColor! "FULL"
echo.
echo.
echo.
set /p tempPermNum=!=!

if !tempPermNum!==1 (
	set thePerm=READ
	set caclPerm=R
)
if !tempPermNum!==2 (
	set thePerm=CHANGE
	set caclPerm=M
)
if !tempPermNum!==3 (
	set thePerm=FULL
	set caclPerm=F
)

if "!thePerm!"=="" (
	set thePerm=READ
	set caclPerm=R
)

set shareUsers=!shareUsers!/GRANT:^"!theUser!^",!thePerm! 
set permUsers=!permUsers!/GRANT:r ^"!theUser!^":!caclPerm! 

set anotherUser=
cls
call :color !basicColor! "Would you like to add another user? ^(y^/n^)"
echo.
call :color !basicColor! "Default is: "
call :color !highlightColor! "N"
echo.
echo.
echo.
set /p anotherUser=!=!

if !anotherUser!==y goto newShareUsers
if !anotherUser!==Y goto newShareUsers
goto startShare

:startShare
cls
call :color !basicColor! "Sharing "
call :color !highlightColor! "!thePath! "
call :color !basicColor! "as "
call :color !highlightColor! "!theName!"
call :color !basicColor! "..."
echo.
echo.

echo NET SHARE ^"!theName!^"=^"!thePath!^" !shareUsers!

echo.
NET SHARE "!theName!"="!thePath!" !shareUsers!
echo.
timeout 5

set doPerm=

cls

call :color !basicColor! "Would you like to set permissions for "
call :color !highlightColor! "!theName!"
call :color !basicColor! "? ^(y/n^)"
echo.
call :color !basicColor! "Default is: "
call :color !highlightColor! "Y"
echo.
echo.
echo.

set /p doPerm=!=!

if "!doPerm!"=="" set doPerm=y

if !doPerm!==y goto setThePerm
if !doPerm!==Y goto setThePerm

goto mainMenu

:setThePerm
cls
if NOT EXIST "!thisDir!Permissions" mkdir "!thisDir!\Permissions"

call :color !basicColor! "Backing up current permissions..."
echo.
echo.
echo ICACLS "!thePath!" /SAVE "!thisDir!Permissions\!theName!.txt" /T /C /Q
ICACLS "!thePath!" /SAVE "!thisDir!Permissions\!theName!.txt" /T /C /Q
echo.
echo.
call :color !basicColor! "Setting new permissions..."
echo.
echo.
echo ICACLS "!thePath!" /INHERITANCE:r !permUsers! /T /C /Q
ICACLS "!thePath!" !permUsers! /INHERITANCE:r /T /C /Q
echo.

timeout 5

goto mainMenu

:permissions
cls
if EXIST "!thisDir!\Permissions" (
	call :color !basicColor! "Available Permissions:"
	echo.
	echo.
	set /a permissionCount=0
	pushd "!thisDir!\Permissions"
	For /R %%G IN (*) do (
		set /a permissionCount+=1
		call :color !basicColor! "!permissionCount!. "
		call :name_without_extension theFile "%%G"
		call :color !highlightColor! "!theFile!"
		echo.
		REM echo !permissionCount!. %%G
	)
	echo.
	popd
) else (
	call :color !basicColor! "No permissions found..."
	echo.
	echo.
)

pause

:quit
call :cleanupColor
exit /b

:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::

:StartsWith text string -- Tests if a text starts with a given string
::                      -- [IN] text   - text to be searched
::                      -- [IN] string - string to be tested for
:$created 20080320 :$changed 20080320 :$categories StringOperation,Condition
:$source http://www.dostips.com
SETLOCAL
set "txt=%~1"
set "str=%~2"
if defined str call set "s=%str%%%txt:*%str%=%%"
if /i "%txt%" NEQ "%s%" set=2>NUL
EXIT /b

:name_without_extension <resultVar> <pathVar>
(
    set "%~1=%~n2"
    exit /b
)

:folder_path_with_drive <resultVar> <pathVar>
(
    set "%~1=%~dp2"
    exit /b
)


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