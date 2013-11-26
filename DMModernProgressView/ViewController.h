//
//  ViewController.h
//  DMModernProgressView
//
//  Created by Dmitry Ponomarev on 22/11/13.
//  Copyright (c) 2013 demdxx. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "DMModernProgressView.h"

@interface ViewController : UIViewController<DMModernProgressViewDelegate>

@property (strong, nonatomic) IBOutletCollection(DMModernProgressView) NSArray *ranges;

- (IBAction)generate:(id)sender;
- (IBAction)onEditMode:(id)sender;

@end
