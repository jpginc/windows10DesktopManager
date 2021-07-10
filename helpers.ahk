activeWindowOnCurrentDesktop()
{
	; winIDList contains a list of windows IDs ordered from the top to the bottom for each desktop.
	WinGet, winIDList, list
	Loop % winIDList 
	{
		windowID := % winIDList%A_Index%
		WinGetClass, cl,  % "ahk_id " windowID
		if(cl == "Shell_TrayWnd") 
		{
			continue
		}
		if(IsWindowOnCurrentVirtualDesktop(windowID) && isActivatableWindow(windowID)) 
		{
			return windowID
		}
	}
	return false
}
; https://autohotkey.com/boards/viewtopic.php?p=64295#p64295
; https://autohotkey.com/boards/viewtopic.php?f=5&t=12388&p=64256#p64256
;------------------------------------------------------------------------------------------------------
; Indicates whether the prvided window is on the currently active virtual desktop.
;------------------------------------------------------------------------------------------------------
IsWindowOnCurrentVirtualDesktop(hWnd) {
	onCurrentDesktop := ""
	CLSID := "{aa509086-5ca9-4c25-8f95-589d3c07b48a}"
	IID := "{a5cd92ff-29be-454c-8d04-d82879fb3f1b}"
	IVirtualDesktopManager := ComObjCreate(CLSID, IID)	
	Error := DllCall(NumGet(NumGet(IVirtualDesktopManager+0), 3*A_PtrSize), "Ptr", IVirtualDesktopManager, "Ptr", hWnd, "IntP", onCurrentDesktop)
	ObjRelease(IVirtualDesktopManager)	
	if !(Error=0)
	{
		return false, ErrorLevel := true
	}
	return onCurrentDesktop, ErrorLevel := false
}
;----------------------------------------------------------------------
; Check whether the target window is activation target
; https://www.autohotkey.com/boards/viewtopic.php?t=45871
;----------------------------------------------------------------------
IsActivatableWindow(hWnd){
	WinGet, dwStyle, Style, ahk_id %hWnd%
	if ((dwStyle&0x08000000) || !(dwStyle&0x10000000)) {
		return false
	}
	WinGet, dwExStyle, ExStyle, ahk_id %hWnd%
	if (dwExStyle & 0x00000080) {
		return false
	}
	WinGetClass, szClass, ahk_id %hWnd%
	if (szClass = "TApplication") {
		return false
	}
	return true
}
