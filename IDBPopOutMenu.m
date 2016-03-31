//
//  IDBPopOutMenu.m
//  PopViewDemoe
//
//  Created by Han Yahui on 16/1/6.
//  Copyright © 2016年 Han Yahui. All rights reserved.
//

#import "IDBPopOutMenu.h"


#define TRANSITION_DURATION  0.3
#define SCREENSHOT_QUALITY  0.75

#pragma mark Category

@implementation UIView (ScreenShot)

-(UIImage*)screenShot
{
  UIGraphicsBeginImageContext(self.bounds.size);
  CGContextRef context = UIGraphicsGetCurrentContext();
  [self.layer renderInContext:context];
  UIImage * screenImage = UIGraphicsGetImageFromCurrentImageContext();
  UIGraphicsEndImageContext();
  NSData * imageData = UIImageJPEGRepresentation(screenImage, SCREENSHOT_QUALITY);
  screenImage = [UIImage imageWithData:imageData];
  return screenImage;
}

-(UIImage*)screenShotOnScrolViewWithContentOffset:(CGPoint)offset
{
  UIGraphicsBeginImageContext(self.bounds.size);
  CGContextRef context = UIGraphicsGetCurrentContext();
  CGContextTranslateCTM(context, -offset.x, -offset.y);
  [self.layer renderInContext:context];
  UIImage * screenImage = UIGraphicsGetImageFromCurrentImageContext();
  UIGraphicsEndImageContext();
  NSData * imageData = UIImageJPEGRepresentation(screenImage, SCREENSHOT_QUALITY);
  screenImage = [UIImage imageWithData:imageData];
  return screenImage;
}

@end

//@implementation UIImage (Blur_and_Color_Filter)
//
//-(UIImage*)blurWithRadius:(CGFloat)radius{
//  radius =(radius<0)?0:radius;
////  radius =(radius>4)?4:radius;
//  CIImage * inputImage = [CIImage imageWithCGImage:self.CGImage];
//  CIFilter * blurFilter = [CIFilter filterWithName:@"CIGaussianBlur"];
//  [blurFilter setValue:inputImage forKey:@"inputImage"];
//  [blurFilter setValue:[NSNumber numberWithFloat:radius] forKey:@"inputRadius"];
//  CIImage * outputImage = [blurFilter outputImage];
//  outputImage = [outputImage imageByCroppingToRect:[inputImage extent]];
//  UIImage * blurImage = [UIImage imageWithCIImage:outputImage];
//  return blurImage;
//}
//
//@end

#import "UIImage+ImageEffects.h"

@class IDBPopOutMenuItemView;

@protocol IDBPopOutMenuItemViewDelegate <NSObject>

- (void)clickItemView:(IDBPopOutMenuItemView *)itemView;

@end

@interface IDBPopOutMenuItemView : UIView

@property (nonatomic) UIButton *itemButton;
@property (nonatomic) UILabel *titleLabel;

@property (nonatomic) CGSize imageSize;

@property (nonatomic,weak) id<IDBPopOutMenuItemViewDelegate> delegate;

@end

@implementation IDBPopOutMenuItemView

- (instancetype)initWithFrame:(CGRect)frame withMenuItem:(IDBPopOutMenuItem *)item
{
  self = [super initWithFrame:frame];
  if (self) {
    
    self.backgroundColor = item.backgroundColor;
    
    if (item.image) {
      self.itemButton = [UIButton buttonWithType:UIButtonTypeCustom];
      [self.itemButton setImage:item.image forState:UIControlStateNormal];
      [self.itemButton addTarget:self action:@selector(pressAction) forControlEvents:UIControlEventTouchUpInside];
      [self addSubview:self.itemButton];
    }
    
    if (item.title) {
      self.titleLabel = [UILabel new];
      self.titleLabel.backgroundColor = [UIColor clearColor];
      [self.titleLabel setText:item.title];
      [self.titleLabel setFont:item.font];
      [self.titleLabel setTextAlignment:item.alignment];
      [self.titleLabel setTextColor:kTextColor];
      [self addSubview:self.titleLabel];
    }
    
    if (frame.size.height <= item.imageSize.height || frame.size.width <= item.imageSize.width) {
      
      self.imageSize = CGSizeMake(frame.size.width - 10, frame.size.height - 10);
    }
    else {
      self.imageSize = item.imageSize;
    }
    
    self.frame = frame;
  }
  return self;
}

- (void)pressAction
{
  [self.delegate clickItemView:self];
  
}

-(void)layoutSubviews
{

  CGFloat x = (self.bounds.size.width - self.imageSize.width) / 2.0;
  self.itemButton.frame = CGRectMake(x, 0, self.imageSize.width, self.imageSize.height);
  
  CGSize labelSize = CGSizeMake(self.imageSize.width, 20);
  self.titleLabel.frame = CGRectMake(0,self.itemButton.frame.size.height + 5, self.frame.size.width, labelSize.height);
}

@end


@interface IDBPopOutMenu ()<IDBPopOutMenuItemViewDelegate>

@property (nonatomic)UIImageView * blurView;
@property (nonatomic)CGRect pressFrame;
@property (nonatomic)NSMutableArray * itemViews;

@property (nonatomic) UIImageView *underView;

@end

@implementation IDBPopOutMenu

#pragma mark -LifeCycle

-(instancetype)init{
  NSAssert(NO, @"Can't create with init");
  return nil;
}

-(instancetype)initWithItems:(NSArray *)items
{
  self = [super init];
  
  if (self) {
    
    _items = items;
    _menuView = [UIView new];
    self.backgroundColor = [UIColor whiteColor];
    self.tintColor = [UIColor whiteColor];
//    self.highlightColor = [UIColor colorWithRed:1 green:1 blue:1 alpha:0.5];
    self.borderColor  = [UIColor whiteColor];
    self.borderWidth  = 1;
    self.borderRadius = 5;
    self.blurLevel    = 5;
    self.height       = 100;
  }
  
  return self;
}

-(void)showMenuInParentViewController:(UIViewController *)parentVC aboveFrame:(CGRect)frame
{
  [self addToParentViewController:parentVC];
  self.pressFrame = frame;
  self.view.frame = parentVC.view.bounds;
  self.blurView = [[UIImageView alloc]init];
  
  [self.view addSubview:self.blurView];
  
  
//  if (self.underImage) {
//    _underView = [[UIImageView alloc] initWithImage:self.underImage];
//    CGFloat y = self.pressFrame.origin.y +self.pressFrame.size.height;
//    _underView.frame = CGRectMake(0, y + 25, self.view.frame.size.width, self.height);
//    _underView.contentMode =  UIViewContentModeScaleAspectFill;
//    [self.view addSubview:_underView];
//  }
  
  [self screenShotWithCompletion:^{
    if (self.aboveImage) {
      UIImageView *pressView = [[UIImageView alloc] initWithImage:self.aboveImage];
      pressView.frame = frame;
      [self.view addSubview:pressView];
    }
  
    [self layoutMenuView];
  }];
  
}

- (void)addToParentViewController:(UIViewController *)parentViewController
{
  [parentViewController addChildViewController:self];
  [parentViewController.view addSubview:self.view];
}

-(void)removeFromSuperViewController{
  [self removeFromParentViewController];
  [self.view removeFromSuperview];
  [self.blurView removeFromSuperview];
  self.blurView = nil;
}


- (void)layoutMenuView
{
  self.itemViews = [NSMutableArray new];
  
  self.menuView.backgroundColor     = self.backgroundColor;
  self.menuView.tintColor           = self.tintColor;
  self.menuView.layer.borderWidth   = self.borderWidth;
  self.menuView.layer.borderColor   = self.borderColor.CGColor;
  self.menuView.layer.masksToBounds = YES;
  [self layoutSubViews];
  
  [self.view addSubview:self.menuView];
}

-(void)layoutSubViews
{
  CGFloat menuWidth = self.view.frame.size.width;

  CGSize itemSize = CGSizeMake(menuWidth / self.items.count, self.pressFrame.size.height);
  
  [self.items enumerateObjectsUsingBlock:^(IDBPopOutMenuItem *obj, NSUInteger idx, BOOL * _Nonnull stop) {
    
    IDBPopOutMenuItemView *itemView = [[IDBPopOutMenuItemView alloc]
                                       initWithFrame:CGRectMake(idx*itemSize.width, 10, itemSize.width, itemSize.height)
                                       withMenuItem:obj];
    itemView.delegate = self;
    
    [self.menuView addSubview:itemView];
    [self.itemViews addObject:itemView];
  }];
  
  CGFloat y = self.pressFrame.origin.y +self.pressFrame.size.height;
  
  self.menuView.frame = CGRectMake(0, y, self.view.frame.size.width, 0);
  [UIView animateWithDuration:0.3 delay:0 usingSpringWithDamping:1 initialSpringVelocity:0.75 options:0 animations:^{
//    self.underView.frame = CGRectMake(0, y + self.height + 25, self.view.frame.size.width, self.height);
    self.menuView.frame = CGRectMake(0, y, self.view.frame.size.width, self.height);

  } completion:^(BOOL finished) {

  }];
  
}

-(void)dismissMenu
{
  [UIView animateWithDuration:0.3 delay:0 usingSpringWithDamping:1 initialSpringVelocity:0.75 options:0 animations:^{
    if (self.menuView.superview!=nil) {
      CGRect frame = self.menuView.frame;
      frame.size.height = 0;
      self.menuView.frame = frame;
      
//      CGFloat y = self.pressFrame.origin.y +self.pressFrame.size.height + 25;
//      CGRect underViewFrame = _underView.frame;
//      underViewFrame.origin.y = y;
//      _underView.frame = underViewFrame;
    }
  } completion:^(BOOL finished) {
    [self removeFromSuperViewController];
  }];
}

-(void)screenShotWithCompletion:(dispatch_block_t)completion
{
  self.blurView.frame = self.view.bounds;
  self.blurView.alpha = 0.0;
  self.menuView.alpha = 0.0;
  UIImage * screenshot = nil;
  if ([self.parentViewController.view isKindOfClass:[UIScrollView class]]) {
    screenshot = [self.parentViewController.view screenShotOnScrolViewWithContentOffset:[(UIScrollView*)self.parentViewController.view contentOffset]];
  }else{
    screenshot = [self.parentViewController.view screenShot];
  }
  self.blurView.alpha = 1.0;
  self.menuView.alpha = 1.0;
  if (self.blurLevel > 0.0) {
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{

      UIImage * blurImage = [screenshot applyLightEffect];
      

      dispatch_async(dispatch_get_main_queue(), ^{
        CATransition * transition = [CATransition animation];
        transition.duration = TRANSITION_DURATION;
        transition.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
        transition.type = kCATransitionFade;
        
        self.blurView.image = blurImage;
        [self.blurView.layer addAnimation:transition forKey:@"showBlurView"];
        [self.view setNeedsLayout];
        if (completion) {
          completion();
        }
        
        [self.view setNeedsLayout];
        [self.view layoutIfNeeded];
      });
    });
  }else{
    self.blurView.image = screenshot;
    if (completion) {
      completion();
    }
  }
}

-(void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
  if ([self.delegate respondsToSelector:@selector(popOutMenuWillDismiss:)]) {
    [self.delegate popOutMenuWillDismiss:self];
  }
  [self dismissMenu];
}

#pragma mark -

-(void)clickItemView:(IDBPopOutMenuItemView *)itemView
{
  if ([self.delegate respondsToSelector:@selector(popOutMenu:didSelectedItemAtIndex:)]) {
    [self.delegate popOutMenu:self didSelectedItemAtIndex:[_itemViews indexOfObject:itemView]];
  }
  if ([self.delegate respondsToSelector:@selector(popOutMenuWillDismiss:)]) {
    [self.delegate popOutMenuWillDismiss:self];
  }
  [self dismissMenu];
}


@end



