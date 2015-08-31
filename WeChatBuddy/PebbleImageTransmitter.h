//
//  PebbleImageTransmitter.h
//  WeChatBuddy
//
//  Created by Tyler Weimin Ouyang on 8/2/15.
//  Copyright (c) 2015 Tyler. All rights reserved.
//

@import UIKit;

#import <PebbleKit/PebbleKit.h>

@protocol PebbleImageTransmitterDelegate;

@interface PebbleImageTransmitter: NSObject

@property (weak) id <PebbleImageTransmitterDelegate> delegate;

- (void)sendBitmapToPebble:(PBBitmap*)bitmap;

@end
