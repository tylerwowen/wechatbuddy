//
//  ViewController.m
//  WeChatBuddy
//
//  Created by Tyler Weimin Ouyang on 7/31/15.
//  Copyright (c) 2015 Tyler. All rights reserved.
//

#import "ViewController.h"
#import "AppDelegate.h"

@interface ViewController ()

@property (nonatomic, weak) IBOutlet UIImageView *imageView;
@property (nonatomic, weak) IBOutlet UIToolbar *toolBar;

@property (nonatomic) UIImagePickerController *imagePickerController;
@property (nonatomic) NSMutableArray *capturedImages;

@property PBWatch *watch;

@end

@implementation ViewController

- (void)viewDidLoad {
  [super viewDidLoad];
  
  // Get reference to watch
  AppDelegate *delegate = [[UIApplication sharedApplication] delegate];
  self.watch = [delegate getConnectedWatch];
  
  self.capturedImages = [[NSMutableArray alloc] init];
  
  if (![UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera])
  {
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


- (IBAction)showImagePickerForCamera:(id)sender
{
  [self showImagePickerForSourceType:UIImagePickerControllerSourceTypeCamera];
}


- (IBAction)showImagePickerForPhotoPicker:(id)sender
{
  [self showImagePickerForSourceType:UIImagePickerControllerSourceTypePhotoLibrary];
}


- (void)showImagePickerForSourceType:(UIImagePickerControllerSourceType)sourceType
{
  if (self.imageView.isAnimating)
  {
    [self.imageView stopAnimating];
  }
  
  if (self.capturedImages.count > 0)
  {
    [self.capturedImages removeAllObjects];
  }
  
  UIImagePickerController *imagePickerController = [[UIImagePickerController alloc] init];
  imagePickerController.modalPresentationStyle = UIModalPresentationCurrentContext;
  imagePickerController.sourceType = sourceType;
  imagePickerController.delegate = self;
  
  if (sourceType == UIImagePickerControllerSourceTypeCamera)
  {
    /*
     The user wants to use the camera interface. Set up our custom overlay view for the camera.
     */
    //imagePickerController.showsCameraControls = NO;
    
  }
  
  self.imagePickerController = imagePickerController;
  [self presentViewController:self.imagePickerController animated:YES completion:nil];
}


#pragma mark - Toolbar actions

- (void)finishAndUpdate
{
  [self dismissViewControllerAnimated:YES completion:NULL];
  
  if ([self.capturedImages count] > 0)
  {
    if ([self.capturedImages count] == 1)
    {
      // Camera took a single picture.
      [self.imageView setImage:[self.capturedImages objectAtIndex:0]];
    }
    else
    {
      // Camera took multiple pictures; use the list of images for animation.
      self.imageView.animationImages = self.capturedImages;
      self.imageView.animationDuration = 5.0;    // Show each captured photo for 5 seconds.
      self.imageView.animationRepeatCount = 0;   // Animate forever (show all photos).
      [self.imageView startAnimating];
    }
    
    // To be ready to start again, clear the captured images array.
    [self.capturedImages removeAllObjects];
  }
  
  self.imagePickerController = nil;
}


#pragma mark - UIImagePickerControllerDelegate

// This method is called when an image has been chosen from the library or taken from the camera.
- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{
  UIImage *image = [info valueForKey:UIImagePickerControllerOriginalImage];
  
  [self.capturedImages addObject:image];
  
  [self finishAndUpdate];
}


- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker
{
  [self dismissViewControllerAnimated:YES completion:NULL];
}


@end

