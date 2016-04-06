moveToDesktop(desktopNumber)
{
	;after the left 10 it will be on window 1 so decrement the count by 1 to compensate
	desktopNumber--
	send {tab}{left 10}{right %desktopNumber%}{return}
	return
}

moveActiveWindowToDesktop(newDesktopNumber, follow := false)
{
	desktopNumber := newDesktopNumber
	
	monitorNumber := getCurrentMonitor()
	SysGet, primaryMonitor, MonitorPrimary
	
	currentDesktopNumber := getCurrentDesktopNumber()
	if(currentDesktopNumber == newDesktopNumber)
	{
		return
	}
	;desktop starts at 1 so decrement the new desktopNumber by 1
	newDesktopNumber--
	if(currentDesktopNumber <= newDesktopNumber)
	{
		newDesktopNumber--
	}
	
	if(monitorNumber <> primaryMonitor)
	{
		send {Esc}{tab 2}{AppsKey}
	}
	
	send m{down %newDesktopNumber%}{return}
	
	if(follow == true) 
	{
		send #{tab}
		WinWait, ahk_class MultitaskingViewFrame
		moveToDesktop(desktopNumber)
	}
	return	
}

/*
 * Gets the current desktop number by processing the contents of the right click context menu in 
 * the multitasking view frame (the view after pressing Windows key + tab)
 *
 * Pass false as the first parameter to close with multitasking view after getting the desktop number
 *
 * returns 0 if there was an error
 */
getCurrentDesktopNumber(leaveWinTabOpen := true)
{
	currentDesktopId := getCurrentDesktopId()
	allDesktopIds := getAllDesktopIds()
	; Get the current desktop UUID. Length should be 32 always, but there's no guarantee this couldn't change in a later Windows release so we check.

	allDesktopIds := splitStringByCharCount(StrLen(currentDesktopId), allDesktopIds)
	currentDesktopNumber := getIndexFromArray(currentDesktopId, allDesktopIds)
	
	return currentDesktopNumber
}
getIndexFromArray(searchFor, array) 
{
	loop, % array.MaxIndex()
	{
		MsgBox % array[A_index] " "  searchFor
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

splitStringByCharCount(count, string) {
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
