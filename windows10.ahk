#IfWinActive ahk_class MultitaskingViewFrame
;Pressing windows + tab puts you in the MultitaskingViewFrame. Press windows key + a number will switch to that desktop
#1::
#2::
#3::
#4::
#5::
#6::
{
	StringTrimLeft, count, A_ThisHotkey, 1
	moveToDesktop(count)
	return
}
1::
2::
3::
4::
5::
6::
{
	moveToDesktop(A_ThisHotkey)
	return
}


#if

;pressing windows + shift + a number should send the active window to that desktop
+#1::
+#2::
+#3::
+#4::
+#5::
+#6::
{
	StringTrimLeft, newDesktopNumber, A_ThisHotkey, 2
	moveActiveWindowToDesktop(newDesktopNumber)
	return	
}

moveToDesktop(desktopNumber)
{
	;after the left 10 it will be on window 1 so decrement the count by 1 to compensate
	desktopNumber--
	send {tab}{left 10}{right %desktopNumber%}{return}
	return
}

moveActiveWindowToDesktop(newDesktopNumber)
{
	currentDesktopNumber := getCurrentDesktopNumber()
	if(currentDesktopNumber == newDesktopNumber)
	{
		return
	}
	;desktop starts at 1 so decrement the new desktopNumber by 1
	newDesktopNumber--
	if(currentDesktopNumber < newDesktopNumber)
	{
		newDesktopNumber--
	}
	send m{down %newDesktopNumber%}{enter}
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
	currentDesktopNumber := 0
	send #{tab}
	winwait, ahk_class MultitaskingViewFrame
	send {Appskey}
	menuString := getMenuString(getContextMenuHwnd())

	while(instr(menuString, "Desktop"))
	{
		if(! regexMatch(menuString, ",Desktop " A_index ","))
		{
			currentDesktopNumber := A_Index
			break
		}
	}
	if(!leaveWinTabOpen)
	{
		send #{tab}
	}
	return currentDesktopNumber
}
