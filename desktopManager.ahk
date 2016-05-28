﻿class JPGIncDesktopManagerClass
{	
	__new()
	{
		this._desktopChanger := new JPGIncDesktopChangerClass()
		this._windowMover := new JPGIncWindowMoverClass()
		this.hotkeyManager := new JPGIncHotkeyManager()
		
		this._setupDefaultHotkeys()
		return this
	}
	
	/*
	 * Public API to setup virtual desktop hotkeys and callbacks
	 */
	setGoToDesktop(hotkeyKey)
	{
		this.hotkeyManager.setupNumberedHotkey(this._desktopChanger, this._desktopChanger.goToDesktopCallbackFunctionName, hotkeyKey)
		return this
	}
	setMoveWindowToDesktop(hotkeyKey)
	{
		this.hotkeyManager.setupNumberedHotkey(this._windowMover, this._windowMover.moveActiveWindowToDesktopFunctionName, hotkeyKey)
		return this
	}
	
	setGoToNextDesktop(hotkeyKey)
	{
		this.hotkeyManager.setupHotkey(this._desktopChanger, this._desktopChanger.nextDesktopFunctionName, hotkeyKey)
		return this
	}
	
	setGoToPreviousDesktop(hotkeyKey)
	{
		this.hotkeyManager.setupHotkey(this._desktopChanger, this._desktopChanger.PreviousDesktopFunctionName, hotkeyKey)
		return this
	}
	
	afterGoToDesktop(functionLabelOrClassWithCallMethodName)
	{
		this._desktopChanger.postGoToDesktopFunctionName := functionLabelOrClassWithCallMethodName
		return this
	}
	
	afterMoveWindowToDesktop(functionLabelOrClassWithCallMethodName)
	{
		this._windowMover.postMoveWindowFunctionName := functionLabelOrClassWithCallMethodName
		return this
	}
	
	/*
	 * end public api
	 */
	 
	_setupDefaultHotkeys()
	{
		Hotkey, IfWinActive, ahk_class MultitaskingViewFrame
		this.hotkeyManager.setupNumberedHotkey(this._desktopChanger, this._desktopChanger.goToDesktopCallbackFunctionName, "")
		Hotkey, If
		return this
	}
}