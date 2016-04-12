JPGIncDesktopManagerCallback(desktopManager, functionName, keyPressed)
{
	desktopManager[functionName](keyPressed)
	return
}

class JPGIncDesktopManagerClass
{
	iVirtualDesktopManager := ""
	isWindowOnCurrentVirtualDesktopAddress := ""
	getWindowDesktopIdAddress := ""
	moveWindowToDesktopAddress := ""
	
	moveWinMod := "moveWindowModKey"
	changeVDMod := "changeDesktopModKey"
	notAnAutohotkeyModKeyRegex := "[^#!^+<>*~$]"
	
	desktopMapper := ""
	
	
	__new(options) 
	{
		this.setupIVirtualDesktopManager()
		this.options := options
		this.desktopMapper := new DesktopMapperClass(this.iVirtualDesktopManager, this.isWindowOnCurrentVirtualDesktopAddress, this.getWindowDesktopIdAddress)
		
		this.desktopMapper.mapVirtualDesktops() ;don't need to do this. it will map the first time it's used
		this.mapHotkeys()
		
		return this
	}
	
	setupIVirtualDesktopManager()
	{
		;IVirtualDesktopManager interface
		;Exposes methods that enable an application to interact with groups of windows that form virtual workspaces.
		;https://msdn.microsoft.com/en-us/library/windows/desktop/mt186440(v=vs.85).aspx
		CLSID := "{aa509086-5ca9-4c25-8f95-589d3c07b48a}" ;search VirtualDesktopManager clsid
		IID := "{a5cd92ff-29be-454c-8d04-d82879fb3f1b}" ;search IID_IVirtualDesktopManager
		this.iVirtualDesktopManager := ComObjCreate(CLSID, IID)
		
		this.isWindowOnCurrentVirtualDesktopAddress := NumGet(NumGet(this.iVirtualDesktopManager+0), 3*A_PtrSize)
		this.getWindowDesktopIdAddress := NumGet(NumGet(this.iVirtualDesktopManager+0), 4*A_PtrSize)
		this.moveWindowToDesktopAddress := NumGet(NumGet(this.iVirtualDesktopManager+0), 5*A_PtrSize)
	
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
		;~ newDesktopGuid := this.desktopMapper.getGuidOfDesktop(newDesktopNumber)._getVirtualDesktopId()
		toMoveHwnd := this.desktopMapper.getHwndOfDesktop(2)
		moveToHwnd := this.desktopMapper.getHwndOfDesktop(1)
		;~ WinExist("A")
		
		this._moveWindowToDesktop(toMoveHwnd, moveToHwnd)
		return	this
	}
	
	_moveWindowToDesktop(toMoveHwnd, moveToHwnd)
	{
		desktopId := ""
		VarSetCapacity(desktopID, 16, 0)
		Error := DllCall(this.getWindowDesktopIdAddress, "Ptr", this.iVirtualDesktopManager, "Ptr",moveToHwnd , "Ptr", &desktopID)	
		if(Error != 0) {
			msgbox % "error in _getVirtualDesktopId " Error "`n" this.hwnd
		}
		Error := DllCall(this.moveWindowToDesktopAddress, "Ptr", this.iVirtualDesktopManager, "Ptr", toMoveHwnd, "Ptr", &desktopID)
		if(Error != 0) {
			msgbox % "error in _moveWindowToDesktop " Error "but no error?"
			clipboard := error
		}
		MsgBox done
		return this
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