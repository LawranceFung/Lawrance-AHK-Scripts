#Requires AutoHotkey v2.0

SetTitleMatchMode(2)
#HotIf WinActive("ahk_class CabinetWClass")  || WinActive("ahk_class ExploreWClass") || WinActive("ahk_class Progman") || WinActive("ahk_class WorkerW")
{
	^h:: ; hide/show hidden files
	{
	}
	
	^g:: ; hide file extensions ; #todo get this working or find something online for v2
	{
	}

	^+h:: ; make hidden selected files and folders
	{
	}
}
#HotIf