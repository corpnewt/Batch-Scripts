'Let's get our command line arguments
'Available options are /exe, /path, /wait, /launch, /menuKey

'EXAMPLE:

'cscript.exe Minimize.vbs /exe:Uplay.exe 
'/path:"C:\Program Files (x86)\Ubisoft\Ubisoft Game Launcher\Uplay.exe"
'/wait:1000 /launch:true /menuKey:c

'This would all be run on one line - and would launch Uplay.exe, wait
'for /wait milliseconds (1000) - then minimize it.  The launch option
'means we will launch from the path - it HAS to be "true" if we want it
'to work - everything else will be false

set objArgs = WScript.Arguments.Named

exe = ""
path = ""
wait = 1000
launch = "false"
menuKey = "n"

If NOT(objArgs.Exists("exe")) Then
	WScript.Quit 1
Else
	exe = objArgs.Item("exe")
End If

if objArgs.Exists("launch") Then
	if StrComp(objArgs.Item("launch"), "true", vbTextCompare) = 0 Then
		launch = "true"
		WScript.Echo(exe & " launch? - " & launch)
	else
		launch = "false"
		WScript.Echo(exe & " launch? - " & launch)
	end if
end if

If objArgs.Exists("path") Then
	path = objArgs.Item("path")
Else
	launch = "false"
End If

If objArgs.Exists("menuKey") Then
	menuKey = objArgs.Item("menuKey")
End If

if objArgs.Exists("wait") Then
	wait = objArgs.Item("wait")
end if

set oShell = CreateObject("WScript.Shell")

'Now we see if we should launch
if StrComp(launch, "true", vbTextCompare) = 0 then
	set appLaunch = oShell.Exec(path)
end if

dim pidAr
pidAr = getPIDForName(exe)

on error resume next
	WScript.Echo("There are " & UBound(pidAr)+1 & " instances of " & exe & ".")
if err.number<>0 then
	WScript.Echo("An error!!")
    'do x,y,z instead
    WScript.Quit 2
end if
on error goto 0


'WScript.Echo(UBound(pidAr))

'WScript.Echo("There are " & UBound(pidAr) & " instances of " & exe & ".")

for i = 0 to UBound(pidAr)

	oShell.AppActivate pidAr(i)
	WScript.Sleep wait
	'WScript.Echo("% (" & menuKey & ")")
	'oShell.SendKeys "% (" & menuKey & ")" ' minimize (Alt+SpaceBar,n)
	'Open menu
	oShell.SendKeys "% "
	'Type our menuKey
	WScript.Sleep wait
	oShell.SendKeys menuKey ' minimize (Alt+SpaceBar,n)

next


Function getPIDForName(processName)
	'Get process ids for the named application
	'returns an array
	Dim computer 
	computer = "."
	Dim process  
	process = exe
	Dim pidArray()
	Dim arrayIndex
	arrayIndex = 0
	
	Set service = GetObject("winmgmts:\\" & computer & "\root\cimv2")
	Set results = service.ExecQuery(" Select * from Win32_Process where Name ='" & process & "'")
	for each obj in results
      'Wscript.echo obj.Name
      Wscript.echo obj.ProcessID
	  ReDim Preserve pidArray(arrayIndex)
	  pidArray(arrayIndex) = obj.ProcessID
	  arrayIndex = arrayIndex + 1
	next
	getPIDForName = pidArray
End Function	

'Firefox = """c:\path to\firefox.exe"""
'Set oShell = CreateObject("WScript.Shell")
'Set oFFox  = oShell.Exec(Firefox)

'WScript.Sleep 1000
'oShell.AppActivate oFFox.ProcessID

'WScript.Sleep 1000
'oShell.SendKeys "% (n)" ' minimize (Alt+SpaceBar,n)

'WScript.Sleep 10 * 1000 ' wait 10 seconds
'next AppActivate call need Full and Exact title
'oShell.AppActivate "Mozilla Firefox Start Page - Mozilla Firefox"

'WScript.Sleep 1000
'oShell.SendKeys "% (r)"  ' restore (Alt+SpaceBar,r)
'oShell.SendKeys "%{F4}"  ' close (Alt+F4)