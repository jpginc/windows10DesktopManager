#SingleInstance
afterDesktopChangeTurnOffCapslock()
{
	SetCapsLockState , Off
	return
}
options := {"moveWindowModKey" : "Capslock"
	,"postChangeDesktop" : Func("afterDesktopChangeTurnOffCapslock").bind()}
	
;~ options := {"changeDesktopModKey": "#", "moveWindowModKey" : "+#"}
globalDesktopManager := new JPGIncDesktopManager(options)
return
#c::ExitApp

#Include contextMenu.ahk
#Include desktopChanger.ahk
