//
//  PebbleImageTransmitterDelegate.h
//  WeChatBuddy
//
//  Created by Tyler Weimin Ouyang on 8/31/15.
//  Copyright (c) 2015 Tyler. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol PebbleImageTransmitterDelegate

@required
- (void)willStartTransmitting;
- (void)didTransmitNumberOfPackges:(unsigned int)numberOfPackages inTotal:(unsigned int)total;
- (void)didFailTransmitting;
- (void)didFinishTransmitting;

@end
