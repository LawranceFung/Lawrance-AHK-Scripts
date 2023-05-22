; AutoHotkey Version: 1.x
; Language:       English
; Platform:       Win9x/NT
; Author:         A.N.Other <myemail@nowhere.com>
;
; Script Function:
;	Template script (you can customize this template by editing "ShellNew\Template.ahk" in your Windows folder)
;

#NoEnv  ; Recommended for performance and compatibility with future AutoHotkey releases.
SendMode Input  ; Recommended for new scripts due to its superior speed and reliability.
SetWorkingDir %A_ScriptDir%  ; Ensures a consistent starting directory.

#Include, %A_ScriptDir%\SwitchProgramWindows.ahk ; @todo change directory to %A_WorkingDir% instead
#Include, %A_ScriptDir%\TerminalFromExplorer.ahk ; contextual shortcuts for opening CMD, PowerShell, Git Bash, etc
#Include, %A_ScriptDir%\ExplorerShowHidden.ahk
#Include, %A_ScriptDir%\HideTaskbar.ahk
#Include, %A_ScriptDir%\Navigation.ahk

#F5::Reload