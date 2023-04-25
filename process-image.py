# iFit-Wolf3 - Autoincline control of treadmill via ADB and OCR
# Author: Al Udell
# Revised: April 22, 2023

# process-image.py - take Zwift screenshot, crop incline, OCR incline

# imports
import cv2
import numpy as np
import win32gui
from paddleocr import PaddleOCR
from PIL import ImageGrab

# File paths
outfileName = 'zwift-crop.png'
ocrfileName = 'ocr-output.txt'

# Take Zwift screenshot
hwnd = win32gui.FindWindow(None,'Zwift') 
win32gui.SetForegroundWindow(hwnd)
img = ImageGrab.grab()

# Crop image to incline area
screenwidth, screenheight = img.size
col1 = int(screenwidth/3000 * 2800)
row1 = int(screenheight/2000 * 75)
row2 = int(screenheight/2000 * 200)
col2 = screenwidth
img = img.crop((col1,row1,col2,row2)).save(outfileName)

# Read image
image = cv2.imread(outfileName)

# Convert image to HSV
result = image.copy()
image = cv2.cvtColor(image, cv2.COLOR_BGR2HSV)

# Isolate white mask
lower = np.array([0,0,159])
upper = np.array([0,0,255])
mask0 = cv2.inRange(image, lower, upper)
result0 = cv2.bitwise_and(result, result, mask=mask0)

# Isolate yellow mask
lower = np.array([24,239,241])
upper = np.array([24,253,255])
mask1 = cv2.inRange(image, lower, upper)
result1 = cv2.bitwise_and(result, result, mask=mask1)

# Isolate orange mask
lower = np.array([8,191,243])
upper = np.array([8,192,243])
mask2 = cv2.inRange(image, lower, upper)
result2 = cv2.bitwise_and(result, result, mask=mask2)

# Isolate red mask
lower = np.array([0,255,255])
upper = np.array([10,255,255])
mask3 = cv2.inRange(image, lower, upper)
result3 = cv2.bitwise_and(result, result, mask=mask3)

# Join colour masks
mask = mask0+mask1+mask2+mask3

# Set output image to zero everywhere except mask
merge = image.copy()
merge[np.where(mask==0)] = 0

# Convert to grayscale
gray = cv2.cvtColor(merge, cv2.COLOR_BGR2GRAY)

# Convert to black/white by threshhold
ret,bin = cv2.threshold(gray,30,255,cv2.THRESH_BINARY)

# Closing
kernel = np.ones((3,3),np.uint8)
closing = cv2.morphologyEx(bin, cv2.MORPH_CLOSE, kernel)

# Invert black/white
inv = cv2.bitwise_not(closing)

# Apply average blur
averageBlur = cv2.blur(inv, (3, 3))

# Write image to png file
cv2.imwrite(outfileName, averageBlur, [cv2.IMWRITE_PNG_COMPRESSION, 0])

# OCR image
ocr = PaddleOCR(lang='en', use_gpu=False, show_log=False)
result = ocr.ocr(outfileName, cls=False)

for idx in range(len(result)):
  res = result[idx]
  with open(ocrfileName, 'w') as f:
    for line in res:
      #print(line)
      print(line, file=f)
