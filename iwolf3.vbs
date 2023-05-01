' iFit-Wolf3 - Autoincline control of treadmill via ADB and OCR
' Author: Al Udell
' Revised: April 22, 2023

'to debug - enable wscript.echo and run by cscript in command line
'on error resume next 

'display startup message
createobject("wscript.shell").popup "Ensure treadmill is in manual workout mode with onscreen speed and incline controls visible. " _
  & vbCrLf & vbCrLf & "Also ensure Zwift is running in game with incline showing.", 10, "Warning", 64

'initialize
set wso = createobject("wscript.shell")

'treadmill tablet coordinates (ifit manual workout)
inclinex1 = 75	   'x pixel position of middle of incline slider
bottomy = 807        'y pixel position of bottom of sliders
inclinescale = 31.1  'pixel scaling factor

'construct todays wolflog filename
dy = right(string(2,"0") & day(now), 2)
mo = right(string(2,"0") & month(now), 2)
yr = year(now)
infilename = yr & "-" & mo & "-" & dy & "_logs.txt"
infilename2 = "/sdcard/.wolflogs/" & infilename
'wscript.echo infilename2

'loop - process wolflog and Zwift screenshot
Do

  'query treadmill for incline
  cmdString = "cmd /c adb shell tail -n5000 " & infilename2 & " | grep -a ""Changed Grade""" & " | tail -n1 | grep -oE ""[^ ]+$"""
  'wscript.echo cmdString 
  'use synchronous Exec
  set oexec = wso.exec(cmdString)
  'wait for completion
  Do While oexec.Status = 0
    wscript.sleep 100
  Loop
  sValue = oexec.stdout.readline
  if sValue <> "" then
    sValue = formatnumber(csng(sValue),1)
    cIncline = sValue
    wscript.echo "Treadmill incline: " & cIncline
  else
    wscript.echo "Waiting for treadmill to come online..."
  end if

  'query Zwift for incline
  nIncline = GetZwiftIncline
  If IsEmpty(nIncline) Then 
    wscript.echo "Waiting for Zwift to come online..."
  Else
    wscript.echo "Zwift incline: " & nIncline

    'correct incline value for treadmill 
    if nIncline < -3 then nIncline = -3
    if nIncline > 15 then nIncline = 15

    'get y pixel position of incline slider from current incline
    incliney1 = bottomy - Round((cIncline + 3.0) * inclinescale)

    'set incline slider to target position
    incliney2 = incliney1 - Round((nIncline - cIncline) * inclinescale)  'calculate vertical pixel position for new incline 
    cmdString = "cmd /c adb shell input swipe " & inclinex1 & " " & incliney1 & " " & inclinex1 & " " & incliney2 & " 200"  'simulate touch-swipe on incline slider
    'wscript.echo cmdString 
    'use synchronous Exec
    set oexec = wso.exec(cmdString)
    'wait for completion
    Do While oexec.Status = 0
      wscript.sleep 100
    Loop

    'report new incline and corresponding swipe
    'wscript.echo "New treadmill incline: " & formatnumber(nIncline,1) & " - " & cmdString
    wscript.echo "New treadmill incline: " & formatnumber(nIncline,1)

    'give treadmill time to adjust incline
    'wscript.sleep 2000
  End If
  wscript.echo 

Loop 'process wolflog and Zwift screenshot

'--- Functions ---

Function GetZwiftIncline

  'take a screenshot of Zwift, save it to disk, then OCR image for incline
  set wshShell = WScript.CreateObject("WScript.Shell")
  set fso = WScript.CreateObject("Scripting.FileSystemObject")
  strComputer = "."
  FindProc = "zwiftapp.exe"
  ocrOutput = "ocr-output.txt"
  sIncline = ""

  'is Zwift running?
  set objWMIService = GetObject("winmgmts:" _
    & "{impersonationLevel=impersonate}!\\" & strComputer & "\root\cimv2")
  set colProcessList = objWMIService.ExecQuery _
    ("Select Name from Win32_Process WHERE Name='" & FindProc & "'")

  if colProcessList.count > 0 then
    'wscript.echo "Zwift is running..."

    'use synchronous Exec
    cmdString = "cmd /c python process-image.py"
    set oexec = wshShell.exec(cmdString)
    'wait for completion
    Do While oexec.Status = 0
      wscript.sleep 100
    Loop
    'wscript.echo "Image processed..."

    'get incline from file
    set objFile = fso.GetFile(ocrOutput)

    'file not empty
    if objFile.Size > 0 then
      Set ocrfile = fso.OpenTextFile(ocrOutput,1)
      sIncline = ocrfile.ReadLine()        
      'wscript.echo sIncline

      'string not empty (failed OCR)
      if sIncline <> "" then
        GetZwiftIncline = formatnumber(cstr(sIncline),1)
      end if

    end if 'file not empty
  end if 'zwift is running

  Set objWMIService = Nothing
  Set colProcessList = Nothing

End Function









