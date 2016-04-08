#SingleInstance
options := {"modKey": "#", "moveWindowModKey" : "+"}
globalDesktopManager := new JPGIncDesktopManager(options)
return
#c::ExitApp
#Include contextMenu.ahk
#Include desktopChanger.ahk
