;~ SetFormat, Integer, H


;load the custom dll
libraryHandle := DllCall("LoadLibrary", "Str", "injection dll\hook.dll", "Ptr") 
;~ MsgBox % "libraryHandle " libraryHandle
;get the address of the move desktop callback
moveDesktopHookHandle := DllCall("GetProcAddress", Ptr, libraryHandle, Astr, "GetMsgProc", "Ptr")
;~ MsgBox % "moveDesktopHookHandle " moveDesktopHookHandle
;hook up the move desktop callback on WH_GETMESSAGE messages
WH_GETMESSAGE := 3 
didTheCallSucceed := DllCall("user32.dll\SetWindowsHookEx", "Int", WH_GETMESSAGE, "Ptr", moveDesktopHookHandle, "Ptr", libraryHandle, "Ptr", 0)
MsgBox % "windows hook " didTheCallSucceed
return
#a::
{
    hwnd := WinExist("A")
    wParam := 3
    lParam := hwnd
    WM_SYSCOMMAND := 274
    PostMessage, % WM_SYSCOMMAND , % wParam, % lParam, , % "ahk_id " hwnd
    ToolTip, % "hwnd: " hwnd "`nlasterror " A_LastError "` n WM_SYSCOMMAND :" WM_SYSCOMMAND 
    return
}
#x::ExitApp