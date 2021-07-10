class JPGIncWindowMoverClass
{
	moveActiveWindowToDesktopFunctionName := "moveActiveWindowToDesktop"
	moveToNextFunctionName := "moveActiveWindowToNextDesktop"
	moveToPreviousFunctionName := "moveActiveWindowToPreviousDesktop"
	postMoveWindowFunctionName := ""
	followToNewDesktop := false
	
	__new()
	{
		this.dllWindowMover := new JPGIncDllWindowMover()
		this.desktopMapper := new DesktopMapperClass(new VirtualDesktopManagerClass())
		this.monitorMapper := new MonitorMapperClass()
		this._desktopChanger := new JPGIncDesktopChangerClass()
		return this
	}
	
	doPostMoveWindow() 
	{
		callFunction(this.postMoveWindowFunctionName)
		return this
	}
	
	moveActiveWindowToDesktop(targetDesktop, follow := false)
	{
		if(targetDesktop < 1) 
		{
			return this
		}
		activeHwnd := WinExist("A")
		currentDesktop := this.desktopMapper.getDesktopNumber()

		if(this.dllWindowMover.isAvailable()) 
		{
			this.dllWindowMover.moveActiveWindowToDesktop(targetDesktop)
			if(this.followToNewDesktop)
			{
				activateWindow := false ; we will reactivate the window ourselves
				this._desktopChanger.goToDesktop(targetDesktop, activateWindow)
				this._reactivateWindow(activeHwnd)
			}			
		} else 
		{
			winhide,  % "ahk_id " activeHwnd
			this._desktopChanger.goToDesktop(targetDesktop)
			WinActivate, ahk_class Shell_TrayWnd
			sleep 50
			winshow,  % "ahk_id " activeHwnd
			if(! this.followToNewDesktop) 
			{
				this._desktopChanger.goToDesktop(currentDesktop)
			}
		}

		return	this
	}
	
	moveActiveWindowToNextDesktop(follow := false)
	{
		currentDesktop := this.desktopMapper.getDesktopNumber()
		return this.moveActiveWindowToDesktop(currentDesktop + 1, follow)
	}
	
	moveActiveWindowToPreviousDesktop(follow := false)
	{
		currentDesktop := this.desktopMapper.getDesktopNumber()
		if(currentDesktop == 1) 
		{
			return this
		}
		return this.moveActiveWindowToDesktop(currentDesktop - 1, follow)
	}	
	
	_reactivateWindow(activeHwnd)
	{
		WinActivate, ahk_class Shell_TrayWnd
		sleep 50
		WinActivate,  % "ahk_id " activeHwnd
		return this
	}
}