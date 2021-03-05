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
		activeHwnd := WinExist("A")
		if(this.dllWindowMover.isAvailable()) 
		{
			this.dllWindowMover.moveActiveWindowToDesktop(targetDesktop)
		} else 
		{
			currentDesktop := this.desktopMapper.getDesktopNumber()
			if(currentDesktop == targetDesktop) 
			{
				return this
			}
			numberOfTabsNeededToSelectActiveMonitor := this.monitorMapper.getRequiredTabCount(WinActive("A"))
			numberOfDownsNeededToSelectDesktop := this.getNumberOfDownsNeededToSelectDesktop(targetDesktop, currentDesktop)
			
			openMultitaskingViewFrame()
			send("{tab " numberOfTabsNeededToSelectActiveMonitor "}")
			send("{Appskey}m{Down " numberOfDownsNeededToSelectDesktop "}{Enter}")
			closeMultitaskingViewFrame()
		}
		
		this._followWindow(targetDesktop)
			.doPostMoveWindow()
		
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
	
	getNumberOfDownsNeededToSelectDesktop(targetDesktop, currentDesktop)
	{
		; This part figures out how many times we need to push down within the context menu to get the desktop we want.	
		if (targetDesktop > currentDesktop)
		{
			targetDesktop -= 2
		}
		else
		{
			targetdesktop--
		}
		return targetDesktop
	}
	
	_followWindow(targetDesktop)
	{
		if(this.followToNewDesktop)
		{
			this._desktopChanger.goToDesktop(targetDesktop)
		}
		return this
	}
}
