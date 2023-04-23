:: iFit-Wolf3 - Autoincline control of treadmill via ADB and OCR
:: Author: Al Udell
:: Revised: April 22, 2023

:: Assumes android treadmill usb debugging is turned on 

@echo off

set SAVESTAMP=%DATE:/=-%@%TIME::=-%
set SAVESTAMP=%SAVESTAMP: =%

adb shell screencap -p /sdcard/%SAVESTAMP%.png

adb pull /sdcard/%SAVESTAMP%.png
adb shell rm /sdcard/%SAVESTAMP%.png
