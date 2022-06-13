; changes the Alt-Tab order since it focuses windows

; Switch between Windows of a program, Mac OSX style
	SetTitleMatchMode, 2		
	~Alt up::
	{	
		FileDelete, C:\Users\Public\alt_grave.txt ; the reason I use file stores for this is in case AHK crashes in the middle, although that's not a very good reason
		FileDelete, C:\Users\Public\alt_grave_programDesktopWindows.txt
		FileDelete, C:\Users\Public\alt_grave_allWindows.txt		
	}
	return

	SetTitleMatchMode, 2		
	#IfWinNotActive,  - Microsoft Visual Studio,
	!`::SwitchWindows(1)    ; Next window
	+!`::SwitchWindows(-1)	; Previous window
	SwitchWindows(myTab)

	{			
		if(FileExist("C:\Users\Public\alt_grave.txt")) ; if user has already pressed the shortcut, retrieve stored data
		{				
			myGlobals := FileOpen("C:\Users\Public\alt_grave.txt", "r") ; file store for non-array variables
			programDesktopWindows := FileOpen("C:\Users\Public\alt_grave_programDesktopWindows.txt", "r") ; the recency list for the program's windows on the specific desktop
			allWindows := FileOpen("C:\Users\Public\alt_grave_allWindows.txt", "r") ; the recency list for all active programs			

			; read window data
			alt_graves := RegExReplace(myGlobals.ReadLine(), "\D")			
			oldId := RegExReplace(myGlobals.ReadLine(), "[^\S]")			
			concealer := RegExReplace(myGlobals.ReadLine(), "[^\S]")
			myGlobals.Close()			
		 	numWinOnDesktop := RegExReplace(programDesktopWindows.ReadLine(), "\D")		 	
		 	numAllWindows := RegExReplace(allWindows.ReadLine(), "\D")							 	

			if (alt_graves != 0) { ; don't conceal the window that was active when hotkey was pressed ; actually, if we're switching between windows, shouldn't we hide it?
				WinGetPos, X, Y, Width, Height, ahk_id %oldId%
				DllCall("SetWindowPos" ; note that DllCall("SetWindowPos") can't disrupt the Alt-Tab order of windows
				, "UInt", oldId ;handle
				, "UInt", concealer ;HWND_TOP ; concealer defaults to zero, which for the dll interprets to place it at the top
				, "Int", X ;x
				, "Int", Y ;y
				, "Int", Width ;width
				, "Int", Height ;height
				, "UInt", 0x4010) ; 0x0010 SWP_NOACTIVATE ; SWP_ASYNCWINDOWPOS 0x4000 ; the problem with this function is that it only puts the window behind concealer
				WinSet, AlwaysOnTop, Off, ahk_id %oldId% ; DllCall("SetWindowPos") is MOTHERFUCKING bugged and sometimes makes the chosen window topmost
			}	

			alt_graves := Mod(alt_graves + numWinOnDesktop + myTab, numWinOnDesktop) ; count the number of times we've pressed grave, equivalent to the difference in index of the windows that we should move through				

		 	; get the list of windows for the program on the current desktop
		 	WindowsOnDesktop := []		 	
		 	loop, %numWinOnDesktop%
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
		 	loop, %numAllWindows%
		 	{
		 		someId := RegExReplace(allWindows.ReadLine(), "[^\S]")		 		
		 		allMyWindows[i].Push(someId)

		 		if newId == %someId%
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
			WinGetClass, ActiveClass, A						
			WinGet, myIds, List, ahk_class %ActiveClass% ; locate windows by id
			; WinGet, MyProcessName, ProcessName, A
			; WinGet, myIds, List, ahk_exe %MyProcessName%
			WindowsOnDesktop := [] ; modulate our keypresses by the number of those on the current desktop
			i := 1
			numWinOnDesktop = 0		
			loop, %myIds%
			{
				desktoppedId := myIds%i%			
				if(IsWindowOnCurrentVirtualDesktop(desktoppedId))
				{
					WindowsOnDesktop.Push(desktoppedId)				
					numWinOnDesktop++
				}			
				i++
			}		
			alt_graves := Mod(numWinOnDesktop + myTab, numWinOnDesktop) ; count the number of times we've pressed grave, equivalent to the difference in index of the windows that we should move through			

			; store the list of current windows of the active program on the current desktop
			FileDelete, C:\Users\Public\alt_grave_programDesktopWindows.txt
			programDesktopWindows := FileOpen("C:\Users\Public\alt_grave_programDesktopWindows.txt", "w")
			programDesktopWindows.WriteLine(numWinOnDesktop)		
			i := 1
			Loop, %numWinOnDesktop%
			{
				programDesktopWindows.WriteLine(WindowsOnDesktop[i])
				i++
			}
			programDesktopWindows.Close()

			; figure out which window to preview
			tabulations := alt_graves + 1 ; array index in ahk begins at 1 ...
			newId := WindowsOnDesktop[tabulations]

			; record the window immediately above the window to preview, and the total list of windows
			WinGet, allIds, List
			i := 1
			numAllWindows := 0
			loop, %allIds%
			{
				anyId := allIds%i%
				if newId = %anyId%
				{	
					i--
					concealer := allIds%i%
					; break
					i++
				}
				i++
				numAllWindows++
			}
			
			FileDelete, C:\Users\Public\alt_grave_allWindows.txt
			allWindows := FileOpen("C:\Users\Public\alt_grave_allWindows.txt", "w")
			allWindows.WriteLine(numAllWindows)
			i := 1
			Loop, %numAllWindows%
			{
				allWindows.WriteLine(allIds%i%)
				i++
			}
			allWindows.Close()
		}		
		
		; store global variables		
		FileDelete, C:\Users\Public\alt_grave.txt
		myGlobals := FileOpen("C:\Users\Public\alt_grave.txt", "w")
		myGlobals.WriteLine(alt_graves)
		myGlobals.WriteLine(newId)
		myGlobals.WriteLine(concealer)
		myGlobals.Close()

		; preview the window
		WinActivate, ahk_id %newId% ; have to actually activate the window (thereby messing with the alt-tab order) due to the way windows handles different windows of the same program; merely making it temporarily topmost risks, for example, in microsoft word, activating "%AppData%\Local\Temp" instead		
		return
	}
	#IfWinNotActive

; https://autohotkey.com/boards/viewtopic.php?p=64295#p64295
; Indicates whether the provided window is on the currently active virtual desktop:
IsWindowOnCurrentVirtualDesktop(hWnd) {
    onCurrentDesktop := ""
    CLSID := "{aa509086-5ca9-4c25-8f95-589d3c07b48a}" 
    IID := "{a5cd92ff-29be-454c-8d04-d82879fb3f1b}" 
    IVirtualDesktopManager := ComObjCreate(CLSID, IID)  
    Error := DllCall(NumGet(NumGet(IVirtualDesktopManager+0), 3*A_PtrSize), "Ptr", IVirtualDesktopManager, "Ptr", hWnd, "IntP", onCurrentDesktop)
    ObjRelease(IVirtualDesktopManager)  
    if !(Error=0)
        return false, ErrorLevel := true
    return onCurrentDesktop, ErrorLevel := false
}