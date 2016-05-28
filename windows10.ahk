#SingleInstance
 /*
  * Alternatively you can use the hotkeyManager to set the hotkeys after the JPGIncDesktopManagerClass has been
  * constructed like this
  */
globalDesktopManager := new JPGIncDesktopManagerClass()
globalDesktopManager.hotkeyManager.goToDesktopHotkey("Capslock")
globalDesktopManager.hotkeyManager.moveWindowToDesktopHotkey("+#")
globalDesktopManager.afterGoToDesktop("afterDesktopChangeTurnOffCapslock")

return

afterDesktopChangeTurnOffCapslock()
{
	SetCapsLockState , Off
	return
}

#c::ExitApp

#Include desktopChanger.ahk
#Include desktopMapper.ahk
#include virtualDesktopManager.ahk
#Include monitorMapper.ahk
#Include hotkeyManager.ahk

debugger(message) 
{
	;~ ToolTip, % message
	;~ sleep 10
	return
}