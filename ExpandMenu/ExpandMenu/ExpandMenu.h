//
//  ExpandMenu.h
//  demotest
//
//  Created by 孙昕 on 16/2/25.
//  Copyright © 2016年 孙昕. All rights reserved.
//

#import <UIKit/UIKit.h>
/**
 折叠，展开，折叠中或者展开中
 */
enum EXPANDSTATE {COLLAPSE,EXPAND,PENDING};
@interface ExpandMenu : NSObject
/**
 *  菜单当前状态
 */
@property (assign,nonatomic) enum EXPANDSTATE state;
/**
 *  设置当前需要折叠的view
 *
 *  @param view  view
 *  @param width 宽度
 *  @param vc    绑定的viewController
 */
-(void)setExpandMenu:(UIView*)view  Width:(CGFloat)width VC:(UIViewController*)vc;
/**
 *  展开菜单
 */
-(void)expand;
/**
 *  折叠菜单
 */
-(void)collapse;
/**
 *  通过菜单的view获取对应的menu实例
 *
 *  @param view 菜单view
 *
 *  @return 菜单实例
 */
+(instancetype)menuForView:(UIView*)view;
/**
 *  通过viewController获取对应的menu实例
 *
 *  @param vc 绑定vc实例
 *
 *  @return 菜单实例
 */
+(instancetype)menuForVC:(UIViewController*)vc;
@end
