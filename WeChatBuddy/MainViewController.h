//
//  MainViewController.h
//  WeChatBuddy
//
//  Created by Tyler Weimin Ouyang on 7/31/15.
//  Copyright (c) 2015 Tyler. All rights reserved.
//
@import UIKit;

#import "PebbleImageTransmitterDelegate.h"

@interface MainViewController : UIViewController <UINavigationControllerDelegate, UIImagePickerControllerDelegate, PebbleImageTransmitterDelegate>

@property (nonatomic, weak) IBOutlet UILabel *progressLabel;
@property (nonatomic, weak) IBOutlet UIProgressView *progressView;

@end

