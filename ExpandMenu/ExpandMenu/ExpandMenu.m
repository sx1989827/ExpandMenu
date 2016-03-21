//
//  ExpandMenu.m
//  demotest
//
//  Created by 孙昕 on 16/2/25.
//  Copyright © 2016年 孙昕. All rights reserved.
//

#import "ExpandMenu.h"
@interface ExpandMenuItem : NSObject
@property (weak,nonatomic) ExpandMenu *menu;
@property (weak,nonatomic) UIViewController *vc;
@property (weak,nonatomic) UIView *view;
@end
@implementation ExpandMenuItem

@end
static NSMutableArray<ExpandMenuItem*> *g_arr;
@interface ExpandMenu()
{
    UIView *viewMenu;
    UIImageView *view1;
    UIImageView *view2;
    UIView *snapView;
    CGFloat angle;
    NSInteger count;
    NSInteger dynamicCount;
    CADisplayLink *link;
    CGFloat restlen;
    CGFloat originX;
    void (^completeBlock)();
    BOOL bExpandSuccess;
    __weak UIViewController *vcBind;
    CGFloat widthMenu;
}
@end
@implementation ExpandMenu
+(void)initialize
{
    g_arr=[[NSMutableArray alloc] initWithCapacity:30];
}

-(void)dealloc
{
    NSMutableArray *arr=[[NSMutableArray alloc] initWithCapacity:30];
    for(ExpandMenuItem *item in g_arr)
    {
        if(item.menu==self)
        {
            [arr addObject:item];
        }
    }
    [g_arr removeObjectsInArray:arr];
}

-(void)setExpandMenu:(UIView*)view Width:(CGFloat)width VC:(UIViewController *)vc
{
    viewMenu=view;
    widthMenu=width;
    vcBind=vc;
    viewMenu.frame=CGRectMake(0, 0, widthMenu, [UIScreen mainScreen].bounds.size.height);
    UIScreenEdgePanGestureRecognizer *rec=[[UIScreenEdgePanGestureRecognizer alloc] initWithTarget:self action:@selector(onExpand:)];
    rec.edges=UIRectEdgeLeft;
    [vcBind.view addGestureRecognizer:rec];
    _state=COLLAPSE;
    ExpandMenuItem *item=[[ExpandMenuItem alloc] init];
    item.menu=self;
    item.vc=vc;
    item.view=view;
    NSMutableArray *arr=[[NSMutableArray alloc] initWithCapacity:30];
    for(ExpandMenuItem *item in g_arr)
    {
        if(item.menu==self || item.vc==vc || item.view==view)
        {
            [arr addObject:item];
        }
    }
    [g_arr removeObjectsInArray:arr];
    [g_arr addObject:item];
}

-(void)onExpand:(UIScreenEdgePanGestureRecognizer*)rec
{
    if (rec.state == UIGestureRecognizerStateBegan)
    {
        _state=PENDING;
        UIImage *img=[self imageCache:viewMenu];
        view1=[[UIImageView alloc] initWithFrame:CGRectMake(viewMenu.frame.origin.x, viewMenu.frame.origin.y, viewMenu.frame.size.width/2, viewMenu.frame.size.height)];
        view1.image=img;
        view1.layer.contentsRect=CGRectMake(0, 0, 0.5, 1);
        view1.layer.anchorPoint=CGPointMake(0, 0.5);
        view1.frame=CGRectMake(0, 0, viewMenu.frame.size.width/2, viewMenu.frame.size.height);
        view1.layer.transform=CATransform3DMakeRotation(M_PI_2, 0, 1, 0);
        [[UIApplication sharedApplication].keyWindow addSubview:view1];
        view2=[[UIImageView alloc] initWithFrame:CGRectMake(viewMenu.frame.origin.x+viewMenu.frame.size.width/2, viewMenu.frame.origin.y, viewMenu.frame.size.width/2, viewMenu.frame.size.height)];
        view2.image=img;
        view2.layer.contentsRect=CGRectMake(0.5, 0, 0.5, 1);
        view2.layer.anchorPoint=CGPointMake(1, 0.5);
        view2.frame=CGRectMake(-widthMenu/2, 0, viewMenu.frame.size.width/2, viewMenu.frame.size.height);
        view2.layer.transform=CATransform3DMakeRotation(-M_PI_2, 0, 1, 0);
        [[UIApplication sharedApplication].keyWindow addSubview:view2];
        snapView=[vcBind.navigationController.view snapshotViewAfterScreenUpdates:NO];
        [vcBind.navigationController.view addSubview:snapView];
        angle=M_PI_2/widthMenu;
    }
    else if (rec.state == UIGestureRecognizerStateChanged)
    {
        
        CGPoint p= [rec translationInView:vcBind.view];
        CATransform3D matrixView1,matrixView2;
        if(p.x>0 && p.x<=widthMenu)
        {
            CGFloat radius=asin(p.x/widthMenu);
            matrixView1=CATransform3DIdentity;
            matrixView1.m34=-1/1000.0;
            matrixView2=CATransform3DIdentity;
            matrixView2.m34=-1/1000.0;
            matrixView2=CATransform3DTranslate(matrixView2, p.x, 0, 0);
            matrixView2=CATransform3DRotate(matrixView2, -M_PI_2+radius, 0, 1, 0);
            view1.layer.transform=CATransform3DRotate(matrixView1, M_PI_2- radius, 0, 1, 0);
            view2.layer.transform=matrixView2;
            CGRect frame=vcBind.navigationController.view.frame;
            frame.origin.x=p.x;
            vcBind.navigationController.view.frame=frame;
        }
        else if(p.x>widthMenu)
        {
            view1.layer.transform=CATransform3DIdentity;
            view2.layer.transform=CATransform3DMakeTranslation(widthMenu, 0, 0);
            CGRect frame=vcBind.navigationController.view.frame;
            frame.origin.x=widthMenu;
            vcBind.navigationController.view.frame=frame;
        }
    }
    else if (rec.state == UIGestureRecognizerStateEnded || rec.state == UIGestureRecognizerStateCancelled)
    {
        CGFloat len=[rec translationInView:vcBind.view].x;
        BOOL bSuccess;
        if(len<widthMenu/2)
        {
            bSuccess=NO;
        }
        else
        {
            bSuccess=YES;
        }
        [self startAnimate:0.3 Success:bSuccess  Block:^{
            [view1 removeFromSuperview];
            [view2 removeFromSuperview];
            if(vcBind.navigationController.view.frame.origin.x==0)
            {
                [snapView removeFromSuperview];
            }
            else
            {
                UITapGestureRecognizer *tap=[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(onTap:)];
                snapView.userInteractionEnabled=YES;
                [snapView addGestureRecognizer:tap];
                UISwipeGestureRecognizer *swipe=[[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(onTap:)];
                swipe.direction=UISwipeGestureRecognizerDirectionLeft;
                [snapView addGestureRecognizer:swipe];
                [[UIApplication sharedApplication].keyWindow addSubview:viewMenu];
            }
        }];
    }
}

-(void)startAnimate:(CGFloat)duration Success:(BOOL)bSuccess Block:(void (^)())block
{
    completeBlock=block;
    count=duration*60;
    originX=vcBind.navigationController.view.frame.origin.x;
    bExpandSuccess=bSuccess;
    if(bSuccess)
    {
        restlen=(widthMenu-originX*1.0)/count;
    }
    else
    {
        restlen=originX*1.0/count;
    }
    dynamicCount=0;
    link=[CADisplayLink displayLinkWithTarget:self selector:@selector(link:)];
    [link addToRunLoop:[NSRunLoop currentRunLoop] forMode:NSRunLoopCommonModes];
}

-(void)link:(CADisplayLink*)displayLink
{
    if(dynamicCount>=count)
    {
        CGRect frame=vcBind.navigationController.view.frame;
        CATransform3D matrixView1,matrixView2;
        if(bExpandSuccess)
        {
            frame.origin.x=widthMenu;
            matrixView1=CATransform3DIdentity;
            matrixView1.m34=-1/1000.0;
            matrixView2=CATransform3DIdentity;
            matrixView2.m34=-1/1000.0;
            matrixView2=CATransform3DTranslate(matrixView2, frame.origin.x, 0, 0);
        }
        else
        {
            frame.origin.x=0;
            matrixView1=CATransform3DMakeRotation(M_PI_2, 0, 1, 0);
            matrixView1.m34=-1/1000.0;
            matrixView2=CATransform3DMakeRotation(-M_PI_2, 0, 1, 0);
            matrixView2.m34=-1/1000.0;
        }
        view1.layer.transform=matrixView1;
        view2.layer.transform=matrixView2;
        vcBind.navigationController.view.frame=frame;
        if(completeBlock)
        {
            completeBlock();
            completeBlock=nil;
        }
        [link invalidate];
        link=nil;
        _state=EXPAND;
    }
    else
    {
        CGRect frame=vcBind.navigationController.view.frame;
        if(bExpandSuccess)
        {
            frame.origin.x=originX+restlen*(dynamicCount+1);
        }
        else
        {
            frame.origin.x=originX-restlen*(dynamicCount+1);
        }
        CGFloat radius=asin(frame.origin.x/widthMenu);
        CATransform3D matrixView1=CATransform3DIdentity;
        matrixView1.m34=-1/1000.0;
        CATransform3D matrixView2=CATransform3DIdentity;
        matrixView2.m34=-1/1000.0;
        matrixView2=CATransform3DTranslate(matrixView2, frame.origin.x, 0, 0);
        matrixView2=CATransform3DRotate(matrixView2, -M_PI_2+radius, 0, 1, 0);
        view1.layer.transform=CATransform3DRotate(matrixView1, M_PI_2- radius, 0, 1, 0);
        view2.layer.transform=matrixView2;
        vcBind.navigationController.view.frame=frame;
        _state=PENDING;
    }
    dynamicCount++;
}

-(void)onTap:(UITapGestureRecognizer*)rec
{
    [viewMenu removeFromSuperview];
    [[UIApplication sharedApplication].keyWindow addSubview:view1];
    [[UIApplication sharedApplication].keyWindow addSubview:view2];
    [self startAnimate:0.5 Success:NO Block:^{
        [snapView removeFromSuperview];
        [view1 removeFromSuperview];
        [view2 removeFromSuperview];
    }];
}

-(UIImage*)imageCache:(UIView*)view
{
    UIGraphicsBeginImageContextWithOptions(view.bounds.size,NO,[[UIScreen mainScreen] scale]);
    [view.layer renderInContext:UIGraphicsGetCurrentContext()];
    UIImage*img = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return img;
}

-(void)expand
{
        UIImage *img=[self imageCache:viewMenu];
        view1=[[UIImageView alloc] initWithFrame:CGRectMake(viewMenu.frame.origin.x, viewMenu.frame.origin.y, viewMenu.frame.size.width/2, viewMenu.frame.size.height)];
        view1.image=img;
        view1.layer.contentsRect=CGRectMake(0, 0, 0.5, 1);
        view1.layer.anchorPoint=CGPointMake(0, 0.5);
        view1.frame=CGRectMake(0, 0, viewMenu.frame.size.width/2, viewMenu.frame.size.height);
        view1.layer.transform=CATransform3DMakeRotation(M_PI_2, 0, 1, 0);
        [[UIApplication sharedApplication].keyWindow addSubview:view1];
        view2=[[UIImageView alloc] initWithFrame:CGRectMake(viewMenu.frame.origin.x+viewMenu.frame.size.width/2, viewMenu.frame.origin.y, viewMenu.frame.size.width/2, viewMenu.frame.size.height)];
        view2.image=img;
        view2.layer.contentsRect=CGRectMake(0.5, 0, 0.5, 1);
        view2.layer.anchorPoint=CGPointMake(1, 0.5);
        view2.frame=CGRectMake(-widthMenu/2, 0, viewMenu.frame.size.width/2, viewMenu.frame.size.height);
        view2.layer.transform=CATransform3DMakeRotation(-M_PI_2, 0, 1, 0);
        [[UIApplication sharedApplication].keyWindow addSubview:view2];
        snapView=[vcBind.navigationController.view snapshotViewAfterScreenUpdates:NO];
        [vcBind.navigationController.view addSubview:snapView];
        [self startAnimate:0.5 Success:YES  Block:^{
            [view1 removeFromSuperview];
            [view2 removeFromSuperview];
            if(vcBind.navigationController.view.frame.origin.x==0)
            {
                [snapView removeFromSuperview];
            }
            else
            {
                UITapGestureRecognizer *tap=[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(onTap:)];
                snapView.userInteractionEnabled=YES;
                [snapView addGestureRecognizer:tap];
                UISwipeGestureRecognizer *swipe=[[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(onTap:)];
                swipe.direction=UISwipeGestureRecognizerDirectionLeft;
                [snapView addGestureRecognizer:swipe];
                [[UIApplication sharedApplication].keyWindow addSubview:viewMenu];
            }
        }];
    
}

-(void)collapse
{
    [self onTap:nil];
}

+(instancetype)menuForView:(UIView*)view
{
	for(ExpandMenuItem *item in g_arr)
    {
        if(item.view==view)
        {
            return item.menu;
        }
    }
    return nil;
}

+(instancetype)menuForVC:(UIViewController*)vc
{
    for(ExpandMenuItem *item in g_arr)
    {
        if(item.vc==vc)
        {
            return item.menu;
        }
    }
    return nil;
}

@end








