JPGIncDesktopManagerCallback(desktopManager, functionName, keyPressed)
{
	desktopManager[functionName](keyPressed)
	return
}

class JPGIncDesktopManagerClass
{
	moveWinMod := "moveWindowModKey"
	changeVDMod := "changeDesktopModKey"
	notAnAutohotkeyModKeyRegex := "[^#!^+<>*~$]"
	
	desktopMapper := ""
	
	__new(options) 
	{
		this.options := options
		this.desktopMapper := new DesktopMapperClass()
		
		this.desktopMapper.mapVirtualDesktops() ;don't need to do this. it will map the first time it's used
		this.mapHotkeys()
		
		return this
	}
	
	mapHotkeys()
	{
		this.fixModKeysForHotkeySyntax()
		loop, 10
		{
			moveCallback := Func("JPGIncDesktopManagerCallback").Bind(this, "moveActiveWindowToDesktop", A_Index - 1)
			changeCallback := Func("JPGIncDesktopManagerCallback").Bind(this, "moveToDesktop", A_Index -1)
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
	moveToDesktop(newDesktopNumber) 
	{
		this._moveToDesktop(newDesktopNumber)
			.doPostMoveDesktop()
		return this
	}	
	
	_moveToDesktop(newDesktopNumber)
	{
		currentDesktopNumber := this.desktopMapper.getCurrentDesktopNumber()
		distanceToMove := currentDesktopNumber - newDesktopNumber
		absDistanceToMove := Abs(distanceToMove)
		debugger("current " currentDesktopNumber "`ndistance: " distanceToMove)
		if(distanceToMove < 0)
		{
			send ^#{right %absDistanceToMove%}
		} else 
		{
			send ^#{left %absDistanceToMove%}
		}
		
		IfWinActive, ahk_class MultitaskingViewFrame
		{
			send, #{tab}
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
	
	moveActiveWindowToDesktop(newDesktopNumber, follow := false)
	{
		;~ currentDesktopNumber := this.getCurrentDesktopNumber()
		;~ if(currentDesktopNumber == newDesktopNumber)
		;~ {
			;~ return this
		;~ }

		;~ active := "ahk_id " WinExist("A")
		;~ WinHide, % active
		;~ this.moveToDesktop(newDesktopNumber)
		;~ WinShow, % active
		
		;~ if(! follow) 
		;~ {
			;~ WinActivate, % active
			;~ this._moveToDesktop(currentDesktopNumber)
		;~ }
		
		;~ this.doPostMoveWindow()

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