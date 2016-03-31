//
//  IDBPopOutMenu.h
//  PopViewDemoe
//
//  Created by Han Yahui on 16/1/6.
//  Copyright © 2016年 Han Yahui. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "IDBPopOutMenuItem.h"

@class IDBPopOutMenu;

@protocol IDBPopOutMenuDelegate <NSObject>

- (void)popOutMenu:(IDBPopOutMenu *)menu didSelectedItemAtIndex:(NSUInteger)index;

@optional
- (void)popOutMenuWillDismiss:(IDBPopOutMenu *)menu;

@end



@interface IDBPopOutMenu : UIViewController

@property (nonatomic) id<IDBPopOutMenuDelegate>delegate;

@property (nonatomic,readonly) NSArray * items;

@property (nonatomic,readonly) UIView * menuView;

@property (nonatomic) UIColor * backgroundColor, * highlightColor, *tintColor;

@property (nonatomic) UIColor *borderColor;

@property (nonatomic) CGFloat blurLevel, borderRadius, borderWidth;

@property (nonatomic) UIImage *aboveImage;
@property (nonatomic) UIImage *underImage;

@property (nonatomic) CGFloat height;

-(instancetype)initWithItems:(NSArray *)items;

-(void)showMenuInParentViewController:(UIViewController *)parentVC aboveFrame:(CGRect)frame;
- (void)dismissMenu;

@end

