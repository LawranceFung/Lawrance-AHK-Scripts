ProcessExist(Name){
    Process,Exist,%Name%
    return Errorlevel
}

sequenceTooltip(Tooltips)
{
    IfWinExist, tooltipWin
        Gui, destroy
    
    Gui, +ToolWindow -Caption +0x400000 +alwaysontop        
    Gui, Font, s15
    Gui, Add, text, x0 y0, %Tooltips%
    SysGet, screenx, 0
    SysGet, screeny, 1
    xpos:=screenx / 2
    ypos:=screeny / 2
    Gui, Show, NoActivate xcenter ycenter AutoSize center, tooltipWin
    
    SetTimer,tooltipWinClose, 1000
}
tooltipWinClose:
    SetTimer,tooltipWinClose, off
    Gui, destroy
Return

; debugging attempt to create lasting tooltips
; #z::sequenceTooltipHold("I Lo&ve Penguins")
sequenceTooltipHold(Tooltips)
{
    ; IfWinExist, tooltipWin
    ;   Gui, destroy
    
    Gui, +ToolWindow -Caption +0x400000 +alwaysontop        
    Gui, Font, s15
    Gui, Add, text, x0 y0, %Tooltips%
    SysGet, screenx, 0
    SysGet, screeny, 1
    xpos:=screenx / 2
    ypos:=screeny / 2
    Gui, Show, NoActivate xcenter ycenter AutoSize center, tooltipWin

    global tooltipTimer = true
    ; MsgBox % tooltipTimer
    
}

; #z up::tooltipWinClose_Hold()
tooltipWinClose_Hold()
{
    MsgBox %tooltipTimer%
    if (%tooltipTimer% == 1){
        Gui, destroy
    }
    ; SetTimer,tooltipWinClose, 1000
    
    Return
}

; How to catch output from command line
HiddenCommand(CmdToHide)
{
    WinGetTitle, Title, A
    SanitizedFolderName := RegExReplace(Title, "MSYS:/([a-z])", "$U1:")
    ; #todo make sure it's the main drive, which isn't necessarily C:\
    RunWait, %comspec% /c cd %SanitizedFolderName% && %CmdToHide% > C:\Users\Public\temp-cmd-output.txt,,Hide
    tempCmdOutFile := FileOpen("C:\Users\Public\temp-cmd-output.txt", "r")
    cmdOut := RegExReplace(tempCmdOutFile.ReadLine(), "(.*)\n$", "$1")
    tempCmdOutFile.Close()
    FileDelete, C:\Users\Public\temp-cmd-output.txt
    return cmdOut
}