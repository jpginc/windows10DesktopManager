class JPGIncDesktopChangerClass
{
	goToDesktopCallbackFunctionName := "goToDesktop"
	nextDesktopFunctionName := "goToNextDesktop"
	PreviousDesktopFunctionName := "goToPreviousDesktop"
	_postGoToDesktopFunctionName := ""
	
	__new() 
	{
		this.desktopMapper := new DesktopMapperClass(new VirtualDesktopManagerClass())
		this.virtualDesktopManagerInternal := new VirtualDesktopManagerInternalClass()
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
		this.virtualDesktopManagerInternal.goToDesktop(newDesktopNumber)
		return this
	}
	
	doPostGoToDesktop() 
	{
		activateTopMostWindowIfNoneActive()
		callFunction(this.postGoToDesktopFunctionName)
		return this
	}
}