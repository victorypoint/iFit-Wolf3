:: iFit-Wolf3 - Autoincline control of treadmill via ADB and OCR
:: Author: Al Udell
:: Revised: April 22, 2023

:: Assumes treadmill USB Debugging is turned on 

@echo off

set /p TMIP="Enter treadmill IP address: "

ping %TMIP%
timeout 5

adb disconnect
adb kill-server
adb connect %TMIP%
adb devices -l

timeout 5


