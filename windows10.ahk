#SingleInstance
/*
 * 	The options object below defines the hotkeys for the window manager. 
 *  
 *	Usage:
 *  An Empty Object:
 * 		Pressing numbers 1 through 0 while in the multi tasking view (the view that comes up after pressing win + tab) will go to the desktop number that you pressed
 *
 *  "goToDesktopModKey" : modKey (optional)
 * 		the key or modifier for going to a desktop. 
 *		Example: "#" == windows key + number to go to another desktop
 *
 * 	"moveWindowModKey" : ModKey (optional)
 *		The key or modifier for moving the active window to a desktop
 *		Example: "+#" == shift + windows key + number moves the active window to another desktop
 *
 *	"postChangeDesktop" : function name or function object (optional)
 *		A function that will be called after moving desktops
 *
 *	"postMoveWindow": function name or function object (optional)
 *		A function that will be called after moving the active window to a desktop
 * 	
 */
;~ options := {"goToDesktopModKey" : "Capslock" ;capslock + number number jumps to desktop
	;~ ,"moveWindowModKey" : "+#" ;windows key + shift + number moves the active window to a desktop
	;~ ,"postChangeDesktop" : Func("afterDesktopChangeTurnOffCapslock").bind()} ;after moving the active window turn off capslock
	
;~ globalDesktopManager := new JPGIncDesktopManagerClass(options)

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