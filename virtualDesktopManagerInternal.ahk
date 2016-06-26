class VirtualDesktopManagerInternalClass
{
	__new()
	{	
		debugger("creating th vdm internal")
		
		;https://m.reddit.com/r/Windows10/comments/4c11v2/is_there_a_way_builtin_3rd_party_tool_to_show_the/?ref=readnext_7
		ImmersiveShell   := ComObjCreate("{C2F03A33-21F5-47FA-B4BB-156362A2F239}", "{00000000-0000-0000-C000-000000000046}")
		
		;http://www.cyberforum.ru/blogs/105416/blog3671.html
		CLSID := "{C5E0CDCA-7B6E-41B2-9FC4-D93975CC467B}" ;search CLSID VirtualDesktopAPIUnknown 
		IID := "{AF8DA486-95BB-4460-B3B7-6E7A6B2962B5}" ;search IID IVirtualDesktopManagerInternal
		this.iVirtualDesktopManagerInternal := ComObjQuery(ImmersiveShell, CLSID, IID)
		
		
		this.switchDesktopAddress := getComObjectFunctionAddress(this.iVirtualDesktopManagerInternal, 9) ; IVirtualDesktopManagerInternal::SwitchDesktop
		this.getDesktopsAddress := getComObjectFunctionAddress(this.iVirtualDesktopManagerInternal, 7) ; IVirtualDesktopManagerInternal::GetDesktops
		
		return this
	}
	
	goToDesktop(newDesktopNumber)
	{
		this._moveToDesktop(this._getDesktop(newDesktopNumber))
		return this
	}
	
	getNumberOfDesktops()
	{
		desktopsObject := this._getDesktopsObject()
		getCountAddress := getComObjectFunctionAddress(desktopsObject, 3) ; IObjectArray::GetCount
		
		DllCall(getCountAddress, "Ptr", desktopsObject, "UIntP", numberOfDesktops) 
		
		return numberOfDesktops
	}
	
	_getDesktop(desktopNumber)
	{
		;the desktops array is zero indexed
		desktopNumber--
		
		desktopsObject := this._getDesktopsObject()
		
		this._createGuidFromString(virtualDesktopGuid, "{FF72FFDD-BE7E-43FC-9C03-AD81681E88E4}")
		getAtAddress := getComObjectFunctionAddress(desktopsObject, 4) ; IObjectArray::GetAt
		
		DllCall(getAtAddress, "Ptr", desktopsObject, "UInt", desktopNumber,  "Ptr", &virtualDesktopGuid, "Ptr*", virtualDesktop)
		
		return virtualDesktop
	}
	
	_moveToDesktop(desktop)
	{
		DllCall(this.switchDesktopAddress, "Ptr", this.iVirtualDesktopManagerInternal, "Ptr", desktop)
		return this
	}
	
	_getDesktopsObject() 
	{
		DllCall(this.getDesktopsAddress, "Ptr", this.iVirtualDesktopManagerInternal, "Ptr*", desktopsObject)
		
		return desktopsObject
	}
	
	; Converts a string to a binary GUID https://m.reddit.com/r/Windows10/comments/4c11v2/is_there_a_way_builtin_3rd_party_tool_to_show_the/?ref=readnext_7
	_createGuidFromString(ByRef GUID, sGUID) 
	{
		VarSetCapacity(GUID, 16, 0)
		DllCall("ole32\CLSIDFromString", "Str", sGUID, "Ptr", &GUID)
		return this
	}
}