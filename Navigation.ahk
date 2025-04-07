#Requires AutoHotkey v2.0

+#F11:: ; extend number of registry keys if attached to external monitor
{
	myKeyValue := RegRead("HKEY_CURRENT_USER\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\Advanced\", "JumpListItems_Maximum")
	if (myKeyValue = 53)
	{
		RegWrite(22, "REG_DWORD", "HKEY_CURRENT_USER\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\Advanced\", "JumpListItems_Maximum")
	}
	else
	{
		RegWrite(53, "REG_DWORD", "HKEY_CURRENT_USER\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\Advanced\", "JumpListItems_Maximum")
	}
	Return
}

; full screen across multiple monitors
#F11::
{
	Title := WinGetTitle("A")
	WinRestore(Title)
	X1 := SysGet(76)
	Y1 := SysGet(77)
	Width := SysGet(78)
	Height := SysGet(79)
	WinMove(X1, Y1, Width, Height, Title)
	return 
}

; GoDownNumber:
; 	MsgBox, fuck
; 	Send, {Down}{Enter}
	; Return
SetTitleMatchMode(2) ; jumplist is ShellExperienceHost.exe ; full path is C:\Windows\SystemApps\ShellExperienceHost_cw5n1h2txyewy\ShellExperienceHost.exe
removeFromJumplistByF4 := false
#HotIf WinActive("Jump List for", ) ; @todo contingently define hotkeys instead
{	
	; Hotkey, $1, GoDownNumber
	global removeFromJumplistByF4
	F4::
	{
		removeFromJumplistByF4 := true ; remove item from vlc jumplist
		; Sleep, 10000
		; remove = false
		Return
	}
	$0::ActivateJumplistEntry(0)
	$1::ActivateJumplistEntry(1)	
	$2::ActivateJumplistEntry(2)		
	$3::ActivateJumplistEntry(3)
	$4::ActivateJumplistEntry(4)
	$5::ActivateJumplistEntry(5)
	$6::ActivateJumplistEntry(6)
	$7::ActivateJumplistEntry(7)
	$8::ActivateJumplistEntry(8)
	$9::ActivateJumplistEntry(9)
	$a::ActivateJumplistEntry(10)
	$b::ActivateJumplistEntry(11)
	$c::ActivateJumplistEntry(12)
	$d::ActivateJumplistEntry(13)
	$e::ActivateJumplistEntry(14)
	$f::ActivateJumplistEntry(15)
	$g::ActivateJumplistEntry(16)
	$h::ActivateJumplistEntry(17)
	$i::ActivateJumplistEntry(18)
	$j::ActivateJumplistEntry(19)
	$k::ActivateJumplistEntry(20)
	$l::ActivateJumplistEntry(21)
	$m::ActivateJumplistEntry(22)
	$n::ActivateJumplistEntry(23)
	$o::ActivateJumplistEntry(24)
	$p::ActivateJumplistEntry(25)
	$q::ActivateJumplistEntry(26)
	$r::ActivateJumplistEntry(27)
	$s::ActivateJumplistEntry(28)
	$t::ActivateJumplistEntry(29)
}
#HotIf
ActivateJumplistEntry(index)
{	
	global removeFromJumplistByF4
	if removeFromJumplistByF4 := true
	{
		Send("{Down " index "}")
		Sleep(100)
		; Send {Down %index%}
		; Sleep, 100
		Send("{AppsKey}")
		Sleep(100)
		; Send {Down 4}
		Send("{Up 2}")
		Sleep(300)
		; Send {Down 4}
		Send("{Enter}")
		removeFromJumplistByF4 := false
	}
	Else
		Send("{Down " index "}{Enter}")
	Return
}
; Taskview
#HotIf WinActive("Task View", )
{
	; Hotkey, $1, GoRightNumber
	$0::	Send("{Enter}") ; choose window on desktop by number
	$1::	Send("{Right}{Enter}")
	$2::	Send("{Right 2}{Enter}")
	$3::	Send("{Right 3}{Enter}")
	$4::	Send("{Right 4}{Enter}")
	$5::	Send("{Right 5}{Enter}")
	$6::	Send("{Right 6}{Enter}")
	$7::	Send("{Right 7}{Enter}")
	$8::	Send("{Right 8}{Enter}")
	$9::	Send("{Right 9}{Enter}")
	$a::	Send("{Right 10}{Enter}")
	$b::	Send("{Right 11}{Enter}")
	$c::	Send("{Right 12}{Enter}")
	$d::	Send("{Right 13}{Enter}")
	$e::	Send("{Right 14}{Enter}")
	$f::	Send("{Right 15}{Enter}")
	$g::	Send("{Right 16}{Enter}")
	$h::	Send("{Right 17}{Enter}")
	$i::	Send("{Right 18}{Enter}")
	$j::	Send("{Right 19}{Enter}")
	$k::	Send("{Right 20}{Enter}")
	$[::	Send("^#{Left}") ; next or previous desktop
	$]::	Send("^#{Right}")
	$n::	Send("^#{d}") ; new desktop		
	$x::	Send("^#{F4}") ; close desktop		
	;!1::; choose virtual desktop by number
}
#HotIf
; GoRightNumber:
; 	Send, {Down}{Enter}
; 	Return