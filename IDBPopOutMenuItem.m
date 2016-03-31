//
//  IDBPopOutMenuItem.m
//  PopViewDemoe
//
//  Created by Han Yahui on 16/1/6.
//  Copyright © 2016年 Han Yahui. All rights reserved.
//

#import "IDBPopOutMenuItem.h"

@implementation IDBPopOutMenuItem

-(instancetype)init{
  NSAssert(NO, @"Can't create with init");
  return nil;
}

-(instancetype)initWithTitle:(NSString *)title image:(UIImage *)image
{
  if (self = [super init]) {
    _title = title;
    _image = image;
    self.font = [UIFont systemFontOfSize:14];
    self.tintColor = [UIColor whiteColor];
    self.backgroundColor = [UIColor clearColor];
    self.alignment = NSTextAlignmentCenter;
    self.imageSize = CGSizeMake(50, 50);
  }
  return self;
}


@end
