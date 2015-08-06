//
//  QRCodeRegenerator.m
//  WeChatBuddy
//
//  Created by Tyler Weimin Ouyang on 8/2/15.
//  Copyright (c) 2015 Tyler. All rights reserved.
//

#import "QRCodeRegenerator.h"

#import <ZXingObjC/ZXingObjCQRCode.h>

@interface QRCodeRegenerator ()

@property (nonatomic) UIImage *image;
@property (nonatomic) NSString *data;

@end

@implementation QRCodeRegenerator

- (UIImage*)regenerateQRCodeWithUIImage:(UIImage*)inputIMG {
  
  self.image = inputIMG;
  [self decodeOriginalImage];
  [self encodeQRCode];
  
  return self.image;
}

- (void)decodeOriginalImage {
  
  CGImageRef imageToDecode = self.image.CGImage;  // Given a CGImage in which we are looking for barcodes
  
  ZXLuminanceSource *source = [[ZXCGImageLuminanceSource alloc] initWithCGImage:imageToDecode];
  ZXBinaryBitmap *bitmap = [ZXBinaryBitmap binaryBitmapWithBinarizer:[ZXHybridBinarizer binarizerWithSource:source]];
  
  NSError *error = nil;
  
  ZXQRCodeReader *reader = [[ZXQRCodeReader alloc] init];
  
  ZXResult *result = [reader decode:bitmap
                              hints:nil
                              error:&error];
  if (result) {
    // The coded result as a string. The raw data can be accessed with
    // result.rawBytes and result.length.
    self.data = result.text;
  } else {
    // Use error to determine why we didn't get a result, such as a barcode
    // not being found, an invalid checksum, or a format inconsistency.
    NSLog(@"unable to decode: %@", error);
  }
}

- (void)encodeQRCode {
  
  if (!_data) {
    self.image = nil;
    return;
  }
  
  NSError *error = nil;
  
  ZXQRCodeWriter *writer = [[ZXQRCodeWriter alloc] init];
  ZXBitMatrix *result = [writer encode:_data
                                format:kBarcodeFormatQRCode
                                 width:116
                                height:116
                                 error:&error];
  
  if (result) {
    ZXImage *image = [ZXImage imageWithMatrix:result];
    self.image = [UIImage imageWithCGImage:image.cgimage];
  } else {
    self.image = nil;
    NSLog(@"Encode failed: %@", error);
  }

}

@end
