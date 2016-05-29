class JPGIncDesktopChangerClass
{
	goToDesktopCallbackFunctionName := "goToDesktop"
	nextDesktopFunctionName := "goToNextDesktop"
	PreviousDesktopFunctionName := "goToPreviousDesktop"
	_postGoToDesktopFunctionName := ""
	
	__new() 
	{
		this.desktopMapper := new DesktopMapperClass(new VirtualDesktopManagerClass())
		return this
	}

	goToNextDesktop(keyCombo := "")
	{
		send("^#{right}")
		return this.doPostGoToDesktop()
	}
	
	goToPreviousDesktop(keyCombo := "")
	{
		send("^#{left}")
		return this.doPostGoToDesktop()
	}
	
	/*
	 *	swap to the given virtual desktop number
	 */
	goToDesktop(newDesktopNumber) 
	{
		debugger("in go to desktop changing to " newDesktopNumber)
		this._makeDesktopsIfRequired(newDesktopNumber)
			._goToDesktop(newDesktopNumber)
		closeMultitaskingViewFrame()
		this.doPostGoToDesktop()
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
		return this
	}
	
	doPostGoToDesktop() 
	{
		this._activateTopMostWindow()
		callFunction(this.postGoToDesktopFunctionName)
		return this
	}
	
	_activateTopMostWindow()
	{
		If(WinActive("ahk_exe explorer.exe"))
		{
			send !{tab}
		}
		return this
	}
}