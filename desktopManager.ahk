class JPGIncDesktopManagerClass
{	
	__new()
	{
		this._desktopChanger := new JPGIncDesktopChangerClass()
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
		this.hotkeyManager.setupNumberedHotkey(this._desktopChanger, this._desktopChanger.moveActiveWindowToDesktopFunctionName, hotkeyKey)
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
		this._postGoToDesktopFunctionName := functionLabelOrClassWithCallMethodName
		return this
	}
	
	afterMoveWindowToDesktop(functionLabelOrClassWithCallMethodName)
	{
		this._postMoveWindowFunctionName := functionLabelOrClassWithCallMethodName
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