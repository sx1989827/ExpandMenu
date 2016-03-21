//
//  ViewController.m
//  ExpandMenu
//
//  Created by 孙昕 on 16/3/21.
//  Copyright © 2016年 孙昕. All rights reserved.
//

#import "ViewController.h"
#import "ExpandMenu.h"
@interface ViewController ()
{
    ExpandMenu *menu;
}
- (IBAction)onClick:(id)sender;
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    UIView *view=[[UIView alloc] initWithFrame:CGRectMake(0, 0, 300, 300)];
    view.backgroundColor=[UIColor orangeColor];
    menu=[[ExpandMenu alloc] init];
    [menu setExpandMenu:view Width:[UIScreen mainScreen].bounds.size.width*2/3 VC:self];
}

- (IBAction)onClick:(id)sender
{
    [menu expand];
}
@end









