@echo off
setlocal enabledelayedexpansion

:mainMenu
set /a count=0
cls
for /F "delims=" %%A in (BattleScript.bat) do (
	set /a count+=1
)
echo !count! Non-Empty Lines.
pause
