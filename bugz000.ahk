#NoEnv
SetWorkingDir %A_ScriptDir%
#singleInstance, force
setbatchlines -1
coordMode, caret, screen
name:="Bugz000 Soundboard"
defaultDevice:="VoiceMeeter Input"
defaultName:="Zira"
www:=252
navigate:=current
quickies:={}
choices:=[]
cli := new cli("CMD.exe","","CP850")
sleep 200
loop, files, %A_ScriptDir%\quickies\*.wav, R
	{
		quickies[A_Index, "Category"] := strreplace(strreplace(strreplace(substr(A_LoopFileFullPath, instr(A_loopfilefullpath,"\quickies\")),A_Loopfilename), "\quickies\"),"\")
		if !instr(categories, quickies[A_Index, "Category"])
			categories .= quickies[A_Index, "Category"] "`n"
		quickies[A_Index, "Name"]:=substr(A_LoopFileName, 1, -4)
		quickies[A_Index, "Path"]:= A_LoopFileFullPath
		, choices.push(substr(A_LoopFileName, 1, -4))
	}
o:={} ;makes arr
loop, parse, categories, "`n" ;parse category
	o.push(A_Loopfield)  		;put shit in arr
Categories := {}				;clear categories make arr
Categories := o					;fill arr
o:=""
SVSFlagsAsync := 1
SVSFPurgeBeforeSpeak := 2
SVSFIsNotXML := 0
flags:=SVSFlagsAsync | SVSFPurgeBeforeSpeak | SVSFIsNotXML
SAPI:=new soundBoard
SAPI.getVoices()
arr:=[]
hasOptions:=0
readyToSend:=0
gui, font, s10, Letter Gothic
gui, color, 0x8D9670, 0x8D9670 ; beautiful colors
gui, margin, 2, 2
gui, add, text, xm ym+2 r1.5, % "Volume: "
gui, add, edit, ys-3 w80 hp number vVolume gChangeSettings, 100
gui, add, upDown, wrap range0-100 gChangeSettings, 100
options:=""
www2:=www/2-4 ; -4 for the margins
for k, name in SAPI.getOutputs()
	options.=A_Index - 1 ") " name.getDescription() ((inStr(name.getDescription(), defaultDevice)) ? "||" : "|")
gui, add, dropDownList, ys-3 w%www2% hp r8 vaudioDevice gchangeAudio, %options%

gui, add, text, x5 y+m w%www% r1 vprog2 , % ProgressBar(40, 100, 100, 1)
gui, add, text, x5 y+m w%www% r1 vprog1 , % ProgressBar(40, 100, 100, 1)
gui, color,, 0x303030 ; beautiful colors
gridwidth:=3
gridheight:=3
grid:=generateGrid(gridwidth,gridheight)

for x, v in grid
	{
		for y, v in grid[x]
			{
				w:=www/gridwidth
				h:=www/gridheight
				; Gui, Add, progress, x%X% y%Y% w%bS% H%bS% hwndBlock_%A_index%_%index%HWND vpBlock_%A_Index%_%_index%, 100
				if !(y=1)
					gui, add, edit, x+m yp w%w% h%h% vguiGrid_%X%_%Y% gSendSound 0x200 +center +Wrap -Vscroll -E0x200 +cWhite +hwndHWND_%X%_%Y%, %X% | %Y%
				else
					gui, add, edit, xm y+m w%w% h%h% vguiGrid_%X%_%Y% gSendSound 0x200 +center +Wrap  -Vscroll -E0x200 +cWhite +hwndHWND_%X%_%Y%, %X% | %Y%
				CTLCOLORS.Attach(HWND_%X%_%Y%, "797096")
			}
	}

www2:=www-80-6
;gui, add, edit, xm y+m w%www2% r2 -wantreturn hwndInputCtrl vtoSpeak gtyping, cheers ; beep beep I'm a jeep`, lol
;gui, add, button, x+m yp w80 hp default gspeak, Say
gui, +hwndMYHWND alwaysOnTop
guiControl, focus, toSpeak
gui, show,, %name%
out:=""
inc:=35
loop % quickies.count()
	{
		index := A_Index
		guicontrol, text, prog1, % "Loading file-[" index "/" quickies.count() "]-" A_tickcount - oldtime "ms-"quickies[index, "Name"]
		guicontrol, text, prog2, % ProgressBar(60, index, quickies.count(), 1)
		oldtime := A_tickcount
		loop
			{
				cli.write(A_scriptdir "\ffprobe.exe -hide_banner -loglevel quiet -i " chr(34) quickies[index, "Path"] chr(34) " -show_entries format=filename,duration`r`n`r`n")
				for x, v in grid
					for y, v in grid[x]
						CTLCOLORS.Change(HWND_%X%_%Y%, hexify(index, quickies.count()))
				sleep % inc*2
				read := cli.read()
				if instr(Read, "duration=")
					{
						loop, parse, read, `n,`r
							{ ;quickies[index, "Duration"] := done := substr(instr(A_Loopfield,"=")), inc-=1
								if instr(A_loopfield, "filename=")
									path := substr(A_Loopfield, instr(A_Loopfield,"=")+1)
								if instr(A_loopfield, "duration=") AND (path = quickies[index, "Path"])
									quickies[index, "Duration"] := done := round(substr(A_loopfield, instr(A_Loopfield,"=")+1),2)

							}
					}
				else
					inc += 1
				path:=read:=""
				if (Done)
					break
			}
		done:=0
	}

for x, v in grid
	for y, v in grid[x]
		CTLCOLORS.Change(HWND_%X%_%Y%, "797096")
OnMessage(WM_MOUSEWHEEL:=0x20A, "wheel") 
gosub, changeAudio
gosub, ChangeSettings
gui, submit, noHide
x:=1
y:=1
Page:={}
PageNum:=1
i:=1
for k, cat in categories
	{
		i2:=i:=x:=y:=pagenum:=1
		for id, v in quickies
			{
				if !(Quickies[A_Index, "Category"] = cat)
					continue
				page[cat, pagenum, x, y] := quickies[A_index]
				i+=1
				x+=1
				if !mod(i2, gridwidth)
					y+=x:=1
				if ((i-1) = (gridwidth*gridheight))
					pagenum+=i:=y:=1
				i2+=1
			}
	}
grid := ""
grid := {}
pagenum:=1
gosub, popgrid
clipboard := St_printarr(page)
gosub gostart
categories.pop()
SetTimer , PollTime, 500
return
PollTime:
polltime()
return
guiDropFiles:
	for k, v in strSplit(A_GuiEvent, "`n", "`r")
	{
		SAPI.playFile(v, flags)
		; break ; stop at the first item
	}
return
numpadadd::
	pagenum +=1
	if (pagenum>page[category].count())
		pagenum := 1
	gosub popgrid
return
numpadenter::
	pagenum -=1
	if (pagenum<=0)
		pagenum:=page[category].count()
	gosub popgrid
return
gostart:
numpadmult::
	catcount -=1
	if (catcount<=0)
		catcount := categories.count()
	category := categories[catcount]
	pagenum := 1
	gosub popgrid
return
numpadsub::
	catcount +=1
	if (catcount>categories.count())
		catcount := 1
	category := categories[catcount]
	pagenum := 1
	gosub popgrid
return
guiClose:
guiEscape:
	exitapp
return


numpad1::
numpad2::
numpad3::
numpad4::
numpad5::
numpad6::
numpad7::
numpad8::
numpad9::
	gui, submit, nohide
	conversion:={	numpad1:"3|1"
					,numpad2:"3|2"
					,numpad3:"3|3"
					,numpad4:"2|1"
					,numpad5:"2|2"
					,numpad6:"2|3"
					,numpad7:"1|1"
					,numpad8:"1|2"
					,numpad9:"1|3"}
	x:=substr(conversion[A_thishotkey], -2,1)
	y:=substr(conversion[A_thishotkey],0)
	if (page[category, pagenum, x, y,"name"])
		{
			CTLCOLORS.Change(HWND_%X%_%Y%, "709679")
			SAPI.playFile(page[category, pagenum,x,y,"path"], flags)
			grid[x,y,"start"]:=A_Tickcount
			grid[x,y,"duration"]:=page[category, pagenum,x,y,"duration"]
			time:=strsplit(page[category, pagenum,x,y,"duration"], ".")
			ms := (time[1]*1000) + time[2]
			sleep % ms
			PollTime()
		}
	else
		{
			CTLCOLORS.Change(HWND_%X%_%Y%, "96708d")
			grid[x,y,"start"]:=A_Tickcount
			grid[x,y,"duration"]:=page[category, pagenum,x,y,"duration"]
			time:=strsplit(page[category, pagenum,x,y,"duration"], ".")
			ms := (time[1]*1000) + time[2]
			sleep % ms
			PollTime()
		}
return

sendsound:
x:=substr(A_GuiControl, -2, 1)
y:=substr(A_guicontrol, 0)
return
popgrid:
	gui, submit, noHide
	i:=0
	for x, v in page[category, pagenum]
		for y, v in page[category, pagenum,x]
			{
				if (pagenum = page.count())
					i+=1
				guicontrol, text, guiGrid_%X%_%Y%, % page[category, pagenum,x,y,"name"] "`n" page[category, pagenum,x,y,"Duration"]
			}
	
	loop % gridwidth
	{
		X := A_index
		loop % gridheight
			{
				y:=A_Index
				if (page[category, pagenum,x,y,"name"])
					guicontrol, text, guiGrid_%X%_%Y%, % page[category, pagenum,x,y,"name"] "`n" page[category, pagenum,x,y,"Duration"]
				else
					guicontrol, text, guiGrid_%X%_%A_Index%, --- 
			}
	}
	PollTime(1)
	guicontrol, text, prog1, % ProgressBar(30, pagenum, page[category].count(), 1) "-[" pagenum "/" page[category].count() "]"
	guicontrol, text, prog2, % ProgressBar(30, catcount, categories.count(), 1) "-[" catcount "/" categories.count() "]-[" category "]"
return

changeAudio:
	gui, submit, noHide
	SAPI.setOutput(audioDevice)
return
changeVoice:
	gui, submit, noHide	
	SAPI.setVoice((audioVoices))
return
ChangeSettings:
	gui, submit, noHide
	SAPI.setRate(Rate)
	SAPI.setVolume(Volume)
return
SortByChild(arr, var, child:="")
	{ ;made by bugz000
		child := child?child:var
		for parent, child in arr
			__list .= arr[parent, Child] "|" parent "`n"
		
		Sort, __list , N
		loop, parse, __list, "`n"
			{
				split := strsplit(A_loopfield, "|")
				__o .= split[2] "`n"
			}
		return __o
	}
	
PollTime(f=0)
{
	global
	loop % gridwidth
	{
		X := A_index
		loop % gridheight
			{
				y:=A_Index

				if ((A_Tickcount - grid[x,y,"start"])>(grid[x,y,"duration"]*1000)) OR (F)
					{
						CTLCOLORS.Change(HWND_%X%_%Y%, "797096")
						grid[x,y,"Start"]:=""
						grid[x,y,"duration"]:=""
					}
			}
		
	}

}
ToHex(input)
	{
		;made by bugz000
		SetFormat Integer, H
		(input := input+0)
		SetFormat Integer, D
		StringTrimLeft, input, input, 2
		length := StrLen(input)
		if (length = 0)
			exitapp
		if (length = 1)
				input := "0"  .  input
		return, input
	}
hexify(in, total=100)
	{
		global debug
		hue := 35
		Clip := 15
		;total += clip
		in := (in+hue) 
		if (in > total)
			in := in - total
		sec := round(total/6)
		If (in//sec = 0 || in//sec = 3)
		   R := (in//sec = 0) ? 255 : 0, G := (in//sec = 0) ? 0 : 255, B := (in//sec = 0) ? Round((in/sec - in//sec) * 255) : 255 - Round((in/sec - in//sec) * 255)
		Else If (in//sec = 1 || in//sec = 4)
		   R := (in//sec = 1) ? 255 - Round((in/sec - in//sec) * 255) : Round((in/sec - in//sec) * 255), G := (in//sec = 1) ? 0 : 255, B := (in//sec = 1) ? 255 : 0
		Else If (in//sec = 2 || in//sec = 5)
		   R := (in//sec = 2) ? 0 : 255, G := (in//sec = 2) ? Round((in/sec - in//sec) * 255) : 255 - Round((in/sec - in//sec) * 255), B := (in//sec = 2) ? 255 : 0
		if (R="") || (G="") || (B="")
			return % "FAILSAFE" "`n" " R:" R " G:" G " B:" B "`ntotal: " total " in:" in " stage:" in/sec "`nthis.in:" in " this.sec:" sec "`n`n"
		return %  tohex(R) tohex(G) tohex(B)  
	}
st_printArr(array, depth=5, indentLevel="")
{
	for k,v in Array
	{
		list.= indentLevel "[" k "]"
		if (IsObject(v) && depth>1)
			list.="`n" st_printArr(v, depth-1, indentLevel . "    ")
		Else
			list.=" => " v
		list:=rtrim(list, "`r`n `t") "`n"
	}
	return rtrim(list)
}

getActiveControl()
{
	GuiControlGet, OutputVar, Focus
	guiControlGet, hwnd, hwnd, %OutputVar%
	return hwnd
}

mouseIsOver()
{
	mouseGetPos,,,, hwnd, 2
	return hwnd
}
ProgressBar(Length, Current, Max, Unlock = 0)
	{
		;Made by Bugz000 with assistance from tidbit, Chalamius and Bigvent
		Percent := (Current / Max) * 100
		if (unlock = 0)
			length := length > 97 ? 97 : length < 4 ? 4 : length
		percent := percent > 100 ? 100 : percent < 0 ? 0 : percent
		Loop % round(((percent / 100) * length), 0)
			Progress .= "/"
		loop % Length - round(((percent / 100) * length), 0)
			Progress .= "-"
		return "[" progress "]"
	}
	
	
wheel(wParam, lParam)
	{
	amt:=1
	mouseGetPos,,,, controlType
	if (!instr(controlType, "Edit"))
		return

	GuiControlGet, value,, %A_GuiControl%
	if value is not number
		return

	value+=((StrLen(wParam)>7) ? -amt : amt)
	GuiControl,, %A_GuiControl%, % RegExReplace(value, "(\.[1-9]+)0+$", "$1")
}


getEditSelection(hwnd) ; linearspoon https://www.autohotkey.com/boards/viewtopic.php?p=178225#p178225
{
  VarSetCapacity(buf, 8)
  SendMessage, 0xB0, &buf, &buf+4,, ahk_id %hwnd%
  return { start: NumGet(buf, 0, "uint"), end: NumGet(buf, 4, "uint") }
}

selectText(hwnd, s, e)
{
	sendMessage, 0xB1, %s% , %e%,, ahk_id %hwnd%
}


fuzzybit(fuzz, master)
{
	score:=0, pos:=1
	for k, char in StrSplit(fuzz)
	{
		segment:=substr(master, pos)
		, foundPos:=inStr(segment, char)
		if (foundPos>0)
		{
			master:=segment
			, score+=1
			, pos:=foundPos+1
			continue ; we found a match, check the next letter to find
		}
	}
	return score/strLen(fuzz)
}

generateGrid(x,y)
	{
		arr := {}
		loop % x
			{
				_x := A_Index
				loop % y
					{
						arr[_x, A_index] := 0
					}
			}
		return % arr
	}

class soundBoard {
    ; rate:=0
    ; volume:=100
	__new()
	{
		this.SAPI:=comObjCreate("SAPI.SpVoice")
		this.rate:=0
		this.volume:=100
	}
	rate[] {
		set {
			this.SAPI.Rate:=value			
		}
	}
	
	volume[] {
		set {
			this.SAPI.Volume:=value
		}
	}
	
    setOutput(name)
	{
		for k, item in this.getOutputs()
			if (inStr(name, item.getDescription()))
				this.setOutputItem(item)
	}
	
	setOutputItem(item)
	{
		this.SAPI.AudioOutput:=item
	}
	
	getOutputs() ; partial name or full, like "Zira" or "Mike"
	{
		out:=[]
		audioOutputs:=this.SAPI.getAudioOutputs()
		loop, % audioOutputs.Count()
			out.push(audioOutputs.Item(A_Index - 1))
		return out
	}
	
	playFile(filePath, flags:="")
	{
		spFile:=comObjCreate("SAPI.SpFileStream")
		spFile.open(filePath)
		this.SAPI.speakStream(spFile, flags)
	}

	; !!! not finding anything on how to set the volume on .wav files
	; playTempFile(filePath, tempRate, tempVolume)
	; {
	; 	oRate:=this.rate
	; 	oVol:=this.volume
		
	; 	; msgBox % this.rate "/" tempRate
	; 	spFile:=comObjCreate("SAPI.SpFileStream")
	; 	spFile.open(filePath)
	; 	spFile.Volume:=40
	; 	this.SAPI.speakStream(spFile)
		
	; 	; this.rate:=oRate
	; 	; this.volume:=oVol
	; }
	
	playText(str, flags:=0)
	{
		this.SAPI.speak(str, flags)
	}

	setRate(int:=0) ; -10 to 10
	{
		if int is not number
			this.SAPI.Rate:=0
		else
			this.SAPI.Rate:=int
	}
	
	setVolume(int:=100) ; 0 to 100
	{
		if int is not number
			this.SAPI.Volume:=100
		else
			this.SAPI.Volume:=int
	}

	setVoice(name) ; partial name or full, like "Zira" or "Mike"
	{
		voiceOutputs:=this.SAPI.GetVoices()
		loop, % voiceOutputs.Count()
			if (inStr(trim(name), voiceOutputs.item(A_Index-1).getDescription()))
			{
				this.SAPI.Voice:=voiceOutputs.Item(A_Index - 1)
				break
			}
	}
	
	getVoices() ; partial name or full, like "Zira" or "Mike"
	{
		out:=[]
		voiceOutputs:=this.SAPI.GetVoices()
		loop, % voiceOutputs.Count()
			out.push(voiceOutputs.Item(A_Index - 1))
		return out
	}
}

class cli {
    __New(sCmd, sDir="",codepage="") {
      DllCall("CreatePipe","Ptr*",hStdInRd,"Ptr*",hStdInWr,"Uint",0,"Uint",0)
      DllCall("CreatePipe","Ptr*",hStdOutRd,"Ptr*",hStdOutWr,"Uint",0,"Uint",0)
      DllCall("SetHandleInformation","Ptr",hStdInRd,"Uint",1,"Uint",1)
      DllCall("SetHandleInformation","Ptr",hStdOutWr,"Uint",1,"Uint",1)
      if (A_PtrSize=4) {
         VarSetCapacity(pi, 16, 0)
         sisize:=VarSetCapacity(si,68,0)
         NumPut(sisize, si,  0, "UInt"), NumPut(0x100, si, 44, "UInt"),NumPut(hStdInRd , si, 56, "Ptr"),NumPut(hStdOutWr, si, 60, "Ptr"),NumPut(hStdOutWr, si, 64, "Ptr")
         }
      else if (A_PtrSize=8) {
         VarSetCapacity(pi, 24, 0)
         sisize:=VarSetCapacity(si,96,0)
         NumPut(sisize, si,  0, "UInt"),NumPut(0x100, si, 60, "UInt"),NumPut(hStdInRd , si, 80, "Ptr"),NumPut(hStdOutWr, si, 88, "Ptr"), NumPut(hStdOutWr, si, 96, "Ptr")
         }
      pid:=DllCall("CreateProcess", "Uint", 0, "Ptr", &sCmd, "Uint", 0, "Uint", 0, "Int", True, "Uint", 0x08000000, "Uint", 0, "Ptr", sDir ? &sDir : 0, "Ptr", &si, "Ptr", &pi)
      DllCall("CloseHandle","Ptr",NumGet(pi,0))
      DllCall("CloseHandle","Ptr",NumGet(pi,A_PtrSize))
      DllCall("CloseHandle","Ptr",hStdOutWr)
      DllCall("CloseHandle","Ptr",hStdInRd)
         ; Create an object.
		this.hStdInWr:= hStdInWr, this.hStdOutRd:= hStdOutRd, this.pid:=pid
		this.codepage:=(codepage="")?A_FileEncoding:codepage
	}
    __Delete() {
        this.close()
    }
    close() {
       hStdInWr:=this.hStdInWr
       hStdOutRd:=this.hStdOutRd
       DllCall("CloseHandle","Ptr",hStdInWr)
       DllCall("CloseHandle","Ptr",hStdOutRd)
      }
   write(sInput="")  {
		If   sInput <>
			FileOpen(this.hStdInWr, "h", this.codepage).Write(sInput)
      }
	readline() {
       fout:=FileOpen(this.hStdOutRd, "h", this.codepage)
	   this.AtEOF:=fout.AtEOF
       if (IsObject(fout) and fout.AtEOF=0)
         return fout.ReadLine()
      return ""
      }
	read(chars="") {
       fout:=FileOpen(this.hStdOutRd, "h", this.codepage)
       this.AtEOF:=fout.AtEOF
	   if (IsObject(fout) and fout.AtEOF=0)
         return chars=""?fout.Read():fout.Read(chars)
      return ""
      }
}

; ======================================================================================================================
; AHK 1.1 +
; ======================================================================================================================
; Function:          Helper object to color controls on WM_CTLCOLOR... notifications.
;                    Supported controls are: Checkbox, ComboBox, DropDownList, Edit, ListBox, Radio, Text.
;                    Checkboxes and Radios accept background colors only due to design.
; Namespace:         CTLCOLORS
; AHK version:       1.1.11.01
; Language:          English
; Version:           0.9.01.00/2012-04-05/just me
;                    0.9.02.00/2013-06-26/just me  -  fixed to run on Win 7 x64
;                    0.9.03.00/2013-06-27/just me  -  added support for disabled edit controls
;
; How to use:        To register a control for coloring call
;                       CTLCOLORS.Attach()
;                    passing up to three parameters:
;                       Hwnd        - Hwnd of the GUI control                                   (Integer)
;                       BkColor     - HTML color name, 6-digit hex value ("RRGGBB")             (String)
;                                     or "" for default color
;                       ------------- Optional -------------------------------------------------------------------------
;                       TextColor   - HTML color name, 6-digit hex value ("RRGGBB")             (String)
;                                     or "" for default color
;                    If both BkColor and TextColor are "" the control will not be added and the call returns False.
;
;                    To change the colors for a registered control call
;                       CTLCOLORS.Change()
;                    passing up to three parameters:
;                       Hwnd        - see above
;                       BkColor     - see above
;                       ------------- Optional -------------------------------------------------------------------------
;                       TextColor   - see above
;                    Both BkColor and TextColor may be "" to reset them to default colors.
;                    If the control is not registered yet, CTLCOLORS.Attach() is called internally.
;
;                    To unregister a control from coloring call
;                       CTLCOLORS.Detach()
;                    passing one parameter:
;                       Hwnd      - see above
;
;                    To stop all coloring and free the resources call
;                       CTLCOLORS.Free()
;                    It's a good idea to insert this call into the scripts exit-routine.
;
;                    To check if a control is already registered call
;                       CTLCOLORS.IsAttached()
;                    passing one parameter:
;                       Hwnd      - see above
;
;                    To get a control's Hwnd use either the option "HwndOutputVar" with "Gui, Add" or the command
;                    "GuiControlGet" with sub-command "Hwnd".
;
;                    Properties/methods/functions declared as PRIVATE must not be set/called by the script!
;
; Special features:  On the first call for a specific control class the function registers the CTLCOLORS_OnMessage()
;                    function as message handler for WM_CTLCOLOR messages of this class(es).
;
;                    Buttons (Checkboxes and Radios) do not make use of the TextColor to draw the text, instead of
;                    that they use it to draw the focus rectangle.
;
;                    After displaying the GUI per "Gui, Show" you have to execute "WinSet, Redraw" once.
;                    It's no bad idea to do it using a GuiSize label, because it avoids rare problems when restoring
;                    a minimized window:
;                       GuiSize:
;                          If (A_EventInfo != 1) {
;                             Gui, %A_Gui%:+LastFound
;                             WinSet, ReDraw
;                          }
;                       Return
; ======================================================================================================================
; This software is provided 'as-is', without any express or implied warranty.
; In no event will the authors be held liable for any damages arising from the use of this software.
; ======================================================================================================================
Class CTLCOLORS {
   ; +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
   ; +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
   ; PRIVATE Properties and Methods ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
   ; +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
   ; +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
   ; Registered Controls
   Static Attached := {}
   ; OnMessage Handlers
   Static HandledMessages := {Edit: 0, ListBox: 0, Static: 0}
   ; Message Handler Function
   Static MessageHandler := "CTLCOLORS_OnMessage"
   ; Windows Messages
   Static WM_CTLCOLOR := {Edit: 0x0133, ListBox: 0x134, Static: 0x0138}
   ; HTML Colors (BGR)
   Static HTML := {AQUA:    0xFFFF00, BLACK:   0x000000, BLUE:    0xFF0000, FUCHSIA: 0xFF00FF, GRAY:    0x808080
                 , GREEN:   0x008000, LIME:    0x00FF00, MAROON:  0x000080, NAVY:    0x800000, OLIVE:   0x008080
                 , PURPLE:  0x800080, RED:     0x0000FF, SILVER:  0xC0C0C0, TEAL:    0x808000, WHITE:   0xFFFFFF
                 , YELLOW:  0x00FFFF}
   ; System Colors
   Static SYSCOLORS := {Edit: "", ListBox: "", Static: ""}
   Static Initialize := CTLCOLORS.InitClass()
   ; ===================================================================================================================
   ; PRIVATE SUBCLASS CTLCOLORS_Base  - Base class
   ; ===================================================================================================================
   Class CTLCOLORS_Base {
      __New() {   ; This class is a helper object, you must not instantiate it.
         Return False
      }
      __Delete() {
         This.Free()
      }
   }
   ; ===================================================================================================================
   ; PRIVATE METHOD Init  Class       - Set the base
   ; ===================================================================================================================
   InitClass() {
      This.Base := This.CTLCOLORS_Base
      Return "DONE"
   }
   ; ===================================================================================================================
   ; PRIVATE METHOD CheckColors       - Check parameters BkColor and TextColor not to be empty both
   ; ===================================================================================================================
   CheckColors(BkColor, TextColor) {
      This.ErrorMsg := ""
      If (BkColor = "") && (TextColor = "") {
         This.ErrorMsg := "Both parameters BkColor and TextColor are empty!"
         Return False
      }
      Return True
   }
   ; ===================================================================================================================
   ; PRIVATE METHOD CheckBkColor      - Check parameter BkColor
   ; ===================================================================================================================
   CheckBkColor(ByRef BkColor, Class) {
      This.ErrorMsg := ""
      If (BkColor != "") && !This.HTML.HasKey(BkColor) && !RegExMatch(BkColor, "i)^[0-9A-F]{6}$") {
         This.ErrorMsg := "Invalid parameter BkColor: " . BkColor
         Return False
      }
      BkColor := BkColor = "" ? This.SYSCOLORS[Class]
               : This.HTML.HasKey(BkColor) ? This.HTML[BkColor]
               : "0x" . SubStr(BkColor, 5, 2) . SubStr(BkColor, 3, 2) . SubStr(BkColor, 1, 2)
      Return True
   }
   ; ===================================================================================================================
   ; PRIVATE METHOD CheckTextColor    - Check parameter TextColor
   ; ===================================================================================================================
   CheckTextColor(ByRef TextColor) {
      This.ErrorMsg := ""
      If (TextColor != "") && !This.HTML.HasKey(TextColor) && !RegExMatch(TextColor, "i)^[\dA-F]{6}$") {
         This.ErrorMsg := "Invalid parameter TextColor: " . TextColor
         Return False
      }
      TextColor := TextColor = "" ? ""
                 : This.HTML.HasKey(TextColor) ? This.HTML[TextColor]
                 : "0x" . SubStr(TextColor, 5, 2) . SubStr(TextColor, 3, 2) . SubStr(TextColor, 1, 2)
      Return True
   }
   ; +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
   ; +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
   ; PUBLIC Interface ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
   ; +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
   ; +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
   ; Error message in case of errors
   Static ErrorMsg := ""
   ; ===================================================================================================================
   ; METHOD Attach         Register control for coloring
   ; Parameters:           Hwnd        - HWND of the GUI control                                   (Integer)
   ;                       BkColor     - HTML color name, 6-digit hex value ("RRGGBB")             (String)
   ;                                     or "" for default color
   ;                       ------------- Optional ----------------------------------------------------------------------
   ;                       TextColor   - HTML color name, 6-digit hex value ("RRGGBB")             (String)
   ;                                     or "" for default color
   ; Return values:        On success  - True
   ;                       On failure  - False, CTLCOLORS.ErrorMsg contains additional informations
   ; ===================================================================================================================
   Attach(Hwnd, BkColor, TextColor = "") {
      ; Names of supported classes
      Static ClassNames := {Button: "", ComboBox: "", Edit: "", ListBox: "", Static: ""}
      ; Button styles
      Static BS_CHECKBOX := 0x2
           , BS_RADIOBUTTON := 0x8
      ; Editstyles
      Static ES_READONLY := 0x800
      ; Default class background colors
      Static COLOR_3DFACE := 15
           , COLOR_WINDOW := 5
      ; Initialize default background colors on first call -------------------------------------------------------------
      If (This.SYSCOLORS.Edit = "") {
         This.SYSCOLORS.Static := DllCall("User32.dll\GetSysColor", "Int", COLOR_3DFACE, "UInt")
         This.SYSCOLORS.Edit := DllCall("User32.dll\GetSysColor", "Int", COLOR_WINDOW, "UInt")
         This.SYSCOLORS.ListBox := This.SYSCOLORS.Edit
      }
      ; Check Hwnd -----------------------------------------------------------------------------------------------------
      This.ErrorMsg := ""
      If !(CtrlHwnd := Hwnd + 0)
      Or !DllCall("User32.dll\IsWindow", "UPtr", Hwnd, "UInt") {
         This.ErrorMsg := "Invalid parameter Hwnd: " . Hwnd
         Return False
      }
      If This.Attached.HasKey(Hwnd) {
         This.ErrorMsg := "Control " . Hwnd . " is already registered!"
         Return False
      }
      Hwnds := [CtrlHwnd]
      ; Check control's class ------------------------------------------------------------------------------------------
      Classes := ""
      WinGetClass, CtrlClass, ahk_id %CtrlHwnd%
      This.ErrorMsg := "Unsupported control class: " . CtrlClass
      If !ClassNames.HasKey(CtrlClass)
         Return False
      ControlGet, CtrlStyle, Style, , , ahk_id %CtrlHwnd%
      If (CtrlClass = "Edit")
         Classes := ["Edit", "Static"]
      Else If (CtrlClass = "Button") {
         IF (CtrlStyle & BS_RADIOBUTTON) || (CtrlStyle & BS_CHECKBOX)
            Classes := ["Static"]
         Else
            Return False
      }
      Else If (CtrlClass = "ComboBox") {
         VarSetCapacity(CBBI, 40 + (A_PtrSize * 3), 0)
         NumPut(40 + (A_PtrSize * 3), CBBI, 0, "UInt")
         DllCall("User32.dll\GetComboBoxInfo", "Ptr", CtrlHwnd, "Ptr", &CBBI)
         Hwnds.Insert(NumGet(CBBI, 40 + (A_PtrSize * 2, "UPtr")) + 0)
         Hwnds.Insert(Numget(CBBI, 40 + A_PtrSize, "UPtr") + 0)
         Classes := ["Edit", "Static", "ListBox"]
      }
      If !IsObject(Classes)
         Classes := [CtrlClass]
      ; Check colors ---------------------------------------------------------------------------------------------------
      If !This.CheckColors(BkColor, TextColor)
         Return False
      ; Check background color -----------------------------------------------------------------------------------------
      If !This.CheckBkColor(BkColor, Classes[1])
         Return False
      ; Check text color -----------------------------------------------------------------------------------------------
      If !This.CheckTextColor(TextColor)
         Return False
      ; Activate message handling on the first call for a class --------------------------------------------------------
      For I, V In Classes {
         If (This.HandledMessages[V] = 0)
            OnMessage(This.WM_CTLCOLOR[V], This.MessageHandler)
         This.HandledMessages[V] += 1
      }
      ; Store values for Hwnd ------------------------------------------------------------------------------------------
      Brush := DllCall("Gdi32.dll\CreateSolidBrush", "UInt", BkColor, "UPtr")
      For I, V In Hwnds
         This.Attached[V] := {Brush: Brush, TextColor: TextColor, BkColor: BkColor, Classes: Classes, Hwnds: Hwnds}
      ; Redraw control -------------------------------------------------------------------------------------------------
      DllCall("User32.dll\InvalidateRect", "Ptr", Hwnd, "Ptr", 0, "Int", 1)
      This.ErrorMsg := ""
      Return True
   }
   ; ===================================================================================================================
   ; METHOD Change         Change control colors
   ; Parameters:           Hwnd        - HWND of the GUI control                                   (Integer)
   ;                       BkColor     - HTML color name, 6-digit hex value ("RRGGBB")             (String)
   ;                                     or "" for default color
   ;                       ------------- Optional ----------------------------------------------------------------------
   ;                       TextColor   - HTML color name, 6-digit hex value ("RRGGBB")             (String)
   ;                                     or "" for default color
   ; Return values:        On success  - True
   ;                       On failure  - False, CTLCOLORS.ErrorMsg contains additional informations
   ; Remarks:              If the control isn't registered yet, METHOD Add() is called instead internally.
   ; ===================================================================================================================
   Change(Hwnd, BkColor, TextColor = "") {
      ; Check Hwnd -----------------------------------------------------------------------------------------------------
      This.ErrorMsg := ""
      Hwnd += 0
      If !This.Attached.HasKey(Hwnd)
         Return This.Attach(Hwnd, BkColor, TextColor)
      CTL := This.Attached[Hwnd]
      ; Check BkColor --------------------------------------------------------------------------------------------------
      If !This.CheckBkColor(BkColor, CTL.Classes[1])
         Return False
      ; Check TextColor ------------------------------------------------------------------------------------------------
      If !This.CheckTextColor(TextColor)
         Return False
      ; Store Colors ---------------------------------------------------------------------------------------------------
      If (BkColor <> CTL.BkColor) {
         If (CTL.Brush) {
            DllCall("Gdi32.dll\DeleteObject", "Prt", CTL.Brush)
            This.Attached[Hwnd].Brush := 0
         }
         Brush := DllCall("Gdi32.dll\CreateSolidBrush", "UInt", BkColor, "UPtr")
         This.Attached[Hwnd].Brush := Brush
         This.Attached[Hwnd].BkColor := BkColor
      }
      This.Attached[Hwnd].TextColor := TextColor
      This.ErrorMsg := ""
      DllCall("User32.dll\InvalidateRect", "Ptr", Hwnd, "Ptr", 0, "Int", 1)
      Return True
   }
   ; ===================================================================================================================
   ; METHOD Detach         Stop control coloring
   ; Parameters:           Hwnd        - HWND of the GUI control                                   (Integer)
   ; Return values:        On success  - True
   ;                       On failure  - False, CTLCOLORS.ErrorMsg contains additional informations
   ; ===================================================================================================================
   Detach(Hwnd) {
      This.ErrorMsg := ""
      Hwnd += 0
      If This.Attached.HasKey(Hwnd) {
         CTL := This.Attached[Hwnd].Clone()
         If (CTL.Brush)
            DllCall("Gdi32.dll\DeleteObject", "Prt", CTL.Brush)
         For I, V In CTL.Classes {
            If This.HandledMessages[V] > 0 {
               This.HandledMessages[V] -= 1
               If This.HandledMessages[V] = 0
                  OnMessage(This.WM_CTLCOLOR[V], "")
         }  }
         For I, V In CTL.Hwnds
            This.Attached.Remove(V, "")
         DllCall("User32.dll\InvalidateRect", "Ptr", Hwnd, "Ptr", 0, "Int", 1)
         CTL := ""
         Return True
      }
      This.ErrorMsg := "Control " . Hwnd . " is not registered!"
      Return False
   }
   ; ===================================================================================================================
   ; METHOD Free           Stop coloring for all controls and free resources
   ; Return values:        Always True
   ; ===================================================================================================================
   Free() {
      For K, V In This.Attached
         DllCall("Gdi32.dll\DeleteObject", "Ptr", V.Brush)
      For K, V In This.HandledMessages
         If (V > 0) {
            OnMessage(This.WM_CTLCOLOR[K], "")
            This.HandledMessages[K] := 0
         }
      This.Attached := {}
      Return True
   }
   ; ===================================================================================================================
   ; METHOD IsAttached     Check if the control is registered for coloring
   ; Parameters:           Hwnd        - HWND of the GUI control                                   (Integer)
   ; Return values:        On success  - True
   ;                       On failure  - False
   ; ===================================================================================================================
   IsAttached(Hwnd) {
      Return This.Attached.HasKey(Hwnd)
   }
}
; ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
; ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
; PRIVATE Functions ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
; ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
; ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
; ======================================================================================================================
; PRIVATE FUNCTION CTLCOLORS_OnMessage
; This function is destined to handle CTLCOLOR messages. There's no reason to call it manually!
; ======================================================================================================================
CTLCOLORS_OnMessage(wParam, lParam) {
   Global CTLCOLORS
   Static SetTextColor := 0, SetBkColor := 0, Counter := 0
   Critical, 50
   If (SetTextColor = 0) {
      HM := DllCall("Kernel32.dll\GetModuleHandle", "Str", "Gdi32.dll", "UPtr")
      SetTextColor := DllCall("Kernel32.dll\GetProcAddress", "Ptr", HM, "AStr", "SetTextColor", "UPtr")
      SetBkColor := DllCall("Kernel32.dll\GetProcAddress", "Ptr", HM, "AStr", "SetBkColor", "UPtr")
   }
   Hwnd := lParam + 0, HDC := wParam + 0
   If CTLCOLORS.IsAttached(Hwnd) {
      CTL := CTLCOLORS.Attached[Hwnd]
      If (CTL.TextColor != "")
         DllCall(SetTextColor, "Ptr", HDC, "UInt", CTL.TextColor)
      DllCall(SetBkColor, "Ptr", HDC, "UInt", CTL.BkColor)
      Return CTL.Brush
   }
}

