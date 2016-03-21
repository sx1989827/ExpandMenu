//
//  ExpandMenu.h
//  demotest
//
//  Created by 孙昕 on 16/2/25.
//  Copyright © 2016年 孙昕. All rights reserved.
//

#import <UIKit/UIKit.h>
enum EXPANDSTATE {COLLAPSE,EXPAND,PENDING};
@interface ExpandMenu : NSObject
@property (assign,nonatomic) enum EXPANDSTATE state;
-(void)setExpandMenu:(UIView*)view  Width:(CGFloat)width VC:(UIViewController*)vc;
-(void)expand;
-(void)collapse;
+(instancetype)menuForView:(UIView*)view;
+(instancetype)menuForVC:(UIViewController*)vc;
@end
