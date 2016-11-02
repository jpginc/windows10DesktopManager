SetWorkingDir, % A_ScriptDir
parentPID = %1%
32Or64 = %2%
libraryFileName := "hook " 32Or64 ".dll"

validateArgsOrDie(parentPID, 32Or64)

;load the custom dll
libraryHandle := loadDllOrDie(libraryFileName)
;get the address of the move desktop callback
moveDesktopHookHandle := getHookHandleOrDie(libraryHandle)
;hook up the move desktop callback on WH_GETMESSAGE messages
setupMoveDesktopCallback(moveDesktopHookHandle, libraryHandle)
waitForParentToClose(parentPID)
ExitApp

setupMoveDesktopCallback(functionHandle, libraryHandle)
{
	WH_GETMESSAGE := 3 
	errorMessage := "Callback dll call did not succeed. Windows error code: "
	
	didTheCallSucceed := DllCall("user32.dll\SetWindowsHookEx", "Int", WH_GETMESSAGE, "Ptr", functionHandle, "Ptr", libraryHandle, "Ptr", 0)
	if(! didTheCallSucceed)
	{
		alertErrorAndDie(errorMessage A_LastError)
	}
	return
}
getHookHandleOrDie(libraryHandle)
{
	errorMessage := "GetProcAddress dll call failed. Windows error code: "
	handle := DllCall("GetProcAddress", Ptr, libraryHandle, Astr, "GetMsgProc", "Ptr")
	if(! handle) 
	{
		alertErrorAndDie(errorMessage A_LastError)
	}
	return handle
}
loadDllOrDie(filename) 
{
	dllDoesNotExist := "Error, the dll does not exist!`nfilename: " filename
	error126 := "Error, unable to load custom DLL. You may be missing VS 2013 runtime files`nThe download link has been copied to the clipboard`nYou must install BOTH the 32 and 64 bit libraries"
	downloadLink := "https://www.microsoft.com/en-us/download/details.aspx?id=40784"
	LoadLibraryFailed := "LoadLibrary DLL call failed with windows error code: "
	
	if(! FileExist(filename)) 
	{
		alertErrorAndDie(dllDoesNotExist)
	}
	handle :=  DllCall("LoadLibrary", "Str", filename, "Ptr") 
	if(! handle) 
	{
		if(A_LastError == 126) 
		{
			Clipboard := downloadLink
			alertErrorAndDie(error126)
		}
		alertErrorAndDie(LoadLibraryFailed A_LastError)
	}
	return handle
}

waitForParentToClose(parentPID) 
{
	Process, waitclose, % parentPID
	return
}

validateArgsOrDie(parentPID, 32Or64)
{
	invalidCommandLineArgs := "Invalid command line args`nneed a process id and the string '64' or '32'"
	if(! parentPid) 
	{
		alertErrorAndDie(invalidCommandLineArgs)
	}
	if(!(32Or64 == "32" || 32Or64 == "64")) 
	{
		alertErrorAndDie(invalidCommandLIneArgs)
	}
	return
}

alertErrorAndDie(msg) 
{
	MsgBox, % msg
	ExitApp
}