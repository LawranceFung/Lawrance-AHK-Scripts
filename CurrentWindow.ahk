#Requires AutoHotkey v2.0

; https://www.autohotkey.com/boards/viewtopic.php?p=593212#p593212

GetOpenExplorerWindows()  {
    for window in ComObject("Shell.Application").Windows
    	{
        if (InStr(window.FullName, "explorer.exe"))  {
			shellFolderView := window.Document
            ExplorerPath := shellFolderView.Folder.Self.Path

			; exclude "Start", "Catalog", "Trash", "Home" and "Network"
			If (ExplorerPath = "::{F874310E-B6B7-47DC-BC84-B9E6B38F5903}" || ExplorerPath = "::{E88865EA-0E1C-4E20-9AA6-EDCD0212C87C}" || ExplorerPath = "::{645FF040-5081-101B-9F08-00AA002F954E}" || ExplorerPath = "::{20D04FE0-3AEA-1069-A2D8-08002B30309D}" || ExplorerPath = "::{F02C1A0D-BE21-4350-88B0-7367FC96EF3C}")
					continue

			ExplorerPath := RegExReplace(ExplorerPath, "^file:///", "")
            ExplorerPath := StrReplace(ExplorerPath, "/", "\")
            ExplorerPath := RegExReplace(ExplorerPath, "%20", " ")

			ExplorerWindows .= ExplorerPath "`n"
        	}
		}
	return RemoveDuplicateLines(ExplorerWindows)
}

GetExplorerHwndByPath(FolderPath)  {
    FolderPath := RegExReplace(FolderPath, "[\\/]+$", "") ; Entfernt abschließende Backslashes oder Slashes

    for window in ComObject("Shell.Application").Windows  {
        if (InStr(window.FullName, "explorer.exe"))  {
			shellFolderView := window.Document
            windowPath := shellFolderView.Folder.Self.Path

            windowPath := RegExReplace(windowPath, "^file:///", "")
            windowPath := StrReplace(windowPath, "/", "\")
            windowPath := RegExReplace(windowPath, "%20", " ")

            if (windowPath = FolderPath)  {
                return window.HWND
            	}
        	}
    	}
    return 0 ; No window found
}



GetCurrentExplorerPath(hwnd := WinExist("A")) { 
	; by lexikos - modified (from: https://www.autohotkey.com/boards/viewtopic.php?f=83&t=109907)

 	if !(explorerHwnd := explorerGethWnd(hwnd))
		return ErrorLevel := "ERROR"
	; exclude "Start", "Catalog", "Trash", "Home" and "Network"
	if (explorerHwnd="desktop")
		return A_Desktop

	activeTab := 0
	activeTab := ControlGetHwnd("ShellTabWindowClass1", hwnd) ; File Explorer (Windows 11)
	for window in ComObject("Shell.Application").Windows {
		if window.hwnd != hwnd
			continue
		if activeTab { ; The window has tabs, so make sure this is the right one.
			static IID_IShellBrowser := "{000214E2-0000-0000-C000-000000000046}"
			shellBrowser := ComObjQuery(window, IID_IShellBrowser, IID_IShellBrowser)
			ComCall(3, shellBrowser, "uint*", &thisTab:=0)
			if thisTab != activeTab
				continue
		}
        if (type(window.Document) = "ShellFolderView")  {
			ExplorerPath := window.Document.Folder.Self.Path
			; exclude "Start", "Catalog", "Trash", "Home" and "Network"
			If (ExplorerPath = "::{F874310E-B6B7-47DC-BC84-B9E6B38F5903}" || ExplorerPath = "::{E88865EA-0E1C-4E20-9AA6-EDCD0212C87C}" || ExplorerPath = "::{645FF040-5081-101B-9F08-00AA002F954E}" || ExplorerPath = "::{20D04FE0-3AEA-1069-A2D8-08002B30309D}" || ExplorerPath = "::{F02C1A0D-BE21-4350-88B0-7367FC96EF3C}")
				return ErrorLevel := "ERROR"
			else
				return ExplorerPath
			} 
        else
            return "ERROR"
		}
	Return "ERROR"
}

explorerGethWnd(hwnd:="")  {
	; by WKen - modified (from: https://www.autohotkey.com/boards/viewtopic.php?t=114431)
	processName := WinGetProcessName("ahk_id " hwnd := hwnd? hwnd:WinExist("A"))
	class := WinGetClass("ahk_id " hwnd)
			if (processName!="explorer.exe")
		return
	if (class ~= "(Cabinet|Explore)WClass")  {
		for window in ComObject("Shell.Application").Windows
			try if (window.hwnd==hwnd)
				return hwnd
		}
	else if (class ~= "Progman|WorkerW") 
		return "desktop" ; desktop found
}

JumpToExplorerTab2(parentHwnd:=WinActive("A"), ExplorerPath := "")  {
	TabExplorerPath := GetCurrentExplorerPath(parentHwnd)
	If (ExplorerPath = "" || TabExplorerPath == ExplorerPath)  ; no path or serached path is active tab
		return 

	ExplorerTabList := GetExplorerTabList(parentHwnd)
	WinActivate("ahk_id" parentHwnd)
	ControlFocus("Microsoft.UI.Content.DesktopChildSiteBridge1",  "ahk_id" parentHwnd)  ; ShellTabWindowClass1 indicate that windows has tabs
	Sleep(50)
    Loop ExplorerTabList.Length {
        Send("{Ctrl down}" A_Index "{Ctrl up}")
        Sleep(25)
        TabExplorerPath := GetCurrentExplorerPath(parentHwnd)
        If (TabExplorerPath == ExplorerPath)
            break
        }
}

OpenNewExplorerTab(ExplorerHwnd:=WinActive("A"))  {
    SendMessage(0x0111, 0xA21B, 0, "ShellTabWindowClass1", ExplorerHwnd)
    return ExplorerHwnd
}

OpenPathInNewExplorerTab(Path, ExplorerHwnd:=WinActive("A"))  {
    ; by ntepa - from https://www.autohotkey.com/boards/viewtopic.php?p=586602&sid=c080c461dd2bb15cb1e933d9a5628414#p586602

    If !(WinGetClass(ExplorerHwnd) == "CabinetWClass")
        ExplorerHwnd := WinExist("ahk_class CabinetWClass",,, "Address: Control Panel")

    if !ExplorerHwnd {
        OpenPathInNewExplorerWindows(path)
        ExitApp
        }

    Windows := ComObject("Shell.Application").Windows
    Count := Windows.Count() ; Count of open windows

    if WinGetMinMax(ExplorerHwnd) = -1
        WinRestore(ExplorerHwnd)
    ; open a new tab (https://stackoverflow.com/a/78502949)
    SendMessage(0x0111, 0xA21B, 0, "ShellTabWindowClass1", ExplorerHwnd)

    timeout := A_TickCount + 5000
    ; Wait for new tab.
    while Windows.Count() = Count {
        sleep 10
        ; If unable to create new tab in 5 seconds, create new window.
        if A_TickCount > timeout {
            OpenPathInNewExplorerWindows(path)
            ExitApp
            }
        }
    Item := Windows.Item(Count)
    try Item.Navigate2(path) ; Navigate to path in new tab
    catch {
        OpenPathInNewExplorerWindows(path)
        ExitApp
        }
}

OpenPathInNewExplorerWindows(Path)  {
    ; by ntepa - from https://www.autohotkey.com/boards/viewtopic.php?p=586602&sid=c080c461dd2bb15cb1e933d9a5628414#p586602
    Run("Explorer " path)
    WinWaitActive("ahk_class CabinetWClass")
    SendEvent "{Space}" ; Select first item
}


GetExplorerTabList(parentHwnd:=WinActive("A")) {
    WindowList := WinGetControlsHwnd("ahk_id " parentHwnd)
    ExplorerTabList := []
    Loop WindowList.Length  {
        ClassName := WinGetClass("ahk_id " WindowList[A_Index])
        If (InStr(ClassName, "ShellTabWindowClass"))  {
            ExplorerTabList.Push(WindowList[A_Index])
            }
        }
    return ExplorerTabList
}

RemoveDuplicateLines(Text) {
    UniqueLinesArray := Map()
    Loop Parse, Text, "`n", "`r"
    	{
        if (!UniqueLinesArray.Has(A_LoopField))  {
            UniqueLinesArray.Set(A_LoopField,1)
            UniqueLines .= A_LoopField "`n"
        	}
    	}
    return UniqueLines
}
