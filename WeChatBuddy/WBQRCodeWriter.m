//
//  WBQRCodeWriter.h
//  WeChatBuddy
//
//  Created by Tyler Weimin Ouyang on 8/2/15.
//  Copyright (c) 2015 Tyler. All rights reserved.
//

#import "WBQRCodeWriter.h"

#import <ZXingObjC/ZXBitMatrix.h>
#import <ZXingObjC/ZXByteMatrix.h>
#import <ZXingObjC/ZXQRCode.h>


@implementation WBQRCodeWriter

- (ZXBitMatrix *)renderResult:(ZXQRCode *)code width:(int)width height:(int)height quietZone:(int)quietZone {
  ZXByteMatrix *input = code.matrix;
  if (input == nil) {
    return nil;
  }
  int inputWidth = input.width;
  int inputHeight = input.height;
  int qrWidth = inputWidth;
  int qrHeight = inputHeight;
  int outputWidth = MAX(width, qrWidth);
  int outputHeight = MAX(height, qrHeight);
  
  int multiple = MIN(outputWidth / qrWidth, outputHeight / qrHeight);
  // Padding includes both the quiet zone and the extra white pixels to accommodate the requested
  // dimensions. For example, if input is 25x25 the QR will be 33x33 including the quiet zone.
  // If the requested size is 200x160, the multiple will be 4, for a QR of 132x132. These will
  // handle all the padding from 100x100 (the actual QR) up to 200x160.
  int leftPadding = (outputWidth - (inputWidth * multiple)) / 2;
  int topPadding = (outputHeight - (inputHeight * multiple)) / 2;
  
  ZXBitMatrix *output = [[ZXBitMatrix alloc] initWithWidth:outputWidth height:outputHeight];
  
  for (int inputY = 0, outputY = topPadding; inputY < inputHeight; inputY++, outputY += multiple) {
    for (int inputX = 0, outputX = leftPadding; inputX < inputWidth; inputX++, outputX += multiple) {
      if ([input getX:inputX y:inputY] == 1) {
        [output setRegionAtLeft:outputX top:outputY width:multiple height:multiple];
      }
    }
  }
  
  return output;
}


@end
