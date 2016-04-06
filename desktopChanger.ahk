class JPGIncDesktopManager 
{
	/*
	 *	swap to the given virtual desktop number
	 */
	moveToDesktop(newDesktopNumber) 
	{
		distanceToMove := newDesktopNumber - this.getCurrentDesktopNumber()
		loop % abs(distanceToMove)
		{
			if(distanceToMove < 0) 
			{
				send ^#{Left}
			} else 
			{
				send ^#{Right}
			}
		}
		return
	}	
	
	moveActiveWindowToDesktop(newDesktopNumber, follow := false)
	{
		currentDesktopNumber := this.getCurrentDesktopNumber()
		if(currentDesktopNumber == newDesktopNumber)
		{
			return
		}
		
		monitorNumber := getCurrentMonitor()
		SysGet, primaryMonitor, MonitorPrimary
		
		active := "ahk_id " WinExist("A")
		WinHide, % active
		
		this.moveToDesktop(newDesktopNumber)
		
		WinShow, % active
		
		if(! follow) 
		{
			this.moveToDesktop(currentDesktopNumber)
		}
		return	
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
		infoNumber := 0

		while (! currentDesktopId)
		{         
			 RegRead, currentDesktopId, HKEY_CURRENT_USER, SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\SessionInfo\%infoNumber%\VirtualDesktops, CurrentVirtualDesktop
			 infoNumber++
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

GetCurrentMonitor() {
	SysGet, numberOfMonitors, MonitorCount
	WinGetPos, winX, winY, winWidth, winHeight, A
	winMidX := winX + winWidth / 2
	winMidY := winY + winHeight / 2
	Loop %numberOfMonitors%
	{
	SysGet, monArea, Monitor, %A_Index%
	if (winMidX > monAreaLeft && winMidX < monAreaRight && winMidY < monAreaBottom && winMidY > monAreaTop)
		return %A_Index%
	}
	return
}
