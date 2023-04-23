# iFit-Wolf3 - Autoincline control of treadmill via ADB and OCR
# Author: Al Udell
# Revised: April 22, 2023

# process-image.py - Get Zwift screenshot, crop incline, OCR incline

# imports
import cv2
import numpy as np
from paddleocr import PaddleOCR

# image path
infileName = 'zwift.png'
outfileName = 'zwift-crop.png'
ocrfileName = 'ocr-output.txt'

# Read image
zwiftImage = cv2.imread(infileName)

# Crop image to incline area (don't crop without % symbol - gives worse OCR results)
# format: [start_row:end_row, start_col:end_col]
# newcol = screenwidth/3000 * oldcol
# newrow = screenheight/2000 * oldrow
image = zwiftImage[75:200, 2800:3000]  #surface pc 3000x2000
#image = zwiftImage[54:144, 2389:2560]  #zwift pc 2560x1440

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
      print(line, file=f)
