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
  [[PBPebbleCentral defaultCentral] setAppUUID:[[NSUUID alloc] initWithUUIDString:WeChatBuddy_UUID_String]];
  [[PBPebbleCentral defaultCentral] run];
  
  return YES;
}

- (PBWatch *)getConnectedWatch {
  return self.watch;
}

- (void)pebbleCentral:(PBPebbleCentral*)central watchDidConnect:(PBWatch*)watch isNew:(BOOL)isNew {
  NSLog(@"Pebble connected: %@", [watch name]);
  self.watch = watch;
  
  if ([[PBPebbleCentral defaultCentral] isMobileAppInstalled]) {
    [self.watch appMessagesLaunch:^(PBWatch *watch, NSError *error) {
      if (!error) {
        NSLog(@"Successfully launched app.");
      }
      else {
        NSLog(@"Error launching app - Error: %@", error);
      }
    }
     ];
  }
}

- (void)pebbleCentral:(PBPebbleCentral*)central watchDidDisconnect:(PBWatch*)watch {
  NSLog(@"Pebble disconnected: %@", [watch name]);
  
  if (self.watch == watch || [watch isEqual:self.watch]) {
    self.watch = nil;
  }
}

@end
