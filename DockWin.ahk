;DockWin v0.5 - Save and Restore window positions when docking/undocking (using hotkeys) over all Windows 10 Desktops
; Paul Troiano, 6/2014
; Updated by Ashley Dawson 7/2015
; Updated by Robert Niebsch 10/2016
;
; Hotkeys: Capslock + 0 to save; Capslock + 9 to load

class DockWinClass
{

    SaveAllWindowsFunctionName := "SaveAllWindows"
    LoadAllWindowsFunctionName := "LoadAllWindows"
    
	
	__new()
    {  
        this.WindowMover := new JPGIncWindowMoverClass()
		this.desktopMapper := new DesktopMapperClass(new VirtualDesktopManagerClass())
		this.monitorMapper := new MonitorMapperClass()  
        return this
    }
    
; goes through file
; title of line in file is matched with open windows
LoadAllWindows()
{
    SetTitleMatchMode, 3		; 2: A window's title can contain WinTitle anywhere inside it to be a match. 
    SetTitleMatchMode, Fast		;Fast is default
    DetectHiddenWindows, off	;Off is default

    SetWorkingDir %A_ScriptDir%  ; Ensures a consistent starting directory.
    CrLf=`r`n
    FileName:="WinPos.txt"
        
    WinGetActiveTitle, SavedActiveWindow
    ParmVals:="Title Desktop x y height width maximized path"
    SectionToFind:= this.SectionHeader()
    SectionFound:= 0
    
    FileSelectFile, FileName, 1, WinPos.txt ;ask when overwriting; default name WinPos.txt
    MsgBox, 4, Dock Windows, Load window positions?
    IfMsgBox, NO, Return

    Loop, Read, %FileName%
    {
        if !SectionFound
        {
          ;Read through file until correct section found
          If (A_LoopReadLine<>SectionToFind) 
            Continue
        }	  

        ;Exit if another section reached
        If ( SectionFound and SubStr(A_LoopReadLine,1,8)="SECTION:")
            Break

        SectionFound:=1
        
        Win_Title:="", Win_desktop:=1, Win_x:=0, Win_y:=0, Win_width:=0, Win_height:=0, Win_maximized:=0

        Loop, Parse, A_LoopReadLine, CSV 
        {
            EqualPos:=InStr(A_LoopField,"=")
            Var:=SubStr(A_LoopField,1,EqualPos-1)
            Val:=SubStr(A_LoopField,EqualPos+1)
            IfInString, ParmVals, %Var%
            
            {
                ;Remove any surrounding double quotes (")
                If (SubStr(Val,1,1)=Chr(34)) 
                {
                    StringMid, Val, Val, 2, StrLen(Val)-2
                }
                Win_%Var%:=Val
            }
        }
        
        ;Check if program is already running, if not, start it
        If  (!WinExist(Win_Title) and (Win_path<>""))
        {
            Try
            {
                Run %Win_path%	
                sleep 1000		;Give some time for the program to launch.	
            }
        }

        If ( (Win_maximized = 1) and WinExist(Win_Title) )
        {	
            WinRestore
            WinActivate
            
            this.WindowMover.moveActiveWindowToDesktop(Win_desktop)
            WinMove, A,,%Win_x%,%Win_y%,%Win_width%,%Win_height%
            
            WinMaximize, A
        } Else If ((Win_maximized = -1) and (StrLen(Win_Title) > 0) and WinExist(Win_Title) )		; Value of -1 means Window is minimised
        {	
            WinRestore
            WinActivate
            
            
            this.WindowMover.moveActiveWindowToDesktop(Win_desktop)
            WinMove, A,,%Win_x%,%Win_y%,%Win_width%,%Win_height%

            WinMinimize, A
        } Else If ( (StrLen(Win_Title) > 0) and WinExist(Win_Title) )
        {	
            WinRestore
            WinActivate
            
            this.WindowMover.moveActiveWindowToDesktop(Win_desktop)
            WinMove, A,,%Win_x%,%Win_y%,%Win_width%,%Win_height%
        }
    }

    if !SectionFound
    {
        msgbox,,Dock Windows, Section does not exist in %FileName% `nLooking for: %SectionToFind%`n`nTo save a new section, use Win-Shift-0     (zero key above letter P on keyboard)
    }

  ;Restore window that was active at beginning of script
  WinActivate, %SavedActiveWindow%

  return this
}

;(Save current windows to file)
SaveAllWindows()
{

    SetTitleMatchMode, 2		; 2: A window's title can contain WinTitle anywhere inside it to be a match. 
    SetTitleMatchMode, Fast		;Fast is default
    DetectHiddenWindows, off	;Off is default

    SetWorkingDir %A_ScriptDir%  ; Ensures a consistent starting directory.
    CrLf=`r`n
    FileName:="WinPos.txt"

    FileSelectFile, FileName, 16, WinPos.txt ;ask when overwriting; default name WinPos.txt
    MsgBox, 4, Dock Windows, Save window positions?
    IfMsgBox, NO, Return
    
    WinGetActiveTitle, SavedActiveWindow

    file := FileOpen(FileName, "w")
    if !IsObject(file)
    {
        MsgBox, Can't open "%FileName%" for writing.
        Return
    }

  line:= this.SectionHeader() . CrLf
  file.Write(line)

  ; Loop through all windows on the entire system
  WinGet, id, list,,, Program Manager
  Loop, %id%
  {
    this_id := id%A_Index%
    WinActivate, ahk_id %this_id%
    WinGetPos, x, y, Width, Height, A ;Wintitle
    WinGetClass, this_class, ahk_id %this_id%
    WinGetTitle, this_title, ahk_id %this_id%
    WinGet, win_maximized, minmax, %this_title%
    
    currentDesktop := this.desktopMapper.getDesktopNumber()

	if ( (StrLen(this_title)>0) and (this_title<>"Start") )
	{
		line=Title="%this_title%"`,desktop=%currentDesktop%`,x=%x%`,y=%y%`,width=%width%`,height=%height%`,maximized=%win_maximized%,path=""`r`n
		file.Write(line)
   	}
	
	if(win_maximized = -1)		;Re-minimize any windows that were minimised before we started.
	{
		WinMinimize, A
	}
    
    
  }

  file.write(CrLf)  ;Add blank line after section
  file.Close()

  ;Restore active window
  WinActivate, %SavedActiveWindow%

return this
}

; -------

;Create standardized section header for later retrieval
SectionHeader()
{
	SysGet, MonitorCount, MonitorCount
	SysGet, MonitorPrimary, MonitorPrimary
	line=SECTION: Monitors=%MonitorCount%,MonitorPrimary=%MonitorPrimary%

    WinGetPos, x, y, Width, Height, Program Manager
	line:= line . "; Desktop size:" . x . "," . y . "," . width . "," . height

	return %line%
}

}
