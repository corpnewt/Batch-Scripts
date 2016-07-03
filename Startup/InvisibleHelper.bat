@set @junk=1 /*
@echo off

REM This script just launches a batch file invisibly

*/

var x = WScript.Arguments;
var name = x(0);
var objShell = new ActiveXObject("WScript.shell");
objShell.run("\"" + name + "\"",0);