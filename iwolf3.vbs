' iFit-Wolf3 - Autoincline control of treadmill via ADB and OCR
' Author: Al Udell
' Revised: April 22, 2023

'to debug - enable wscript.echo and run by cscript in command line
'on error resume next 

'display startup message
createobject("wscript.shell").popup "Ensure treadmill is in manual workout mode with onscreen speed and incline controls visible. " _
  & vbCrLf & vbCrLf & "Also ensure Zwift is running with incline showing.", 10, "Warning", 64

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
  cmdstring = "adb shell tail -n5000 " & infilename2 & " | grep -a ""Changed Grade""" & " | tail -n1 | grep -oE ""[^ ]+$"""
  'wscript.echo cmdstring 
  set oexec = wso.exec("cmd /c " & cmdstring)
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
    cmdString = "adb shell input swipe " & inclinex1 & " " & incliney1 & " " & inclinex1 & " " & incliney2 & " 200"  'simulate touch-swipe on incline slider
    set oexec = wso.exec("cmd /c" & cmdstring)  'execute adb command
    'wscript.echo cmdString 

    'report new incline and corresponding swipe
    'wscript.echo "New treadmill incline: " & formatnumber(nIncline,1) & " - " & cmdString
    wscript.echo "New treadmill incline: " & formatnumber(nIncline,1)

    'give treadmill time to adjust incline
    wscript.sleep 2000
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
  rConfidence = 0

  'is Zwift running?
  set objWMIService = GetObject("winmgmts:" _
    & "{impersonationLevel=impersonate}!\\" & strComputer & "\root\cimv2")
  set colProcessList = objWMIService.ExecQuery _
    ("Select Name from Win32_Process WHERE Name='" & FindProc & "'")

  if colProcessList.count>0 then
    'wscript.echo "Zwift is running..."

    'run python script - hide window, wait for completion
    wshShell.Run "process-image.py", 7, true
    'wscript.echo "Image processed..."

    'get incline from file
    set objFile = fso.GetFile(ocrOutput)
    'file not empty
    if objFile.Size > 0 then
      Set ocrfile = fso.OpenTextFile(ocrOutput,1)
      'process each line
      do Until ocrfile.AtEndOfStream
        str = ocrfile.ReadLine()
        'wscript.echo str

        'get incline
        quoteIndex1 = InStr(str, "'")
        quoteIndex2 = InStrRev(str, "'")
        valueSubstring = Mid(str, quoteIndex1 + 1, quoteIndex2 - quoteIndex1 - 1)
        sIncline = sIncline & valueSubstring

        'get recognition confidence
        commaIndex = InStrRev(str, ",")
        subString = Mid(str, commaIndex + 1, Len(str) - commaIndex - 2)
        subString = Trim(subString)
        rConfidence = FormatPercent(CDbl(subString), 0)

      loop 'each line

      'finalize incline value
      intValue = ""
      'isolate number
      for i = 1 To Len(sIncline)
        if IsNumeric(Mid(sIncline, i, 1)) then
          intValue = intValue & Mid(sIncline, i, 1)
        end if
      next
      'check for - sign
      for i = 1 To Len(sIncline)
        if Mid(sIncline, i, 1) = "-" then
          intValue = "-" & intValue
        end if
      next
      if intValue <> "" then
        GetZwiftIncline = formatnumber(cstr(intValue),1)
      end if
      ocrfile.Close

    end if 'file not empty

  end if 'zwift is running

  Set objWMIService = Nothing
  Set colProcessList = Nothing

End Function









