//
//  MainViewController.m
//  WeChatBuddy
//
//  Created by Tyler Weimin Ouyang on 7/31/15.
//  Copyright (c) 2015 Tyler. All rights reserved.
//

#import "MainViewController.h"

#import "AppDelegate.h"
#import "GradientBackgroundSetter.h"
#import "PebbleImageTransmitter.h"
#import "QRCodeRegenerator.h"

@interface MainViewController ()

@property (nonatomic, weak) IBOutlet UIImageView *imageView;
@property (nonatomic, weak) IBOutlet UILabel *statusLabel;
@property (nonatomic, weak) IBOutlet UIToolbar *toolBar;

@property (nonatomic) UIImagePickerController *imagePickerController;
@property (nonatomic) UIImage *QRCode;
@property (nonatomic) PBBitmap *bitmap;
@property (nonatomic) float percentage;

@property PBWatch *watch;

@end

@implementation MainViewController

NSString * const WatchAppDeepLink = @"pebble://appstore/55c712656b4abe9e19000069";
NSString * const PebbleAppStoreLink = @"itms-apps://geo.itunes.apple.com/us/app/pebble-smartwatch/id592012721?mt=8";

- (void)viewDidLoad {
  [super viewDidLoad];
  
  // Appearance
  [GradientBackgroundSetter setBackgrooundColorForView:self.view];
  
  // Get reference to watch
  AppDelegate *delegate = [[UIApplication sharedApplication] delegate];
  self.watch = [delegate getConnectedWatch];
  
  if (![UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]) {
    // There is not a camera on this device, so don't show the camera button.
    NSMutableArray *toolbarItems = [self.toolBar.items mutableCopy];
    [toolbarItems removeObjectAtIndex:2];
    [self.toolBar setItems:toolbarItems animated:NO];
  }
  
  // Progress
  self.percentage = 0;
  
}

- (void)viewWillAppear:(BOOL)animated {
  [super viewWillAppear:YES];
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

- (IBAction)showImagePickerForCamera:(id)sender {
  [self showImagePickerForSourceType:UIImagePickerControllerSourceTypeCamera];
}


- (IBAction)showImagePickerForPhotoPicker:(id)sender {
  [self showImagePickerForSourceType:UIImagePickerControllerSourceTypePhotoLibrary];
}


- (void)showImagePickerForSourceType:(UIImagePickerControllerSourceType)sourceType {
  if (self.imageView.isAnimating) {
    [self.imageView stopAnimating];
  }
  
  UIImagePickerController *imagePickerController = [[UIImagePickerController alloc] init];
  imagePickerController.modalPresentationStyle = UIModalPresentationCurrentContext;
  imagePickerController.sourceType = sourceType;
  imagePickerController.delegate = self;
  
  self.imagePickerController = imagePickerController;
  [self presentViewController:self.imagePickerController animated:YES completion:nil];
}

#pragma mark - UIImagePickerControllerDelegate

// This method is called when an image has been chosen from the library or taken from the camera.
- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info {
  
  UIImage *image = [info valueForKey:UIImagePickerControllerOriginalImage];
  // Resize it in order to be processed by ZXing
  self.QRCode = [self imageWithImage:image scaledToSize:CGSizeMake(480.0, 640.0)];
  
  [self finishAndUpdate];
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker {
  [self dismissViewControllerAnimated:YES completion:NULL];
}

- (UIImage *)imageWithImage:(UIImage *)image scaledToSize:(CGSize)newSize {
  
  UIGraphicsBeginImageContextWithOptions(newSize, NO, 1.0);
  [image drawInRect:CGRectMake(0, 0, newSize.width, newSize.height)];
  UIImage *newImage = UIGraphicsGetImageFromCurrentImageContext();
  UIGraphicsEndImageContext();
  return newImage;
}

- (void)finishAndUpdate {
  [self dismissViewControllerAnimated:YES completion:NULL];
  
  if (self.QRCode) {
    
    [self processImage];
    [self.imageView setImage:self.QRCode];
  }
  
  self.imagePickerController = nil;
}

#pragma mark - Process Image

- (void)processImage {
  
  QRCodeRegenerator *processor = [[QRCodeRegenerator alloc]init];
  self.QRCode= [processor regenerateQRCodeWithUIImage:self.QRCode];
  
  if (self.QRCode) {
    [self generateBitmap];
    [self sendBitmapToPebble];
  }
  else {
    self.statusLabel.text = NSLocalizedString(@"Oops, unable to find a QR code😅", @"Error info when QR code is not found in image");
  }
}

- (void)generateBitmap {
  self.bitmap = [PBBitmap pebbleBitmapWithUIImage:self.QRCode];
}

#pragma mark - Pebble App Message

- (void)sendBitmapToPebble {
  
  PebbleImageTransmitter *transmitter = [[PebbleImageTransmitter alloc]init];
  transmitter.delegate = self;
  [transmitter sendBitmapToPebble:self.bitmap];
}

#pragma mark - Pebble Transmitter Delegate

- (void)willStartTransmitting {
  [self showProgress];
  [self setStatusLabelToInProgress];
  [self setPercentageWithTransferedPacakges:0 total:1];
}

- (void)didTransmitNumberOfPackges:(unsigned int)numberOfPackages inTotal:(unsigned int)total {
  [self setPercentageWithTransferedPacakges:numberOfPackages total:total];
}

- (void)didFailTransmitting {
  [self setStatusLabelToFail];
}

- (void)didFinishTransmitting {
  [self setPercentageWithTransferedPacakges:1 total:1];
  [self setStatusLabelToSuccess];
  [self hideProgress];
}

- (void)setPercentageWithTransferedPacakges:(unsigned int)transfered total:(unsigned int)total {
  
  self.percentage = (float)transfered / (float)total;
  BOOL animated = self.percentage != 0;
  
  [self.progressView setProgress:self.percentage animated:animated];
  self.progressLabel.text = [NSString stringWithFormat:@"%d%%", (int)(self.percentage * 100)];
}

- (void)hideProgress {
  
  self.progressView.hidden = YES;
  self.progressLabel.hidden = YES;
}

- (void)showProgress {
  
  self.progressView.hidden = NO;
  self.progressLabel.hidden = NO;
}

#pragma mark - Unwind

- (IBAction)unwindToMain:(UIStoryboardSegue*)sender {
  
}

#pragma mark - Status
- (void)setStatusLabelToSuccess {
  self.statusLabel.text = NSLocalizedString(@"Success! Now you can use you Pebble App only😁", @"Success text");
}

- (void)setStatusLabelToFail {
  self.statusLabel.text = NSLocalizedString(@"Failed to send the QR code. Please try again😅", @"Failure text");
}

- (void)setStatusLabelToInProgress {
  self.statusLabel.text = NSLocalizedString(@"Sending...", @"Sending text");
}

#pragma mark - Get WatchApp
- (IBAction)getPebbleWatchAppButton:(UIButton *)sender {
  NSURL *pebbleURL = [NSURL URLWithString:WatchAppDeepLink];
  if ([[UIApplication sharedApplication] canOpenURL:pebbleURL]) {
    [[UIApplication sharedApplication] openURL:pebbleURL];
  }
  else {
    [self showAlert];
  }
}

- (void)showAlert {
  UIAlertController* alert = [UIAlertController alertControllerWithTitle:@"Pebble App Not Found"
                                                                 message:@"Do you want to download the Pebble App from App Store?"
                                                          preferredStyle:UIAlertControllerStyleAlert];
  
  UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"No, thanks"
                                                         style:UIAlertActionStyleCancel
                                                       handler:nil];
  
  UIAlertAction* defaultAction = [UIAlertAction actionWithTitle:@"Yes"
                                                          style:UIAlertActionStyleDefault
                                                        handler:^(UIAlertAction * action) {
                                                          NSURL *storeURL = [NSURL URLWithString:PebbleAppStoreLink];
                                                          [[UIApplication sharedApplication] openURL:storeURL];
                                                        }];
  
  [alert addAction:defaultAction];
  [alert addAction:cancelAction];
  [self presentViewController:alert animated:YES completion:nil];
}


@end

