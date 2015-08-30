//
//  PebbleImageTransmitter.m
//  WeChatBuddy
//
//  Created by Tyler Weimin Ouyang on 8/2/15.
//  Copyright (c) 2015 Tyler. All rights reserved.
//

#import "AppDelegate.h"
#import "PebbleImageTransmitter.h"
#import "MainViewController.h"

/* The key used to transmit download data. Contains byte array. */
#define IOSDL_DATA @(100)
/* The key used to start a new image transmission. Contains uint32 size */
#define IOSDL_BEGIN @(101)
/* The key used to finalize an image transmission. Data not defined. */
#define IOSDL_END @(102)
/* The key used to tell the JS how big chunks should be */
#define IOSDL_CHUNK_SIZE @(103)
/* The key used to request a PBI */
#define IOSDL_URL @(104)

// TODO: Check if this can base on pebble modles
#define MAX_OUTGOING_SIZE 120

@interface PebbleImageTransmitter ()

@property (nonatomic) MainViewController *viewController;

@end

@implementation PebbleImageTransmitter {
  
  NSError *error;
  NSMutableArray *packages;
  PBWatch *watch;
  
  NSInteger currentIndex;
}

- (void)sendBitmapToPebble:(PBBitmap*)bitmap{
  
  self.viewController = (MainViewController *)[[[UIApplication sharedApplication].delegate window] rootViewController];
  
  if (!bitmap) {
   
    error = [NSError errorWithDomain:@"com.wechatbuddy" code:2101 userInfo:@{@2101:@"empty bitmap"}] ;
  }
  
  AppDelegate *delegate = [[UIApplication sharedApplication] delegate];
  watch = [delegate getConnectedWatch];
  
  packages = [[NSMutableArray alloc] init];
  currentIndex = 0;
  
  [self makeSmallPackages:bitmap];
  [self sendPackages];
}

#pragma mark - helpers

- (void)makeSmallPackages:(PBBitmap *)bitmap {
  
  size_t length = [bitmap.pixelData length];
  NSNumber *size = [NSNumber numberWithLong:length] ;
  
  [packages addObject:@{IOSDL_BEGIN: size}];
  
  for(size_t i = 0; i < length; i += MAX_OUTGOING_SIZE) {
    
    NSMutableData *outgoing = [[NSMutableData alloc] initWithCapacity:MAX_OUTGOING_SIZE];
    NSRange range = NSMakeRange(i, MIN(MAX_OUTGOING_SIZE, length - i));
    [outgoing appendData:[bitmap.pixelData subdataWithRange:range]];
    
    [packages addObject:@{IOSDL_DATA: outgoing}];
  }
  
  [packages addObject:@{IOSDL_END: @""}];
}


- (void)sendPackages {
  
  [self.viewController showProgress];
  [self.viewController setStatusLabelToInProgress];
  [self.viewController setPercentageWithTransferedPacakges:0 total:(unsigned int)[packages count]];
  
  [watch appMessagesPushUpdate:[packages objectAtIndex:currentIndex] onSent:^(PBWatch *watch, NSDictionary *update, NSError *apmerror) {
    
    if (!apmerror) {
      
      if (currentIndex < [packages count] - 1) {
        
        currentIndex++;
        [self.viewController setPercentageWithTransferedPacakges:(unsigned int)currentIndex total:(unsigned int)[packages count]];
        [self recursivelySendAppMessage];
      }
    }
    else {
      NSLog(@"Error sending message at index: %ld", (long)currentIndex);
      [self.viewController setStatusLabelToFail];
      error = apmerror;
    }
  }];
}

- (void)recursivelySendAppMessage {
  
  [watch appMessagesPushUpdate:[packages objectAtIndex:currentIndex] onSent:^(PBWatch *watch, NSDictionary *update, NSError *apmerror) {
    
    if (!apmerror) {
      NSLog(@"Successfully sent message no.%ld", (long)currentIndex);
      if (currentIndex < [packages count] - 1) {
        
        currentIndex++;
        [self.viewController setPercentageWithTransferedPacakges:(unsigned int)currentIndex total:(unsigned int)[packages count]];
        [self recursivelySendAppMessage];
      }
      else{
        [self.viewController setPercentageWithTransferedPacakges:1 total:1];
        [self.viewController setStatusLabelToSuccess];
        packages = nil;
        self.viewController = nil;
      }
    }
    else {
      NSLog(@"Error sending message at index: %ld", (long)currentIndex);
      [self.viewController setStatusLabelToFail];
      packages = nil;
      self.viewController = nil;
      return;
    }
  }];
}



@end
