class JPGIncDesktopChangerClass
{
	goToDesktopCallbackFunctionName := "goToDesktop"
	nextDesktopFunctionName := "goToNextDesktop"
	PreviousDesktopFunctionName := "goToPreviousDesktop"
	postGoToDesktopFunctionName := ""
	
	__new() 
	{
		this.DllWindowMover := new JPGIncDllWindowMover()
		this.desktopMapper := new DesktopMapperClass(new VirtualDesktopManagerClass())
		Gui, destkopChanginGUI: new,
		Gui, destkopChanginGUI: -caption,
		Gui, destkopChanginGUI: -SysMenu,
		return this
	}

	goToNextDesktop(keyCombo := "")
	{
		send("^#{right}")
		return this.doPostGoToDesktop(true)
	}
	
	goToPreviousDesktop(keyCombo := "")
	{
		send("^#{left}")
		return this.doPostGoToDesktop(true)
	}
	
	/*
	 *	swap to the given virtual desktop number
	 */
	goToDesktop(newDesktopNumber, activateWindow := true) 
	{
		debugger("in go to desktop changing to " newDesktopNumber)
		this._makeDesktopsIfRequired(newDesktopNumber)
			._goToDesktop(newDesktopNumber)
		this.doPostGoToDesktop(activateWindow)
		return this
	}
	
	_makeDesktopsIfRequired(minimumNumberOfDesktops)
	{
		currentNumberOfDesktops := this.desktopMapper.getNumberOfDesktops()
		loop, % minimumNumberOfDesktops - currentNumberOfDesktops
		{
			send("#^d")
		}
		
		return this
	}

	_goToDesktop(newDesktopNumber)
	{
		; Fixes the issue of active windows in intermediate desktops capturing the switch shortcut and therefore delaying or 
		; stopping the switching sequence. This also fixes the flashing window button after switching in the taskbar. 
		; More info: https://github.com/pmb6tz/windows-desktop-switcher/pull/19
		WinActivate, ahk_class Shell_TrayWnd

		if(this.DllWindowMover.isAvailable())
		{
			Gui destkopChanginGUI: show, W0 H0
			Gui destkopChanginGUI: +HwnddesktopChangingGuiHwnd
			this.DllWindowMover.moveWindowToDesktop(newDesktopNumber, desktopChangingGuiHwnd)
			WinActivate, ahk_class Shell_TrayWnd
			Gui destkopChanginGUI: show, W0 H0
			Gui destkopChanginGUI: hide,
			; wait a bit for the desktop to changes
			sleep 50
		} else 
		{
			currentDesktop := this.desktopMapper.getDesktopNumber()
			direction := currentDesktop - newDesktopNumber
			distance := Abs(direction)
			debugger("distance to move is " distance "`ndirectin" direction)
			if(direction < 0)
			{
				debugger("Sending right! " distance "times")
				send("^#{right " distance "}")
			} else
			{
				send("^#{left " distance "}")
			}
		}
		return this
	}
	
	doPostGoToDesktop(activateWindow) 
	{
		if(activateWindow)
		{
			this._activateTopMostWindow()
		}
		callFunction(this.postGoToDesktopFunctionName)
		return this
	}
	
	_activateTopMostWindow()
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
				;WinGetTitle, title, % "ahk_id " windowID
				;ToolTip % "id is: " windowID " title: " title " class: " cl
				WinActivate, % "ahk_id " windowID
				return this
			}
		}
		return this
	}
	
	_doesDesktopHaveFocus() 
	{
		;CabinetWClass is file explorer
		return WinActive("ahk_exe explorer.exe") && ! WinActive("ahk_class CabinetWClass") 
	}
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
