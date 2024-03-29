; Windows TaskBar
!#Space:: ; this seems to have been deprecated by recent versions of ahk
	VarSetCapacity(APPBARDATA, A_PtrSize=4 ? 36:48)
	NumPut(DllCall("Shell32\SHAppBarMessage", "UInt", 4 ; ABM_GETSTATE
                                           , "Ptr", &APPBARDATA
                                           , "Int")
	? 2:1, APPBARDATA, A_PtrSize=4 ? 32:40) ; 2 - ABS_ALWAYSONTOP, 1 - ABS_AUTOHIDE
	, DllCall("Shell32\SHAppBarMessage", "UInt", 10 ; ABM_SETSTATE
                                    , "Ptr", &APPBARDATA)
	KeyWait, % A_ThisHotkey
	Return
^!#Space:: ; completely hide taskbar to lock down strangers borrowing my computer
	WinExist("ahk_class Shell_TrayWnd")
	t := !t
	If (t = "1") {
		WinHide, ahk_class Shell_TrayWnd
		WinHide, Start ahk_class Button
	} Else {
		WinShow, ahk_class Shell_TrayWnd
		WinShow, Start ahk_class Button
	}
	Return