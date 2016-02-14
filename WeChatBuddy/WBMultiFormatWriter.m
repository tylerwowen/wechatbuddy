//
//  WBMultiFormatWriter.m
//  
//
//  Created by Tyler Weimin Ouyang on 2/13/16.
//
//

#import "WBMultiFormatWriter.h"
#import "WBQRCodeWriter.h"

@implementation WBMultiFormatWriter

- (ZXBitMatrix *)encode:(NSString *)contents format:(ZXBarcodeFormat)format width:(int)width height:(int)height hints:(ZXEncodeHints *)hints error:(NSError **)error {
  id<ZXWriter> writer;
  switch (format) {
    case kBarcodeFormatQRCode:
      writer = [[WBQRCodeWriter alloc] init];
      break;
      
    case kBarcodeFormatAztec:
      writer = [[ZXAztecWriter alloc] init];
      break;
      
    default:
      if (error) *error = [NSError errorWithDomain:ZXErrorDomain code:ZXWriterError userInfo:@{NSLocalizedDescriptionKey: @"No encoder available for format"}];
      return nil;
  }
  return [writer encode:contents format:format width:width height:height hints:hints error:error];
}

@end
