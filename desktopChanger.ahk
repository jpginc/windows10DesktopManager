class JPGIncDesktopManagerClass
{
	goToDesktopCallbackFunctionName := "goToDesktop"
	moveActiveWindowToDesktopFunctionName := "moveActiveWindowToDesktop"
	nextDesktopFunctionName := "goToNextDesktop"
	PreviousDesktopFunctionName := "goToPreviousDesktop"
	
	_postMoveWindowFunctionName := ""
	_postGoToDesktopFunctionName := ""
	
	__new() 
	{
		this.desktopMapper := new DesktopMapperClass(new VirtualDesktopManagerClass())
		this.monitorMapper := new MonitorMapperClass()
		this.hotkeyManager := new JPGIncHotkeyManager()
		
		this._setupDefaultHotkeys()
		return this
	}
	
	_setupDefaultHotkeys()
	{
		Hotkey, IfWinActive, ahk_class MultitaskingViewFrame
		this.hotkeyManager.setupNumberedHotkey(this, this.goToDesktopCallbackFunctionName, "")
		Hotkey, If
		return this
	}
	
	/*
	 * Public API to setup virtual desktop hotkeys and callbacks
	 */
	setGoToDesktop(hotkeyKey)
	{
		this.hotkeyManager.setupNumberedHotkey(this, this.goToDesktopCallbackFunctionName, hotkeyKey)
		return this
	}
	setMoveWindowToDesktop(hotkeyKey)
	{
		this.hotkeyManager.setupNumberedHotkey(this, this.moveActiveWindowToDesktopFunctionName, hotkeyKey)
		return this
	}
	
	setGoToNextDesktop(hotkeyKey)
	{
		this.hotkeyManager.setupHotkey(this, this.nextDesktopFunctionName, hotkeyKey)
		return this
	}
	
	setGoToPreviousDesktop(hotkeyKey)
	{
		this.hotkeyManager.setupHotkey(this, this.PreviousDesktopFunctionName, hotkeyKey)
		return this
	}
	
	afterGoToDesktop(functionLabelOrClassWithCallMethodName)
	{
		this._postGoToDesktopFunctionName := functionLabelOrClassWithCallMethodName
		return this
	}
	
	afterMoveWindowToDesktop(functionLabelOrClassWithCallMethodName)
	{
		this._postMoveWindowFunctionName := functionLabelOrClassWithCallMethodName
		return this
	}
	
	goToNextDesktop(keyCombo := "")
	{
		return this._send("^#{right}")
	}
	
	goToPreviousDesktop(keyCombo := "")
	{
		return this._send("^#{left}")
	}
	
	/*
	 *	swap to the given virtual desktop number
	 */
	goToDesktop(newDesktopNumber) 
	{
		newDesktopNumber := this._getDesktopNumberFromHotkey(newDesktopNumber)
		debugger("in go to desktop changing to " newDesktopNumber)
		this._makeDesktopsIfRequired(newDesktopNumber)
			._goToDesktop(newDesktopNumber)
			.closeMultitaskingViewFrame()
			.doPostGoToDesktop()
		return this
	}
	
	_makeDesktopsIfRequired(minimumNumberOfDesktops)
	{
		currentNumberOfDesktops := this.desktopMapper.getNumberOfDesktops()
		loop, % minimumNumberOfDesktops - currentNumberOfDesktops
		{
			this._send("#^d")
		}
		
		return this
	}
	
	/*
	 * If we send the keystrokes too quickly you sometimes get a flickering of the screen
	 */
	_send(toSend)
	{
		oldDelay := A_KeyDelay
		SetKeyDelay, 30
		
		send, % toSend
		
		SetKeyDelay, % oldDelay
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
			this._send("^#{right " distance "}")
		} else
		{
			this._send("^#{left " distance "}")
		}
		return this
	}
	
	closeMultitaskingViewFrame()
	{
		IfWinActive, ahk_class MultitaskingViewFrame
		{
			this._send("#{tab}")
		}
		return this
	}
	
	openMultitaskingViewFrame()
	{
		IfWinNotActive, ahk_class MultitaskingViewFrame
		{
			this._send("#{tab}")
			WinWaitActive, ahk_class MultitaskingViewFrame
		}
		return this
	}
	
	doPostGoToDesktop() 
	{
		this._callFunction(this._postGoToDesktopFunctionName)
		return this
	}
	
	doPostMoveWindow() 
	{
		this._callFunction(this._postMoveWindowFunctionName)
		return this
	}
	
	_callFunction(possibleFunction)
	{
		if(IsFunc(possibleFunction)) 
		{
			%possibleFunction%()
		} else if(IsObject(possibleFunction))
		{
			possibleFunction.Call()
		} else if(IsLabel(possibleFunction))
		{
			gosub, % possibleFunction
		}
		return this
	}
	
	moveActiveWindowToDesktop(targetDesktop, follow := false)
	{
		currentDesktop := this.desktopMapper.getDesktopNumber()
		if(currentDesktop == targetDesktop) 
		{
			return this
		}
		numberOfTabsNeededToSelectActiveMonitor := this.monitorMapper.getRequiredTabCount(WinActive("A"))
		numberOfDownsNeededToSelectDesktop := this.getNumberOfDownsNeededToSelectDesktop(targetDesktop, currentDesktop)
		
		this.openMultitaskingViewFrame()
			._send("{tab " numberOfTabsNeededToSelectActiveMonitor "}")
			._send("{Appskey}m{Down " numberOfDownsNeededToSelectDesktop "}{Enter}")
			.closeMultitaskingViewFrame()
			.doPostMoveWindow()
		
		return	this
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
	
	getIndexFromArray(searchFor, array) 
	{
		loop, % array.MaxIndex()
		{
			if(array[A_index] == searchFor) 
			{
				return A_index
			}
		}
		return false
	}
	_getDesktopNumberFromHotkey(keyCombo)
	{
		return RegExReplace(keyCombo, "[^\d]", "")
	}
}