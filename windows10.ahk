#SingleInstance
afterDesktopChangeTurnOffCapslock()
{
	SetCapsLockState , Off
	return
}
options := {"moveWindowModKey" : "Capslock"
	,"changeDesktopModKey" : "#"
	,"postChangeDesktop" : Func("afterDesktopChangeTurnOffCapslock").bind()}
	
;~ options := {"changeDesktopModKey": "#", "moveWindowModKey" : "+#"}
globalDesktopManager := new JPGIncDesktopManagerClass(options)
return
#c::ExitApp

#Include desktopChanger.ahk
#Include desktopMapper.ahk
#Include desktopMarker.ahk

debugger(message) {
	ToolTip, % message
	sleep 10
	return
}