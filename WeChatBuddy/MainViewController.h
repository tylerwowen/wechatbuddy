//
//  ViewController.h
//  WeChatBuddy
//
//  Created by Tyler Weimin Ouyang on 7/31/15.
//  Copyright (c) 2015 Tyler. All rights reserved.
//

@import UIKit;

@interface MainViewController : UIViewController <UINavigationControllerDelegate, UIImagePickerControllerDelegate>

@property (nonatomic, weak) IBOutlet UILabel *progressLabel;
@property (nonatomic, weak) IBOutlet UIProgressView *progressView;

- (void)hideProgress;
- (void)showProgress;
- (void)setPercentageWithTransferedPacakges:(unsigned int)transfered total:(unsigned int)total;

@end

