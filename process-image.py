# iFit-Wolf3 - Autoincline control of treadmill via ADB and OCR
# Author: Al Udell
# Revised: April 22, 2023

# process-image.py - take Zwift screenshot, crop incline, OCR incline

# imports
import cv2
import numpy as np
import win32gui
from paddleocr import PaddleOCR
from PIL import Image, ImageGrab

# File paths
outfileName = 'zwift-crop.png'
ocrfileName = 'ocr-output.txt'

# Take Zwift screenshot
hwnd = win32gui.FindWindow(None,'Zwift') 
win32gui.SetForegroundWindow(hwnd)
screenshot = ImageGrab.grab()
#cropped_cv2.show()

# Convert screenshot to a numpy array
screenshot_np = np.array(screenshot)

# Crop image to incline area (don't crop without % symbol - gives worse OCR results)
screenwidth, screenheight = screenshot.size
col1 = int(screenwidth/3000 * 2800)
row1 = int(screenheight/2000 * 75)
row2 = int(screenheight/2000 * 200)
col2 = screenwidth
screenshot_np = screenshot_np[row1:row2, col1:col2]

# Convert numpy array to PIL image
screenshot_pil = Image.fromarray(screenshot_np)

# Convert PIL Image to a cv2 image
cropped_cv2 = cv2.cvtColor(np.array(screenshot_pil), cv2.COLOR_RGB2BGR)
#cropped_cv2.show()

# Convert cv2 image to HSV
result = cropped_cv2.copy()
image = cv2.cvtColor(cropped_cv2, cv2.COLOR_BGR2HSV)

# Isolate white mask
lower = np.array([0,0,159])
upper = np.array([0,0,255])
mask0 = cv2.inRange(image, lower, upper)
result0 = cv2.bitwise_and(result, result, mask=mask0)
#result0.show()

# Isolate yellow mask
lower = np.array([24,239,241])
upper = np.array([24,253,255])
mask1 = cv2.inRange(image, lower, upper)
result1 = cv2.bitwise_and(result, result, mask=mask1)
#result1.show()

# Isolate orange mask
lower = np.array([8,191,243])
upper = np.array([8,192,243])
mask2 = cv2.inRange(image, lower, upper)
result2 = cv2.bitwise_and(result, result, mask=mask2)
#result2.show()

# Isolate red mask
lower = np.array([0,255,255])
upper = np.array([10,255,255])
mask3 = cv2.inRange(image, lower, upper)
result3 = cv2.bitwise_and(result, result, mask=mask3)
#result3.show()

# Join colour masks
mask = mask0+mask1+mask2+mask3

# Set output image to zero everywhere except mask
merge = image.copy()
merge[np.where(mask==0)] = 0

# Convert to grayscale
gray = cv2.cvtColor(merge, cv2.COLOR_BGR2GRAY)
#gray.show()

# Convert to black/white by threshhold
ret,bin = cv2.threshold(gray,30,255,cv2.THRESH_BINARY)
#bin.show()

# Closing
kernel = np.ones((3,3),np.uint8)
closing = cv2.morphologyEx(bin, cv2.MORPH_CLOSE, kernel)

# Invert black/white
inv = cv2.bitwise_not(closing)
#inv.show()

# Apply average blur
averageBlur = cv2.blur(inv, (3, 3))
#averageBlur.show()

# Write image to png file
cv2.imwrite(outfileName, averageBlur, [cv2.IMWRITE_PNG_COMPRESSION, 0])

# OCR image
ocr = PaddleOCR(lang='en', use_gpu=False, show_log=False)
result = ocr.ocr(outfileName, cls=False)
#print(result)

# Extract OCR text
ocr_text = ''
for line in result:
    for word in line:
        ocr_text += f"{word[1][0]}"
    #ocr_text += '\n'
#print(ocr_text)

# Write OCR text to file
with open(ocrfileName, 'w') as f:
    f.write(ocr_text)


