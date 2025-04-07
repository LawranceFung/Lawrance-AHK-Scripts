#Requires Autohotkey v2.0

; Windows TaskBar
!#Space:: ; this seems to have been deprecated by recent versions of ahk
{
	static ABM_SETSTATE := 0xA, ABS_AUTOHIDE := 0x1, ABS_ALWAYSONTOP := 0x2
    static hide := 0
    hide := !hide
    APPBARDATA := Buffer(size := 2*A_PtrSize + 2*4 + 16 + A_PtrSize, 0)
    NumPut("UInt", size, APPBARDATA), NumPut("Ptr", WinExist("ahk_class Shell_TrayWnd"), APPBARDATA, A_PtrSize)
    NumPut("UInt", hide ? ABS_AUTOHIDE : ABS_ALWAYSONTOP, APPBARDATA, size - A_PtrSize)
    DllCall("Shell32\SHAppBarMessage", "UInt", ABM_SETSTATE, "Ptr", APPBARDATA)
	Return
}
^!#Space:: ; completely hide taskbar to lock down strangers borrowing my computer
{
	If (WinExist("ahk_class Shell_TrayWnd"))
	{
		WinHide("ahk_class Shell_TrayWnd")
	} Else {
		WinShow("ahk_class Shell_TrayWnd")
	}
	Return
}