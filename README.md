# iFit-Wolf3
Experimental iFit auto-incline control of treadmill via ADB and OCR

### Tested on the NordicTrack Commercial 2950 iFit Embedded Wifi Treadmill (2021 model)

Building on the initial iFit-Wolf repo and code at https://github.com/victorypoint/iFit-Wolf, this update includes the capability to control the treadmill speed and incline. I've only tested this on the NordicTrack C2950 treadmill (2021 model). Refer to the iFit-Wolf repo for technical details on how the treadmill records individual workouts to a local text log in a sequential streaming format. The NT C2950 treadmills embedded iFit console runs Android (currently v9 on my model). 

Building on the previous iFit-Wolf Windows VBscript code which displays the real-time speed and inclination values, this update includes functions to control the treadmill speed and incline by moving it's on-screen speed and incline slider controls up and down. The VBscript assumes an ADB connection has already been established with the treadmill, and proceeds to communicate speed and incline information over ADB.

I've not included documentation here on how to configure the NT C2950 treadmill for ADB communication, but it involves accessing the machines “Privileged Mode”, turning on “Developer Options” in Android settings, and enabling “USB Debugging” mode. Accessing Privileged Mode is well documented on many websites, dependent on the treadmill model, and version of Android and iFit.

Files included:
- adb-connect.bat (batch script to initiate an ADB connection with the treadmill – change the IP to that of the treadmill)
- iwolf2.vbs (VBscript)
- iwolf.bat (commands to launch VBscript in CScript window)
- adb-screenshot.bat (batch script to take a screenshot of the treadmill screen)
- onscreen-controls.png (example screenshot of NT C2950 screen with on-screen speed and incline controls)
- adb.exe, AdbWinApi.dll, AdbWinUsbApi.dll, grep.exe, tail.exe (required support files)

ADB stands for Android Debug Bridge used by developers to connect their development computer with an Android device via a USB cable (and over Wifi in this case). If you don't have Android SDK installed on your PC, ADB may not be recognized. It's recommended you download the latest version.

### Methodology for determining values for the on-screen speed and incline control calculations:

- NordicTrack C2950 tablet screen is 1920 x 1080 (1080p HD)
     
- Get distances and dimensions in pixels from tablet screenshot showing manual workout with onscreen controls
  - 1845 - x pixel position of middle of speed slider
  - 75 - x pixel position of middle of incline slider
  - 803 - y pixel position of bottom of sliders - this is anchor for Y pixel calculations
  - Incline slider range - bottom - 803,  top - 248
  - Speed slider range - bottom - 803, top - 248
  - Y = 803 - 248 = 555 pixels
  - For speed range of 1.0 - 19.0 = 18
  - 555 pixels / 18 speed range = 30.83 pixels / 1 speed
  - For incline range of -3 - 15 = 18
  - 555 pixels / 18 incline range = 30.83 pixels / 1 incline
       
- Document equations to calculate speed and incline slider vertical positions
   
  - Speed slider
    - Speed scale factor - (BottomY - TopY) / speed range = 555 / 18 = 30.83
    - Step 1: get speed slider position from current speed - SpeedY = BottomY - round((current speed - 1) * 30.83)
    - Step 2: set new slider position from new speed - SpeedY2 = speedY - round((newspeed - current speed) * 30.83)
    - Important - by trial and error I found the speed scale factor had to be adjusted to 31.0 for my machine
    - Round current and target speeds to 1 decimal 
    - The swipe is then - Input swipe 1845 speedY 1845 speedY2
       
  - Incline slider
    - Inclination scale factor - (BottomY - TopY) / incline range = 555 / 18 = 30.83
    - Important - by trial and error I found the incline scale factor had to be adjusted to 31.1 for my machine
