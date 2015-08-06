//
//  AppDelegate.m
//  WeChatBuddy
//
//  Created by Tyler Weimin Ouyang on 7/31/15.
//  Copyright (c) 2015 Tyler. All rights reserved.
//

#import "AppDelegate.h"

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

- (void)applicationWillResignActive:(UIApplication *)application {
  // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
  // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application {
  // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
  // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application {
  // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
  // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application {
  // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
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