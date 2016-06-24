class JPGIncDllWindowMover
{
	static 32BitPID
	static 64BitPID
	
	__new()
	{
		debugger("starting the dll window mover")
		if(this.isAvailable())
		{
			debugger("the scripts to run the dll's are already running")
			return this
		}
		myPID := DllCall("GetCurrentProcessId")
		run, AutoHotkeyU32.exe "injection dll/dllCaller.ahk" "%myPID%" "32", , , 32BitPID
		run, AutoHotkeyU64.exe "injection dll/dllCaller.ahk" %myPID% 64, , , 64BitPID
		
		debugger( "32 bit pid is " 32BitPID "`n64bit pid is " 64BitPID)
		this.32BitPID := 32BitPID
		this.64BitPID := 64BitPID
		return this
	}
	
	isAvailable()
	{
		debugger("Checking availability")
		if(! this.32BitPID || ! this.64BitPID)
		{
			return false
		}
		process, exist, % this.32BitPID
		if(ErrorLevel == 0)
		{
			debugger("32 bit isn't available")
			return false
		}
		process, exist, % this.64BitPID
		if(ErrorLevel == 0)
		{
			debugger("64 bit isn't available")
			return false
		}
		return true
	}
	
	/*
	 * might return FAIL if the call fails?
	 */
	moveActiveWindowToDesktop(desktopNumber)
	{
		desktopNumber-- ;the dll numbers windows from 0 this is wParam
		hwnd := WinExist("A")
		marker := 43968 ; 0xABC0
		wParam := desktopNumber | marker
		lParam := hwnd
		WM_SYSCOMMAND := 274
		debugger("moving " hwnd " to desktop " desktopNumber)
		PostMessage, % WM_SYSCOMMAND , % wParam, % lParam, , % "ahk_id " hwnd
		return ErrorLevel
	}
}