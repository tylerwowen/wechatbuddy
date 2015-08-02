//
//  ViewController.m
//  WeChatBuddy
//
//  Created by Tyler Weimin Ouyang on 7/31/15.
//  Copyright (c) 2015 Tyler. All rights reserved.
//

#import "AppDelegate.h"
#import "QRCodeRegenerator.h"
#import "ViewController.h"

//NSNumber *keyData = @(5);

@interface ViewController ()

@property (nonatomic, weak) IBOutlet UIImageView *imageView;
@property (nonatomic, weak) IBOutlet UILabel *statusLabel;
@property (nonatomic, weak) IBOutlet UIToolbar *toolBar;

@property (nonatomic) UIImagePickerController *imagePickerController;
@property (nonatomic) UIImage *QRCode;
@property (nonatomic) PBBitmap *bitmap;

@property PBWatch *watch;

@end

@implementation ViewController

- (void)viewDidLoad {
  [super viewDidLoad];
  
  // Get reference to watch
  AppDelegate *delegate = [[UIApplication sharedApplication] delegate];
  self.watch = [delegate getConnectedWatch];
  
  if (![UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]) {
    // There is not a camera on this device, so don't show the camera button.
    NSMutableArray *toolbarItems = [self.toolBar.items mutableCopy];
    [toolbarItems removeObjectAtIndex:2];
    [self.toolBar setItems:toolbarItems animated:NO];
  }
  
}

- (void)didReceiveMemoryWarning {
  [super didReceiveMemoryWarning];
  // Dispose of any resources that can be recreated.
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

- (void)finishAndUpdate {
  [self dismissViewControllerAnimated:YES completion:NULL];
  
  if (self.QRCode) {
    
    [self processImage];
    [self.imageView setImage:self.QRCode];
  }
  
  self.imagePickerController = nil;
}

- (UIImage *)imageWithImage:(UIImage *)image scaledToSize:(CGSize)newSize {

  UIGraphicsBeginImageContextWithOptions(newSize, NO, 1.0);
  [image drawInRect:CGRectMake(0, 0, newSize.width, newSize.height)];
  UIImage *newImage = UIGraphicsGetImageFromCurrentImageContext();
  UIGraphicsEndImageContext();
  return newImage;
}

#pragma mark - Pebble App Message

- (void)sendBitmapToPebble {
  
  NSDictionary *message = @{ @(0): self.bitmap};
  [self.watch appMessagesPushUpdate:message onSent:^(PBWatch *watch, NSDictionary *update, NSError *error) {
    if (!error) {
      self.statusLabel.text = @"Cool, the QR code was uploaded!";
    }
    else {
      self.statusLabel.text = @"Oops, failed to send to pebble.";
      NSLog(@"Error sending message: %@", error);
    }
  }];
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
    self.statusLabel.text = @"Oops, unable to find a QR code.";
  }
}

- (void)generateBitmap {
  self.bitmap = [PBBitmap pebbleBitmapWithUIImage:self.QRCode];
}


@end

