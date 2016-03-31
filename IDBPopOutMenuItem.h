//
//  IDBPopOutMenuItem.h
//  PopViewDemoe
//
//  Created by Han Yahui on 16/1/6.
//  Copyright © 2016年 Han Yahui. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface IDBPopOutMenuItem : NSObject

@property (nonatomic,readonly) NSString *title;
@property (nonatomic,readonly) UIImage *image;
@property (nonatomic) UIColor *tintColor,*backgroundColor;
@property (nonatomic) UIFont *font;
@property (nonatomic) NSTextAlignment alignment;

@property (nonatomic) CGSize imageSize;

-(instancetype)initWithTitle:(NSString*)title image:(UIImage*)image;

@end
