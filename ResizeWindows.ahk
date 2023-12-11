; full screen across multiple monitors
#F11::
{
    WinGetActiveTitle, Title
    WinRestore, %Title%
    SysGet, X1, 76
    SysGet, Y1, 77
    SysGet, Width, 78
    SysGet, Height, 79
    WinMove, %Title%,, X1, Y1, Width, Height
    return
}

; debugging
; catch dimensions of current windows
+^#F11::
{
    WinGetActiveTitle, Title
    WinGetPos, X, Y, W, H, %Title%
    MsgBox, %W%, %H%
    return
}

; Right-size certain windows
^#F11::
{
    WinGetActiveTitle, Title
    WinRestore, %Title%
    SysGet, X1, 76
    SysGet, Y1, 77
    SysGet, Width, 78
    SysGet, Height, 79

    WinMove, %Title%,, 0, 0, 2180, 1432
    return
}
