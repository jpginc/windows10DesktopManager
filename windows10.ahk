#SingleInstance

globalDesktopManager := new JPGIncDesktopManager()
return
#c::ExitApp

#0::globalDesktopManager.moveToDesktop(10)
#IfWinActive ahk_class MultitaskingViewFrame
;Press windows key + a number will switch to that desktop
#1::
#2::
#3::
#4::
#5::
#6::
#7::
#8::
#9::
{
	StringTrimLeft, newDekstopNumber, A_ThisHotkey, 1
	globalDesktopManager.moveToDesktop(newDekstopNumber, true)
	return
}
;Pressing windows + tab puts you in the MultitaskingViewFrame. Then pressing a number will switch to that desktop
1::
2::
3::
4::
5::
6::
7::
8::
9::
0::
{
	globalDesktopManager.moveToDesktop(A_ThisHotkey == 0 ? 10 : A_ThisHotkey, true)
	return
}


#if

;pressing windows + shift + a number should send the active window to that desktop
+#1::
+#2::
+#3::
+#4::
+#5::
+#6::
+#7::
+#8::
+#9::
+#0::
{
	;setting this to true will make you follow the active window to its new desktop
	StringTrimLeft, newDesktopNumber, A_ThisHotkey, 2
	globalDesktopManager.moveActiveWindowToDesktop(newDesktopNumber)
	return	
}

#Include contextMenu.ahk
#Include desktopChanger.ahk
