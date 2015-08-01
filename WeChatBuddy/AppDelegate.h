//
//  AppDelegate.h
//  WeChatBuddy
//
//  Created by Tyler Weimin Ouyang on 7/31/15.
//  Copyright (c) 2015 Tyler. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <PebbleKit/PebbleKit.h>

@interface AppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) UIWindow *window;

- (PBWatch *)getConnectedWatch;

@end

