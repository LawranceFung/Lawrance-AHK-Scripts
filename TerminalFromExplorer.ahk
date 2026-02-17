#Requires AutoHotkey v2.0

; Open terminal in current directory of a windows explorer folder
#Include "%A_ScriptDir%\Utilities.ahk"
#Include "%A_ScriptDir%\CurrentWindow.ahk"
; SetTitleMatchMode, RegEx
; #todo once this is fully working on Windows 10, should be able to delete commands other than F12⇨Windows Terminal
; #F12:: Run, wt.exe -w 1 nt
SetTitleMatchMode(2)
#HotIf WinActive("ahk_class CabinetWClass") || WinActive("ahk_class ExploreWClass") || WinActive("ahk_class Progman") || WinActive("ahk_class WorkerW")
{
	; Open terminal in current directory of a windows explorer folder
    !t::OpenCmdInCurrent()
    ; Open git bash in current directory of a windows explorer folder
    ;^t::OpenGBInCurrent() ; @todo get this to work in
    ; @todo open VS15 bash in current directory of a windows explorer folder
    +^t::OpenVSDCPInCurrent()
    ; @todo add powershell
    +!t::OpenPSinCurrent()
	; F12::OpenCmdInCurrent()
    F12::OpenWTinCurrent()
    F8::OpenWTinCurrent() ; while F12 on W530 isn't working
}
#HotIf

OpenCmdInCurrent()
{
	; This is required to get the full path of the file from the address bar
    full_path := WinGetText("A")

    ; Split on newline (`n)
    word_array := StrSplit(full_path,"`n")

    ; Find and take the element from the array that contains address
    Loop word_array.Length
    {
        if InStr(word_array[A_Index], "Address")
        {
            full_path := word_array[A_Index]
            break
        }
    }

    ; strip to bare address
    full_path := RegExReplace(full_path, "^Address: ", "")

    ; Just in case - remove all carriage returns (`r)
    full_path := StrReplace(full_path, "`r")

    ; Sanitize Path for Shortcuts like Downloads⇨C:\Users\Lawrance\Downloads
    ; if ((SubStr(full_path, 2, 2) != ":\") && SubStr(full_path, 1, 1)) ; also check Drive letter
    if (SubStr(full_path, 2, 2) != ":\") ; check if path is absolute and not a shortcut #todo need to correctly sanitize shell:appsfolder
    {
        full_path := "C:\Users\Lawrance\" . full_path ; #todo this is hardcoded
    }

    Run("cmd /K cd /D `"" full_path "`"")

    Return
}
OpenGBInCurrent()
{
    ; This is required to get the full path of the file from the address bar
    full_path := WinGetText("A")

    ; Split on newline (`n)
    word_array := StrSplit(full_path,"`n")

    ; Find and take the element from the array that contains address
    Loop word_array.Length
    {
        if InStr(word_array[A_Index], "Address")
        {
            full_path := word_array[A_Index]
            break
        }
    }

    ; strip to bare address
    full_path := RegExReplace(full_path, "^Address: ", "")

    ; Just in case - remove all carriage returns (`r)
    full_path := StrReplace(full_path, "`r")

    Run("`"C:\Program Files\Git\git-bash.exe`" `"--cd=" full_path "`"")

    Return
}

OpenVSDCPInCurrent()
{
    ; This is required to get the full path of the file from the address bar
    full_path := WinGetText("A")

    ; Split on newline (`n)
    word_array := StrSplit(full_path,"`n")

    ; Find and take the element from the array that contains address
    Loop word_array.Length
    {
        if InStr(word_array[A_Index], "Address")
        {
            full_path := word_array[A_Index]
            break
        }
    }

    ; strip to bare address
    full_path := RegExReplace(full_path, "^Address: ", "")

    ; Just in case - remove all carriage returns (`r)
    full_path := StrReplace(full_path, "`r")

    Run("cmd.exe /K " A_ComSpec " /C `"C:\Program Files (x86)\Microsoft Visual Studio 14.0\Common7\Tools\VsDevCmd.bat`"")

    Return
}

OpenPSinCurrent()
{
    ; This is required to get the full path of the file from the address bar
    full_path := WinGetText("A")

    ; Split on newline (`n)
    word_array := StrSplit(full_path,"`n")

    ; Find and take the element from the array that contains address
    Loop word_array.Length
    {
        if InStr(word_array[A_Index], "Address")
        {
            full_path := word_array[A_Index]
            break
        }
    }

    ; strip to bare address
    full_path := RegExReplace(full_path, "^Address: ", "")

    ; Just in case - remove all carriage returns (`r)
    full_path := StrReplace(full_path, "`r")

    Run("`"C:\WINDOWS\system32\WindowsPowerShell\v1.0\powershell.exe`"")

    Return
}

OpenWTinCurrent() ; #todo implement shift+key to open in new window, or ctrl+key to open in most recent window
{
    sequenceTooltip("&Git Bash`nPower&Shell`n&Ubuntu`n&VS Dev Cmd Prompt 19")
    ihKey := InputHook("L1T.4"), ihKey.Start(), ihKey.Wait(), Key := ihKey.Input ; since L1 specifies a total of 1 followup stroke, we don't need to handle ESC as a sequence break

    full_path := GetActiveExplorerPath()

    Switch Key ; switch profile based on user input
    {
        case "g": 
            selectedProfile := "Bash"
            windowNumber := 1
        ; case Chr(7): ; Chr(7) = Ctrl + g
        ;     selectedProfile := "Bash"
        ;     windowNumber := -1
        case "s": 
            selectedProfile := "PowerShell"
            windowNumber := 1
        case "u": 
            selectedProfile := "Ubuntu"
            windowNumber := 1
        case "v": 
            selectedProfile := "Developer Command Prompt for VS 2019"
            windowNumber := 1
        default: 
            selectedProfile := "Command Prompt"
            windowNumber := 1
    }

    ; Expand shortcuts
    if (SubStr(full_path, 2, 2) != ":\") ; check if path is absolute and not a shortcut
    {
        full_path := "C:\Users\Lawrance\" . full_path ; #todo this is hardcoded
    }

    if ProcessExist("WindowsTerminal.exe") ; open new tab if already open
    {
        Run("wt.exe -w 0 nt -d `"" full_path "`" -p `"" selectedProfile "`"")
        ; Run, wt.exe -w "%windowNumber%" nt -d "%full_path%" -p "%selectedProfile%" ; #todo should actually open new tab in window that is most recent in alt+tab order, not the first one that was opened ; not sure if that functionality is currently supported as a command line argument by MicroSoft.  The -w flag is poorly documented.  I do know that I can get functionally the result I want to open a new tab in the most recently used window by calling WinGet, myIds, List, ahk_class %ActiveClass% like in SwitchProgramWindows.ahk, bringing the most recently used window to foreground, and opening a new tab in it.  However, -w currently fails to open a new tab in any window other than the first one launched.
    }
    else ; otherwise, open the terminal profile in a new Windows Terminal window
        Run("wt.exe -d `"" full_path "`" -p `"" selectedProfile "`"")

    Return
}

GetActiveExplorerPath()
{
	explorerHwnd := WinActive("ahk_class CabinetWClass")
    return GetCurrentExplorerPath(explorerHwnd)
	; if (explorerHwnd)
	; {
	; 	for window in ComObject("Shell.Application").Windows
	; 	{
	; 		if (window.hwnd==explorerHwnd)
	; 		{
	; 			return window.Document.Folder.Self.Path
    ;             ; #todo assumes first, leftmost tab not active tab
    ;             ; known resolution in AHK v2: GetCurrentExplorerPath(hwnd := WinExist("A")) in https://www.autohotkey.com/boards/viewtopic.php?p=593212#p593212
    ;             return GetCurrentExplorerPath()
    ;         }
	; 	}
	; }
}

ShellRunBasic(prms*) ; launch terminal as not admin
{
    shellWindows := ComObject("{9BA05972-F6A8-11CF-A442-00A0C90A8F39}")

    desktop := shellWindows.Item(ComObject(19, 8)) ; VT_UI4, SCW_DESKTOP

    ; Retrieve top-level browser object.
    if ptlb := ComObjQuery(desktop
        , "{4C96BE40-915C-11CF-99D3-00AA004AE837}"
        , "{000214E2-0000-0000-C000-000000000046}")
    {
        ; IShellBrowser.QueryActiveShellView -> IShellView
        if DllCall(NumGet(NumGet(ptlb+0, "UPtr")+15*A_PtrSize, "UPtr"), "ptr", ptlb, "ptr*", &psv:=0) = 0
        {
            ; Define IID_IDispatch.
            VarSetStrCapacity(&IID_IDispatch, 16) ; V1toV2: if 'IID_IDispatch' is NOT a UTF-16 string, use 'IID_IDispatch := Buffer(16)' and replace all instances of 'StrPtr(IID_IDispatch)' with 'IID_IDispatch.Ptr'
            NumPut("int64", 0x20400, 
               "int64", 0x46000000000000C0, 
               IID_IDispatch)

            ; IShellView.GetItemObject -> IDispatch (object which implements IShellFolderViewDual)
            DllCall(NumGet(NumGet(psv+0, "UPtr")+15*A_PtrSize, "UPtr"), "ptr", psv
, "uint", 0, "ptr", StrPtr(IID_IDispatch), "ptr*", &pdisp:=0)

            ; Get Shell object.
            shell := ComObject(9,pdisp,1).Application

            ; IShellDispatch2.ShellExecute
            shell.ShellExecute(prms*)

            ObjRelease(psv)
        }
        ObjRelease(ptlb)
    }
}

SetTitleMatchMode(1)
; #IfWinActive, MINGW64:
#HotIf (WinActive("ahk_exe WindowsTerminal.exe") && WinActive("MSYS:/")) || WinActive("MINGW64") ; #todo migrate to Windows Terminal JSON settings?  https://docs.microsoft.com/en-us/windows/terminal/customize-settings/actions
{
    ; Helper functions
    UpstreamBranch()
    {
        defaultRemoteBranch := HiddenCommand("git rev-parse --abbrev-ref --symbolic-full-name @{u}") ; get upstream for current branch
        slashPos := InStr(defaultRemoteBranch, "/") - 1
        return SubStr(defaultRemoteBranch, (slashPos+2)<1 ? (slashPos+2)-1 : (slashPos+2))
    }
    DefaultBranch() ; get default branch for remote for upstream for current branch
    {
        defaultRemoteBranch := HiddenCommand("git symbolic-ref refs/remotes/origin/HEAD --short") ; get upstream for current branch
        slashPos := InStr(defaultRemoteBranch, "/") - 1
        return SubStr(defaultRemoteBranch, (slashPos+2)<1 ? (slashPos+2)-1 : (slashPos+2))
    }

    ;encapsulated in function in case git cli changes
    ActiveBranch()
    {
        return HiddenCommand("git branch --show current")
    }
    MostRecentCommit()
    {
        return HiddenCommand("git rev-parse HEAD")
    }


    ; #todo call git rev-parse --abbrev-ref origin/HEAD to get the name of the default branch, which isn't necessarily master
    F1:: ; abort merge and set HEAD to latest commit on default branch of remote
    {
        defaultBranchName := HiddenCommand("git rev-parse --abbrev-ref origin/HEAD")
        SendInput("git merge --abort & git rebase --abort & git fetch --force && git reset --hard " defaultBranchName)
        Return
    }
    ; F2::SendInput, git commit --amend && git pull && git push
    +F2::    SendInput("git rebase -i HEAD~ && git push --force{left 20}")
    F3::    SendInput("grep -r '' | grep -r '\.cpp:\|\.h:' | sed 's/:.*$//p' | sort | uniq{left 58}") ; '-i' to grep ignores case
    +F3::    SendInput("find . -type f -exec sed -i ':a;N;$!ba;s///g' {{}{}} {+}{left 9}") ; find and replace
    ^F3::    SendInput("git branch -a") ; show all branches
    +^F3::    SendInput("git log -n 1 --pretty=format:`%s") ; find commit message for a given commit hash
    ; !F4::WinClose, A
    F5::    SendInput("git rm -r --cached . && git add . && git commit -m `"refresh for .gitignore`" && git push{left 13}") ; @todo handle submodules here because git rm -r --cached isn't written to handle them correctly
    ^F5::    SendInput("git submodule deinit -f . && git submodule update --init --recursive") ; reset submodules
    +^F5::    SendInput("git reflog expire --all --expire=now && git gc --prune=now --aggressive") ; clean the reflog
    +!^F5::    SendInput("git ls-files -ci --exclude-standard && git ls-files -ci --exclude-standard -z | xargs -0 git rm --cached") ; apply .gitignore retroactively
    !^F5::    SendInput("git submodule update --remote") ; update submodules
    F6::    SendInput("start .{Enter}")
    +F8::    SendInput("git add . && git commit -m `"`" && git push{left 13}")
    +^F8::    SendInput("git add . && git commit -m `"`"{left 1}")
    F8:: ; stamp commit with branch name, in case project management requires name of branch in commit to push
    {
        myBranchName := HiddenCommand("git branch --show-current")
        SendInput("git add . && git commit -m `"" myBranchName " `"{left 1}")
        Return
    }
    +F9::    SendInput("git checkout release && git merge --squash master && git commit -m `"`"{left}")
    +^F9::    SendInput("git fetch upstream && git rebase upstream/master") ; merge changes from an upstream repo

    +F11::    SendInput("git diff  -- . `'`:{!}boost`'{left 15}") ; diff excluding submodules
    +^!7:: ; merge active branch into main ; mnemonic 7 comes from 7-zip ; assumes default branch on remote for active branch is the default branch for project (e.g. 1 forge for development; others would be mirrors)
    {
        sequenceTooltip("S&quash`nNull: Merge commit")
        ihKey := InputHook("L1T1"), ihKey.Start(), ErrorLevel := ihKey.Wait(), Key := ihKey.Input
        Switch Key
        {
            case "q": 
                squash := "1"
            default: 
        }

        defaultBranch := DefaultBranch()
        activeBranch := ActiveBranch()
        SendInput("git checkout " defaultBranch " && git merge")
        if (squash)
        {
            SendInput("{SPACE}--squash " activeBranch " && git commit -m `"merge squash " activeBranch "`"")
        }
        else
        {
            SendInput("{SPACE}--no-ff " activeBranch)
        }
        SendInput("{SPACE}&& git push{left 13}")
        
        Return
    }
    +!7:: ; create and --autosquash commit into most recent commit
    {   ; give user option to add commit message
        sequenceTooltip("Add &commit message`n&specify commit to squash into`nSpecify commit &2 squash new commit with message into")   
        sc := 0
        cm := 0
        ihKey := InputHook("L1T1"), ihKey.Start(), ErrorLevel := ihKey.Wait(), Key := ihKey.Input
        Switch Key
        {
            case "c": 
                cm := "1"
            case "s": 
                sc := "1"
            case "2": 
                cm := "1"
                sc := "1"
            default:
        }
        
        SendInput("git add . && git commit --fixup")
        if (sc == 1)
        {
            SendInput("{SPACE}HaSh")
        }
        else
        {
            HiddenCommand("git config --global rebase.autosquash true") ; ensure autosquash enabled
            SendInput("{SPACE}" MostRecentCommit())
        }
        
        ; #todo — how would I suppress the editor?
        if (cm == 1)
        {
            SendInput("{SPACE}-m `"`" && git rebase -i --autosquash{left 31}")
        }
        else
        {
            SendInput("{SPACE}&& git rebase -i --autosquash{left 30}")
        }
        Return
    }
    +^!8:: ; merge changes into master without squashing
    {
        SendInput("git checkout master && git merge " ActiveBranch() " && git push")
        Return
    }
    ; #todo — initialize a repository by cherry-picking the gitignore from github
    ; git rebase since a certain commit (in the clipboard) ; this sounds redundant.  Is there already a git command for this? yes, it's "git rebase -i <last commit to not rebase>"
    ; ^!t::
    ; {        
    ;     commitsSinceIncluding := HiddenCommandComplete("git rev-list " clipboard "^^..HEAD") ; in cmd ^^ escapes to ^
    ;     ; StringReplace, var, var, `n, `n, UseErrorLevel
    ;     ; if SubStr(var, 0) != "`n"
    ;     ;     ErrorLevel++ 
    ;     ; MsgBox % var
    ;     count := StrSplit(commitsSinceIncluding, "`n").maxindex() - 1 ; subtract one for ending newline
    ;     SendInput, git rebase -i HEAD~%count%
    ;     Return
    ; }
    ^!c::A_Clipboard := MostRecentCommit()
    ^!n:: ; WARNING!!!  merge --allow-unrelated-histories creates a new history which increases the size of your git repo
    ; create a new domain branch from master with a blank commit history ; todo consolidate these 2 into 1 command palette with a tooltip
    {
        sequenceTooltip("Create domain branch`n`tStep &1: Create and name orphan`n`tStep &2: Squash master into orphan")

        ihKey := InputHook("L1T1"), ihKey.Start(), ErrorLevel := ihKey.Wait(), Key := ihKey.Input
        Switch Key
        {
            case "1": 
                SendInput("git checkout master && git switch --orphan  && git checkout master -- .gitignore{Left 37}")
                return
            case "2": 
                { ; my biggest problem with this macro is that --squash --allow-unrelated-histories won't produce a(ny) commit that points out a merge has occurred
                    myBranchName := HiddenCommand("git branch --show current")
                    SendInput("git add . && git commit -m `"create new domain branch " myBranchName "`" && git push --set-upstream origin " myBranchName " && git merge --squash master -m `"merge changes from master to domain branch " myBranchName "`" --allow-unrelated-histories && git push")
                }
                return
            default: 
                Send(Key)
                return
        }
        Return
    }
    +^#BS::    SendInput("git reset HEAD^ && git push origin +HEAD") ; delete most recent commit and push it to remote
    ::git overweight::git ls-tree -r -t -l --full-name HEAD | sort -n -k 4 ; find the largest blobs in repo causing it to swell up https://stackoverflow.com/a/1290046/7361019
    ::git logbook::git log --date-order --date=iso --graph --full-history --all --pretty=format:'%x08%x09%C(red)%h %C(cyan)%ad%x08%x08%x08%x08%x08%x08%x08%x08%x08%x08%x08%x08%x08%x08%x08 %C(bold blue)%aN%C(reset)%C(bold yellow)%d %C(reset)%s' ; commits lbl like bitbucket
    ::git loggraph::git log --date-order --graph --all --date=short --pretty=format:"%x09%C(auto)%h  %C(cyan)%ad  %C(green)%<(12,trunc)%aN    %C(reset)%<(50,trunc)%s    %C(auto)%d" ; commits lbl but with branch graph
    ::git lg::git log --graph --abbrev-commit --decorate --format=format:'%C(bold blue)%h%C(reset) - %C(bold cyan)%aD%C(reset) %C(bold green)(%ar)%C(reset) %C(bold cyan)(committed: %cD)%C(reset) %C(auto)%d%C(reset)%n''          %C(white)%s%C(reset)%n''          %C(dim white)- %an <%ae> %C(reset) %C(dim white)(committer: %cn <%ce>)%C(reset)' --all
    #HotIf WinActive("/Cantokeys")
    +^!9:: ; 
    {
        defaultRemoteBranch := HiddenCommand("git rev-parse --abbrev-ref origin/HEAD") ; assumes "origin" as the default remote
        slashPos := InStr(defaultRemoteBranch, "/") - 1
        defaultBranch := SubStr(defaultRemoteBranch, (slashPos+2)<1 ? (slashPos+2)-1 : (slashPos+2))
        ; #todo get vsn no from file
        ; SendInput("git checkout " defaultBranch " && git pull && git checkout release && git merge " defaultBranch " && git commit -m `"" vsn "`" && git push") ; uncomment after grab vrsion number from file
        Return
    }
    #HotIf
}
#HotIf



; Hotstrings for PowerShell
SetTitleMatchMode(1)
#HotIf (WinActive("ahk_exe WindowsTerminal.exe") && WinActive("Administrator: Windows PowerShell")) || WinActive("Windows PowerShell") || WinActive("Windows PowerShell ISE")
{
    F5::
    {
        sequenceTooltip("Update:`n`t&Choco`n`t&Pip")

        ihKey := InputHook("L1T1"), ihKey.Start(), ErrorLevel := ihKey.Wait(), Key := ihKey.Input
        Switch key
        {
            case "c": 
                SendInput("choco upgrade -y all") ; isn't this redundant due to choco install choco-upgrade-all-at-startup ?
                ; #todo - delete all .lnk files on desktop
                ; choco export "'C:\Users\Lawrance\OneDrive\Backup\packages.config'"
                ; choco upgrade -y C:\Users\Lawrance\OneDrive\Backup\packages.config
                return
            case "p": 
                SendInput("pip freeze | `%{U+007B}$_.split(`'==`')[0]{U+007D} | `%{U+007B}pip install --upgrade $_ pip{U+007D}")
                return
            default: 
                Send(Key)
                return
        }
    }
}
#HotIf
