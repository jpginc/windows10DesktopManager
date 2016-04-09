JPGIncDesktopManagerCallback(desktopManager, functionName, keyPressed)
{
	desktopManager[functionName](keyPressed)
	return
}

class JPGIncDesktopManager 
{
	moveWinMod := "moveWindowModKey"
	changeVDMod := "changeDesktopModKey"
	notAnAutohotkeyModKeyRegex := "[^#!^+<>*~$]"
	
	__new(options) 
	{
		this.options := options
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
			Hotkey, % this.options[this.moveWinMod] (A_index -1), % moveCallback
			Hotkey, % this.options[this.changeVDMod] (A_index -1), % changeCallback
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
			this.options[this.moveWinMod] += " & "
		}
		
		if(RegExMatch(this.options[this.changeVDMod], this.notAnAutohotkeyModKeyRegex)) {
			this.options[this.changeVDMod] += " & "
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
		distanceToMove := newDesktopNumber - this.getCurrentDesktopNumber()
		absDistance := Abs(distanceToMove)
		if(distanceToMove < 0) 
		{
			send ^#{Left %absDistance%}
		} else 
		{
			send ^#{Right %absDistance%}
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
		currentDesktopNumber := this.getCurrentDesktopNumber()
		if(currentDesktopNumber == newDesktopNumber)
		{
			return this
		}

		active := "ahk_id " WinExist("A")
		WinHide, % active
		this.moveToDesktop(newDesktopNumber)
		WinShow, % active
		
		if(! follow) 
		{
			WinActivate, % active
			this._moveToDesktop(currentDesktopNumber)
		}
		
		this.doPostMoveWindow()

		return	this
	}
	
	getCurrentDesktopNumber()
	{
		currentDesktopId := this.getCurrentDesktopId()
		allDesktopIds := this.getAllDesktopIds()
		; Get the current desktop UUID. Length should be 32 always, but there's no guarantee this couldn't change in a later Windows release so we check.

		allDesktopIds := this.splitStringByCharCount(StrLen(currentDesktopId), allDesktopIds)
		currentDesktopNumber := this.getIndexFromArray(currentDesktopId, allDesktopIds)

		return currentDesktopNumber
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
	
	getAllDesktopIds()
	{
		; Get a list of the UUIDs for all virtual desktops on the system
		RegRead, allDesktopIds, HKEY_CURRENT_USER, SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\VirtualDesktops, VirtualDesktopIDs
		return allDesktopIds	
	}
	
	getCurrentDesktopId() 
	{
		; RegRead strategy from optimist__prime and pmb6tz https://autohotkey.com/boards/viewtopic.php?t=9224
		currentDesktopId := false
		infoNumber := 1

		while (! currentDesktopId)
		{         
			 RegRead, currentDesktopId, HKEY_CURRENT_USER, SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\SessionInfo\%infoNumber%\VirtualDesktops, CurrentVirtualDesktop
			 infoNumber++
			if (InfoNumber = 10) ;if the user has never changed virtual desktops then there may not be a reg entry. changing desktops will create it 
			{
				Send ^#{Right}
				Send ^#{Left} 
				InfoNumber = 1
			}
		}

		return currentDesktopId
	}

	splitStringByCharCount(count, string) 
	{
		splitString := []
		currentIndex := 1
		loop
		{
			splitString.Insert(SubStr(string, currentIndex, count))
			
			currentIndex += count
			if(currentIndex >= StrLen(string)) {
				break
			}
		}
		return splitString
	}
}