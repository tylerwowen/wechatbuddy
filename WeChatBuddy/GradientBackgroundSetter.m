//
//  GradientBackgroundSetter.m
//  WeChatBuddy
//
//  Created by Tyler Weimin Ouyang on 8/8/15.
//  Copyright (c) 2015 Tyler. All rights reserved.
//

#import "GradientBackgroundSetter.h"

@implementation GradientBackgroundSetter


+ (void)setBackgrooundColorForView:(UIView *)view {
  
  // Create the colors
  CGColorRef blue = [[UIColor colorWithRed:30.0/255.0 green:90.0/255.0 blue:150.0/255.0 alpha:1.0] CGColor];
  CGColorRef green = [[UIColor colorWithRed:20.0/255.0 green:145.0/255.0 blue:95.0/255.0 alpha:1.0] CGColor];
  
  // Create the gradient
  CAGradientLayer *gradient = [CAGradientLayer layer];
  
  // Set colors
  gradient.colors = [NSArray arrayWithObjects:(__bridge id)(green), (__bridge id)(blue), nil];
  
  // Set bounds
  gradient.frame = view.bounds;
  gradient.startPoint = CGPointMake(1.0, 0.5);
  gradient.endPoint = CGPointMake(0, 0.5);
  
  // Add the gradient to the view
  [view.layer addSublayer:gradient];
}

@end
