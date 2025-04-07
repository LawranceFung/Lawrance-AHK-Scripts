#Requires AutoHotkey v2.0
; changes the Alt-Tab order since it focuses windows

#Include %A_ScriptDir%\VirtualDesktops.ahk

; Switch between Windows of a program, Mac OSX style	
; @Todo if capslock is on then ignore desktop number; switch between all windows of an application ignoring which desktop the window is on
wndwDt := "C:\Users\Public\alt_grave.txt" ; the reason I use file stores for this is in case AHK crashes in the middle, although that's not a very good reason
prgsWinsCurDsktp := "C:\Users\Public\alt_grave_programDesktopWindows.txt"
allWins := "C:\Users\Public\alt_grave_allWindows.txt"
SetTitleMatchMode(2)
~Alt up::
{	; the reason I use file stores for this is in case AHK crashes in the middle, although that's not a very good reason
	DelFile(wndwDt)
	DelFile(prgsWinsCurDsktp)
	DelFile(allWins)
	return
}

SetTitleMatchMode(2)
#HotIf !WinActive("- Microsoft Visual Studio", )

!`::switchWindows(1)    ; Next window
+!`::switchWindows(-1)	; Previous window

switchWindows(myTab)
{			
	if(FileExist(wndwDt)) ; if user has already pressed the shortcut, retrieve stored data
	{				
		myGlobals := FileOpen(wndwDt, "r") ; file store for non-array variables
		programDesktopWindows := FileOpen(prgsWinsCurDsktp, "r") ; the recency list for the program's windows on the specific desktop
		allWindows := FileOpen(allWins, "r") ; the recency list for all active programs			

		; read window data
		alt_graves := RegExReplace(myGlobals.ReadLine(), "\D")			
		oldId := RegExReplace(myGlobals.ReadLine(), "[^\S]")			
		concealer := RegExReplace(myGlobals.ReadLine(), "[^\S]")
		myGlobals.Close()			
		numWinOnDesktop := RegExReplace(programDesktopWindows.ReadLine(), "\D")		 	
		numAllWindows := RegExReplace(allWindows.ReadLine(), "\D")							 	

		if (alt_graves != 0) { ; don't conceal the window that was active when hotkey was pressed ; actually, if we're switching between windows, shouldn't we hide it?
			WinGetPos(&X, &Y, &Width, &Height, "ahk_id " oldId)
			DllCall("SetWindowPos"
			, "UInt", oldId
			, "UInt", concealer
			, "Int", X
			, "Int", Y
			, "Int", Width
			, "Int", Height
			, "UInt", 0x4010) ; note that DllCall("SetWindowPos") can't disrupt the Alt-Tab order of windows
			WinSetAlwaysOnTop(0, "ahk_id " oldId) ; DllCall("SetWindowPos") is MOTHERFUCKING bugged and sometimes makes the chosen window topmost
		}	

		alt_graves := Mod(alt_graves + numWinOnDesktop + myTab, numWinOnDesktop) ; count the number of times we've pressed grave, equivalent to the difference in index of the windows that we should move through				

		 ; get the list of windows for the program on the current desktop
		WindowsOnDesktop := []		 	
		Loop numWinOnDesktop
		{
			desktoppedId := programDesktopWindows.ReadLine()
			WindowsOnDesktop.Push(desktoppedId)		 		
		}
		programDesktopWindows.Close()
		
		; figure out which window to preview		 			 	
		tabulations := alt_graves + 1 ; array index in ahk begins at 1 ...
		newId := RegExReplace(WindowsOnDesktop[tabulations], "[^\S]")

		allMyWindows := []		 	
		i := 1
		Loop numAllWindows
		{
			someId := RegExReplace(allWindows.ReadLine(), "[^\S]")		 		
			allMyWindows.Push(someId)

			if (newId = "= " someId)
			{
				concealer := allMyWindows[i - 1]
			}
			i++
		}
		allWindows.Close()
	 }
	else ; otherwise, get and store the list of windows
	{
		; get a list of windows of the active program on the current desktop
		ActiveClass := WinGetClass("A")
		omyIds := WinGetList("ahk_class " ActiveClass,,,)
		amyIds := Array()
		myIds := omyIds.Length
		For v in omyIds
		{   amyIds.Push(v)
		} ; locate windows by id
		; WinGet, MyProcessName, ProcessName, A
		; WinGet, myIds, List, ahk_exe %MyProcessName%
		WindowsOnDesktop := [] ; modulate our keypresses by the number of those on the current desktop
		i := 1
		numWinOnDesktop := "0"
		Loop amyIds.Length
		{
			desktoppedId := amyIds[i]
			; if(IsWindowOnCurrentVirtualDesktop(desktoppedId)) ; Windows 10 WinGetList AutoHotkey v2 seems to already limit to current desktop
			; {
				WindowsOnDesktop.Push(desktoppedId)				
				numWinOnDesktop++
			; }		
			i++
		}		
		alt_graves := Mod(numWinOnDesktop + myTab, numWinOnDesktop) ; count the number of times we've pressed grave, equivalent to the difference in index of the windows that we should move through			

		; store the list of current windows of the active program on the current desktop
		DelFile(prgsWinsCurDsktp)
		
		programDesktopWindows := FileOpen(prgsWinsCurDsktp, "w")
		programDesktopWindows.WriteLine(numWinOnDesktop)		
		i := 1
		Loop numWinOnDesktop
		{
			programDesktopWindows.WriteLine(WindowsOnDesktop[i])
			i++
		}
		programDesktopWindows.Close()

		; figure out which window to preview
		tabulations := alt_graves + 1 ; array index in ahk begins at 1 ...
		newId := WindowsOnDesktop[tabulations]

		; record the window immediately above the window to preview, and the total list of windows
		oallIds := WinGetList(,,,)
		aallIds := Array()
		allIds := oallIds.Length
		For v in oallIds
		{
			aallIds.Push(v)
		}
		i := 1
		numAllWindows := 0
		Loop aallIds.Length
		{
			anyId := aallIds[i]
			if (newId = anyId)
			{	
				i--
				concealer := aallIds[i]
				; break
				i++
			}
			i++
			numAllWindows++
		}
		
		DelFile(allWins)
		
		allWindows := FileOpen(allWins, "w")
		allWindows.WriteLine(numAllWindows)
		i := 1
		Loop numAllWindows
		{
			allWindows.WriteLine(aallIds[i])
			i++
		}
		allWindows.Close()
	}		
	
	; store global variables
	DelFile(wndwDt)
	
	myGlobals := FileOpen(wndwDt, "w")
	myGlobals.WriteLine(alt_graves)
	myGlobals.WriteLine(newId)
	myGlobals.WriteLine(concealer)
	myGlobals.Close()

	; preview the window
	WinActivate("ahk_id " newId) ; have to actually activate the window (thereby messing with the alt-tab order) due to the way windows handles different windows of the same program; merely making it temporarily topmost risks, for example, in microsoft word, activating "%AppData%\Local\Temp" instead		
	return
}
#HotIf

; https://autohotkey.com/boards/viewtopic.php?p=64295#p64295
; Indicates whether the provided window is on the currently active virtual desktop:
IsWindowOnCurrentVirtualDesktop(hWnd) { ; inner NumGet() is #buggy
	onCurrentDesktop := ""
	CLSID := "{aa509086-5ca9-4c25-8f95-589d3c07b48a}" 
	IID := "{a5cd92ff-29be-454c-8d04-d82879fb3f1b}" 
	IVirtualDesktopManager := ComObject(CLSID, IID)

	; idk why following throws error but GetWinList for Autohotkey v2 on W10 seems to already limit to current virtual desktop
	myError := DllCall(NumGet(NumGet(IVirtualDesktopManager+0, "UPtr"), 3*A_PtrSize, "UPtr"), "Ptr", IVirtualDesktopManager, "Ptr", hWnd, "IntP", &onCurrentDesktop)
	
	if !(myError=0)
		return (AHKv1v2_Temp := false, ErrorLevel := true, AHKv1v2_Temp) ; V1toV2: Wrapped Multi-statement return with parentheses
	return (AHKv1v2_Temp := onCurrentDesktop, ErrorLevel := false, AHKv1v2_Temp) ; V1toV2: Wrapped Multi-statement return with parentheses	
}