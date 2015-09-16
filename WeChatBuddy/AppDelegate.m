//
//  AppDelegate.m
//  WeChatBuddy
//
//  Created by Tyler Weimin Ouyang on 7/31/15.
//  Copyright (c) 2015 Tyler. All rights reserved.
//

#import "AppDelegate.h"

#import <PebbleKit/PebbleKit.h>

NSString * const WeChatBuddy_UUID_String = @"043fe8a1-70df-403b-a7bb-3338db1fa55f";

@interface AppDelegate () <PBPebbleCentralDelegate>

@property PBWatch *watch;

@end


@implementation AppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
  // Get Pebble events by setting this object as the delegate
  [[PBPebbleCentral defaultCentral] setDelegate:self];
  
  // Set watch property to the object representing the last connected watch
  self.watch = [[PBPebbleCentral defaultCentral] lastConnectedWatch];
  [self setAppUUID];
  
  return YES;
}

- (PBWatch *)getConnectedWatch {
  return self.watch;
}

- (void)pebbleCentral:(PBPebbleCentral*)central watchDidConnect:(PBWatch*)watch isNew:(BOOL)isNew {
  NSLog(@"Pebble connected: %@", [watch name]);
  self.watch = watch;
}

- (void)pebbleCentral:(PBPebbleCentral*)central watchDidDisconnect:(PBWatch*)watch {
  NSLog(@"Pebble disconnected: %@", [watch name]);
  
  if (self.watch == watch || [watch isEqual:self.watch]) {
    self.watch = nil;
  }
}

- (void)setAppUUID {
  
  uuid_t AppUUIDbytes;
  NSUUID *AppUUID = [[NSUUID alloc] initWithUUIDString:WeChatBuddy_UUID_String];
  [AppUUID getUUIDBytes:AppUUIDbytes];
  
  [[PBPebbleCentral defaultCentral] setAppUUID:[NSData dataWithBytes:AppUUIDbytes length:16]];
}

@end
