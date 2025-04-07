#Requires AutoHotkey v2.0

; Turns on hotkeys if off

SendMode("Input")  ; Recommended for new scripts due to its superior speed and reliability.
SetWorkingDir(A_ScriptDir)  ; Ensures a consistent starting directory.

; #todo switch statement on A_ComputerName to determine device-specific macros
SetTitleMatchMode(2)
DetectHiddenWindows(true)
if !WinExist("Hotkeys.ahk")
	Run("Hotkeys.ahk")
Return