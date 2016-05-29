/*
 * If we send the keystrokes too quickly you sometimes get a flickering of the screen
 */
send(toSend)
{
	oldDelay := A_KeyDelay
	SetKeyDelay, 30
	
	send, % toSend
	
	SetKeyDelay, % oldDelay
	return 
}

closeMultitaskingViewFrame()
{
	IfWinActive, ahk_class MultitaskingViewFrame
	{
		send("#{tab}")
	}
	return 
}

	
openMultitaskingViewFrame()
{
	IfWinNotActive, ahk_class MultitaskingViewFrame
	{
		send("#{tab}")
		WinWaitActive, ahk_class MultitaskingViewFrame
	}
	return
}


callFunction(possibleFunction)
{
	if(IsFunc(possibleFunction)) 
	{
		%possibleFunction%()
	} else if(IsObject(possibleFunction))
	{
		possibleFunction.Call()
	} else if(IsLabel(possibleFunction))
	{
		gosub, % possibleFunction
	}
	return
}

getDesktopNumberFromHotkey(keyCombo)
{
	number := RegExReplace(keyCombo, "[^\d]", "")
	return number == 0 ? 10 : number
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
	return -1
}