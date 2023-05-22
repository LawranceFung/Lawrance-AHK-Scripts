; Visibility of 
; File Explorer's Hidden Files
SetTitleMatchMode, 2
#If WinActive("ahk_class CabinetWClass")  || WinActive("ahk_class ExploreWClass") || WinActive("ahk_class Progman") || WinActive("ahk_class WorkerW")
{
	^h::	;GoSub,CheckActiveWindow
	{
		; CheckActiveWindow:
		;   ID := WinExist("A")
		;   WinGetClass,Class, ahk_id %ID%
		;   WClasses := "CabinetWClass ExploreWClass"
		;   IfInString, WClasses, %Class%
		;     GoSub, Toggle_HiddenFiles_Display
		; Return

		; Toggle_HiddenFiles_Display:
	; RootKey = HKEY_CURRENT_USER
	; SubKey  = Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced

	; RegRead, HiddenFiles_Status, % RootKey, % SubKey, Hidden

		if HiddenFiles_Status = 2
			RegWrite, REG_DWORD, % RootKey, % SubKey, Hidden, 1 
		else 
			RegWrite, REG_DWORD, % RootKey, % SubKey, Hidden, 2
		PostMessage, 0x111, 41504,,, ahk_id %ID%
		return
	}
	; helper function
	f_RefreshExplorer()
	{
		WinGet, id, ID, ahk_class Progman
		SendMessage, 0x111, 0x1A220,,, ahk_id %id%
		WinGet, id, List, ahk_class CabinetWClass
		Loop, %id%
	{
		id := id%A_Index%
		SendMessage, 0x111, 0x1A220,,, ahk_id %id%
	}
		WinGet, id, List, ahk_class ExploreWClass
		Loop, %id%
	{
		id := id%A_Index%
		SendMessage, 0x111, 0x1A220,,, ahk_id %id%
	}
		WinGet, id, List, ahk_class #32770
		Loop, %id%
	{
		id := id%A_Index%
		ControlGet, w_CtrID, Hwnd,, SHELLDLL_DefView1, ahk_id %id%
		if w_CtrID !=
		SendMessage, 0x111, 0x1A220,,, ahk_id %w_CtrID%
	}
		return
	}
	; hide file extensions
	^g::
	{
		Global lang_ToggleFileExt, lang_ShowFileExt, lang_HideFileExt
		RootKey = HKEY_CURRENT_USER
		SubKey  = Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced
		RegRead, HideFileExt    , % RootKey, % SubKey, HideFileExt
		if HideFileExt = 1
		{
		  ; MsgBox, 4131,, Show File Extentions?
		  ; IfMsgBox Yes
		  ; {
		  RegWrite, REG_DWORD, % RootKey, % SubKey, HideFileExt, 0
		  f_RefreshExplorer()
		  ; }
		}
		else
		{
		  ; MsgBox, 4131,, Hide File Extentions?
		  ; IfMsgBox Yes
		  ; {
		  RegWrite, REG_DWORD, % RootKey, % SubKey, HideFileExt, 1
		  f_RefreshExplorer()
		  ; }
		}
		return
	}		
	; F8::
	; {
	; 	Send !{Up}
	; 	return
	; }
	; F9:: ; F9 should go down a layer in the directory
	; {
	; 	Send !{Down}
	; 	return
	; }			
	^+h:: ; make hidden selected files and folders
	{
		mySelection := Explorer_GetSelection()

		Loop, parse, mySelection , `n, `r			; loop through all the file paths
			; MsgBox % A_LoopField
			FileSetAttrib, ^H, % A_LoopField  	 
		return
	}
	Explorer_GetSelection() {
	   WinGetClass, winClass, % "ahk_id" . hWnd := WinExist("A")
	   if (winClass ~= "Progman|WorkerW")
	      oShellFolderView := GetDesktopIShellFolderViewDual()
	   else if (winClass ~= "(Cabinet|Explore)WClass") {
	      for window in ComObjCreate("Shell.Application").Windows
	         if (hWnd = window.HWND) && (oShellFolderView := window.document)
	            break
	   }
	   else
	      Return
	   
	   for item in oShellFolderView.SelectedItems
	      result .= (result = "" ? "" : "`n") . item.path
	   if !result
	      result := oShellFolderView.Folder.Self.Path
	   Return result
	}
	GetDesktopIShellFolderViewDual(){
	    IShellWindows := ComObjCreate("{9BA05972-F6A8-11CF-A442-00A0C90A8F39}")
	    desktop := IShellWindows.Item(ComObj(19, 8)) ; VT_UI4, SCW_DESKTOP                
	   
	    ; Retrieve top-level browser object.
	    if ptlb := ComObjQuery(desktop
	        , "{4C96BE40-915C-11CF-99D3-00AA004AE837}"  ; SID_STopLevelBrowser
	        , "{000214E2-0000-0000-C000-000000000046}") ; IID_IShellBrowser
	    {
	        ; IShellBrowser.QueryActiveShellView -> IShellView
	        if DllCall(NumGet(NumGet(ptlb+0)+15*A_PtrSize), "ptr", ptlb, "ptr*", psv) = 0
	        {
	            ; Define IID_IDispatch.
	            VarSetCapacity(IID_IDispatch, 16)
	            NumPut(0x46000000000000C0, NumPut(0x20400, IID_IDispatch, "int64"), "int64")
	           
	            ; IShellView.GetItemObject -> IDispatch (object which implements IShellFolderViewDual)
	            DllCall(NumGet(NumGet(psv+0)+15*A_PtrSize), "ptr", psv
	                , "uint", 0, "ptr", &IID_IDispatch, "ptr*", pdisp)
	           
	            IShellFolderViewDual := ComObjEnwrap(pdisp)
	            ObjRelease(psv)
	        }
	        ObjRelease(ptlb)
	    }
	    return IShellFolderViewDual
	}
}
#IfWinActive