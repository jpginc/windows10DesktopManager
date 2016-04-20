
#SingleInstance
afterDesktopChangeTurnOffCapslock()
{
	SetCapsLockState , Off
	return
}
options := {"moveWindowModKey" : "Capslock"
	,"changeDesktopModKey" : "#"
	,"postChangeDesktop" : Func("afterDesktopChangeTurnOffCapslock").bind()}
	
globalDesktopManager := new JPGIncDesktopManagerClass(options)
return
#c::ExitApp

#Include desktopChanger.ahk
#Include desktopMapper.ahk
#include virtualDesktopManager.ahk

debugger(message) {
	;~ ToolTip, % message
	;~ sleep 10
	return
}