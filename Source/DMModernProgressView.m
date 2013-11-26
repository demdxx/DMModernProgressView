//
//  DMModernProgressView.m
//  DMModernProgressView
//
//  Created by Dmitry Ponomarev on 22/11/13.
//  Copyright (c) 2013 demdxx. All rights reserved.
//

#import "DMModernProgressView.h"

#if __has_feature(objc_arc)
  #define M_OBJECT_RELEASE(obj) obj = nil
#else
  #define M_OBJECT_RELEASE(obj) if (obj!=nil) { [obj release]; obj=nil; }
#endif

////////////////////////////////////////////////////////////////////////////////
/// Hidden declaration
////////////////////////////////////////////////////////////////////////////////

@interface DMModernProgressView ()

@property (nonatomic, strong) UIImageView *indicatorView;

- (void)updateIndicatorView;
- (void)initIndicatorView;

// Helpers
- (long)valueAtPosition:(CGFloat)position;
- (void)indicatorViewUpdate;

- (CGFloat)progressItemSize;
- (CGFloat)progressSize;
- (CGFloat)progressSize:(CGFloat)itemSize;
- (CGRect)activeRect;
- (CGRect)activeRect:(CGFloat)itemSize;

// CG helpers

- (CGRect)drawRectForImage:(UIImage *)image
                         x:(CGFloat)x
                     width:(CGFloat)width
                    height:(CGFloat)height;

@end

////////////////////////////////////////////////////////////////////////////////
/// Implementation
////////////////////////////////////////////////////////////////////////////////

@implementation DMModernProgressView

@synthesize value = _value;
@synthesize maxValue;
@synthesize minAllowedValue;
@synthesize maxAllowedValue;
@synthesize progressBlocks;
@synthesize canEdit;
@synthesize progressViewStyle;
@synthesize aligment = _aligment;
@synthesize progressImageItem = _progressImageItem;
@synthesize progressSelectedImageItem = _progressSelectedImageItem;
@synthesize replacedImageColor;

#if __IPHONE_OS_VERSION_MIN_ALLOWED < __IPHONE_7_0
@synthesize selectedColor = _selectedColor;
#endif

@synthesize indicatorView = _indicatorView;

- (id)init
{
  if (self = [super init]) {
    maxValue = 100;
  }
  return self;
}

- (id)initWithFrame:(CGRect)frame
{
  if (self = [super initWithFrame:frame]) {
    maxValue = 100;
  }
  return self;
}

- (id)initWithCoder:(NSCoder *)coder
{
  if (self = [super initWithCoder:coder]) {
    maxValue = 100;
  }
  return self;
}

- (void)layoutSubviews
{
  [super layoutSubviews];
  
  // Refresh indicator view
  if (nil != _indicatorView) {
    if (!CGSizeEqualToSize(_indicatorView.image.size, self.frame.size)) {
      _indicatorView.image = nil;
      [self updateIndicatorView];
    }
  }
  [self setNeedsDisplay];
}

- (void)drawRect:(CGRect)rect
{
  [super drawRect:rect];
  
  // Calc progres size
  CGFloat progressItemSize = [self progressItemSize];
  CGFloat progressSize = progressItemSize * (CGFloat)_value;
  
  // If we have image
  if (_progressImageItem) {
    // Get items count
    const long itemsCount = self.blockCount;
    
    // Calculate residue
    const CGFloat offset = DMModernProgressViewAlignCenter == _aligment
                         ? (self.frame.size.width - (itemsCount * progressItemSize)) / 2
                         : 0.f;
    
    // Draw items
    for (long i = 0 ; i < itemsCount ; i++) {
      CGFloat x = i * progressItemSize + offset;
      
      if (_aligment == DMModernProgressViewAlignRight) {
        x = self.frame.size.width - x - progressItemSize;
      }
      
      CGRect drawRect = [self drawRectForImage:_progressImageItem
                                             x:x
                                         width:progressItemSize
                                        height:self.frame.size.height];
      
      // Draw item
      [_progressImageItem drawInRect:drawRect];
    }
    
    // Generate selection if necessary
    [self initIndicatorView];
  } else {
    [self.selectedColor setFill];
    CGRect rect = self.bounds;
    rect.size.width = progressSize;
    if (DMModernProgressViewAlignRight == _aligment) {
      rect.origin.x = self.bounds.size.width - progressSize;
    }
    UIRectFill(rect);
  }
}

////////////////////////////////////////////////////////////////////////////////
#pragma mark GC Helpers
////////////////////////////////////////////////////////////////////////////////

- (void)indicatorViewUpdate
{
  if (nil != _indicatorView) {
    _indicatorView.image = [self generateForground:self.bounds];
  }
}

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
                      itemSize:(CGFloat)itemSize
{
  
  // create a new bitmap image context at the device resolution (retina/non-retina)
  UIGraphicsBeginImageContextWithOptions(rect.size, NO, 0);
  
  // get context
  CGContextRef ctx = UIGraphicsGetCurrentContext();
  
  // push context to make it current
  // (need to do this manually because we are not drawing in a UIView)
  UIGraphicsPushContext(ctx);
  
  // Selected image
  UIImage *item = _progressImageItem;
  if (_progressSelectedImageItem) {
    item = _progressSelectedImageItem;
  }
  
  // Draw items
  for (long i = 0 ; i < itemsCount ; i++) {
    CGFloat x = i * itemSize + offset;
    
    if (_aligment == DMModernProgressViewAlignRight) {
      x = self.frame.size.width - x - itemSize;
    }
    
    CGRect drawRect = [self drawRectForImage:item
                                           x:x
                                       width:itemSize
                                      height:self.frame.size.height];
    
    // Draw item
    [item drawInRect:drawRect];
  }
  
  // pop context
  UIGraphicsPopContext();
  
  // get a UIImage from the image context- enjoy!!!
  UIImage *outputImage = UIGraphicsGetImageFromCurrentImageContext();
  
  // clean up drawing environment
  UIGraphicsEndImageContext();
  
  // Replace color
//  if (replacedImageColor && false) {
//    UIImage *newImage = [self.class replaceColorFromImage:outputImage color:replacedImageColor];
//    M_OBJECT_RELEASE(outputImage); // ??? possible problem. Leak?
//    outputImage = newImage;
//  }
  
  return outputImage;
}

- (UIImage *)generateForground:(CGRect)rect
{
  CGFloat progressItemSize = [self progressItemSize];

  // Get items count
  const long itemsCount = self.blockCount;
  
  // Calculate residue
  const CGFloat offset  = DMModernProgressViewAlignCenter == _aligment
                        ? (self.frame.size.width - (itemsCount * progressItemSize)) / 2
                        : 0.f;
  
  return [self generateForground:self.bounds
                           offset:offset
                      itemsCount:itemsCount
                        itemSize:progressItemSize];
}

////////////////////////////////////////////////////////////////////////////////
#pragma mark Getters / Setters
////////////////////////////////////////////////////////////////////////////////

- (void)initIndicatorView
{
  if (nil == _indicatorView) {
    _indicatorView = [[UIImageView alloc] initWithFrame:self.bounds];
    _indicatorView.clipsToBounds = YES;
    if (_aligment == DMModernProgressViewAlignRight) {
      _indicatorView.contentMode = UIViewContentModeRight;
    } else {
      _indicatorView.contentMode = UIViewContentModeLeft;
    }
    _indicatorView.autoresizingMask = UIViewAutoresizingFlexibleHeight|UIViewAutoresizingFlexibleWidth;
    [self addSubview:_indicatorView];
  }
  if (nil == _indicatorView.image) {
    _indicatorView.image = [self generateForground:self.bounds];
  }
}

- (void)updateIndicatorView
{
  CGRect frame = self.bounds;
  frame.size.width = self.progressSize;
  
  if (_aligment == DMModernProgressViewAlignRight) {
    frame.origin.x = self.frame.size.width - frame.size.width;
  } else if (_aligment == DMModernProgressViewAlignCenter) {
    CGRect activeRect = self.activeRect;
    frame.size.width += activeRect.origin.x;
  }
  
  self.indicatorView.frame = frame;
}

- (UIImageView *)indicatorView
{
  [self initIndicatorView];
  return _indicatorView;
}

- (void)setValue:(long)value
{
  if (_value != value) {
    _value = value;
    if (nil == _progressImageItem) {
      [self setNeedsDisplay];
    } else {
      [self updateIndicatorView];
    }
    if (nil != self.delegate) {
      if ([self.delegate respondsToSelector:@selector(progressViewChanged:value:)]) {
        [self.delegate progressViewChanged:self value:value];
      }
    }
  }
}

- (void)setValue:(long)value animateDuration:(NSTimeInterval)animateDuration
{
  if (_value != value) {
    if (animateDuration <= 0.f) {
      [self setValue:value];
    } else {
      CGRect frame = self.bounds;
      frame.size.width = self.progressSize;
      [UIView animateWithDuration:animateDuration animations:^{
        self.indicatorView.frame = frame;
      }];
    }
  }
}

- (void)setAligment:(DMModernProgressViewAlign)aligment
{
  if (_aligment != aligment) {
    _aligment = aligment;
    if (nil != _indicatorView) {
      if (aligment == DMModernProgressViewAlignRight) {
        _indicatorView.contentMode = UIViewContentModeRight;
      } else {
        _indicatorView.contentMode = UIViewContentModeLeft;
      }
      // Remove image cache
      _indicatorView.image = nil;
    }
    [self setNeedsDisplay];
  }
}

- (void)setProgressImageItem:(UIImage *)progressImageItem
{
  _progressImageItem = progressImageItem;
  [self setNeedsDisplay];
}

- (void)setProgressSelectedImageItem:(UIImage *)progressSelectedImageItem
{
  _progressSelectedImageItem = progressSelectedImageItem;
  [self setNeedsDisplay];
}

/**
 * Get: Current active color
 *
 * @return selected color
 */
- (UIColor *)selectedColor
{
#if __IPHONE_OS_VERSION_MIN_ALLOWED < __IPHONE_7_0
  if (nil != _selectedColor) {
    return _selectedColor;
  }
  if ([self respondsToSelector:@selector(tintColor)]) {
    return self.tintColor;
  }
  return self.replacedImageColor;
#else
  return self.tintColor;
#endif
}

/**
 * Set: Current active color
 *
 * @param new color
 */
- (void)setSelectedColor:(UIColor *)selectedColor
{
#if __IPHONE_OS_VERSION_MIN_ALLOWED < __IPHONE_7_0
  _selectedColor = selectedColor;
#else
  self.tintColor = selectedColor;
#endif
}

/**
 * Get count visible blocks
 *
 * @return clock
 */
- (long)blockCount
{
  return progressBlocks > 0 ? progressBlocks
          : (long)round(self.frame.size.width / self.progressItemSize);
}

/**
 * Get count active blocks
 *
 * @return count
 */
- (float)selectedBlockCount
{
  if (maxValue == _value) {
    return (float)self.blockCount;
  }
  
  const float progressSize = self.progressSize;
  const CGFloat itemSize = self.progressItemSize;
  float val = progressSize / itemSize;
  
  if (0 != (progressViewStyle & DMModernProgressViewStyleHalfElement)) {
    val = round(progressSize / itemSize);
  } else if (0 != (progressViewStyle & DMModernProgressViewStyleElementwise)) {
    val = round(progressSize / (itemSize / 2.f)) / 2;
  }
  return MIN((float)self.blockCount, val);
}

////////////////////////////////////////////////////////////////////////////////
#pragma mark Helpers
////////////////////////////////////////////////////////////////////////////////

- (long)valueAtPosition:(CGFloat)position
{
  const CGFloat itemSize = self.progressItemSize;
  const long countBlocks  = progressBlocks > 0
                          ? progressBlocks
                          : (long)round(self.frame.size.width / itemSize);
  const CGFloat maxSize = countBlocks * itemSize;
  const CGFloat dif = self.frame.size.width - maxSize;
  
  long value;
  
  switch (_aligment) {
    case DMModernProgressViewAlignLeft:
      value = position / (maxSize / maxValue);
      break;
      
    case DMModernProgressViewAlignRight:
      position -= dif;
      value = (maxSize - position) / (maxSize / maxValue);
      break;
      
    default: // DMModernProgressViewAlignCenter
      position -= dif / 2;
      value = position / (maxSize / maxValue);
      break;
  }
  
  return value;
}

/**
 * Get item size
 *
 * @return item width
 */
- (CGFloat)progressItemSize
{
  CGSize size = self.frame.size;
  CGFloat chainSize = size.width / maxValue;
  
  if (progressBlocks > 0 && 0 != (progressViewStyle & DMModernProgressViewStyleStretching)) {
    chainSize = size.width / progressBlocks;
  } else if (_progressImageItem) {
    CGSize imageSize = _progressImageItem.size;
    
    // Calculate
    if (imageSize.height <= size.height) {
      chainSize = imageSize.width;
    } else {
      chainSize = imageSize.width * (size.height / imageSize.height);
    }
    
    // Correct size
    if (size.width / chainSize < progressBlocks) {
      chainSize = size.width / progressBlocks;
    }
  }
  
  return chainSize;
}

/**
 * Size of progress
 *
 * @return value size
 */
- (CGFloat)progressSize
{
  return [self progressSize:self.progressItemSize];
}

/**
 * Size of progress
 *
 * @param itemSize
 * @return value size
 */
- (CGFloat)progressSize:(CGFloat)itemSize
{
  if (maxValue <= _value) {
    return self.frame.size.width;
  }
  
  const long countBlocks = progressBlocks > 0
                         ? progressBlocks
                         : (long)round(self.frame.size.width / itemSize);
  const CGFloat maxSize = countBlocks * itemSize;
  const CGFloat realItemSize = maxSize / maxValue;
  CGFloat size = _value * realItemSize;
  
  if (0 != (progressViewStyle & DMModernProgressViewStyleHalfElement)) {
    CGFloat itCount = ceilf(size / itemSize);
    if (itCount > 0) {
      size = itemSize * itCount;
    } else {
      size = 0;
    }
  } else if (0 != (progressViewStyle & DMModernProgressViewStyleElementwise)) {
    CGFloat itCount = ceilf(size / (itemSize / 2.f));
    if (itCount > 0) {
      size = (itemSize / 2.f) * itCount;
    } else {
      size = 0;
    }
  }
  return MIN(size, self.frame.size.width);
}

- (CGRect)activeRect
{
  return [self activeRect:self.progressItemSize];
}

- (CGRect)activeRect:(CGFloat)itemSize
{
  const long countBlocks = progressBlocks > 0
                         ? progressBlocks
                         : (long)round(self.frame.size.width / itemSize);
  const CGFloat maxSize = countBlocks * itemSize;
  
  CGFloat offset = 0;
  CGFloat size = self.frame.size.width;
  
  switch (_aligment) {
    case DMModernProgressViewAlignCenter:
      offset = self.frame.size.width - maxSize;
      size -= offset;
      offset /= 2;
      break;
      
    case DMModernProgressViewAlignRight:
      offset = self.frame.size.width - maxSize;
      size -= offset;
      break;
      
    default:
      break;
  }
  return CGRectMake(offset, 0, size, self.frame.size.height);
}

////////////////////////////////////////////////////////////////////////////////
#pragma mark CG Helpers
////////////////////////////////////////////////////////////////////////////////

/**
 * Calculate item position
 *
 * @param image
 * @param x coord or start
 * @param width
 * @param height
 * @return rect
 */
- (CGRect)drawRectForImage:(UIImage *)image
                         x:(CGFloat)x
                     width:(CGFloat)width
                    height:(CGFloat)height
{
  CGSize size = image.size;
  
  if (size.height > height) {
    size.width *= height / size.height;
    size.height = height;
  }
  if (size.width > width) {
    size.height *= width / size.width;
    size.width = width;
  }
  
  return CGRectMake(x + (width - size.width) / 2,
                    (height - size.height) / 2,
                    size.width, size.height);
}

////////////////////////////////////////////////////////////////////////////////
#pragma mark Touch events
////////////////////////////////////////////////////////////////////////////////

- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event
{
  if (canEdit) {
    UITouch *touch = [touches anyObject];
    CGPoint touchLocation = [touch locationInView:self];
    long value = [self valueAtPosition:touchLocation.x];
    if (maxAllowedValue > 0) {
      value = MIN(maxAllowedValue, value);
    }
    if (minAllowedValue > 0) {
      value = MAX(minAllowedValue, value);
    }
    self.value = value;
  }
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
  if (canEdit) {
    UITouch *touch = [touches anyObject];
    CGPoint touchLocation = [touch locationInView:self];
    long value = [self valueAtPosition:touchLocation.x];
    if (maxAllowedValue > 0) {
      value = MIN(maxAllowedValue, value);
    }
    if (minAllowedValue > 0) {
      value = MAX(minAllowedValue, value);
    }
    self.value = value;
  }
}


@end
