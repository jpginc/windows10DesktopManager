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
globalDesktopManager := new JPGIncDesktopManager(options)
return
#c::ExitApp

#Include desktopChanger.ahk
#Include desktopMapper.ahk