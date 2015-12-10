if not A_IsAdmin
{
   Run *RunAs "%A_ScriptFullPath%"  ; Requires v1.0.92.01+
   ExitApp
}


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
#0::
{
	StringTrimLeft, count, A_ThisHotkey, 1
	send #{tab}
	WinWait, ahk_class MultitaskingViewFrame
	moveToDesktop(count)
	return
}
#IfWinActive ahk_class MultitaskingViewFrame
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
	moveToDesktop(A_ThisHotkey)
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
	follow := false
	StringTrimLeft, newDesktopNumber, A_ThisHotkey, 2
	moveActiveWindowToDesktop(newDesktopNumber)
	return	
}

#Include contextMenu.ahk
#Include desktopChanger.ahk
