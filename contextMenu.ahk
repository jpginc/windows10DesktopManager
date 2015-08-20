getContextMenuHwnd()
{
   WinWait, ahk_class #32768
   SendMessage, 0x1E1, 0, 0
   menuHwnd := ErrorLevel
   return menuHwnd
}

/*
 * Given the hwnd of a context menu returns the string (delimited by commas ",")
 */
getMenuString(menuHwnd, Delimiter := ",", subDelimiter := "`n")
{
   Loop, % DllCall("GetMenuItemCount", "Uint", menuHwnd)
   {
      idx := A_Index - 1
      idn := DllCall("GetMenuItemID", "Uint", menuHwnd, "int", idx)
      nSize++ := DllCall("GetMenuString", "Uint", menuHwnd, "int", idx, "Uint", 0, "int", 0, "Uint", 0x400)
      nSize := (nSize * (A_IsUnicode ? 2 : 1))
      VarSetCapacity(sString, nSize)
      DllCall("GetMenuString", "Uint", menuHwnd, "int", idx, "str", sString, "int", nSize, "Uint", 0x400)   ;MF_BYPOSITION
      If !sString
         sString := subDelimiter
      ;sContents .= idx . " : " . idn . A_Tab . A_Tab . sString . "`n"
      sContents .= sString Delimiter
      If (idn = -1) && (hSubMenu := DllCall("GetSubMenu", "Uint", menuHwnd, "int", idx))
         sContents .= getMenuString(hSubMenu, Delimiter)
   }
   Return   sContents
}