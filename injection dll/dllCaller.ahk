parentPID = %1%
32Or64 = %2%
SetWorkingDir, % A_ScriptDir
if(parentPID && 32Or64)
{
	;~ MsgBox % parentPID "`n" 32Or64
	
	libraryFileName := "hook " 32Or64 ".dll"
	
	;~ MsgBox % libraryFileName
	;load the custom dll
	libraryHandle := DllCall("LoadLibrary", "Str", "hook " 32Or64 ".dll", "Ptr") 
	;~ MsgBox % "libraryHandle " libraryHandle "`n" A_LastError
	;get the address of the move desktop callback
	moveDesktopHookHandle := DllCall("GetProcAddress", Ptr, libraryHandle, Astr, "GetMsgProc", "Ptr")
	;~ MsgBox % "moveDesktopHookHandle " moveDesktopHookHandle "`n" A_LastError
	;hook up the move desktop callback on WH_GETMESSAGE messages
	WH_GETMESSAGE := 3 
	didTheCallSucceed := DllCall("user32.dll\SetWindowsHookEx", "Int", WH_GETMESSAGE, "Ptr", moveDesktopHookHandle, "Ptr", libraryHandle, "Ptr", 0)
	if(! didTheCallSucceed)
	{
		MsgBox the call did not succeed for me`nLasError: %A_LastError%
		ExitApp
	}
	Process, waitclose, % parentPID
} else
{
	MsgBox Invalid command line args`nneed a process id and a string "64" or "32" %0% args were recieved
}
ExitApp
