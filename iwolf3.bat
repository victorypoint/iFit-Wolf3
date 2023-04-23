:: iFit-Wolf3 - Autoincline control of treadmill via ADB and OCR
:: Author: Al Udell
:: Revised: April 22, 2023

@echo off

@pushd %~dp0
if NOT ["%errorlevel%"]==["0"] pause

cmd.exe /k cscript iwolf3.vbs

