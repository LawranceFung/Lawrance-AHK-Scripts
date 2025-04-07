#Requires AutoHotkey v2.0

global myGui := Gui()
sequenceTooltip(Tooltips)
{
    global
    if WinExist("tooltipWin")
        myGui.destroy()
        myGui := Gui()
    myGui.Opt("+ToolWindow -Caption +0x400000 +alwaysontop")
    myGui.SetFont("s15")
    myGui.Add("text", "x0 y0", Tooltips)
    screenx := SysGet(0)
    screeny := SysGet(1)
    xpos:=screenx / 2
    ypos:=screeny / 2
    myGui.Title := "tooltipWin"
    myGui.Show("NoActivate xcenter ycenter AutoSize center")
    
    SetTimer(tooltipWinClose,1000)
}
tooltipWinClose()
{
    global
    SetTimer(tooltipWinClose,0)
    myGui.destroy()
    Return
}
sequenceTooltipHold(Tooltips)
{
    ; IfWinExist, tooltipWin
    ;   Gui, destroy
    
    myGui.Opt("+ToolWindow -Caption +0x400000 +alwaysontop")
    myGui.SetFont("s15")
    myGui.Add("text", "x0 y0", Tooltips)
    screenx := SysGet(0)
    screeny := SysGet(1)
    xpos:=screenx / 2
    ypos:=screeny / 2
    myGui.Title := "tooltipWin"
    myGui.Show("NoActivate xcenter ycenter AutoSize center")

    global tooltipTimer := true
    ; MsgBox % tooltipTimer
    
}

; #z up::tooltipWinClose_Hold()
tooltipWinClose_Hold()
{
    MsgBox(tooltipTimer)
    if (%tooltipTimer% == 1){
        myGui := Gui()
        myGui.destroy()
    }
    ; SetTimer,tooltipWinClose, 1000
    
    Return
}

; How to catch output from command line
HiddenCommandComplete(CmdToHide)
{
    Title := WinGetTitle("A")
    SanitizedFolderName := RegExReplace(Title, "MSYS:/([a-z])", "$U1:") ; assumes Git Bash Windows Terminal
    ; SanitizedFolderName := RegExReplace(Title, "MINGW64:/([a-z])", "$U1:") ; assumes Git Bash Windows Terminal
    ; #todo make sure it's the main drive, which isn't necessarily C:\
    RunWait(A_ComSpec " /c cd " SanitizedFolderName " && " CmdToHide " > C:\Users\Public\temp-cmd-output.txt", , "Hide")
    cmdOut := FileRead("C:\Users\Public\temp-cmd-output.txt")
    FileDelete("C:\Users\Public\temp-cmd-output.txt")
    return cmdOut
}
HiddenCommand(CmdToHide)
{
    Title := WinGetTitle("A")
    SanitizedFolderName := RegExReplace(Title, "MSYS:/([a-z])", "$U1:") ; assumes Git Bash Windows Terminal
    ; SanitizedFolderName := RegExReplace(Title, "MINGW64:/([a-z])", "$U1:") ; assumes Git Bash Windows Terminal
    ; #todo make sure it's the main drive, which isn't necessarily C:\
    RunWait(A_ComSpec " /c cd " SanitizedFolderName " && " CmdToHide " > C:\Users\Public\temp-cmd-output.txt", , "Hide")
    tempCmdOutFile := FileOpen("C:\Users\Public\temp-cmd-output.txt", "r")
    cmdOut := RegExReplace(tempCmdOutFile.ReadLine(), "(.*)\n$", "$1")
    tempCmdOutFile.Close()
    FileDelete("C:\Users\Public\temp-cmd-output.txt")
    return cmdOut
}

DelFile(f)
{
    if FileExist(f)
    {
        FileDelete(f)
        return true
    }
    else return false
}