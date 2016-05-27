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
	
	_hotkeys := {}
	
	__new(desktopManager) 
	{
		this._desktopManager := desktopManager
		return this
	}
	
	goToDesktopHotkey(hotkeyKey) 
	{
		callbackName := this._desktopManager.goToDesktopCallbackFunctionName
		return this._setupHotkey(callbackName, hotkeyKey)
	}
	
	moveWindowToDesktopHotkey(hotkeyKey)
	{
		callbackName := this._desktopManager.moveActiveWindowToDesktopFunctionName
		return this._setupHotkey(callbackName, hotkeyKey)
	}
	
	_setupHotkey(callbackFunctionName, hotkeyKey)
	{
		if(this._doesHotkeyRequireCustomHotkeySyntax(hotkeyKey)) 
		{
			hotkeyKey .= " & "
		}
		
		;remove the old keybindings and save the new keybinding
		this._removeHotkey(callbackFunctionName)
		this._hotkeys[callbackFunctionName] := hotkeyKey
		
		loop, 10
		{
			callback := Func("JPGIncDesktopManagerCallback").Bind(this._desktopManager, callbackFunctionName, A_Index -1)
			Hotkey, % hotkeyKey (A_index -1), % callback, On
		}
		
		return this
	}
	
	_removeHotkey(hotkeyIndex) 
	{
		hotkeyKey := this._hotkeys[hotkeyIndex]
		if(hotkeyKey)
		{
			loop, 10
			{
				Hotkey, % hotkeyKey (A_index -1), Off
			}
		}
		return this
	}
	
	setupDefaultHotkeys() 
	{
		callbackFunctionName := this._desktopManager.goToDesktopCallbackFunctionName
		
		Hotkey, IfWinActive, ahk_class MultitaskingViewFrame
		loop, 10
		{
			callback := Func("JPGIncDesktopManagerCallback").Bind(this._desktopManager, callbackFunctionName, A_Index -1)
			Hotkey, % "*" (A_index -1), % callback, On ;if the user has already pressed win + tab then numbers quicly change desktops
		}
		Hotkey, If
		
		return this
	}
	
	/*
	 * If the modifier key used is only a modifier symbol then we don't need to do anything (https://autohotkey.com/docs/Hotkeys.htm#Symbols)
	 * but if it contains any other characters then it means that the hotkey is a combination hotkey then we need to add " & " 
	 */
	_doesHotkeyRequireCustomHotkeySyntax(key)
	{
		return RegExMatch(key, this._notAnAutohotkeyModKeyRegex)
	}
}