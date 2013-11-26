//
//  ViewController.m
//  DMModernProgressView
//
//  Created by Dmitry Ponomarev on 22/11/13.
//  Copyright (c) 2013 demdxx. All rights reserved.
//

#import "ViewController.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
  
  for (int i=0 ; i<self.ranges.count ; i++) {
    DMModernProgressView *pv = ((DMModernProgressView *)self.ranges[i]);
    pv.delegate = self;
  }
  
  
  for (int i=3 ; i<self.ranges.count ; i++) {
    const CGFloat *componentColors = CGColorGetComponents(((DMModernProgressView *)self.ranges[i]).backgroundColor.CGColor);
    
    UIColor *newColor = [UIColor colorWithRed:(1.0 - componentColors[0])
                                        green:(1.0 - componentColors[1])
                                         blue:(1.0 - componentColors[2])
                                        alpha:componentColors[3]];
    
    UIColor *newColor2 = [UIColor colorWithRed:(componentColors[1])
                                         green:(componentColors[2])
                                          blue:(componentColors[0])
                                         alpha:1];
    
    DMModernProgressView *pv = ((DMModernProgressView *)self.ranges[i]);
    pv.backgroundColor = [UIColor clearColor];
    pv.replacedImageColor = newColor;
    
    pv.progressImageItem = [self getStarImage:pv.frame.size.height
                                        scale:0
                                        color:newColor];
    pv.progressSelectedImageItem = [self getStarImage:pv.frame.size.height
                                                scale:0
                                                color:newColor2];
    
    if (0 != (i % 2)) {
      pv.progressViewStyle = DMModernProgressViewStyleElementwise;
      pv.progressBlocks = 7;
    } else {
      pv.progressViewStyle = DMModernProgressViewStyleHalfElement|DMModernProgressViewStyleStretching;
      pv.progressBlocks = 10;
    }
  }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (UIImage *)getStarImage:(CGFloat)size
                    scale:(CGFloat)scale
                    color:(UIColor *)color
{
  // create a new bitmap image context at the device resolution (retina/non-retina)
  UIGraphicsBeginImageContextWithOptions(CGSizeMake(size, size), NO, scale);
  
  // get context
  CGContextRef ctx = UIGraphicsGetCurrentContext();
  
  // push context to make it current
  // (need to do this manually because we are not drawing in a UIView)
  UIGraphicsPushContext(ctx);
  
  CGContextRef context = UIGraphicsGetCurrentContext();
  CGContextSetLineWidth(context, size);
  CGFloat xCenter = size / 2;
  CGFloat yCenter = size / 2;
  
  double r = size / 2.0;
  float flip = -1.0;
  
  /* Draw star */
  {
    CGContextSetFillColorWithColor(context, color.CGColor);
    CGContextSetStrokeColorWithColor(context, color.CGColor);
    
    double theta = 2.0 * M_PI * (2.0 / 5.0); // 144 degrees
    
    CGContextMoveToPoint(context, xCenter, r*flip+yCenter);
    
    for (NSUInteger k=1; k<5; k++)
    {
      float x = r * sin(k * theta);
      float y = r * cos(k * theta);
      CGContextAddLineToPoint(context, x+xCenter, y*flip+yCenter);
    }
  }
  CGContextClosePath(context);
  CGContextFillPath(context);
  
  // pop context
  UIGraphicsPopContext();
  
  // get a UIImage from the image context- enjoy!!!
  UIImage *outputImage = UIGraphicsGetImageFromCurrentImageContext();
  
  // clean up drawing environment
  UIGraphicsEndImageContext();
  
  return outputImage;
}

- (IBAction)generate:(id)sender
{
  for (DMModernProgressView *p in self.ranges) {
    p.maxValue = MAX(10, random() % 1000);
    p.minAllowedValue = MAX(0, MIN(p.maxValue, random() % 100));
    p.maxAllowedValue = MAX(p.minAllowedValue, MIN(p.maxValue, random() % 1000));
    if (rand()%3 == 0) {
      p.aligment  = rand() % 2 == 0
                  ? DMModernProgressViewAlignLeft
                  : DMModernProgressViewAlignRight;
    } else {
      p.aligment  = DMModernProgressViewAlignCenter;
    }
    p.value = random() % p.maxValue;
  }
}

- (IBAction)onEditMode:(id)sender {
  for (DMModernProgressView *p in self.ranges) {
    p.canEdit = ((UISwitch *)sender).on;
  }
}

////////////////////////////////////////////////////////////////////////////////
#pragma mark DMModernProgressViewDelegate
////////////////////////////////////////////////////////////////////////////////

- (void)progressViewChanged:(DMModernProgressView *)progressView value:(long)value
{
  NSLog(@"New value: %ld : %f", value, progressView.selectedBlockCount);
}

@end
