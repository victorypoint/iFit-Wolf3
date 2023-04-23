# iFit-Wolf3
##Experimental iFit auto-incline control of treadmill via ADB and OCR

**Tested on the NordicTrack Commercial 2950 iFit Embedded Wifi Treadmill (2021 model)**

Building on my two initial iFit-Wolf repos and code at https://github.com/victorypoint/iFit-Wolf and https://github.com/victorypoint/iFit-Wolf2, this repo includes the capability to automatically control treadmill incline (auto-incline) from Zwift using OCR technology running on MS Windows. I've only tested this on the NordicTrack C2950 treadmill (2021 model). Refer to the previous iFit-Wolf and iFit-Wolf2 repos for technical details on how the treadmill incline is commmunicated and manually controlled via an ADB connection. The NT C2950 treadmills embedded iFit console runs Android (currently v9 on my model). Treadmill incline is controlled by moving it's on-screen incline slider control up and down.

Note: I have not included documentation here on how to configure the NT C2950 treadmill for ADB communication, but it involves accessing the machines "Privileged Mode", turning on "Developer Options" in Android settings, and enabling "USB Debugging" mode. Accessing Privileged Mode is well documented on many websites, dependent on the treadmill model, and version of Android and iFit.

### OCR Software Install and Setup:

Using Windows 10 or 11:

1. Install Python & PIP

- Download and install Python & PIP 3.10.11 - https://www.python.org/downloads/. Don’t install 3.11.x. It is not compatible with current OCR builds.
- Python installs to - \%USERPROFILE%\AppData\Local\Programs\Python\Python310
- During installation, select 'add python to path', and select default installation options
- After installation, ensure Python is added to Path environment
- Python directory to add: \%USERPROFILE%\AppData\Local\Programs\Python\Python310
- Confirm path: echo %path%
- Confirm Python version: python --version
- Confirm PIP version: pip -V
- Install OpenCV (cv2) if needed (PaddleOCR installer includes this): pip install opencv-python

2. Install PaddleOCR

- Github Repo - https://github.com/PaddlePaddle/PaddleOCR
- Install Paddlepaddle
  - For CPU: pip install paddlepaddle==2.4.2 -i https://pypi.tuna.tsinghua.edu.cn/simple
  - For nVidia GPU - pip install paddlepaddle-gpu -i https://pypi.tuna.tsinghua.edu.cn/simple
- Install PaddleOCR Whl Package: pip install "paddleocr>=2.0.1"
- Confirm PaddleOCR is working. It can be run from the command-line or in Python. Refer to: https://github.com/PaddlePaddle/PaddleOCR/blob/release/2.6/doc/doc_en/whl_en.md
- Command-line testing:
  - paddleocr --image_dir zwift-crop.png --lang en --use_gpu false --use_angle_cls false
  - paddleocr --image_dir zwift-crop.png --lang en --use_gpu false --use_angle_cls false --show_log false > incline.txt

### To Run iFit-Wolf3:

- This solution works on a Windows PC running this solution (iFit-Wolf3) and Zwift. Before running iFit-Wolf3:
  - Ensure tredmill is powered-up and connected to Windows PC via ADB connection. Run adb-connect.bat to establish an ADB connection to the treadmill via its IP address.
  - Ensure treadmill is in manual workout mode with onscreen speed and incline controls visible.
  - Ensure Zwift is launched in "Windowed mode" and is "in game". That is, your avatar is ready to run and Zwift incline is displayed in the upper-right area of the screen.

- Run iwolf3.bat. When executed, iFit-Wolf3 will:
  - Query the treadmill for it's current incline via ADB.
  - Query Zwift for it's current incline by taking a screenshot, and obtaining the incline value via OCR 
  - Set the treadmill incline to the Zwift incline value.

### Files included:
- **adb-connect.bat** (batch script to initiate an ADB connection with the treadmill. Enter the IP address of the treadmill)
- **iwolf3.vbs****** (VBscript script to communicate with treadmill, take screenshots of Zwift, and launch process-image.py script for OCR)
- **iwolf3.bat** (batch script to launch iwolf3.vbs)
- **process-image.py** (Python script to isolate incline area, OCR the incline value, and output OCR results to file ocr-output.txt)
- **adb.exe, AdbWinApi.dll, AdbWinUsbApi.dll, grep.exe, tail.exe, and nircmd.exe** (required support files)
- **zwift.png** (sample Zwift screenshot at 2560 x 1440 resolution)
- **adb-screenshot.bat** (batch script to take a screenshot of the treadmill screen if needed)
- **onscreen-controls.png** (example screenshot of NT C2950 screen with on-screen speed and incline controls)

ADB stands for Android Debug Bridge used by developers to connect their development computer with an Android device via a USB cable (and over Wifi in this case). If you don't have Android SDK installed on your PC, ADB may not be recognized. It's recommended you download the latest version.

![image](https://user-images.githubusercontent.com/63697253/233869227-bde59dc5-283e-45ba-ba16-2fb43af1d11a.png)
Figure 1: Zwift Screenshot

![image](https://user-images.githubusercontent.com/63697253/233869278-14649047-2a53-4c7a-8378-536ad78d3716.png)
Figure 2: Cropped and processed Zwift incline ready for OCR
