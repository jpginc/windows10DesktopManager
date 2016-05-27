/* 
 * this function is used when a hotkey combo is pressed. It directs the program to the appropriate function in the desktop manager
 */ 
JPGIncDesktopManagerCallback(desktopManager, functionName, keyPressed)
{
	if(keyPressed == 0) 
	{
		keyPressed := 10
	}
	desktopManager[functionName](keyPressed)
	return
}

class JPGIncHotkeyManager
{
	_notAnAutohotkeyModKeyRegex := "[^#!^+<>*~$]"
	_desktopManager := ""
	
	_optionsMoveWindowHotkey := "moveWindowModKey"
	_optionsChangeVirtualDesktopHotkey := "goToDesktopModKey"
	
	__new(desktopManager) 
	{
		this._desktopManager := desktopManager
		return this
	}
	
	setupHotkeys(options) 
	{
		options := this._fixModKeysForHotkeySyntax(options)
		loop, 10
		{
			moveCallback := Func("JPGIncDesktopManagerCallback").Bind(this._desktopManager, "moveActiveWindowToDesktop", A_Index - 1)
			changeCallback := Func("JPGIncDesktopManagerCallback").Bind(this._desktopManager, "goToDesktop", A_Index -1)
			Hotkey, If
			if(options[this._optionsMoveWindowHotkey]) 
			{
				Hotkey, % options[this._optionsMoveWindowHotkey] (A_index -1), % moveCallback
			}
			if(options[this._optionsChangeVirtualDesktopHotkey]) 
			{
				Hotkey, % options[this._optionsChangeVirtualDesktopHotkey] (A_index -1), % changeCallback
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
	_fixModKeysForHotkeySyntax(options) 
	{
		if(RegExMatch(options[this._optionsMoveWindowHotkey], this._notAnAutohotkeyModKeyRegex)) {
			options[this._optionsMoveWindowHotkey] .= " & "
		}
		
		if(RegExMatch(options[this._optionsChangeVirtualDesktopHotkey], this._notAnAutohotkeyModKeyRegex)) {
			options[this._optionsChangeVirtualDesktopHotkey] .= " & "
		}
		return options
	}
}