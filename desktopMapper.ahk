class DesktopMapper
{
	desktopMarkers := Object()
	
	getWindowDesktopIdAddress := ""
	isWindowOnCurrentVirtualDesktopAddress := ""
	moveWindowToDesktop  := ""
	iVirtualDesktopManager := ""
	
	__new()
	{
		;IVirtualDesktopManager interface
		;Exposes methods that enable an application to interact with groups of windows that form virtual workspaces.
		;https://msdn.microsoft.com/en-us/library/windows/desktop/mt186440(v=vs.85).aspx
		CLSID := "{aa509086-5ca9-4c25-8f95-589d3c07b48a}" ;search VirtualDesktopManager clsid
		IID := "{a5cd92ff-29be-454c-8d04-d82879fb3f1b}" ;search IID_IVirtualDesktopManager
		this.IVirtualDesktopManager := ComObjCreate(CLSID, IID)
		
		this.isWindowOnCurrentVirtualDesktopAddress := NumGet(NumGet(IVirtualDesktopManager+0), 3*A_PtrSize)
		this.getWindowDesktopIdAddress := NumGet(NumGet(IVirtualDesktopManager+0), 4*A_PtrSize)
		this.moveWindowToDesktop := NumGet(NumGet(IVirtualDesktopManager+0), 5*A_PtrSize)
		return this
	}
	
	mapVirtualDesktops() 
	{
		send ^#{right 10}
		this.desktopMarkers := Object();
		this._createMarkers()
		return this
	}
	
	/*
	 * returns the desktop number or -1 if there was an error
	 */
	getCurrentDesktopNumber() 
	{
		loop, % this.desktopMarkers.MaxIndex()
		{
			if(this.desktopMarkers[A_Index].virtualDesktopId == otherDesktop.virtualDesktopId)
			{
				return A_Index
			}
		}
		return -1
	}
	
	_createMarkers() 
	{
		while(true)
		{
			nextMarker := new DesktopMarker()
		
			if(this._desktopAlreadyMapped(newDesktop)) 
			{
				nextDesktop.Destroy()
				return this
			}
			this.desktopMarker.Insert(nextMarker)
			send ^#{left}
		}
		return
	}
	
	_desktopAlreadyMapped(otherDesktop) 
	{
		loop, % this.desktopMarkers.MaxIndex()
		{
			if(this.desktopMarkers[A_Index].isDesktopCurrentlyActive())
			{
				return true
			}
		}
		;debug
		return false
	}
}

class DesktopMarker
{
	hwnd := ""
	virtualDesktopGuid := ""
	virtualDesktopId := ""
	
	getWindowDesktopIdAddress := ""
	isWindowOnCurrentVirtualDesktopAddress := ""
	iVirtualDesktopManager := ""
	
	
	__new(getWindowDesktopIdAddress, isWindowOnCurrentVirtualDesktopAddress, iVirtualDesktopManager) 
	{
		Gui, show
		Gui, +HwndMyGuiHwnd
		this.hwnd := myGuiHwnd
		
		this.getWindowDesktopIdAddress := getWindowDesktopIdAddress
		this.isWindowOnCurrentVirtualDesktopAddress := isWindowOnCurrentVirtualDesktopAddress
		this.iVirtualDesktopManager := iVirtualDesktopManager
		
		this.virtualDesktopGuid := this._getVirtualDesktopID()
		this.virtualDesktopId := this._guidToStr(this.virtualDesktopGuid)
		
		return this
	}
	
	destroy()
	{
		hwnd := this.hwnd
		Gui %hwnd%:Destroy 
		return this
	}
	
	_getVirtualDesktopID() 
	{
		VarSetCapacity(desktopID, 16, 0)
		;IVirtualDesktopManager::GetWindowDesktopId  method
		;https://msdn.microsoft.com/en-us/library/windows/desktop/mt186441(v=vs.85).aspx
		Error := DllCall(this.getWindowDesktopIdAddress, "Ptr", this.iVirtualDesktopManager, "Ptr", this.hWnd, "Ptr", &desktopID)	
		if(Error != 0) {
			;debug
		}
		return desktopID
	}
	
	isDesktopCurrentlyActive() {
		;IVirtualDesktopManager::IsWindowOnCurrentVirtualDesktop method
		;Indicates whether the provided window is on the currently active virtual desktop.
		;https://msdn.microsoft.com/en-us/library/windows/desktop/mt186442(v=vs.85).aspx
		Error := DllCall(this.isWindowOnCurrentVirtualDesktopAddress, "Ptr", this.iVirtualDesktopManager, "Ptr", this.hWnd, "IntP", onCurrentDesktop)
		if(Error != 0) {
			;debug
		}
		return onCurrentDesktop
	}
	
	; https://github.com/cocobelgica/AutoHotkey-Util/blob/master/Guid.ahk#L36
	_guidToStr(ByRef VarOrAddress)
	{
		pGuid := IsByRef(VarOrAddress) ? &VarOrAddress : VarOrAddress
		VarSetCapacity(sGuid, 78) ; (38 + 1) * 2
		if !DllCall("ole32\StringFromGUID2", "Ptr", pGuid, "Ptr", &sGuid, "Int", 39)
			throw Exception("Invalid GUID", -1, Format("<at {1:p}>", pGuid))
		return StrGet(&sGuid, "UTF-16")
	}
	
	__Delete()
	{
		this.destroy()
		return
	}
}