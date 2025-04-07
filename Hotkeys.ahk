#Requires AutoHotkey v2.0

#SingleInstance force ; yes to singleinstance
SendMode("Input")  ; Recommended for new scripts due to its superior speed and reliability.
SetWorkingDir(A_ScriptDir)  ; Ensures a consistent starting directory.

#Include %A_ScriptDir%\ExplorerShowHidden.ahk
#Include %A_ScriptDir%\HideTaskbar.ahk
#Include %A_ScriptDir%\SwitchProgramWindows.ahk ; @todo change directory to %A_WorkingDir% instead
#Include %A_ScriptDir%\TerminalFromExplorer.ahk ; contextual shortcuts for opening CMD, PowerShell, Git Bash, etc
#Include %A_ScriptDir%\Navigation.ahk

; Reload
; #^r::Reload
F17::Reload()
#F5::Reload()
+#F5::Suspend(-1)
; refresh the ip address
+#F10::Run(A_ComSpec " /c `"ipconfig /release && ipconfig /renew`"", , "Hide")