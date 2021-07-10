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
		currentDesktop := this.desktopMapper.getDesktopNumber()
		return this.goToDesktop(currentDesktop + 1)
	}
	
	goToPreviousDesktop(keyCombo := "")
	{
		currentDesktop := this.desktopMapper.getDesktopNumber()
		return this.goToDesktop(currentDesktop - 1)
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
		windowID := activeWindowOnCurrentDesktop()
		if(windowID) 
		{
			WinActivate, % "ahk_id " windowID
		}
		return this
	}
	
	_doesDesktopHaveFocus() 
	{
		;CabinetWClass is file explorer
		return WinActive("ahk_exe explorer.exe") && ! WinActive("ahk_class CabinetWClass") 
	}
}
