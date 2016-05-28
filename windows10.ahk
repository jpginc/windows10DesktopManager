#SingleInstance
 /*
  * Alternatively you can use the hotkeyManager to set the hotkeys after the JPGIncDesktopManagerClass has been
  * constructed like this
  */
globalDesktopManager := new JPGIncDesktopManagerClass()
globalDesktopManager.setGoToDesktop("Capslock")
    .setMoveWindowToDesktop("+#")
    .afterGoToDesktop("afterDesktopChangeTurnOffCapslock")
    .setGoToNextDesktop("Capslock & w")
    .setGoToPreviousDesktop("Capslock & q")

return

afterDesktopChangeTurnOffCapslock()
{
	SetCapsLockState , Off
	return
}

#c::ExitApp

#Include desktopManager.ahk
#Include desktopChanger.ahk
#Include windowMover.ahk
#Include desktopMapper.ahk
#include virtualDesktopManager.ahk
#Include monitorMapper.ahk
#Include hotkeyManager.ahk
#Include commonFunctions.ahk
debugger(message) 
{
	;~ ToolTip, % message
	;~ sleep 100
	return
}