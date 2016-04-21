JPGIncDesktopManagerCallback(desktopManager, functionName, keyPressed)
{
	desktopManager[functionName](keyPressed)
	return
}

class JPGIncDesktopManagerClass
{
	notAnAutohotkeyModKeyRegex := "[^#!^+<>*~$]"
	moveWinMod := "moveWindowModKey"
	changeVDMod := "changeDesktopModKey"
		
	__new(options) 
	{
		this.options := options
		this.desktopMapper := new DesktopMapperClass(new VirtualDesktopManagerClass())
		
		this.mapHotkeys()
		return this
	}
	
	mapHotkeys()
	{
		this.fixModKeysForHotkeySyntax()
		loop, 10
		{
			moveCallback := Func("JPGIncDesktopManagerCallback").Bind(this, "moveActiveWindowToDesktop", A_Index - 1)
			changeCallback := Func("JPGIncDesktopManagerCallback").Bind(this, "goToDesktop", A_Index -1)
			Hotkey, If
			if(this.options[this.moveWinMod]) 
			{
				Hotkey, % this.options[this.moveWinMod] (A_index -1), % moveCallback
			}
			if(this.options[this.changeVDMod]) 
			{
				Hotkey, % this.options[this.changeVDMod] (A_index -1), % changeCallback
			}
			
			Hotkey, IfWinActive, ahk_class MultitaskingViewFrame
			Hotkey, % "*" (A_index -1), % changeCallback ;if the user has already pressed win + tab then numbers quicly change desktops
		}
		return this
	}
	
	/*
	 * If the modifier key used is only a modifier symbol then we don't need to do anything (https://autohotkey.com/docs/Hotkeys.htm#Symbols)
	 * but if it contains any other characters then it means that the hotkey is a combination hotkey then we need to add " & " 
	 */
	fixModKeysForHotkeySyntax() 
	{
		if(RegExMatch(this.options[this.moveWinMod], this.notAnAutohotkeyModKeyRegex)) {
			this.options[this.moveWinMod] .= " & "
		}
		
		if(RegExMatch(this.options[this.changeVDMod], this.notAnAutohotkeyModKeyRegex)) {
			this.options[this.changeVDMod] .= " & "
		}
		return this
	}
	/*
	 *	swap to the given virtual desktop number
	 */
	goToDesktop(newDesktopNumber) 
	{
		debugger("in go to desktop changing to " newDesktopNumber)
		this._makeDesktopsIfRequired(newDesktopNumber)
			._goToDesktop(newDesktopNumber)
			.closeMultitaskingViewFrame()
			.doPostMoveDesktop()
		return this
	}
	
	_makeDesktopsIfRequired(minimumNumberOfDesktops)
	{
		currentNumberOfDesktops := this.desktopMapper.getNumberOfDesktops()
		loop, % minimumNumberOfDesktops - currentNumberOfDesktops
		{
			Send, #^d
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
			debugger("Sending right!")
			send ^#{right %distance%}
		} else
		{
			send ^#{left %distance%}
		}
		return this
	}
	
	closeMultitaskingViewFrame()
	{
		IfWinActive, ahk_class MultitaskingViewFrame
		{
			send, #{tab}
		}
		return this
	}
	
	openMultitaskingViewFrame()
	{
		IfWinNotActive, ahk_class MultitaskingViewFrame
		{
			send, #{tab}
			WinWaitActive, ahk_class MultitaskingViewFrame
		}
		return this
	}
	
	doPostMoveDesktop() 
	{
		this._callFunction(this.options.postChangeDesktop)
		return this
	}
	
	doPostMoveWindow() 
	{
		this._callFunction(this.options.postMoveWindow)
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
		}
		return this
	}
	
	moveActiveWindowToDesktop(targetDesktop, follow := false)
	{
		currentDesktop := this.desktopMapper.getDesktopNumber()
		this.openMultitaskingViewFrame()
		
		; This part figures out how many times we need to push down within the context menu to get the desktop we want.	
		if (targetDesktop > currentDesktop)
		{
			targetDesktop -= 2
		}
		else
		{
			targetdesktop--
		}
		
		Send {Appskey}m{Down %targetDesktop%}{Enter}
		
		this.closeMultitaskingViewFrame()
		return	this
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
}