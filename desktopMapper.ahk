class DesktopMapperClass
{	
	desktopIds := []
	
	__new(virtualDesktopManager)
	{
		Gui, new
		Gui, show
		Gui, +HwndMyGuiHwnd
		this.hwnd := MyGuiHwnd
		Gui, hide
		this.virtualDesktopManager := virtualDesktopManager
		return this
	}
	
	mapVirtualDesktops() 
	{
		currentDesktop := this.getCurrentDesktopId()
		this.goToFirstDesktop()
			._reMapDesktopsFromLeftToRight()
			.goToDesktopByGuid(currentDesktop)
		return this
	}
	
	goToFirstDesktop()
	{
		debugger("going to desktop 1")
		send ^#{Left 20}
		return this
	}
	
	goToDesktopByGuid(guid)
	{
		this.goToDesktop(this._indexOfGuid(guid))
		return this
	}
	
	goToDesktop(newDesktopNumber)
	{
		currentDesktop := this.getDesktopNumber()
		direction := currentDesktop - newDesktopNumber
		distance := Abs(direction)
		
		if(direction < 0)
		{
			send ^#{right %distance%}
		} else
		{
			send ^#{left %distance%}
		}
		return this
	}
	
	getCurrentDesktopId()
	{
		hwnd := this.hwnd
		Gui %hwnd%:show 
		sleep 50 ;this is necessary, not sure why...
		
		guid := this.virtualDesktopManager.getDesktopGuid(hwnd)

		Gui %hwnd%:hide 
		sleep 100 ;this is necessary, not sure why...
		return guid
	}
	
	getDesktopNumber()
	{
		currentDesktop := this.getCurrentDesktopId()
		if(! this._desktopAlreadyMapped(currentDesktop))
		{
			this.mapVirtualDesktops()
		}	
		return this._indexOfGuid(currentDesktop)
	}
	
	_reMapDesktopsFromLeftToRight()
	{
		debugger("About to remap")
		this.desktopIds := []
		while, true
		{
			nextDesktopGuid := this.getCurrentDesktopId()
			debugger("next guid is " nextDesktopGuid)
			sleep 100
			if(this._desktopAlreadyMapped(nextDesktopGuid))
			{
				return this
			}
			this.desktopIds.Insert(nextDesktopGuid)
			send ^#{right}
		}
	}

	_indexOfGuid(guid) 
	{
		loop, % this.desktopIds.MaxIndex()
		{
			if(this.desktopIds[A_index] == guid)
			{
				return A_Index
			}
		}
		return -1
	}
	
	_desktopAlreadyMapped(otherDesktop) 
	{
		return this._indexOfGuid(otherDesktop) != -1
	}
}
