class DesktopMarkerClass
{
	hwnd := ""
	virtualDesktopGuid := ""
	virtualDesktopId := ""
	
	getWindowDesktopIdAddress := ""
	isWindowOnCurrentVirtualDesktopAddress := ""
	iVirtualDesktopManager := ""
	
	
	__new(getWindowDesktopIdAddress, isWindowOnCurrentVirtualDesktopAddress, iVirtualDesktopManager) 
	{
		Gui, new
		Gui, +HwndMyGuiHwnd
		this.hwnd := myGuiHwnd
		
		this.getWindowDesktopIdAddress := getWindowDesktopIdAddress
		this.isWindowOnCurrentVirtualDesktopAddress := isWindowOnCurrentVirtualDesktopAddress
		this.iVirtualDesktopManager := iVirtualDesktopManager
		
		this.virtualDesktopGuid := this._getVirtualDesktopId()

		this.virtualDesktopId := this._guidToStr(this.virtualDesktopGuid )
		debugger("the guid is " this.virtualDesktopId "`n" this.hwnd)
		;~ debugger("is desktop active? " this.isDesktopCurrentlyActive())
		return this
	}
	
	destroy()
	{
		hwnd := this.hwnd
		if(WinExist("ahk_id " hwnd))
		{
			Gui %hwnd%:Destroy 
		}

		return this
	}
	
	/* 
	 * checks if this marker is still on the same virtual desktop it was when it was created
	 *
	 * if it isn't then it's virtual desktop was probably closed
	 */
	isOnSameDesktop() 
	{
		virtualDesktopId := this._guidToStr(this._getVirtualDesktopId())
		debugger("is on same desktop `n" virtualDesktopId "`n" this.virtualDesktopId "`n" (this.virtualDesktopId == virtualDesktopId))
		return this.virtualDesktopId == virtualDesktopId
	}

	isDesktopCurrentlyActive() 
	{
		;IVirtualDesktopManager::IsWindowOnCurrentVirtualDesktop method
		;Indicates whether the provided window is on the currently active virtual desktop.
		;https://msdn.microsoft.com/en-us/library/windows/desktop/mt186442(v=vs.85).aspx
		;~ WinSet, ExStyle, -0x80 , % "Ahk_id " this.hWnd ;we need the alt tab menu otherwise this function doesn't work
		;~ sleep 500
		Error := DllCall(this.isWindowOnCurrentVirtualDesktopAddress, "Ptr", this.iVirtualDesktopManager, "Ptr", this.hWnd, "IntP", onCurrentDesktop)
		if(Error != 0) {
			msgbox error in isDesktopCurrentlyActive
		}
		;~ WinSet, ExStyle, +0x80 , % "Ahk_id " this.hWnd ;remove the window from the alt tab menu again

		return onCurrentDesktop
	}
	
	_getVirtualDesktopId() 
	{
		desktopId := ""
		VarSetCapacity(desktopID, 16, 0)
		;IVirtualDesktopManager::GetWindowDesktopId  method
		;https://msdn.microsoft.com/en-us/library/windows/desktop/mt186441(v=vs.85).aspx
		
		;~ WinSet, ExStyle, -0x80 , % "Ahk_id " this.hWnd ;we need the alt tab menu otherwise this function doesn't work
		;~ sleep 500
		Error := DllCall(this.getWindowDesktopIdAddress, "Ptr", this.iVirtualDesktopManager, "Ptr", this.hWnd, "Ptr", &desktopID)	
		if(Error != 0) {
			msgbox % "error in _getVirtualDesktopId " Error "`n" this.hwnd
		}
		;~ WinSet, ExStyle, +0x80 , % "Ahk_id " this.hWnd ;remove the window from the alt tab menu again
		return &desktopID
	}
	
	
	; https://github.com/cocobelgica/AutoHotkey-Util/blob/master/Guid.ahk#L36
	_guidToStr(ByRef VarOrAddress)
	{
		;~ debugger(&VarOrAddress " address")
		pGuid := IsByRef(VarOrAddress) ? &VarOrAddress : VarOrAddress
		VarSetCapacity(sGuid, 78) ; (38 + 1) * 2
		if !DllCall("ole32\StringFromGUID2", "Ptr", pGuid, "Ptr", &sGuid, "Int", 39)
			throw Exception("Invalid GUID", -1, Format("<at {1:p}>", pGuid))
		return StrGet(&sGuid, "UTF-16")
	}
	
	__Delete()
	{
		debugger("getting deleted")
		this.destroy()
		return
	}
}