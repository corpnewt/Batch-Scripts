@set @junk=1 /*
@echo off
setlocal enableDelayedExpansion

IF "%selfWrapped%"=="" (
  REM this is necessary so that we can use "exit" to terminate the batch file,
  REM and all subroutines, but not the original cmd.exe
  SET selfWrapped=true
  %ComSpec% /s /c ""%~0" %*"
  GOTO :EOF
)

set thisScript=%0
set /a defaultTime=50
set thisDir=%~dp0
set /a playAnimations=1
set /a cheatsEnabled=0
set /a playSounds=1
set /a devMode=0
set /a noWait=0

set "shootSound=Shoot.wav"
set "missSound=Splash.wav"
set "hitSound=Explosion.wav"
set "sunkSound=Explosion2.wav"

	
set frame1=
set frame2=
set frame3=
set frame4=
set frame5=
set frame6=
set frame7=
set frame8=

set "dirList[1]=u"
set "dirList[2]=d"
set "dirList[3]=l"
set "dirList[4]=r"

set /a lastRow=-1
set /a lastCol=-1
set /a lastCheckRow=-1
set /a lastCheckCol=-1

set /a hitDir=0
set /a lastPM=0
set /a directionChanges=0

set /a p1Random=0
set /a p2Random=0

set /a guesses=0
set /a maxGues1=30
set /a maxGues2=60
set /a maxGues3=120
set /a maxGues4=240

set /a range1=3
set /a range2=5
set /a range3=7
set /a range4=9

REM The board is laid out in a grid of 10x10
REM The top half is where you're targeting,
REM and the bottom half is where your ships are
REM
REM The Legend for the layout will be as follows:
REM
REM CCCCC = Carrier
REM BBBB  = Battleship
REM ccc   = Cruiser
REM SSS   = Submarine
REM DD    = Destroyer
REM .     = Unexplored
REM X     = Hit

REM Carrier
set "car1= ______=_____=__| |______"
set "car2= \  \___________| |____ /"
set "car3=  \_____________________|"

REM Battleship
set "bat1="
set "bat2= ____=____/-|_/\____"
set "bat3= \_________________/"

REM Cruiser
set "cru1="
set "cru2= __=_/|---_||___"
set "cru3= \_____________/"

REM Submarine
set "sub1=      _|"
set "sub2=   __/--\__"
set "sub3= /=========\==/|"

REM Destroyer
set "des1=      __"
set "des2= __=_/  |_||"
set "des3= \__________|"


set p1Layout=
set p2Layout=
set p1Shots=
set p2Shots=
set p1Pass=
set p2Pass=
set /a numPlayers=1
set "letterList=1234567890"
set "numberList=abcdefghij"

set /a p1Ca=0
set /a p1Ba=0
set /a p1Cr=0
set /a p1Su=0
set /a p1De=0

set /a p2Ca=0
set /a p2Ba=0
set /a p2Cr=0
set /a p2Su=0
set /a p2De=0

:mainMenu
if "!toQuit!"=="1" goto quit
set "startTime="
set /a numShots=0
set "currentCPU="
set /a p1Ca=0
set /a p1Ba=0
set /a p1Cr=0
set /a p1Su=0
set /a p1De=0

set /a p2Ca=0
set /a p2Ba=0
set /a p2Cr=0
set /a p2Su=0
set /a p2De=0

set /a lastRow=-1
set /a lastCol=-1
set /a lastCheckRow=-1
set /a lastCheckCol=-1

set /a hitDir=0
set /a lastPM=0
set /a directionChanges=0

set /a guesses=0

set /a lastRowa=-1
set /a lastCola=-1
set /a lastCheckRowa=-1
set /a lastCheckCola=-1

set /a hitDira=0
set /a lastPMa=0
set /a directionChangesa=0

set /a guessesa=0

set /a p2Random=0
set /a p1Random=0

cls
set menu=
echo ### BATTLESCRIPT ###
echo.
if NOT "!lastTurn!"=="" (
	echo ### !lastTurn! ###
) else (
	echo.
)
echo.
echo 1. New Game - 1 Player
echo 2. New Game - 2 Players
echo 3. Rules
echo.
echo 0. CPU Game
echo Q. Quit
echo.
set /p menu="Please make a selection:  "

if /i "!menu!"=="devMode on" call :setDev 1
if /i "!menu!"=="devMode off" call :setDev 0
if /i "!menu!"=="animations on" call :setAnimations 1
if /i "!menu!"=="animations off" call :setAnimations 0
if /i "!menu!"=="sounds on" call :setSound 1
if /i "!menu!"=="sounds off" call :setSound 0
if /i "!menu!"=="cheats on" call :setCheats 1
if /i "!menu!"=="cheats off" call :setCheats 0
if /i "!menu!"=="noWait on" call :setNoWait 1
if /i "!menu!"=="noWait off" call :setNoWait 0

if "!menu!"=="0" goto noPlayers
if "!menu!"=="1" goto player
if "!menu!"=="2" goto players
if "!menu!"=="3" goto rules
if /i "!menu!"=="Q" goto quit
goto mainMenu

:getTime
set "var=%~1"
call :getSafeNumber %var:~0,2% hour
set /a hour=%hour%*3600
call :getSafeNumber %var:~3,2% min
set /a min=%min%*60
call :getSafeNumber %var:~6,2% sec
set /a sec=%sec%
set /a total=!hour!+!min!+!sec!
set %~2=!total!
goto :EOF

:getSafeNumber
set "getSafeNum=%~1"
if "%getSafeNum:~0,1%" == "0" set getSafeNum=%getSafeNum:~1,1%
set %~2=%getSafeNum%
goto :EOF

:setNoWait
set /a noWait=%~1
set "lastTurn=NoWait: %~1"
goto :EOF

:setDev
set /a devMode=%~1
set "lastTurn=DevMode: %~1"
goto :EOF

:setAnimations
set /a playAnimations=%~1
set "lastTurn=Animations: %~1"
goto :EOF

:setCheats
set /a cheatsEnabled=%~1
set "lastTurn=Cheats: %~1"
goto :EOF

:setSound
set /a playSounds=%~1
set "lastTurn=Sounds: %~1"
goto :EOF

:rules
cls
echo ### Rules ###
echo.
echo Basically, if you haven't played Battleship,
echo then you have no idea what you're doing with
echo your life and should go and read some literature
echo on the subject.
echo.
echo Otherwise if you went here just to test for rules:
echo.
echo.
pause
cls
echo ### Rules ###
echo.
echo This is a batch version of Battleship that
echo incorporates the use of 1 or 2 players.
echo.
echo The goal is to hunt out and destroy the other
echo player's 5 ships.
echo.
echo You do this by calling out coordinates on your
echo turn and hoping that you strike a hit.
echo.
echo The first player to sink the other's ships wins.
echo.
pause
cls
echo ### Rules ###
echo.
echo Good luck.
echo.
echo.
pause
goto mainMenu

:quit
set /a toQuit=1
exit /b
goto :EOF

:noPlayers
call :initializeLayout p1Layout
call :initializeLayout p1Shots
call :initializeLayout p2Layout
call :initializeLayout p2Shots
set /a numPlayers=2
call :getTime %TIME: =0% startTime
set "currentCPU=CPU1"
cls
echo ### CPU1 Placing Ships ###
echo.
echo Please wait...

call :cpuPickShip "Carrier" "4" "C" "Player1"
call :cpuPickShip "Battleship" "3" "B" "Player1"
call :cpuPickShip "Cruiser" "2" "c" "Player1"
call :cpuPickShip "Submarine" "2" "S" "Player1"
call :cpuPickShip "Destroyer" "1" "D" "Player1"

echo.
echo Done.
timeout 1 > nul 

cls
echo ### CPU2 Placing Ships ###
echo.
echo Please wait...

call :cpuPickShip "Carrier" "4" "C" "Player2"
call :cpuPickShip "Battleship" "3" "B" "Player2"
call :cpuPickShip "Cruiser" "2" "c" "Player2"
call :cpuPickShip "Submarine" "2" "S" "Player2"
call :cpuPickShip "Destroyer" "1" "D" "Player2"

echo.
echo Done.
timeout 1 > nul 
goto nextCPU

:player
call :initializeLayout p1Layout
call :initializeLayout p1Shots
call :initializeLayout p2Layout
call :initializeLayout p2Shots
set /a numPlayers=1
call :getTime %TIME: =0% startTime
REM goto p1Turn
if "!p1Random!"=="1" (
	call :cpuPickShip "Carrier" "4" "C" "Player1"
	call :cpuPickShip "Battleship" "3" "B" "Player1"
	call :cpuPickShip "Cruiser" "2" "c" "Player1"
	call :cpuPickShip "Submarine" "2" "S" "Player1"
	call :cpuPickShip "Destroyer" "1" "D" "Player1"
) else (
	set theErr=
	call :p1PickShip "Carrier" "4" "C"
	set theErr=
	call :p1PickShip "Battleship" "3" "B"
	set theErr=
	call :p1PickShip "Cruiser" "2" "c"
	set theErr=
	call :p1PickShip "Submarine" "2" "S"
	set theErr=
	call :p1PickShip "Destroyer" "1" "D"
)
if "!toQuit!"=="1" goto quit
cls
echo ### %numPlayers% Player Game ###
echo Player 1 Layout.
echo.
set /a shipLen=!len!+1
call :displayShip !ship! !shipLen!
echo.
call :drawLayout "Player1"
echo.
echo CPU Placing in 5 seconds...
timeout 5 > nul

cls
echo ### CPU Placing Ships ###
echo.
echo Please wait...

call :cpuPickShip "Carrier" "4" "C"
call :cpuPickShip "Battleship" "3" "B"
call :cpuPickShip "Cruiser" "2" "c"
call :cpuPickShip "Submarine" "2" "S"
call :cpuPickShip "Destroyer" "1" "D"

echo.
echo Done.
timeout 1 > nul

goto p1Turn

:players
call :initializeLayout p1Layout
call :initializeLayout p1Shots
call :initializeLayout p2Layout
call :initializeLayout p2Shots
set /a numPlayers=2
call :getTime %TIME: =0% startTime
if "!p1Random!"=="1" (
	call :cpuPickShip "Carrier" "4" "C" "Player1"
	call :cpuPickShip "Battleship" "3" "B" "Player1"
	call :cpuPickShip "Cruiser" "2" "c" "Player1"
	call :cpuPickShip "Submarine" "2" "S" "Player1"
	call :cpuPickShip "Destroyer" "1" "D" "Player1"
) else (
	set theErr=
	call :p1PickShip "Carrier" "4" "C"
	set theErr=
	call :p1PickShip "Battleship" "3" "B"
	set theErr=
	call :p1PickShip "Cruiser" "2" "c"
	set theErr=
	call :p1PickShip "Submarine" "2" "S"
	set theErr=
	call :p1PickShip "Destroyer" "1" "D"
)
if "!toQuit!"=="1" goto quit
cls
echo Press [enter] to start Player 2 selection...
pause > nul
:player2
if "!p2Random!"=="1" (
	call :cpuPickShip "Carrier" "4" "C" "Player2"
	call :cpuPickShip "Battleship" "3" "B" "Player2"
	call :cpuPickShip "Cruiser" "2" "c" "Player2"
	call :cpuPickShip "Submarine" "2" "S" "Player2"
	call :cpuPickShip "Destroyer" "1" "D" "Player2"
) else (
	set theErr=
	call :p2PickShip "Carrier" "4" "C"
	set theErr=
	call :p2PickShip "Battleship" "3" "B"
	set theErr=
	call :p2PickShip "Cruiser" "2" "c"
	set theErr=
	call :p2PickShip "Submarine" "2" "S"
	set theErr=
	call :p2PickShip "Destroyer" "1" "D"
)
goto p1PassSelect

:p1PassSelect
if "!toQuit!"=="1" goto quit
cls
echo ### Player 1 Password Select ###
echo.
set /p p1Pass="Please type the password for Player 1:  "
if "!numPlayers!"=="2" goto p2PassSelect
goto p1EnterPass

:p2PassSelect
if "!toQuit!"=="1" goto quit
cls
echo ### Player 2 Password Select ###
echo.
set /p p2Pass="Please type the password for Player 2:  "
goto p1EnterPass

:p1EnterPass
if "!toQuit!"=="1" goto quit
cls
set passTest=
echo ### Player 1 Password ###
echo.
echo Player 1, please enter your password to play
echo your turn.  If you enter the wrong password,
echo you will see this window again.
echo.
set /p passTest="Enter your password:  "
if NOT "!passTest!"=="!p1Pass!" goto p1EnterPass
set theErr=
goto p1Turn

:p2EnterPass
if "!toQuit!"=="1" goto quit
cls
set passTest=
echo ### Player 2 Password ###
echo.
echo Player 2, please enter your password to play
echo your turn.  If you enter the wrong password,
echo you will see this window again.
echo.
set /p passTest="Enter your password:  "
if NOT "!passTest!"=="!p2Pass!" goto p2EnterPass
set theErr=
goto p2Turn

:p1Turn
cls
set carr=
set carRow=
set carCol=
set carInd=
echo ### Player 1 Turn ###
echo.
if NOT "!lastTurn!"=="" (
	echo ### !lastTurn! ###
) else (
	echo.
)
echo.
call :drawCombat "Player1"
echo.
if "!theErr!"=="" (
	echo.
) else (
	echo !theErr!
)

set /p carr="Attack What Position (A1 type formatting):  "

if /i "!carr!"=="devMode on" call :setDev 1
if /i "!carr!"=="devMode off" call :setDev 0
if /i "!carr!"=="animations on" call :setAnimations 1
if /i "!carr!"=="animations off" call :setAnimations 0
if /i "!carr!"=="sounds on" call :setSound 1
if /i "!carr!"=="sounds off" call :setSound 0
if /i "!carr!"=="cheats on" call :setCheats 1
if /i "!carr!"=="cheats off" call :setCheats 0
if /i "!carr!"=="nowait on" call :setNoWait 1
if /i "!carr!"=="nowait off" call :setNoWait 0

if /i "!carr!"=="showmethemoney" (
	if "!cheatsEnabled!"=="1" call :showGrid "Player2"
)
if /i "!carr!"=="mainMenu" goto mainMenu
if /i "!carr!"=="random" (
:p1RandomShot
	set /a carCol=0
	set /a carInd=0
	call :getRandom carCol carInd 10 1
	REM Let's get some random numbers and then
	REM run that shiz.
	if !carInd! GTR 9 (
		goto p1RandomShot
	)
	if !carInd! LSS 0 (
		goto p1RandomShot
	)
	if !carCol! GTR 10 (
		goto p1RandomShot
	)
	if !carCol! LSS 1 (
		goto p1RandomShot
	)
	call :checkShot "Player2" !carCol! !carInd! outCome

	if !outCome! EQU -1 (
		goto p1RandomShot
	)
	if !outCome! EQU -2 (
		goto p1RandomShot
	)
	set /a numShots+=1
	if !outCome! EQU 0 (
		call :missAnimation
		set "lastTurn=Player 1 missed"
	)	
	if !outCome! EQU 1 (
		call :hitAnimation
		if "!numPlayers!"=="1" (
			set "lastTurn=Player 1 hit one of CPU's ships"
		) else (
			set "lastTurn=Player 1 hit one of Player 2's ships"
		)
	)	
	if !outCome! GTR 1 (
		call :sunkAnimation
		if "!numPlayers!"=="1" (
			set "lastTurn=Player 1 sunk one of CPU's ships"
		) else (
			set "lastTurn=Player 1 sunk one of Player 2's ships"
		)
		set /a theSum=!p2Ca!+!p2Ba!+!p2Cr!+!p2Su!+!p2De!
		if !theSum! GEQ 17 goto p1Victory
	)
	set "theErr="

	cls
	echo ### Player 1 Turn ###
	echo.
	if NOT "!lastTurn!"=="" (
		echo ### !lastTurn! ###
	) else (
		echo.
	)
	echo.
	call :drawCombat "Player1"
	echo.

	if "!numPlayers!"=="2" (
		echo Player 2^'s turn in 5 seconds...
		timeout 5 > nul
		goto p2EnterPass
	) else (
		echo CPU^'s turn in 5 seconds...
		timeout 5 > nul
		goto cpu1Turn
	)	
)

if "%carr%"=="" (
	set "theErr=### Invalid Target ###"
	goto p1Turn
)
set carRow=%carr:~0,1%
set carCol=%carr:~1,2%

if "!carCol!"=="" (
	set "theErr=### Invalid Target ###"
	goto p1Turn
)

call :getNumFromLet %carRow% carInd

if %carCol% GTR 10 (
	set "theErr=### Invalid Target ###"
	goto p1Turn
)
if %carCol% LSS 1 (
	set "theErr=### Invalid Target ###"
	goto p1Turn
)
if %carInd%==-1 (
	set "theErr=### Invalid Target ###"
	goto p1Turn
)

call :checkShot "Player2" !carCol! !carInd! outCome

REM echo DoneChecking: !outCome!

if !outCome! EQU -1 (
	set "theErr=### Already Fired There ###"
	goto p1Turn
)
if !outCome! EQU -2 (
	set "theErr=### Already Fired There ###"
	goto p1Turn
)
set /a numShots+=1
if !outCome! EQU 0 (
	call :missAnimation
	set "lastTurn=Player 1 missed"
)	
if !outCome! EQU 1 (
	call :hitAnimation
	if "!numPlayers!"=="1" (
		set "lastTurn=Player 1 hit one of CPU's ships"
	) else (
		set "lastTurn=Player 1 hit one of Player 2's ships"
	)
	
)	
if !outCome! GTR 1 (
	call :sunkAnimation
	if "!numPlayers!"=="1" (
		set "lastTurn=Player 1 sunk one of CPU's ships"
	) else (
		set "lastTurn=Player 1 sunk one of Player 2's ships"
	)
	set /a theSum=!p2Ca!+!p2Ba!+!p2Cr!+!p2Su!+!p2De!
	if !theSum! GEQ 17 goto p1Victory
)
set "theErr="

cls
echo ### Player 1 Turn ###
echo.
if NOT "!lastTurn!"=="" (
	echo ### !lastTurn! ###
) else (
	echo.
)
echo.
call :drawCombat "Player1"
echo.

if "!numPlayers!"=="2" (
	echo Player 2^'s turn in 5 seconds...
	timeout 5 > nul
	goto p2EnterPass
) else (
	echo CPU^'s turn in 5 seconds...
	timeout 5 > nul
	goto cpu1Turn
)


:p2Turn
cls
set carr=
set carRow=
set carCol=
set carInd=
echo ### Player 2 Turn ###
echo.
if NOT "!lastTurn!"=="" (
	echo ### !lastTurn! ###
) else (
	echo.
)
echo.
call :drawCombat "Player2"
echo.
if "!theErr!"=="" (
	echo.
) else (
	echo !theErr!
)

set /p carr="Attack What Position (A1 type formatting):  "

if /i "!carr!"=="devMode on" call :setDev 1
if /i "!carr!"=="devMode off" call :setDev 0
if /i "!carr!"=="animations on" call :setAnimations 1
if /i "!carr!"=="animations off" call :setAnimations 0
if /i "!carr!"=="sounds on" call :setSound 1
if /i "!carr!"=="sounds off" call :setSound 0
if /i "!carr!"=="cheats on" call :setCheats 1
if /i "!carr!"=="cheats off" call :setCheats 0

if /i "!carr!"=="mainMenu" goto mainMenu
if /i "!carr!"=="showmethemoney" (
	if "!cheatsEnabled!"=="1" call :showGrid "Player1"
)

if /i "!carr!"=="random" (
:p2RandomShot
	set /a carCol=0
	set /a carInd=0
	call :getRandom carCol carInd 10 1
	REM Let's get some random numbers and then
	REM run that shiz.
	if !carInd! GTR 9 (
		goto p2RandomShot
	)
	if !carInd! LSS 0 (
		goto p2RandomShot
	)
	if !carCol! GTR 10 (
		goto p2RandomShot
	)
	if !carCol! LSS 1 (
		goto p2RandomShot
	)
	call :checkShot "Player1" !carCol! !carInd! outCome

	if !outCome! EQU -1 (
		goto p2RandomShot
	)
	if !outCome! EQU -2 (
		goto p2RandomShot
	)
	set /a numShots+=1
	if !outCome! EQU 0 (
		call :missAnimation
		set "lastTurn=Player 2 missed"
	)	
	if !outCome! EQU 1 (
		call :hitAnimation
		set "lastTurn=Player 2 hit one of Player 1's ships"
	)	
	if !outCome! GTR 1 (
		call :sunkAnimation
		set "lastTurn=Player 2 sunk one of Player 1's ships"
		set /a theSum=!p1Ca!+!p1Ba!+!p1Cr!+!p1Su!+!p1De!
		if !theSum! GEQ 17 goto p2Victory
	)
	set "theErr="

	cls
	echo ### Player 2 Turn ###
	echo.
	if NOT "!lastTurn!"=="" (
		echo ### !lastTurn! ###
	) else (
		echo.
	)
	echo.
	call :drawCombat "Player2"
	echo.

	echo Player 1^'s turn in 5 seconds...
	timeout 5 > nul
	goto p1EnterPass	
)

if "%carr%"=="" (
	set "theErr=### Invalid Target ###"
	goto p2Turn
)
set carRow=%carr:~0,1%
set carCol=%carr:~1,2%

if "!carCol!"=="" (
	set "theErr=### Invalid Target ###"
	goto p2Turn
)

call :getNumFromLet %carRow% carInd

if %carCol% GTR 10 (
	set "theErr=### Invalid Target ###"
	goto p2Turn
)
if %carCol% LSS 1 (
	set "theErr=### Invalid Target ###"
	goto p2Turn
)
if %carInd%==-1 (
	set "theErr=### Invalid Target ###"
	goto p2Turn
)

call :checkShot "Player1" !carCol! !carInd! outCome

REM echo DoneChecking: !outCome!

if !outCome! EQU -1 (
	set "theErr=### Already Fired There ###"
	goto p2Turn
)
if !outCome! EQU -2 (
	set "theErr=### Already Fired There ###"
	goto p2Turn
)
set /a numShots+=1
if !outCome! EQU 0 (
	call :missAnimation
	set "lastTurn=Player 2 missed"
)	
if !outCome! EQU 1 (
	call :hitAnimation
	set "lastTurn=Player 2 hit one of Player 1's ships"
)
if !outCome! GTR 1 (
	call :sunkAnimation
	set "lastTurn=Player 2 sunk one of Player 1's ships"
	set /a theSum=!p1Ca!+!p1Ba!+!p1Cr!+!p1Su!+!p1De!
	if !theSum! GEQ 17 goto p2Victory
)

set "theErr="

cls
echo ### Player 2 Turn ###
echo.
call :drawCombat "Player2"
echo.
if NOT "!lastTurn!"=="" (
	echo ### !lastTurn! ###
) else (
	echo.
)
echo.
echo Player 1^'s turn in 5 seconds...
timeout 5 > nul

goto p1EnterPass

:cpu1Turn
cls
echo.
echo Calculating...
set /a guesses=!guesses!+1
REM Let's see if our last shot hit...
if !lastRow! GTR -1 (
	REM we had a hit last time!
	
	REM Let's write this out a bit... AI time kids!!
	REM So we have hit a spot, and we want to continue hitting
	REM targets, so our goal is to try and move left/right or up/down
	REM and see if we hit anything.  If no success, try the other side
	REM and again, if no success, then we switch directions
	
	set /a plusMin=0
	set /a rCol=0
	set /a rRow=0
	set /a uD=0
	
	if !needChangeDir! GTR 0 (
		set /a directionChanges+=1
		set /a lastCheckCol=!ranCol!
		set /a lastCheckRow=!ranRow!
		set /a lastPM=!lastPM! * -1
		set /a needChangeDir=0
		if "!devMode!"=="1" echo Direction Change>>devOutput.txt
	)
	
	if !directionChanges! EQU 2 (
		REM We have changed direction back, and forth, but
		REM we haven't switched between horizontal and vertical
		REM more than once
		REM echo Direction Changes = 2, let's switch our hitDir
		set /a directionChanges+=1
		set /a lastCheckRow=!lastRow!
		set /a lastCheckCol=!lastCol!
		if "!hitDir!"=="2" (
			set /a hitDir=1
		) else if "!hitDir!"=="1" (
			set /a hitDir=2
		)
		set /a lastPM=0
	) else if "!directionChanges!"=="5" (
		REM We've tried to go left right, up and down with no
		REM success, let's randomize!
		if "!devMode!"=="1" echo Switch to random>>devOutput.txt
		call :setLast -1 -1
		set /a guesses=0
		set /a hitDir=0
		set /a lastPM=0
		set /a directionChanges=0
		goto cpu1Turn
	)
	
	REM Let's set up our plusMin variable to decide whether
	REM we add or subtract 1 from our current setup.
	if "!plusMin!"=="0" (
		call :getRandom Du plusMin 3 2
		if "!lastPM!"=="0" (
			set /a lastPM=!plusMin!
		)
	)
	if "!hitDir!"=="0" (
		REM We haven't decided what direction
		REM we need to go to hit some more.
		call :getRandom hitDir Du 2 0
	)
	if "!hitDir!"=="2" (
		REM Horizontal Hit
		if "!lastPM!"=="0" (
			REM we haven't documented our last
			REM plusMin variable.  I think we should
			REM always move in 1s
			set /a lastPM=!plusMin!
			set /a rCol=!plusMin!
		) else (
			REM Our plusMin variable is defined,
			REM let's add it to our rRow (which should be
			REM 0 at the moment)
			set /a rCol=!lastPM!
		)
	) else (
		REM Vertical Hit
		if "!lastPM!"=="0" (
			REM Same deal as before, but with colums.
			set /a lastPM=!plusMin!
			set /a rRow=!plusMin!
		) else (
			set /a rRow=!lastPM!
		)
	)
	
	REM This is the problem section here...
	REM This shit doesn't want to play nice haha
	if NOT "!lastCheckCol!"=="-1" (
		set /a ranCol=!lastCheckCol!+!rCol!
		if "!lastCheckRow!"=="0" (
			set /a ranRow=10+!rRow!
		) else (
			set /a ranRow=!lastCheckRow!+!rRow!
		)
	) else (
		set /a ranCol=!lastCol!+!rCol!
		if "!lastRow!"=="0" (
			set /a ranRow=10+!rRow!
		) else (
			set /a ranRow=!lastRow!+!rRow!
		)
	)
	
	REM set /a rRow-=!plusMin!
	REM set /a rCol-=!plusMin!
	if "!devMode!"=="1" (
		echo Guesses: !guesses! 
		echo Change in Row-Col: !rRow! !rCol! 
		echo PlusMin: !plusMin! 
		echo uD: "!uD!" 
		echo LastPM: "!lastPM!" 
		echo Direction Changes: !directionChanges!
		echo HitDir: "!hitDir!"
		echo LastCheckRow: !lastCheckRow! LastCheckCol: !lastCheckCol!
		echo LastRow: !lastRow! LastCol: !lastCol!
		echo.
		echo RanRow: !ranRow! RanCol: !ranCol!
		echo Direction Changes: !directionChanges!>>devOutput.txt
		echo HitDir: !hitDir!>>devOutput.txt
		echo LastPM: !lastPM!>>devOutput.txt
		pause
	)
	if !ranRow!==0 set /a ranRow=-1
	if !ranRow!==10 set /a ranRow=0
	
	REM echo !lastRow!-!ranRow! !lastCol!-!ranCol!
	
) else (
	REM Let's generate 2 random numbers, then set shit up
	set /a directionChanges=0
	set /a needChangeDir=0
	set /a lastPM=0
	set /a plusMin=0
	call :getRandom ranCol ranRow 10 1
	REM set /a ranRow=9
	REM set /a ranCol=2
)
	if !ranRow! GTR 9 (
		REM Change direction
		set /a needChangeDir+=1
		if "!devMode!"=="1" echo !ranRow! !ranCol! Out of bounds - RowMax>> devOutput.txt
		goto cpu1Turn
	)
	if !ranRow! LSS 0 (
		set /a needChangeDir+=1
		if "!devMode!"=="1" echo !ranRow! !ranCol! Out of bounds - RowMin>> devOutput.txt
		goto cpu1Turn
	)
	if !ranCol! GTR 10 (
		set /a needChangeDir+=1
		if "!devMode!"=="1" echo !ranRow! !ranCol! Out of bounds - ColMax>> devOutput.txt
		goto cpu1Turn
	)
	if !ranCol! LSS 1 (
		set /a needChangeDir+=1
		if "!devMode!"=="1" echo !ranRow! !ranCol! Out of bounds - ColMin>> devOutput.txt
		goto cpu1Turn
	)

call :checkShot "Player1" !ranCol! !ranRow! outCome
	
if !outCome! EQU -1 (
	REM We shot at an area we already missed
	if "!devMode!"=="1" echo !ranRow! !ranCol! Shot - Already Missed>> devOutput.txt
	set /a ranRow=-1
	set /a ranCol=-1
	set /a needChangeDir+=1
	goto cpu1Turn
)
if !outCome! EQU -2 (
	REM We shot at an area we already hit
	if "!devMode!"=="1" echo !ranRow! !ranCol! Shot - Already Hit>> devOutput.txt
	set /a lastCheckCol=!ranCol!
	set /a lastCheckRow=!ranRow!
	goto cpu1Turn
)
set /a numShots+=1
if "!noWait!"=="0" cscript //nologo //E:jscript !thisScript! "500"

if !outCome! EQU 0 (
	call :missAnimation
	set /a guesses=0
	if "!devMode!"=="1" echo !ranRow! !ranCol! Shot - Miss>> devOutput.txt
	REM Flip Direction if necessary
	set /a ranRow=!lastCheckRow!
	set /a ranCol=!lastCheckCol!
	set /a needChangeDir+=1
	if "!numPlayers!"=="2" (
		set "lastTurn=CPU1 missed"
	) else (	
		set "lastTurn=CPU missed"
	)
)
if !outCome! EQU 1 (
	call :hitAnimation
	if "!devMode!"=="1" echo !ranRow! !ranCol! Shot - Hit>> devOutput.txt
	set /a guesses=0
	set /a lastCheckCol=!ranCol!
	set /a lastCheckRow=!ranRow!
	if NOT "!lastRow!"=="-1" (
		if NOT !lastRow! EQU !ranRow! (
			REM Horiz Hit
			set /a hitDir=1
			REM set /a lastPM=!ranRow!-!lastRow!
		) else (
			REM Vert Hit
			set /a hitDir=2
			REM set /a lastPM=!ranCol!-!lastCol!
		)
	)
	set /a lastCol=!ranCol!
	set /a lastRow=!ranRow!
	if "!numPlayers!"=="2" (
		set "lastTurn=CPU1 hit one of CPU2's ships"
	) else (
		set "lastTurn=CPU hit one of Player 1's ships"
	)
	REM call :setLast !ranRow! !ranCol!
)
if !outCome! GTR 1 (
	call :sunkAnimation
	if "!devMode!"=="1" echo !ranRow! !ranCol! Shot - Sunk>> devOutput.txt
	call :setLast -1 -1
	set /a guesses=0
	set /a hitDir=0
	set /a lastPM=0
	set /a directionChanges=0
	set /a needChangeDir=0
	if "!numPlayers!"=="2" (
		set "lastTurn=CPU1 sunk one of CPU2's ships"
	) else (
		set "lastTurn=CPU sunk one of Player 1's ships"
	)
	set /a theSum=!p1Ca!+!p1Ba!+!p1Cr!+!p1Su!+!p1De!
	if "!numPlayers!"=="2" (
		if !theSum! GEQ 17 goto cpu1Victory
	) else (
		if !theSum! GEQ 17 goto cpuVictory
	)
)
if "!numPlayers!"=="2" (
	set currentCPU=CPU2
	goto nextCPU
) else (
	goto p1Turn
)

:cpu2Turn
cls
echo.
echo Calculating...
set /a guessesa=!guessesa!+1
REM Let's see if our last shot hit...
if !lastRowa! GTR -1 (
	REM we had a hit last time!
	
	REM Let's write this out a bit... AI time kids!!
	REM So we have hit a spot, and we want to continue hitting
	REM targets, so our goal is to try and move left/right or up/down
	REM and see if we hit anything.  If no success, try the other side
	REM and again, if no success, then we switch directions
	
	set /a plusMina=0
	set /a rCola=0
	set /a rRowa=0
	set /a uDa=0
	
	if !needChangeDira! GTR 0 (
		set /a directionChangesa+=1
		set /a lastCheckCola=!ranCola!
		set /a lastCheckRowa=!ranRowa!
		set /a lastPMa=!lastPMa! * -1
		set /a needChangeDira=0
	)
	
	if !directionChangesa! EQU 2 (
		REM We have changed direction back, and forth, but
		REM we haven't switched between horizontal and vertical
		REM more than once
		REM echo Direction Changes = 2, let's switch our hitDir
		set /a directionChangesa+=1
		set /a lastCheckRowa=!lastRowa!
		set /a lastCheckCola=!lastCola!
		if "!hitDira!"=="2" (
			set /a hitDira=1
		) else if "!hitDira!"=="1" (
			set /a hitDira=2
		)
		set /a lastPMa=0
	) else if "!directionChangesa!"=="5" (
		REM We've tried to go left right, up and down with no
		REM success, let's randomize!
		REM call :setLast -1 -1
		set /a lastCola=-1
		set /a lastRowa=-1
		set /a guessesa=0
		set /a hitDira=0
		set /a lastPMa=0
		set /a directionChangesa=0
		goto cpu2Turn
	)
	
	REM Let's set up our plusMin variable to decide whether
	REM we add or subtract 1 from our current setup.
	if "!plusMina!"=="0" (
		call :getRandom Dua plusMina 3 2
		if "!lastPMa!"=="0" (
			set /a lastPMa=!plusMina!
		)
	)
	if "!hitDira!"=="0" (
		REM We haven't decided what direction
		REM we need to go to hit some more.
		call :getRandom hitDira Dua 2 0
	)
	if "!hitDira!"=="2" (
		REM Horizontal Hit
		if "!lastPMa!"=="0" (
			REM we haven't documented our last
			REM plusMin variable.  I think we should
			REM always move in 1s
			set /a lastPMa=!plusMina!
			set /a rCola=!plusMina!
		) else (
			REM Our plusMin variable is defined,
			REM let's add it to our rRow (which should be
			REM 0 at the moment)
			set /a rCola=!lastPMa!
		)
	) else (
		REM Vertical Hit
		if "!lastPMa!"=="0" (
			REM Same deal as before, but with colums.
			set /a lastPMa=!plusMina!
			set /a rRowa=!plusMina!
		) else (
			set /a rRowa=!lastPMa!
		)
	)
	
	REM This is the problem section here...
	REM This shit doesn't want to play nice haha
	if NOT "!lastCheckCola!"=="-1" (
		set /a ranCola=!lastCheckCola!+!rCola!
		if "!lastCheckRowa!"=="0" (
			set /a ranRowa=10+!rRowa!
		) else (
			set /a ranRowa=!lastCheckRowa!+!rRowa!
		)
	) else (
		set /a ranCola=!lastCola!+!rCola!
		if "!lastRowa!"=="0" (
			set /a ranRowa=10+!rRowa!
		) else (
			set /a ranRowa=!lastRowa!+!rRowa!
		)
	)
	
	REM set /a rRow-=!plusMin!
	REM set /a rCol-=!plusMin!
	if "!devMode!"=="1" (
		echo CPU2
		echo Guesses: !guessesa! 
		echo Change in Row-Col: !rRowa! !rCola! 
		echo PlusMin: !plusMina! 
		echo uD: "!uDa!" 
		echo LastPM: "!lastPMa!" 
		echo Direction Changes: !directionChangesa!
		echo HitDir: "!hitDira!"
		echo LastCheckRow: !lastCheckRowa! LastCheckCol: !lastCheckCola!
		echo LastRow: !lastRowa! LastCol: !lastCola!
		echo.
		echo RanRow: !ranRowa! RanCol: !ranCola!
		pause
	)
	if !ranRowa!==0 set /a ranRowa=-1
	if !ranRowa!==10 set /a ranRowa=0
	
	REM echo !lastRow!-!ranRow! !lastCol!-!ranCol!
	
) else (
	REM Let's generate 2 random numbers, then set shit up
	set /a directionChangesa=0
	set /a needChangeDira=0
	set /a lastPMa=0
	set /a plusMina=0
	call :getRandom ranCola ranRowa 10 1
	REM set /a ranRow=9
	REM set /a ranCol=2
)
	if !ranRowa! GTR 9 (
		REM Change direction
		set /a needChangeDira+=1
		goto cpu2Turn
	)
	if !ranRowa! LSS 0 (
		set /a needChangeDira+=1
		goto cpu2Turn
	)
	if !ranCola! GTR 10 (
		set /a needChangeDira+=1
		goto cpu2Turn
	)
	if !ranCola! LSS 1 (
		set /a needChangeDira+=1
		goto cpu2Turn
	)

call :checkShot "Player2" !ranCola! !ranRowa! outCome
	if "!devMode!"=="1" (
		echo Outcome: !outCome!
		pause
	)
if !outCome! EQU -1 (
	REM We shot at an area we already missed
	set /a ranRowa=-1
	set /a ranCola=-1
	set /a needChangeDira+=1
	goto cpu2Turn
)
if !outCome! EQU -2 (
	REM We shot at an area we already hit
	set /a lastCheckCola=!ranCola!
	set /a lastCheckRowa=!ranRowa!
	goto cpu2Turn
)
set /a numShots+=1
if "!noWait!"=="0" cscript //nologo //E:jscript !thisScript! "500"

if !outCome! EQU 0 (
	call :missAnimation
	set /a guessesa=0
	REM Flip Direction if necessary
	set /a ranRowa=!lastCheckRowa!
	set /a ranCola=!lastCheckCola!
	set /a needChangeDira+=1
	set "lastTurn=CPU2 missed"
)
if !outCome! EQU 1 (
	call :hitAnimation
	set /a guessesa=0
	set /a lastCheckCola=!ranCola!
	set /a lastCheckRowa=!ranRowa!
	if NOT "!lastRowa!"=="-1" (
		if NOT !lastRowa! EQU !ranRowa! (
			REM Horiz Hit
			set /a hitDira=1
			REM set /a lastPM=!ranRow!-!lastRow!
		) else (
			REM Vert Hit
			set /a hitDira=2
			REM set /a lastPM=!ranCol!-!lastCol!
		)
	)
	set /a lastCola=!ranCola!
	set /a lastRowa=!ranRowa!
	set "lastTurn=CPU2 hit one of CPU1's ships"

	REM call :setLast !ranRow! !ranCol!
)
if !outCome! GTR 1 (
	call :sunkAnimation
	REM call :setLast -1 -1
	set /a lastCola=-1
	set /a lastRowa=-1
	set /a guessesa=0
	set /a hitDira=0
	set /a lastPMa=0
	set /a directionChangesa=0
	set /a needChangeDira=0
	set "lastTurn=CPU2 sunk one of CPU1's ships"
	set /a theSum=!p2Ca!+!p2Ba!+!p2Cr!+!p2Su!+!p2De!
	if !theSum! GEQ 17 goto cpu2Victory
)
set currentCPU=CPU1
goto nextCPU
	
:nextCPU
if "!currentCPU!"=="CPU1" (
	REM CPU was set to CPU1 from CPU2, so 
	REM let's show CPU1's board.
	cls
	echo ### CPU2's Last Shot ###
	echo.
	if NOT "!lastTurn!"=="" (
		echo ### !lastTurn! ###
	) else (
		echo.
	)
	echo.
	call :drawCombat "Player1"
	echo.
	if "!noWait!"=="0" timeout 5
	
	cls
	echo ### CPU1 Turn ###
	echo.
	if NOT "!lastTurn!"=="" (
		echo ### !lastTurn! ###
	) else (
		echo.
	)
	echo.
	call :drawCombat "Player2"
	echo.
	if "!noWait!"=="0" timeout 2
	goto cpu1Turn
) else (
	cls
	echo ### CPU1's Last Shot ###
	echo.
	if NOT "!lastTurn!"=="" (
		echo ### !lastTurn! ###
	) else (
		echo.
	)
	echo.
	call :drawCombat "Player2"
	echo.
	if "!noWait!"=="0" timeout 5
	
	cls
	echo ### CPU2 Turn ###
	echo.
	if NOT "!lastTurn!"=="" (
		echo ### !lastTurn! ###
	) else (
		echo.
	)
	echo.
	call :drawCombat "Player1"
	echo.
	if "!noWait!"=="0" timeout 2
	goto cpu2Turn
)
goto mainMenu
	
:showGrid "Player2"
cls
echo ### Filthy Cheater ###
echo.
echo.
echo.
call :drawCombat "%~1" "-1"
echo.
pause
if /i "%~1"=="Player2" (
	goto p1Turn
) else if /i "%~1"=="Player1" (
	goto p2Turn
)
goto :EOF

:setLast
set /a lastRow=%~1
set /a lastCol=%~2
goto :EOF

:getRandom
set /a %~1=!RANDOM! * %~3 /32768 + 1
set /a tV=!RANDOM! * %~3 /32768 + 1
set /a %~2=!tV!-%~4
goto :EOF

:getEndTime
set /a sTime=%~1
call :getTime %TIME: =0% eTime
set /a dTime=!eTime!-!sTime!
set /a hours = !dTime!/3600
set /a minutes = (!dTime! - !hours!*3600) / 60
set /a seconds = !dTime! - (!hours!*3600 + !minutes!*60)
REM echo !hours! !minutes! !seconds! !dTime!
set "outString="
if NOT "!hours!" == "0" set "outString=!hours!h "
if NOT "!minutes!" == "0" set "outString=!outString!!minutes!m "
if NOT "!seconds!" == "0" set "outString=!outString!!seconds!s "
set %~2=!outString!
goto :EOF

:cpuVictory
cls
call :getEndTime !startTime! endTime
echo ### DEFEAT ###
echo.
echo Looks like the computer won in !endTime!after !numShots! shots^!
echo.
call :drawOverview
echo.
echo Press [enter] to return to main menu...
set "lastTurn=CPU Defeated Player 1"
pause > nul
goto mainMenu

:cpu1Victory
cls
call :getEndTime !startTime! endTime
echo ### CPU1 Victory ###
echo.
echo CPU1 beat CPU2 in !endTime!after !numShots! shots in a fair fight^!
echo.
call :drawOverview
echo.
echo Press [etner] to return to main menu...
set "lastTurn=CPU1 Defeated CPU2"
pause > nul
goto mainMenu

:cpu2Victory
cls
call :getEndTime !startTime! endTime
echo ### CPU2 Victory ###
echo.
echo CPU2 beat CPU1 in !endTime!after !numShots! shots in a fair fight^!
echo.
call :drawOverview
echo.
echo Press [etner] to return to main menu...
set "lastTurn=CPU2 Defeated CPU1"
pause > nul
goto mainMenu

:p1Victory
cls
call :getEndTime !startTime! endTime
echo ### VICTORY ###
echo.
echo Player 1 was victorious in !endTime!after !numShots! shots^!
echo.
call :drawOverview
echo.
echo Press [enter] to return to main menu...
if "!numPlayers!"=="1" (
	set "lastTurn=Player 1 Defeated CPU"
) else (
	set "lastTurn=Player 1 Defeated Player 2"
)
pause > nul
goto mainMenu

:p2Victory
cls
call :getEndTime !startTime! endTime
echo ### VICTORY ###
echo.
echo Player 2 was victorious in !endTime!after !numShots! shots^!
echo.
call :drawOverview
echo.
echo Press [enter] to return to main menu...
set "lastTurn=Player 2 Defeated Player 1"
pause > nul
goto mainMenu

:checkShot
REM echo Checking Shot
REM echo %~1 %~2 %~3
REM pause
if "%~1"=="Player1" (
	set row=!p1Layout[%~3]!
	set row2=!p2Shots[%~3]!
	REM echo !row!

	set /a numcheck=%~2*2-2
	call :charFromRow !numCheck! "!row!" tChar
	REM echo !tChar!
	if !numcheck! GTR 0 set /a numcheck-=1

	if "!tChar!"=="+" (
		set /a %~4=0
		call :buildRow "!row!" !numcheck! "*" res
		call :setP1Row %~3 "!res!"
		call :buildRow "!row2!" !numcheck! "*" res
		call :setP2Shots %~3 "!res!"
	) else if "!tChar!"=="C" (
		set /a p1Ca+=1
		if !p1Ca! GEQ 5 (
			set /a %~4=2
		) else (
			set /a %~4=1
		)
		call :buildRow "!row!" !numcheck! "X" res
		call :setP1Row %~3 "!res!"
		call :buildRow "!row2!" !numcheck! "X" res
		call :setP2Shots %~3 "!res!"
	) else if "!tChar!"=="B" (
		set /a p1Ba+=1
		if !p1Ba! GEQ 4 (
			set /a %~4=3
		) else (
			set /a %~4=1
		)
		call :buildRow "!row!" !numcheck! "X" res
		call :setP1Row %~3 "!res!"
		call :buildRow "!row2!" !numcheck! "X" res
		call :setP2Shots %~3 "!res!"
	) else if "!tChar!"=="c" (
		set /a p1Cr+=1
		if !p1Cr! GEQ 3 (
			set /a %~4=4
		) else (
			set /a %~4=1
		)
		call :buildRow "!row!" !numcheck! "X" res
		call :setP1Row %~3 "!res!"
		call :buildRow "!row2!" !numcheck! "X" res
		call :setP2Shots %~3 "!res!"
	) else if "!tChar!"=="S" (
		set /a p1Su+=1
		if !p1Su! GEQ 3 (
			set /a %~4=5
		) else (
			set /a %~4=1
		)
		call :buildRow "!row!" !numcheck! "X" res
		call :setP1Row %~3 "!res!"
		call :buildRow "!row2!" !numcheck! "X" res
		call :setP2Shots %~3 "!res!"
	) else if "!tChar!"=="D" (
		set /a p1De+=1
		if !p1De! GEQ 2 (
			set /a %~4=6
		) else (
			set /a %~4=1
		)
		call :buildRow "!row!" !numcheck! "X" res
		call :setP1Row %~3 "!res!"
		call :buildRow "!row2!" !numcheck! "X" res
		call :setP2Shots %~3 "!res!"
	) else if "!tChar!"=="*" (
		set /a %~4=-1
	) else (
		set /a %~4=-2
	)
	

) else if "%~1"=="Player2" (
	set row=!p2Layout[%~3]!
	set row2=!p1Shots[%~3]!
	REM echo !row!

	set /a numcheck=%~2*2-2
	call :charFromRow !numCheck! "!row!" tChar
	REM echo !tChar!
	if !numcheck! GTR 0 set /a numcheck-=1

	if "!tChar!"=="+" (
		set /a %~4=0
		call :buildRow "!row!" !numcheck! "*" res
		call :setP2Row %~3 "!res!"
		call :buildRow "!row2!" !numcheck! "*" res
		call :setP1Shots %~3 "!res!"
	) else if "!tChar!"=="C" (
		set /a p2Ca+=1
		if !p2Ca! GEQ 5 (
			set /a %~4=2
		) else (
			set /a %~4=1
		)
		call :buildRow "!row!" !numcheck! "X" res
		call :setP2Row %~3 "!res!"
		call :buildRow "!row2!" !numcheck! "X" res
		call :setP1Shots %~3 "!res!"
	) else if "!tChar!"=="B" (
		set /a p2Ba+=1
		if !p2Ba! GEQ 4 (
			set /a %~4=3
		) else (
			set /a %~4=1
		)
		call :buildRow "!row!" !numcheck! "X" res
		call :setP2Row %~3 "!res!"
		call :buildRow "!row2!" !numcheck! "X" res
		call :setP1Shots %~3 "!res!"
	) else if "!tChar!"=="c" (
		set /a p2Cr+=1
		if !p2Cr! GEQ 3 (
			set /a %~4=4
		) else (
			set /a %~4=1
		)
		call :buildRow "!row!" !numcheck! "X" res
		call :setP2Row %~3 "!res!"
		call :buildRow "!row2!" !numcheck! "X" res
		call :setP1Shots %~3 "!res!"
	) else if "!tChar!"=="S" (
		set /a p2Su+=1
		if !p2Su! GEQ 3 (
			set /a %~4=5
		) else (
			set /a %~4=1
		)
		call :buildRow "!row!" !numcheck! "X" res
		call :setP2Row %~3 "!res!"
		call :buildRow "!row2!" !numcheck! "X" res
		call :setP1Shots %~3 "!res!"
	) else if "!tChar!"=="D" (
		set /a p2De+=1
		if !p2De! GEQ 2 (
			set /a %~4=6
		) else (
			set /a %~4=1
		)
		call :buildRow "!row!" !numcheck! "X" res
		call :setP2Row %~3 "!res!"
		call :buildRow "!row2!" !numcheck! "X" res
		call :setP1Shots %~3 "!res!"
	) else if "!tChar!"=="*" (
		set /a %~4=-1
	) else (
		set /a %~4=-2
	)

)
goto :EOF

:charFromRow
set rRow=%~2
set rInd=%~1
set %~3=!rRow:~%~1,1!
goto :EOF

REM Ther are still some (A lot of) generating errors with this function
:cpuPickShip
if "!toQuit!"=="1" goto quit
set ship=%~1
set /a len=%~2
set ident=%~3

set "playName=%~4"

call :getRandom carCol carInd 10 0
call :getRandom ranDir nope 4 0
REM set /a carCol=!RANDOM! * 10 / 32768
REM set /a carInd=!RANDOM! * 10 / 32768
REM set /a ranDir=!RANDOM! * 4 / 32768

set /a carInd=!carInd!-1

call :getCPUDir !ranDir! carDir
set /a shipLen=!len!+1

REM echo !ship! !len! !ident! !carCol! !carInd! !carDir! !shipLen!

if %carInd%==0 (
	set carCheck=10
) else (
	set carCheck=%carInd%
)

REM pause

if /i "!carDir!"=="r" (
	set /a card=!carCol!+!len!
	if 10 LSS !card! goto cpuPickShip
) else if /i "!carDir!"=="l" (
	set /a card=!carCol!-!len!
	if 1 GTR !card! goto cpuPickShip
) else if /i "!carDir!"=="d" (
	set /a card=!carCheck!+!len!
	if 10 LSS !card! goto cpuPickShip
) else if /i "!carDir!"=="u" (
	set /a card=!carCheck!-!len!
	if 1 GTR !card! goto cpuPickShip
) else (
		goto cpuPickShip
)

set err=0
if "!playName!"=="Player1" (
	call :p1PlaceShip !ident! !carInd! !carCol! !carDir! !len! err
) else if "!playName!"=="Player2" (
	call :p2PlaceShip !ident! !carInd! !carCol! !carDir! !len! err
) else (
	call :p2PlaceShip !ident! !carInd! !carCol! !carDir! !len! err
)
if "%err%"=="1" goto cpuPickShip
goto :EOF


:p1PickShip
if "!toQuit!"=="1" goto quit
set ship=%~1
set /a len=%~2
set ident=%~3

cls
set carr=
set carDir=
echo ### %numPlayers% Player Game ###
echo Player 1, Please select a row^/column for your
echo.
set /a shipLen=!len!+1
call :displayShip !ship! !shipLen!
echo.
call :drawLayout "Player1"
echo.
if "!theErr!"=="" (
	echo.
) else (
	echo !theErr!
)
set /p carr="Position (A1, B7, C9 type formatting):  "

if /i "!carr!"=="random" (
	set /a p1Random=1
	if "!numPlayers!"=="1" (
		goto player
	) else (
		goto players
	)
)

if "%carr%"=="" (
	set "theErr=### Invalid Position ###"
	goto p1PickShip
)
set carRow=%carr:~0,1%
set carCol=%carr:~1,2%

if "!carCol!"=="" (
	set "theErr=### Invalid Position ###"
	goto p1PickShip
)

call :getNumFromLet %carRow% carInd

if %carCol% GTR 10 (
	set "theErr=### Invalid Position ###"
	goto p1PickShip
)
if %carCol% LSS 1 (
	set "theErr=### Invalid Position ###"
	goto p1PickShip
)
if %carInd%==-1 (
	set "theErr=### Invalid Position ###"
	goto p1PickShip
)

if %carInd%==0 (
	set carCheck=10
) else (
	set carCheck=%carInd%
)
set theErr=

cls
echo ### %numPlayers% Player Game ###
echo Player 1, Please select the direction for your
echo.
call :displayShip %ship% !shipLen!
echo.
call :drawLayout "Player1"
echo.
if "!theErr!"=="" (
	echo.
) else (
	echo !theErr!
)
set /p carDir="Direction (U-Up, D-Down, L-Left, R-Right):  "

if /i %carDir%==r (
	set /a card=%carCol%+%len%
	if 10 LSS !card! (
		set "theErr=### Not Enough Space ###"
		goto p1PickShip
	)
) else if /i %carDir%==l (
	set /a card=%carCol%-%len%
	if 1 GTR !card! (
		set "theErr=### Not Enough Space ###"
		goto p1PickShip
	)
) else if /i %carDir%==u (
	set /a card=%carCheck%+%len%
	if 10 LSS !card! (
		set "theErr=### Not Enough Space ###"
		goto p1PickShip
	)
) else if /i %carDir%==d (
	set /a card=%carCheck%-%len%
	if 1 GTR !card! (
		set "theErr=### Not Enough Space ###"
		goto p1PickShip
	)
) else (
	set "theErr=### Invalid Direction ###"
	goto p1PickShip
)

REM echo All vars: %ident% %carInd% %carCol% %carDir% %len%
REM pause

set err=0
call :p1PlaceShip !ident! !carInd! !carCol! !carDir! !len! err
if "%err%"=="1" (
	set "theErr=### Intersects Ship ###"
	goto p1PickShip
)
	
goto :EOF

:p2PickShip
if "!toQuit!"=="1" goto quit
set ship=%~1
set /a len=%~2
set ident=%~3

cls
set carr=
set carDir=
echo ### %numPlayers% Player Game ###
echo Player 2, Please select a row^/column for your
echo.
set /a shipLen=!len!+1
call :displayShip !ship! !shipLen!
echo.
call :drawLayout "Player2"
echo.
if "!theErr!"=="" (
	echo.
) else (
	echo !theErr!
)
set /p carr="Position (A1, B7, C9 type formatting):  "

if /i "!carr!"=="random" (
	set /a p2Random=1
	goto player2
)

if "%carr%"=="" (
	set "theErr=### Invalid Position ###"
	goto p2PickShip
)
set carRow=%carr:~0,1%
set carCol=%carr:~1,2%

if "!carCol!"=="" (
	set "theErr=### Invalid Position ###"
	goto p2PickShip
)

call :getNumFromLet %carRow% carInd

if %carCol% GTR 10 (
	set "theErr=### Invalid Position ###"
	goto p2PickShip
)
if %carCol% LSS 1 (
	set "theErr=### Invalid Position ###"
	goto p2PickShip
)
if %carInd%==-1 (
	set "theErr=### Invalid Position ###"
	goto p2PickShip
)

if %carInd%==0 (
	set carCheck=10
) else (
	set carCheck=%carInd%
)
set theErr=

cls
echo ### %numPlayers% Player Game ###
echo Player 2, Please select the direction for your
echo.
call :displayShip %ship% !shipLen!
echo.
call :drawLayout "Player2"
echo.
if "!theErr!"=="" (
	echo.
) else (
	echo !theErr!
)
set /p carDir="Direction (U-Up, D-Down, L-Left, R-Right):  "

if /i %carDir%==r (
	set /a card=%carCol%+%len%
	if 10 LSS !card! (
		set "theErr=### Not Enough Space ###"
		goto p2PickShip
	)
) else if /i %carDir%==l (
	set /a card=%carCol%-%len%
	if 1 GTR !card! (
		set "theErr=### Not Enough Space ###"
		goto p2PickShip
	)
) else if /i %carDir%==u (
	set /a card=%carCheck%+%len%
	if 10 LSS !card! (
		set "theErr=### Not Enough Space ###"
		goto p2PickShip
	)
) else if /i %carDir%==d (
	set /a card=%carCheck%-%len%
	if 1 GTR !card! (
		set "theErr=### Not Enough Space ###"
		goto p2PickShip
	)
) else (
	set "theErr=### Invalid Direction ###"
	goto p2PickShip
)

REM echo All vars: %ident% %carInd% %carCol% %carDir% %len%
REM pause

set err=0
call :p2PlaceShip !ident! !carInd! !carCol! !carDir! !len! err
if "%err%"=="1" (
	set "theErr=### Intersects Ship ###"
	goto p2PickShip
)
	
goto :EOF

:initializeLayout
set "%~1[1]=+ + + + + + + + + + "
set "%~1[2]=+ + + + + + + + + + "
set "%~1[3]=+ + + + + + + + + + "
set "%~1[4]=+ + + + + + + + + + "
set "%~1[5]=+ + + + + + + + + + "
set "%~1[6]=+ + + + + + + + + + "
set "%~1[7]=+ + + + + + + + + + "
set "%~1[8]=+ + + + + + + + + + "
set "%~1[9]=+ + + + + + + + + + "
set "%~1[0]=+ + + + + + + + + + "
goto :EOF

:drawLayout
set var=%~1
if "%var%"=="Player1" (
	echo     1 2 3 4 5 6 7 8 9 10
	echo    ---------------------
	echo(A ^| %p1Layout[1]%^|
	echo(B ^| %p1Layout[2]%^|
	echo(C ^| %p1Layout[3]%^|
	echo(D ^| %p1Layout[4]%^|
	echo(E ^| %p1Layout[5]%^|
	echo(F ^| %p1Layout[6]%^|
	echo(G ^| %p1Layout[7]%^|
	echo(H ^| !p1Layout[8]!^|
	echo(I ^| !p1Layout[9]!^|
	echo(J ^| !p1Layout[0]!^|
	echo    ---------------------
)
if "%var%"=="Player2" (
	echo     1 2 3 4 5 6 7 8 9 10
	echo    ---------------------
	echo(A ^| %p2Layout[1]%^|
	echo(B ^| %p2Layout[2]%^|
	echo(C ^| %p2Layout[3]%^|
	echo(D ^| %p2Layout[4]%^|
	echo(E ^| %p2Layout[5]%^|
	echo(F ^| %p2Layout[6]%^|
	echo(G ^| %p2Layout[7]%^|
	echo(H ^| !p2Layout[8]!^|
	echo(I ^| !p2Layout[9]!^|
	echo(J ^| !p2Layout[0]!^|
	echo    ---------------------
)
goto :EOF

:drawCombat
set var=%~1
if "%var%"=="Player1" (
	if "%~2"=="-1" (
		echo          Your Enemy                    Your Ships           Shots Fired: !numShots!
	) else (
		echo          Your Ships                    Your Enemy           Shots Fired: !numShots!
	)
	echo     1 2 3 4 5 6 7 8 9 10          1 2 3 4 5 6 7 8 9 10
   	echo    ---------------------         ---------------------
	echo(A ^| !p1Layout[1]!^|     A ^| !p1Shots[1]!^|     Legend:
	echo(B ^| !p1Layout[2]!^|     B ^| !p1Shots[2]!^|    
	echo(C ^| !p1Layout[3]!^|     C ^| !p1Shots[3]!^|     C - Carrier
	echo(D ^| !p1Layout[4]!^|     D ^| !p1Shots[4]!^|     B - Battleship
	echo(E ^| !p1Layout[5]!^|     E ^| !p1Shots[5]!^|     c - Cruisier
	echo(F ^| !p1Layout[6]!^|     F ^| !p1Shots[6]!^|     S - Submarine
	echo(G ^| !p1Layout[7]!^|     G ^| !p1Shots[7]!^|     D - Destroyer
	echo(H ^| !p1Layout[8]!^|     H ^| !p1Shots[8]!^|     + - Unknown
	echo(I ^| !p1Layout[9]!^|     I ^| !p1Shots[9]!^|     * - Missed Shot
	echo(J ^| !p1Layout[0]!^|     J ^| !p1Shots[0]!^|     X - Hit Ship
	echo    ---------------------         ---------------------
)
if "%var%"=="Player2" (
	if "%~2"=="-1" (
		echo          Your Enemy                    Your Ships           Shots Fired: !numShots!
	) else (
		echo          Your Ships                    Your Enemy           Shots Fired: !numShots!
	)
	echo     1 2 3 4 5 6 7 8 9 10          1 2 3 4 5 6 7 8 9 10
   	echo    ---------------------         ---------------------
	echo(A ^| !p2Layout[1]!^|     A ^| !p2Shots[1]!^|     Legend:
	echo(B ^| !p2Layout[2]!^|     B ^| !p2Shots[2]!^|    
	echo(C ^| !p2Layout[3]!^|     C ^| !p2Shots[3]!^|     C - Carrier
	echo(D ^| !p2Layout[4]!^|     D ^| !p2Shots[4]!^|     B - Battleship
	echo(E ^| !p2Layout[5]!^|     E ^| !p2Shots[5]!^|     c - Cruisier
	echo(F ^| !p2Layout[6]!^|     F ^| !p2Shots[6]!^|     S - Submarine
	echo(G ^| !p2Layout[7]!^|     G ^| !p2Shots[7]!^|     D - Destroyer
	echo(H ^| !p2Layout[8]!^|     H ^| !p2Shots[8]!^|     + - Unknown
	echo(I ^| !p2Layout[9]!^|     I ^| !p2Shots[9]!^|     * - Missed Shot
	echo(J ^| !p2Layout[0]!^|     J ^| !p2Shots[0]!^|     X - Hit Ship
	echo    ---------------------         ---------------------
)
goto :EOF

:drawOverview
if !numPlayers! GTR 0 (
	if "!numPlayers!"=="1" (
		echo           Player 1                        CPU              Shots Fired: !numShots!
	echo     1 2 3 4 5 6 7 8 9 10          1 2 3 4 5 6 7 8 9 10
	echo    ---------------------         ---------------------
	echo(A ^| !p1Layout[1]!^|     A ^| !p2Layout[1]!^|     Legend:
	echo(B ^| !p1Layout[2]!^|     B ^| !p2Layout[2]!^|    
	echo(C ^| !p1Layout[3]!^|     C ^| !p2Layout[3]!^|     C - Carrier
	echo(D ^| !p1Layout[4]!^|     D ^| !p2Layout[4]!^|     B - Battleship
	echo(E ^| !p1Layout[5]!^|     E ^| !p2Layout[5]!^|     c - Cruisier
	echo(F ^| !p1Layout[6]!^|     F ^| !p2Layout[6]!^|     S - Submarine
	echo(G ^| !p1Layout[7]!^|     G ^| !p2Layout[7]!^|     D - Destroyer
	echo(H ^| !p1Layout[8]!^|     H ^| !p2Layout[8]!^|     + - Unknown
	echo(I ^| !p1Layout[9]!^|     I ^| !p2Layout[9]!^|     * - Missed Shot
	echo(J ^| !p1Layout[0]!^|     J ^| !p2Layout[0]!^|     X - Hit Ship
	echo    ---------------------         ---------------------
	) else (
		if "!currentCPU!"=="" (
		echo           Player 1                      Player 2           Shots Fired: !numShots!
	echo     1 2 3 4 5 6 7 8 9 10          1 2 3 4 5 6 7 8 9 10
	echo    ---------------------         ---------------------
	echo(A ^| !p1Layout[1]!^|     A ^| !p2Layout[1]!^|     Legend:
	echo(B ^| !p1Layout[2]!^|     B ^| !p2Layout[2]!^|    
	echo(C ^| !p1Layout[3]!^|     C ^| !p2Layout[3]!^|     C - Carrier
	echo(D ^| !p1Layout[4]!^|     D ^| !p2Layout[4]!^|     B - Battleship
	echo(E ^| !p1Layout[5]!^|     E ^| !p2Layout[5]!^|     c - Cruisier
	echo(F ^| !p1Layout[6]!^|     F ^| !p2Layout[6]!^|     S - Submarine
	echo(G ^| !p1Layout[7]!^|     G ^| !p2Layout[7]!^|     D - Destroyer
	echo(H ^| !p1Layout[8]!^|     H ^| !p2Layout[8]!^|     + - Unknown
	echo(I ^| !p1Layout[9]!^|     I ^| !p2Layout[9]!^|     * - Missed Shot
	echo(J ^| !p1Layout[0]!^|     J ^| !p2Layout[0]!^|     X - Hit Ship
	echo    ---------------------         ---------------------
		) else (
		echo            CPU1                          CPU2             Shots Fired: !numShots!
	echo     1 2 3 4 5 6 7 8 9 10          1 2 3 4 5 6 7 8 9 10
	echo    ---------------------         ---------------------
	echo(A ^| !p2Layout[1]!^|     A ^| !p1Layout[1]!^|     Legend:
	echo(B ^| !p2Layout[2]!^|     B ^| !p1Layout[2]!^|    
	echo(C ^| !p2Layout[3]!^|     C ^| !p1Layout[3]!^|     C - Carrier
	echo(D ^| !p2Layout[4]!^|     D ^| !p1Layout[4]!^|     B - Battleship
	echo(E ^| !p2Layout[5]!^|     E ^| !p1Layout[5]!^|     c - Cruisier
	echo(F ^| !p2Layout[6]!^|     F ^| !p1Layout[6]!^|     S - Submarine
	echo(G ^| !p2Layout[7]!^|     G ^| !p1Layout[7]!^|     D - Destroyer
	echo(H ^| !p2Layout[8]!^|     H ^| !p1Layout[8]!^|     + - Unknown
	echo(I ^| !p2Layout[9]!^|     I ^| !p1Layout[9]!^|     * - Missed Shot
	echo(J ^| !p2Layout[0]!^|     J ^| !p1Layout[0]!^|     X - Hit Ship
	echo    ---------------------         ---------------------
		)
	)

)
goto :EOF

:displayShip
set var=%~1
if "!var!"=="Carrier" (
	echo(!var!: (%~2 Spaces^)
	echo(!car1!
	echo(!car2!
	echo(!car3!
)
if "!var!"=="Battleship" (
	echo(!var!: (%~2 Spaces^)
	echo(!bat1!
	echo(!bat2!
	echo(!bat3!
)
if "!var!"=="Cruiser" (
	echo(!var!: (%~2 Spaces^)
	echo(!cru1!
	echo(!cru2!
	echo(!cru3!
)
if "!var!"=="Submarine" (
	echo(!var!: (%~2 Spaces^)
	echo(!sub1!
	echo(!sub2!
	echo(!sub3!
)
if "!var!"=="Destroyer" (
	echo(!var!: (%~2 Spaces^)
	echo(!des1!
	echo(!des2!
	echo(!des3!
)
goto :EOF

:getNumFromLet
set var=%~1
set %~2=-1
if /i %var%==a (
	set %~2=1
) else if /i %var%==b (
	set %~2=2
) else if /i %var%==c (
	set %~2=3
) else if /i %var%==d (
	set %~2=4
) else if /i %var%==e (
	set %~2=5
) else if /i %var%==f (
	set %~2=6
) else if /i %var%==g (
	set %~2=7
) else if /i %var%==h (
	set %~2=8
) else if /i %var%==i (
	set %~2=9
) else if /i %var%==j (
	set %~2=0
) else (
	set %~2=-1
)
goto :EOF

:p1PlaceShip
REM %ident% %carInd% %carCol% %carDir% %len% err 
set var1=%~1
set var2=%~2
if "!var2!"=="0" (
	set var2t=10
) else (
	set var2t=!var2!
)
set var3=%~3
set var4=%~4
set var5=%~5


if /i "!var4!"=="u" (
	REM Let's build our ship up
	for /l %%i in (0, 1, !len!) do (
		set /a indvar=!var2t!-%%i
		if "!indvar!"=="10" set /a indvar=0
		call :getP1Row !indvar! row
		call :checkChar !var3! "!row!" cl
		if NOT "!cl!"=="1" (
			set %~6=1
			goto :EOF
		)
	)

	REM We made it this far, that means we're golden, let's write our
	REM variables in.

	for /l %%i in (0, 1, !len!) do (
		set /a indvar=!var2t!-%%i
		if "!indvar!"=="10" set /a indvar=0
		call :getP1Row !indvar! row2
		set /a numcheck=!var3!*2-3
		if !numcheck! LSS 0 set /a numcheck=0
		call :buildRow "!row2!" !numcheck! !var1! res
		call :setP1Row !indvar! "!res!"
	)
) else if /i "!var4!"=="d" (
	REM Let's build our ship down
	for /l %%i in (0, 1, !len!) do (
		set /a indvar=!var2t!+%%i
		if "!indvar!"=="10" set /a indvar=0
		call :getP1Row !indvar! row
		call :checkChar !var3! "!row!" cl
		if NOT "!cl!"=="1" (
			set %~6=1
			goto :EOF
		)
	)

	REM We made it this far, that means we're golden, let's write our
	REM variables in.

	for /l %%i in (0, 1, !len!) do (
		set /a indvar=!var2t!+%%i
		if "!indvar!"=="10" set /a indvar=0
		call :getP1Row !indvar! row2
		set /a numcheck=!var3!*2-3
		if !numcheck! LSS 0 set /a numcheck=0
		call :buildRow "!row2!" !numcheck! !var1! res
		call :setP1Row !indvar! "!res!"
	)

) else if /i "!var4!"=="l" (
	REM Let's build our ship left
	set /a startPoint=!var3!-!len!
	call :getP1Row !var2! row
	for /l %%i in (!startPoint!, 1, !var3!) do (
		call :checkChar %%i "!row!" cl
		if NOT "!cl!"=="1" (
			set %~6=1
			goto :EOF
		)
	)

	REM All clear!	
	set newRow=!row!
	for /l %%i in (!startPoint!, 1, !var3!) do (
		call :autoRow %%i "!newRow!" "!var1!" aRow
		REM set /a inde=%%i*2-3
		REM set aRow=
		REM call :buildRow "!newRow!" !inde! !var1! aRow
		set newRow=!aRow!
	)
	call :setP1Row !var2! "!newRow!"
	

) else if /i "!var4!"=="r" (
	REM Let's build our ship left
	set /a endPoint=!var3!+!len!
	call :getP1Row !var2! row
	for /l %%i in (!var3!, 1, !endPoint!) do (
		call :checkChar %%i "!row!" cl
		if NOT "!cl!"=="1" (
			set %~6=1
			goto :EOF
		)
	)

	REM All clear!	
	set newRow=!row!
	for /l %%i in (!var3!, 1, !endPoint!) do (
		call :autoRow %%i "!newRow!" "!var1!" aRow
		REM set /a inde=%%i*2-3
		REM set aRow=
		REM call :buildRow "!newRow!" !inde! !var1! aRow
		set newRow=!aRow!
	)
	call :setP1Row !var2! "!newRow!"

) else (
	echo Not up
	pause
)
goto :EOF

:p2PlaceShip
REM %ident% %carInd% %carCol% %carDir% %len% err 
set var1=%~1
set var2=%~2
if "!var2!"=="0" (
	set var2t=10
) else (
	set var2t=!var2!
)
set var3=%~3
set var4=%~4
set var5=%~5


if /i "!var4!"=="u" (
	REM Let's build our ship up
	for /l %%i in (0, 1, !len!) do (
		set /a indvar=!var2t!-%%i
		if "!indvar!"=="10" set /a indvar=0
		call :getP2Row !indvar! row
		call :checkChar !var3! "!row!" cl
		if NOT "!cl!"=="1" (
			set %~6=1
			goto :EOF
		)
	)

	REM We made it this far, that means we're golden, let's write our
	REM variables in.

	for /l %%i in (0, 1, !len!) do (
		set /a indvar=!var2t!-%%i
		if "!indvar!"=="10" set /a indvar=0
		call :getP2Row !indvar! row2
		set /a numcheck=!var3!*2-3
		if !numcheck! LSS 0 set /a numcheck=0
		call :buildRow "!row2!" !numcheck! !var1! res
		call :setP2Row !indvar! "!res!"
	)
) else if /i "!var4!"=="d" (
	REM Let's build our ship down
	for /l %%i in (0, 1, !len!) do (
		set /a indvar=!var2t!+%%i
		if "!indvar!"=="10" set /a indvar=0
		call :getP2Row !indvar! row
		call :checkChar !var3! "!row!" cl
		if NOT "!cl!"=="1" (
			set %~6=1
			goto :EOF
		)
	)

	REM We made it this far, that means we're golden, let's write our
	REM variables in.

	for /l %%i in (0, 1, !len!) do (
		set /a indvar=!var2t!+%%i
		if "!indvar!"=="10" set /a indvar=0
		call :getP2Row !indvar! row2
		set /a numcheck=!var3!*2-3
		if !numcheck! LSS 0 set /a numcheck=0
		call :buildRow "!row2!" !numcheck! !var1! res
		call :setP2Row !indvar! "!res!"
	)

) else if /i "!var4!"=="l" (
	REM Let's build our ship left
	set /a startPoint=!var3!-!len!
	call :getP2Row !var2! row
	for /l %%i in (!startPoint!, 1, !var3!) do (
		call :checkChar %%i "!row!" cl
		if NOT "!cl!"=="1" (
			set %~6=1
			goto :EOF
		)
	)

	REM All clear!	
	set newRow=!row!
	for /l %%i in (!startPoint!, 1, !var3!) do (
		call :autoRow %%i "!newRow!" "!var1!" aRow
		REM set /a inde=%%i*2-3
		REM set aRow=
		REM call :buildRow "!newRow!" !inde! !var1! aRow
		set newRow=!aRow!
	)
	call :setP2Row !var2! "!newRow!"
	

) else if /i "!var4!"=="r" (
	REM Let's build our ship left
	set /a endPoint=!var3!+!len!
	call :getP2Row !var2! row
	for /l %%i in (!var3!, 1, !endPoint!) do (
		call :checkChar %%i "!row!" cl
		if NOT "!cl!"=="1" (
			set %~6=1
			goto :EOF
		)
	)

	REM All clear!	
	set newRow=!row!
	for /l %%i in (!var3!, 1, !endPoint!) do (
		call :autoRow %%i "!newRow!" "!var1!" aRow
		REM set /a inde=%%i*2-3
		REM if "!inde!"=="-1" set /a inde=0
		REM call :buildRow "!newRow!" !inde! !var1! aRow
		set newRow=!aRow!
	)
	call :setP2Row !var2! "!newRow!"

)
goto :EOF

:autoRow %%i "!newRow!" "!var1!" aRow
set /a inde=%~1*2-3
if "!inde!"=="-1" set /a inde=0
set bRow=
call :buildRow "%~2" "!inde!" "%~3" bRow
set %~4=!bRow!
goto :EOF

:checkChar
set /a numcheck=%~1*2-2
set rcheck=%~2
set ccheck=!rcheck:~%numcheck%,1!
if "!ccheck!"=="+" (
	set %~3=1
) else (
	set %~3=0
)
goto :EOF

:getCPUDir
REM set /a ranVar=!RANDOM! * 4 / 32768 + 1
set /a ranVar=%~1
REM echo Random !ranVar!
if "!ranVar!"=="1" set "%~2=u"
if "!ranVar!"=="2" set "%~2=d"
if "!ranVar!"=="3" set "%~2=l"
if "!ranVar!"=="4" set "%~2=r"
REM echo getP1Row: !theReturn!
REM set %~2=!theReturn!
goto :EOF

:getP1Row
set elvar=%~1
set theReturn=!p1Layout[%elvar%]!
REM echo getP1Row: !theReturn!
set %~2=!theReturn!
goto :EOF

:setP1Row
set p1Layout[%~1]=%~2
goto :EOF

:getP2Row
set elvar=%~1
set theReturn=!p2Layout[%elvar%]!
REM echo getP2Row: !theReturn!
set %~2=!theReturn!
goto :EOF

:setP2Row
set p2Layout[%~1]=%~2
goto :EOF

:setP1Shots
set p1Shots[%~1]=%~2
goto :EOF

:setP2Shots
set p2Shots[%~1]=%~2
goto :EOF


REM Heres' the part with the problems
REM When a 0 is passed as parameter 2,
REM it gets all jacked up and doubles
REM the row.

:buildRow
set theRow=%~1
set theInd=%~2
set theCha=%~3

REM echo !theInd!

if "!theInd!"=="0" (
	set "newRow=!theCha! "
	set /a theInd2=!theInd!+2
) else (
	set "newRow=!theRow:~0,%theInd%!"
	set "newRow=!newRow! !theCha! "
	set /a theInd2=!theInd!+3
)
set /a duncheck=20-!theInd2!

REM echo !dunCheck!
set newRow=!newRow!!theRow:~%theInd2%,%duncheck%!
set %~4=!newRow!
goto :EOF

:displayAnimation
set /a waitTime=%~1
cls
echo(!frame1!
echo(!frame2!
echo(!frame3!
echo(!frame4!
echo(!frame5!
echo(!frame6!
echo(!frame7!
echo(!frame8!

if "!waitTime!"=="" set waitTime=25
cscript //nologo //E:jscript !thisScript! "!waitTime!"
goto :EOF

:hitAnimation
if "!playAnimations!"=="0" (
	cls
	echo ### Hit ###
	echo.
	echo.
	if "!noWait!"=="0" timeout 5
	goto :EOF
)
REM Hit Animation
set "frame1=  "
set "frame2=  "
set "frame3=  "
set "frame4=  "
set "frame5="
set "frame6=  ____/\_|-\____=__^==>"
set "frame7=  \                 /"
set "frame8=~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~"
call :displayAnimation 1000

if "!playSounds!"=="1" start "" /MIN powershell -c (New-Object Media.SoundPlayer '!thisDir!Sounds\!shootSound!').PlaySync();

set "frame1=  "
set "frame2=  "
set "frame3=  "
set "frame4=  "
set "frame5=                      /"
set "frame6=  ____/\_|-\____=__^=>*"
set "frame7=  \                 / \"
set "frame8=~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~"
call :displayAnimation !defaultTime!

set "frame1=  "
set "frame2=  "
set "frame3=  "
set "frame4=  "
set "frame5=                      ."
set "frame6=  ____/\_|-\____=__^=>  *"
set "frame7=  \                 / ."
set "frame8=~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~"
call :displayAnimation !defaultTime!

set "frame1=  "
set "frame2=  "
set "frame3=  "
set "frame4=                       ."
set "frame5=                      "
set "frame6=  ____/\_|-\____=__^=>    *"
set "frame7=  \                 / "
set "frame8=~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~"
call :displayAnimation !defaultTime!

set "frame1=  "
set "frame2=  "
set "frame3=  "
set "frame4=                       "
set "frame5=                      "
set "frame6=  ____/\_|-\____=__^=>      *"
set "frame7=  \                 / "
set "frame8=~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~"
call :displayAnimation !defaultTime!

set "frame1=  "
set "frame2=  "
set "frame3=  "
set "frame4=                       "
set "frame5=                      "
set "frame6=  ____/\_|-\____=__^=>        *"
set "frame7=  \                 / "
set "frame8=~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~"
call :displayAnimation !defaultTime!

set "frame1=  "
set "frame2=  "
set "frame3=  "
set "frame4=                       "
set "frame5=                      "
set "frame6=  ____/\_|-\____=__^==>         "
set "frame7=  \                 / "
set "frame8=~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~"
call :displayAnimation !defaultTime!

set "frame1=  "
set "frame2=  "
set "frame3=  "
set "frame4=                       "
set "frame5=                      "
set "frame6=        ____=____/-|_/\____    "
set "frame7=        \                 /"
set "frame8=~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~"
call :displayAnimation 1000

set "frame1=  "
set "frame2=  "
set "frame3=  "
set "frame4=                       "
set "frame5=*                      "
set "frame6=        ____=____/-|_/\____    "
set "frame7=        \                 /"
set "frame8=~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~"
call :displayAnimation !defaultTime!

set "frame1=  "
set "frame2=  "
set "frame3=  "
set "frame4=                       "
set "frame5=  *                      "
set "frame6=        ____=____/-|_/\____    "
set "frame7=        \                 /"
set "frame8=~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~"
call :displayAnimation !defaultTime!

set "frame1=  "
set "frame2=  "
set "frame3=  "
set "frame4=                       "
set "frame5=    *                  "
set "frame6=        ____=____/-|_/\____    "
set "frame7=        \                 /"
set "frame8=~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~"
call :displayAnimation !defaultTime!

set "frame1=  "
set "frame2=  "
set "frame3=  "
set "frame4=                       "
set "frame5=                      "
set "frame6=       *____=____/-|_/\____    "
set "frame7=        \                 /"
set "frame8=~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~"
call :displayAnimation !defaultTime!

if "!playSounds!"=="1" start "" /MIN powershell -c (New-Object Media.SoundPlayer '!thisDir!Sounds\!hitSound!').PlaySync();

set "frame1=  "
set "frame2=  "
set "frame3=  "
set "frame4=                       "
set "frame5=        .              "
set "frame6=        _/._=____/-|_/\____    "
set "frame7=       .\                 /"
set "frame8=~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~"
call :displayAnimation !defaultTime!

set "frame1=  "
set "frame2=  "
set "frame3=  "
set "frame4=       .               "
set "frame5=      \    .          "
set "frame6=     .  _  _=____/-|_/\____    "
set "frame7=        \                 /"
set "frame8=~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~"
call :displayAnimation !defaultTime!

set "frame1=  "
set "frame2=  "
set "frame3=     ."
set "frame4=            .           "
set "frame5=   -                  "
set "frame6=    .   _  _=____/-|_/\____    "
set "frame7=        \                 /"
set "frame8=~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~"
call :displayAnimation !defaultTime!

set "frame1=  "
set "frame2=  "
set "frame3=      "
set "frame4=   .         .          "
set "frame5=                      "
set "frame6= /      _  _=____/-|_/\____    "
set "frame7=  .     \                 /"
set "frame8=~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~"
call :displayAnimation !defaultTime!

set "frame1=  "
set "frame2=  "
set "frame3=      "
set "frame4=                       "
set "frame5=.               .     "
set "frame6=        _  _=____/-|_/\____    "
set "frame7=        \                 /"
set "frame8=~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~"
call :displayAnimation !defaultTime!

set "frame1=  "
set "frame2=  "
set "frame3=      "
set "frame4=                       "
set "frame5=                      "
set "frame6=        _  _=____/-|_/\____    "
set "frame7=        \                 /"
set "frame8=~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~"
call :displayAnimation 1000

set "frame1=  "
set "frame2=         D            "
set "frame3=      "
set "frame4=                       "
set "frame5=                      "
set "frame6=        _  _=____/-|_/\____    "
set "frame7=        \                 /"
set "frame8=~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~"
call :displayAnimation !defaultTime!

set "frame1=  "
set "frame2=         DI            "
set "frame3=      "
set "frame4=                       "
set "frame5=                      "
set "frame6=        _  _=____/-|_/\____    "
set "frame7=        \                 /"
set "frame8=~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~"
call :displayAnimation !defaultTime!

set "frame1=  "
set "frame2=         DIR            "
set "frame3=      "
set "frame4=                       "
set "frame5=                      "
set "frame6=        _  _=____/-|_/\____    "
set "frame7=        \                 /"
set "frame8=~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~"
call :displayAnimation !defaultTime!

set "frame1=  "
set "frame2=         DIRE            "
set "frame3=      "
set "frame4=                       "
set "frame5=                      "
set "frame6=        _  _=____/-|_/\____    "
set "frame7=        \                 /"
set "frame8=~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~"
call :displayAnimation !defaultTime!

set "frame1=  "
set "frame2=         DIREC            "
set "frame3=      "
set "frame4=                       "
set "frame5=                      "
set "frame6=        _  _=____/-|_/\____    "
set "frame7=        \                 /"
set "frame8=~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~"
call :displayAnimation !defaultTime!

set "frame1=  "
set "frame2=         DIRECT            "
set "frame3=      "
set "frame4=                       "
set "frame5=                      "
set "frame6=        _  _=____/-|_/\____    "
set "frame7=        \                 /"
set "frame8=~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~"
call :displayAnimation !defaultTime!

set "frame1=  "
set "frame2=         DIRECT H            "
set "frame3=      "
set "frame4=                       "
set "frame5=                      "
set "frame6=        _  _=____/-|_/\____    "
set "frame7=        \                 /"
set "frame8=~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~"
call :displayAnimation !defaultTime!

set "frame1=  "
set "frame2=         DIRECT HI            "
set "frame3=      "
set "frame4=                       "
set "frame5=                      "
set "frame6=        _  _=____/-|_/\____    "
set "frame7=        \                 /"
set "frame8=~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~"
call :displayAnimation !defaultTime!

set "frame1=  "
set "frame2=         DIRECT HIT            "
set "frame3=      "
set "frame4=                       "
set "frame5=                      "
set "frame6=        _  _=____/-|_/\____    "
set "frame7=        \                 /"
set "frame8=~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~"
call :displayAnimation 2000
goto :EOF

:missAnimation
if "!playAnimations!"=="0" (
	cls
	echo ### Miss ###
	echo.
	echo.
	if "!noWait!"=="0" timeout 5
	goto :EOF
)
REM Miss Animation
set "frame1=  "
set "frame2=  "
set "frame3=  "
set "frame4=  "
set "frame5="
set "frame6=  ____/\_|-\____=__^==>"
set "frame7=  \                 /"
set "frame8=~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~"
call :displayAnimation 1000

if "!playSounds!"=="1" start "" /MIN powershell -c (New-Object Media.SoundPlayer '!thisDir!Sounds\!shootSound!').PlaySync();

set "frame1=  "
set "frame2=  "
set "frame3=  "
set "frame4=  "
set "frame5=                      /"
set "frame6=  ____/\_|-\____=__^=>*"
set "frame7=  \                 / \"
set "frame8=~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~"
call :displayAnimation !defaultTime!

set "frame1=  "
set "frame2=  "
set "frame3=  "
set "frame4=  "
set "frame5=                      ."
set "frame6=  ____/\_|-\____=__^=>  *"
set "frame7=  \                 / ."
set "frame8=~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~"
call :displayAnimation !defaultTime!

set "frame1=  "
set "frame2=  "
set "frame3=  "
set "frame4=                       ."
set "frame5=                      "
set "frame6=  ____/\_|-\____=__^=>    *"
set "frame7=  \                 / "
set "frame8=~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~"
call :displayAnimation !defaultTime!

set "frame1=  "
set "frame2=  "
set "frame3=  "
set "frame4=                       "
set "frame5=                      "
set "frame6=  ____/\_|-\____=__^=>      *"
set "frame7=  \                 / "
set "frame8=~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~"
call :displayAnimation !defaultTime!

set "frame1=  "
set "frame2=  "
set "frame3=  "
set "frame4=                       "
set "frame5=                      "
set "frame6=  ____/\_|-\____=__^=>        *"
set "frame7=  \                 / "
set "frame8=~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~"
call :displayAnimation !defaultTime!

set "frame1=  "
set "frame2=  "
set "frame3=  "
set "frame4=                       "
set "frame5=                      "
set "frame6=  ____/\_|-\____=__^==>         "
set "frame7=  \                 / "
set "frame8=~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~"
call :displayAnimation !defaultTime!

set "frame1=  "
set "frame2=  "
set "frame3=  "
set "frame4=                       "
set "frame5=                      "
set "frame6=        ____=____/-|_/\____    "
set "frame7=        \                 /"
set "frame8=~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~"
call :displayAnimation 1000

set "frame1=  "
set "frame2=  "
set "frame3=  "
set "frame4=                       "
set "frame5=                      "
set "frame6=*       ____=____/-|_/\____    "
set "frame7=        \                 /"
set "frame8=~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~"
call :displayAnimation !defaultTime!

set "frame1=  "
set "frame2=  "
set "frame3=  "
set "frame4=                       "
set "frame5=                      "
set "frame6=        ____=____/-|_/\____    "
set "frame7=  *     \                 /"
set "frame8=~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~"
call :displayAnimation !defaultTime!

if "!playSounds!"=="1" start "" /MIN powershell -c (New-Object Media.SoundPlayer '!thisDir!Sounds\!missSound!').PlaySync();

set "frame1=  "
set "frame2=  "
set "frame3=  "
set "frame4=                       "
set "frame5=                      "
set "frame6=        ____=____/-|_/\____    "
set "frame7=        \                 /"
set "frame8=~~~~~\*|~~~~~~~~~~~~~~~~~~~~~~~"
call :displayAnimation !defaultTime!

set "frame1=  "
set "frame2=  "
set "frame3=  "
set "frame4=                       "
set "frame5=                      "
set "frame6=     .  ____=____/-|_/\____    "
set "frame7=    . . \                 /"
set "frame8=~~~~~\ /~~~~~~~~~~~~~~~~~~~~~~~"
call :displayAnimation !defaultTime!

set "frame1=  "
set "frame2=  "
set "frame3=  "
set "frame4=                       "
set "frame5=    .                 "
set "frame6=  .   . ____=____/-|_/\____    "
set "frame7=        \                 /"
set "frame8=~~~~~\-/~~~~~~~~~~~~~~~~~~~~~~~"
call :displayAnimation !defaultTime!

set "frame1=  "
set "frame2=  "
set "frame3=  "
set "frame4=  .                    "
set "frame5=.      .              "
set "frame6=        ____=____/-|_/\____    "
set "frame7=        \                 /"
set "frame8=~~~~~/\~~~~~~~~~~~~~~~~~~~~~~~~"
call :displayAnimation !defaultTime!

set "frame1=  "
set "frame2=  "
set "frame3=  "
set "frame4=.                      "
set "frame5=                      "
set "frame6=        ____=____/-|_/\____    "
set "frame7=        \                 /"
set "frame8=~~~~~-\~~~~~~~~~~~~~~~~~~~~~~~~"
call :displayAnimation !defaultTime!

set "frame1=  "
set "frame2=  "
set "frame3=  "
set "frame4=                      "
set "frame5=                      "
set "frame6=        ____=____/-|_/\____    "
set "frame7=        \                 /"
set "frame8=~~~~~~-~~~~~~~~~~~~~~~~~~~~~~~~"
call :displayAnimation !defaultTime!

set "frame1=  "
set "frame2=  "
set "frame3=  "
set "frame4=                      "
set "frame5=                      "
set "frame6=        ____=____/-|_/\____    "
set "frame7=        \                 /"
set "frame8=~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~"
call :displayAnimation 1000

set "frame1=  "
set "frame2=            M            "
set "frame3=  "
set "frame4=                      "
set "frame5=                      "
set "frame6=        ____=____/-|_/\____    "
set "frame7=        \                 /"
set "frame8=~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~"
call :displayAnimation !defaultTime!

set "frame1=  "
set "frame2=            MI            "
set "frame3=  "
set "frame4=                      "
set "frame5=                      "
set "frame6=        ____=____/-|_/\____    "
set "frame7=        \                 /"
set "frame8=~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~"
call :displayAnimation !defaultTime!

set "frame1=  "
set "frame2=            MIS            "
set "frame3=  "
set "frame4=                      "
set "frame5=                      "
set "frame6=        ____=____/-|_/\____    "
set "frame7=        \                 /"
set "frame8=~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~"
call :displayAnimation !defaultTime!

set "frame1=  "
set "frame2=            MISS            "
set "frame3=  "
set "frame4=                      "
set "frame5=                      "
set "frame6=        ____=____/-|_/\____    "
set "frame7=        \                 /"
set "frame8=~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~"
call :displayAnimation 2000
goto :EOF

:sunkAnimation
if "!playAnimations!"=="0" (
	cls
	echo ### Sunk ###
	echo.
	echo.
	if "!noWait!"=="0" timeout 5
	goto :EOF
)
REM Sunk Animation
set "frame1=  "
set "frame2=  "
set "frame3=  "
set "frame4=  "
set "frame5="
set "frame6=  ____/\_|-\____=__^==>"
set "frame7=  \                 /"
set "frame8=~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~"
call :displayAnimation 1000

if "!playSounds!"=="1" start "" /MIN powershell -c (New-Object Media.SoundPlayer '!thisDir!Sounds\!shootSound!').PlaySync();

set "frame1=  "
set "frame2=  "
set "frame3=  "
set "frame4=  "
set "frame5=                      /"
set "frame6=  ____/\_|-\____=__^=>*"
set "frame7=  \                 / \"
set "frame8=~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~"
call :displayAnimation !defaultTime!

set "frame1=  "
set "frame2=  "
set "frame3=  "
set "frame4=  "
set "frame5=                      ."
set "frame6=  ____/\_|-\____=__^=>  *"
set "frame7=  \                 / ."
set "frame8=~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~"
call :displayAnimation !defaultTime!

set "frame1=  "
set "frame2=  "
set "frame3=  "
set "frame4=                       ."
set "frame5=                      "
set "frame6=  ____/\_|-\____=__^=>    *"
set "frame7=  \                 / "
set "frame8=~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~"
call :displayAnimation !defaultTime!

set "frame1=  "
set "frame2=  "
set "frame3=  "
set "frame4=                       "
set "frame5=                      "
set "frame6=  ____/\_|-\____=__^=>      *"
set "frame7=  \                 / "
set "frame8=~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~"
call :displayAnimation !defaultTime!

set "frame1=  "
set "frame2=  "
set "frame3=  "
set "frame4=                       "
set "frame5=                      "
set "frame6=  ____/\_|-\____=__^=>        *"
set "frame7=  \                 / "
set "frame8=~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~"
call :displayAnimation !defaultTime!

set "frame1=  "
set "frame2=  "
set "frame3=  "
set "frame4=                       "
set "frame5=                      "
set "frame6=  ____/\_|-\____=__^==>         "
set "frame7=  \                 / "
set "frame8=~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~"
call :displayAnimation !defaultTime!

set "frame1=  "
set "frame2=  "
set "frame3=  "
set "frame4=                       "
set "frame5=                      "
set "frame6=        ____=____/-|_/\____    "
set "frame7=        \                 /"
set "frame8=~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~"
call :displayAnimation 1000

set "frame1=  "
set "frame2=  "
set "frame3=  "
set "frame4=                       "
set "frame5=*                      "
set "frame6=        ____=____/-|_/\____    "
set "frame7=        \                 /"
set "frame8=~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~"
call :displayAnimation !defaultTime!

set "frame1=  "
set "frame2=  "
set "frame3=  "
set "frame4=                       "
set "frame5=  *                      "
set "frame6=        ____=____/-|_/\____    "
set "frame7=        \                 /"
set "frame8=~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~"
call :displayAnimation !defaultTime!

set "frame1=  "
set "frame2=  "
set "frame3=  "
set "frame4=                       "
set "frame5=    *                  "
set "frame6=        ____=____/-|_/\____    "
set "frame7=        \                 /"
set "frame8=~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~"
call :displayAnimation !defaultTime!

set "frame1=  "
set "frame2=  "
set "frame3=  "
set "frame4=                       "
set "frame5=                      "
set "frame6=       *____=____/-|_/\____    "
set "frame7=        \                 /"
set "frame8=~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~"
call :displayAnimation !defaultTime!

if "!playSounds!"=="1" start "" /MIN powershell -c (New-Object Media.SoundPlayer '!thisDir!Sounds\!sunkSound!').PlaySync();

set "frame1=  "
set "frame2=  "
set "frame3=  "
set "frame4=                       "
set "frame5=        .              "
set "frame6=        _/._=____/-|_/\____    "
set "frame7=       .\                 /"
set "frame8=~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~"
call :displayAnimation !defaultTime!

set "frame1=  "
set "frame2=  "
set "frame3=  "
set "frame4=       .               "
set "frame5=      \    .          "
set "frame6=     .  _  _=____/-|_/\____    "
set "frame7=        \                 /"
set "frame8=~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~"
call :displayAnimation !defaultTime!

set "frame1=  "
set "frame2=  "
set "frame3=     ."
set "frame4=            .           "
set "frame5=   -                  "
set "frame6=    .   _  _=____/-|_/\____    "
set "frame7=        \                 /"
set "frame8=~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~"
call :displayAnimation !defaultTime!

set "frame1=  "
set "frame2=  "
set "frame3=      "
set "frame4=   .         .          "
set "frame5=                      "
set "frame6= /      _  _=____/-|_/\____    "
set "frame7=  .     \                 /"
set "frame8=~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~"
call :displayAnimation !defaultTime!

set "frame1=  "
set "frame2=  "
set "frame3=      "
set "frame4=                       "
set "frame5=.               .     "
set "frame6=        _  _=____/-|_/\____    "
set "frame7=        \                 /"
set "frame8=~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~"
call :displayAnimation !defaultTime!

set "frame1=  "
set "frame2=  "
set "frame3=      "
set "frame4=                       "
set "frame5=                    "
set "frame6=        _  _=____/-|_/\____    "
set "frame7=        \                 /"
set "frame8=~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~"
call :displayAnimation !defaultTime!

set "frame1=  "
set "frame2=  "
set "frame3=      "
set "frame4=                       "
set "frame5=                    "
set "frame6=        _  _=_/._/-|_/\____    "
set "frame7=        \                 /"
set "frame8=~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~"
call :displayAnimation !defaultTime!

set "frame1=  "
set "frame2=  "
set "frame3=      "
set "frame4=               .        "
set "frame5=             |   .    "
set "frame6=        _  _=_  _/-|_/\____    "
set "frame7=        \                 /"
set "frame8=~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~"
call :displayAnimation !defaultTime!

set "frame1=  "
set "frame2=  "
set "frame3=            .                  "
set "frame4=                   .           "
set "frame5=          -                    "
set "frame6=        _  _=_  _/-|_/\/.__    "
set "frame7=        \                 /    "
set "frame8=~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~"
call :displayAnimation !defaultTime!

set "frame1=  "
set "frame2=  "
set "frame3=                               "
set "frame4=        .               .      "
set "frame5=                     .|   .    "
set "frame6=      / _  _=_  _/-|_/\  __    "
set "frame7=        \                 /    "
set "frame8=~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~"
call :displayAnimation !defaultTime!

set "frame1=  "
set "frame2=  "
set "frame3=                          .    "
set "frame4=                     \       . "
set "frame5=      .                        "
set "frame6=        _  _=_  _/-|_/\  __    "
set "frame7=    |   \                 /    "
set "frame8=~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~"
call :displayAnimation !defaultTime!

set "frame1=  "
set "frame2=  "
set "frame3=                    -         ."
set "frame4=                               "
set "frame5=                               "
set "frame6=     .  _  _=_  _/-|_/\  __    "
set "frame7=        \                 /    "
set "frame8=~~~\~~~~~~~~~~~~~~~~~~~~~~~~~~~"
call :displayAnimation !defaultTime!

set "frame1=  "
set "frame2=  "
set "frame3=                               "
set "frame4=                   /           "
set "frame5=                               "
set "frame6=        _  _=_  _/-|_/\  __    "
set "frame7=    .   \                 /    "
set "frame8=~~~-~~~~~~~~~~~~~~~~~~~~~~~~~~~"
call :displayAnimation !defaultTime!

set "frame1=  "
set "frame2=  "
set "frame3=                               "
set "frame4=                               "
set "frame5=                  |            "
set "frame6=        _  _=_  _/-|_/\  __    "
set "frame7=        \                 /    "
set "frame8=~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~"
call :displayAnimation !defaultTime!

set "frame1=  "
set "frame2=  "
set "frame3=                               "
set "frame4=                               "
set "frame5=                              "
set "frame6=        _  _=_  \.-|_/\  __    "
set "frame7=        \                 /    "
set "frame8=~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~"
call :displayAnimation !defaultTime!

set "frame1=  "
set "frame2=  "
set "frame3=                               "
set "frame4=                               "
set "frame5=              - .              "
set "frame6=        _  _=_    .|_/\  __    "
set "frame7=        \                 /    "
set "frame8=~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~"
call :displayAnimation !defaultTime!

set "frame1=  "
set "frame2=  "
set "frame3=                               "
set "frame4=                  .            "
set "frame5=            /      .           "
set "frame6=        _  _=_     |_/\  __    "
set "frame7=        \                 /    "
set "frame8=~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~"
call :displayAnimation !defaultTime!

set "frame1=  "
set "frame2=  "
set "frame3=                               "
set "frame4=                   .           "
set "frame5=                      .        "
set "frame6=        _ -_=_     |_/\  __    "
set "frame7=        \                 /    "
set "frame8=~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~"
call :displayAnimation !defaultTime!

set "frame1=  "
set "frame2=  "
set "frame3=                               "
set "frame4=                    .          "
set "frame5=                               "
set "frame6=        \/ _=_     |_/\ .__    "
set "frame7=        \                 /    "
set "frame8=~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~"
call :displayAnimation !defaultTime!

set "frame1=  "
set "frame2=  "
set "frame3=                               "
set "frame4=                               "
set "frame5=                       .       "
set "frame6=       /.  _=_     |_/\  __    "
set "frame7=        \                 /    "
set "frame8=~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~"
call :displayAnimation !defaultTime!

set "frame1=  "
set "frame2=  "
set "frame3=                               "
set "frame4=                               "
set "frame5=                               "
set "frame6=      -    _=_     |_/\  __.   "
set "frame7=        \                 /    "
set "frame8=~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~"
call :displayAnimation !defaultTime!

set "frame1=  "
set "frame2=  "
set "frame3=                               "
set "frame4=                               "
set "frame5=                               "
set "frame6=           _=_     |_/\  __    "
set "frame7=    /   \                 /    "
set "frame8=~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~"
call :displayAnimation !defaultTime!

set "frame1=  "
set "frame2=  "
set "frame3=                               "
set "frame4=                               "
set "frame5=                               "
set "frame6=           _=_     |_/\  __    "
set "frame7=        \                 /    "
set "frame8=~~~\~~~~~~~~~~~~~~~~~~~~~~~~~~~"
call :displayAnimation !defaultTime!

set "frame1=  "
set "frame2=  "
set "frame3=                               "
set "frame4=                               "
set "frame5=                               "
set "frame6=           _=_     |_/\  __    "
set "frame7=        \                 /    "
set "frame8=~~~-~~~~~~~~~~~~~~~~~~~~~~~~~~~"
call :displayAnimation !defaultTime!

set "frame1=  "
set "frame2=  "
set "frame3=                               "
set "frame4=                               "
set "frame5=                               "
set "frame6=           _=_     |_/\  __    "
set "frame7=        \                 /    "
set "frame8=~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~"
call :displayAnimation 1000

set "frame1=  "
set "frame2=            S            "
set "frame3=                               "
set "frame4=                               "
set "frame5=                               "
set "frame6=           _=_     |_/\  __    "
set "frame7=        \                 /    "
set "frame8=~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~"
call :displayAnimation !defaultTime!

set "frame1=  "
set "frame2=            SU            "
set "frame3=                               "
set "frame4=                               "
set "frame5=                               "
set "frame6=           _=_     |_/\  __    "
set "frame7=        \                 /    "
set "frame8=~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~"
call :displayAnimation !defaultTime!

set "frame1=  "
set "frame2=            SUN            "
set "frame3=                               "
set "frame4=                               "
set "frame5=                               "
set "frame6=           _=_     |_/\  __    "
set "frame7=        \                 /    "
set "frame8=~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~"
call :displayAnimation !defaultTime!

set "frame1=  "
set "frame2=            SUNK            "
set "frame3=                               "
set "frame4=                               "
set "frame5=                               "
set "frame6=           _=_     |_/\  __    "
set "frame7=        \                 /    "
set "frame8=~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~"
call :displayAnimation 2000
goto :EOF

REM Java */
var x = WScript.Arguments;
var sleepTime = x(0);
WScript.Sleep( sleepTime );