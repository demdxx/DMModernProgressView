//
//  DMModernProgressView.h
//  DMModernProgressView
//
//  Created by Dmitry Ponomarev on 22/11/13.
//  Copyright (c) 2013 demdxx. All rights reserved.
//

#import <UIKit/UIKit.h>

#ifndef __has_feature
  #define __has_feature(x) 0
#endif

typedef NS_OPTIONS(int, DMModernProgressViewStyle)
{
  DMModernProgressViewStyleDefault,
  DMModernProgressViewStyleStretching = 1 << 0,
  DMModernProgressViewStyleElementwise = 1 << 1,
  DMModernProgressViewStyleHalfElement = 1 << 2,
};

typedef NS_ENUM(int, DMModernProgressViewAlign) {
  DMModernProgressViewAlignCenter,
  DMModernProgressViewAlignLeft,
  DMModernProgressViewAlignRight,
};

@protocol DMModernProgressViewDelegate;

@interface DMModernProgressView : UIView

// Current progress value
@property (nonatomic, assign) long value;

// Maxomal value
@property (nonatomic, assign) long maxValue;

// Minimal Allowed value (only for edit)
@property (nonatomic, assign) long minAllowedValue;

// Maximal Allowed value (only for edit)
@property (nonatomic, assign) long maxAllowedValue;

// Count of blocks
@property (nonatomic, assign) long progressBlocks;

// Can I'em edit progress?
@property (nonatomic, assign) BOOL canEdit;

// Display progress view style
@property (nonatomic, assign) DMModernProgressViewStyle progressViewStyle;

// Progress block aligment
@property (nonatomic, assign) DMModernProgressViewAlign aligment;

// Image part of progress
@property (nonatomic, strong) UIImage *progressImageItem;

// Selected Image part of progress
@property (nonatomic, strong) UIImage *progressSelectedImageItem;

// Color for replace in image
@property (nonatomic, strong) UIColor *replacedImageColor;

// Current active color
@property (nonatomic) UIColor *selectedColor;

// Get count visible blocks
@property (readonly) long blockCount;

// Get count active blocks
@property (readonly) float selectedBlockCount;

// External delegate
@property (nonatomic, assign) id<DMModernProgressViewDelegate> delegate;

/**
 * Generate front image
 *
 * @param rect
 * @param image
 * @param offset
 * @param itemsCount
 * @param itemSize
 * @return Generated image
 */
- (UIImage *)generateForground:(CGRect)rect
                        offset:(CGFloat)offset
                    itemsCount:(long)itemsCount
                      itemSize:(CGFloat)itemSize;

- (UIImage *)generateForground:(CGRect)rect;

@end


@protocol DMModernProgressViewDelegate <NSObject>

@optional

- (void)progressViewChanged:(DMModernProgressView *)progressView value:(long)value;

@end

