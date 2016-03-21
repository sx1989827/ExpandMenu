# ExpandMenu
一个可以折叠菜单的动画特效

![](https://github.com/sx1989827/ExpandMenu/raw/master/ExpandMenu/1.gif)

##用法
直接将工程里的ExpandMenu文件夹拖入你的项目，在你需要添加的文件中引入ExpandMenu.h

##例子
-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    UIView *view=[[UIView alloc] initWithFrame:CGRectMake(0, 0, 300, 300)];
    view.backgroundColor=[UIColor orangeColor];
    menu=[[ExpandMenu alloc] init];
    [menu setExpandMenu:view Width:[UIScreen mainScreen].bounds.size.width*2/3 VC:self];
}

##注意
目前用的是navigationController.view来做页面的偏移，所以需要在有navigationController作为父VC的情况在，在viewWillAppear里面添加菜单的初始化才有效。

##后记
QQ群：1群：460483960（目前已满） 2群：239309957 这是我们的ios项目的开发者qq群，这是一个纯粹的ios开发者社区，里面汇聚了众多有经验的ios开发者，没有hr和打扰和广告的骚扰，为您创造一个纯净的技术交流环境，如果您对我的项目以及对ios开发有任何疑问，都可以加群交流，欢迎您的加入~
