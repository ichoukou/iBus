//
//  MenuContainer.m
//  iBus-iPhone
//
//  Created by yanghua on 5/19/13.
//  Copyright (c) 2013 yanghua. All rights reserved.
//

#import "MenuContainerController.h"
#import "FetchLineInfoOperation.h"
#import "BasicDataOperation.h"
#import "LineDao.h"
#import "ConfigCategoryDao.h"
#import "BusQueryController.h"
#import "SettingController.h"
#import "AboutController.h"
#import "FavoriteListController.h"

@interface MenuContainerController ()

//menu buttons
@property (nonatomic,retain) UIView *busQueryMenuView;
@property (nonatomic,retain) UIView *myBusZoomView;
@property (nonatomic,retain) UIView *aboutView;
@property (nonatomic,retain) UIView *findFriendView;
@property (nonatomic,retain) UIView *mapShowView;
@property (nonatomic,retain) UIView *settingView;

@property (nonatomic,assign) TAGS_OF_MENUITEM tagOfCurrentSelectedMenuItem;

//store all menu controllers
@property (nonatomic,retain) NSMutableDictionary *menuCtrllerDic;

@end

@implementation MenuContainerController

- (void)dealloc{
    [_busQueryMenuView release],_busQueryMenuView=nil;
    [_myBusZoomView release],_myBusZoomView=nil;
    [_aboutView release],_aboutView=nil;
    [_findFriendView release],_findFriendView=nil;
    [_mapShowView release],_mapShowView=nil;
    [_settingView release],_settingView=nil;
    [_menuCtrllerDic release],_menuCtrllerDic=nil;
    
    [super dealloc];
}

- (void)loadView{
    self.view=[[[UIView alloc] initWithFrame:Default_Frame_WithoutStatusBar] autorelease];
    [self initMenuContainer];
    
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    _menuCtrllerDic=[[NSMutableDictionary alloc] init];
	[self registerTapEventsForMenuItems];
    
    //fetch basic data
    [self fetchLineInfoAsync];
    //init basic data
    [self initBasicData];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - private methods -
- (void)initMenuContainer{
    UIView *menuContainerView=[[UIView alloc] initWithFrame:Default_Frame_WithoutStatusBar];
    menuContainerView.backgroundColor=[UIColor blackColor];
    [self.view addSubview:menuContainerView];
    

    //公交查询
    _busQueryMenuView=[[UIView alloc] initWithFrame:CGRectMake(Default_MenuItem_View_Origin_X, Default_MenuItem_Margin_Top, Default_MenuItem_View_Width, Default_MenuItem_View_Height)];
    self.busQueryMenuView.backgroundColor=Default_MenuItem_NormalColor;
    
    UIImageView *busQueryImgView=[[[UIImageView alloc] initWithFrame:CGRectMake(Default_MenuItem_ImageView_Origin_X, Default_MenuItem_ImageView_Origin_Y, Default_MenuItem_ImageView_Width, Default_MenuItem_ImageView_Height)] autorelease];
    busQueryImgView.image=[UIImage imageNamed:@"busQuery.png"];
    [self.busQueryMenuView addSubview:busQueryImgView];
    [self.busQueryMenuView setTag:TAG_BUSQUERY];
    [menuContainerView addSubview:self.busQueryMenuView];
    
    UILabel *busQueryLbl=[[[UILabel alloc] initWithFrame:CGRectMake(Default_MenuItem_Label_Origin_X, Default_MenuItem_Label_Origin_Y, Default_MenuItem_Label_Width, Default_MenuItem_Label_Height)] autorelease];
    busQueryLbl.text=@"公交查询";
    busQueryLbl.backgroundColor=[UIColor clearColor];
    busQueryLbl.font=[UIFont systemFontOfSize:Default_MenuItem_Label_FontSize];
    [self.busQueryMenuView addSubview:busQueryLbl];
    
    //查看地图
    _mapShowView=[[UIView alloc] initWithFrame:CGRectMake(Default_MenuItem_View_Origin_X, Default_MenuItem_Margin_Top+Default_MenuItem_View_Height+Default_MenuItem_View_Line_Splitor, Default_MenuItem_View_Width, Default_MenuItem_View_Height)];
    self.mapShowView.backgroundColor=Default_MenuItem_NormalColor;
    
    UIImageView *mapShowImgView=[[[UIImageView alloc] initWithFrame:CGRectMake(Default_MenuItem_ImageView_Origin_X, Default_MenuItem_ImageView_Origin_Y, Default_MenuItem_ImageView_Width, Default_MenuItem_ImageView_Height)] autorelease];
    mapShowImgView.image=[UIImage imageNamed:@"map.png"];
    [self.mapShowView addSubview:mapShowImgView];
    [self.mapShowView setTag:TAG_MAP];
    [menuContainerView addSubview:self.mapShowView];
    
    UILabel *mapShowLbl=[[[UILabel alloc] initWithFrame:CGRectMake(Default_MenuItem_Label_Origin_X, Default_MenuItem_Label_Origin_Y, Default_MenuItem_Label_Width, Default_MenuItem_Label_Height)] autorelease];
    mapShowLbl.text=@"查看地图";
    mapShowLbl.backgroundColor=[UIColor clearColor];
    mapShowLbl.font=[UIFont systemFontOfSize:Default_MenuItem_Label_FontSize];
    [self.mapShowView addSubview:mapShowLbl];
    
    //我的巴士空间
    _myBusZoomView=[[UIView alloc] initWithFrame:CGRectMake(Default_MenuItem_View_Origin_X, Default_MenuItem_Margin_Top+2*Default_MenuItem_View_Height+2*Default_MenuItem_View_Line_Splitor, Default_MenuItem_View_Width, Default_MenuItem_View_Height)];
    self.myBusZoomView.backgroundColor=Default_MenuItem_NormalColor;
    
    UIImageView *busZoomImgView=[[[UIImageView alloc] initWithFrame:CGRectMake(Default_MenuItem_ImageView_Origin_X, Default_MenuItem_ImageView_Origin_Y, Default_MenuItem_ImageView_Width, Default_MenuItem_ImageView_Height)] autorelease];
    busZoomImgView.image=[UIImage imageNamed:@"busZoom.png"];
    [self.myBusZoomView addSubview:busZoomImgView];
    [self.myBusZoomView setTag:TAG_BUSZOOM];
    [menuContainerView addSubview:self.myBusZoomView];
    
    UILabel *myBusZoomLbl=[[[UILabel alloc] initWithFrame:CGRectMake(Default_MenuItem_Label_Origin_X, Default_MenuItem_Label_Origin_Y, Default_MenuItem_Label_Width, Default_MenuItem_Label_Height)] autorelease];
    myBusZoomLbl.text=@"巴士空间";
    myBusZoomLbl.backgroundColor=[UIColor clearColor];
    myBusZoomLbl.font=[UIFont systemFontOfSize:Default_MenuItem_Label_FontSize];
    [self.myBusZoomView addSubview:myBusZoomLbl];
    
    
    //附近的人
    _findFriendView=[[UIView alloc] initWithFrame:CGRectMake(Default_MenuItem_View_Origin_X, Default_MenuItem_Margin_Top+3*Default_MenuItem_View_Height+3*Default_MenuItem_View_Line_Splitor, Default_MenuItem_View_Width, Default_MenuItem_View_Height)];
    self.findFriendView.backgroundColor=Default_MenuItem_NormalColor;
    
    UIImageView *findFriendImgView=[[[UIImageView alloc] initWithFrame:CGRectMake(Default_MenuItem_ImageView_Origin_X, Default_MenuItem_ImageView_Origin_Y, Default_MenuItem_ImageView_Width, Default_MenuItem_ImageView_Height)] autorelease];
    findFriendImgView.image=[UIImage imageNamed:@"friends.png"];
    [self.findFriendView addSubview:findFriendImgView];
    [self.findFriendView setTag:TAG_FRIENDS];
    [menuContainerView addSubview:self.findFriendView];
    
    UILabel *findFriendLbl=[[[UILabel alloc] initWithFrame:CGRectMake(Default_MenuItem_Label_Origin_X, Default_MenuItem_Label_Origin_Y, Default_MenuItem_Label_Width, Default_MenuItem_Label_Height)] autorelease];
    findFriendLbl.text=@"附近的人";
    findFriendLbl.backgroundColor=[UIColor clearColor];
    findFriendLbl.font=[UIFont systemFontOfSize:Default_MenuItem_Label_FontSize];
    [self.findFriendView addSubview:findFriendLbl];
    
    //关于
    _aboutView=[[UIView alloc] initWithFrame:CGRectMake(Default_MenuItem_View_Origin_X, Default_MenuItem_Margin_Top+4*Default_MenuItem_View_Height+4*Default_MenuItem_View_Line_Splitor, Default_MenuItem_View_Width, Default_MenuItem_View_Height)];
    self.aboutView.backgroundColor=Default_MenuItem_NormalColor;
    
    UIImageView *aboutImgView=[[[UIImageView alloc] initWithFrame:CGRectMake(Default_MenuItem_ImageView_Origin_X, Default_MenuItem_ImageView_Origin_Y, Default_MenuItem_ImageView_Width, Default_MenuItem_ImageView_Height)] autorelease];
    aboutImgView.image=[UIImage imageNamed:@"about.png"];
    [self.aboutView addSubview:aboutImgView];
    [self.aboutView setTag:TAG_ABOUT];
    [menuContainerView addSubview:self.aboutView];
    
    UILabel *aboutLbl=[[[UILabel alloc] initWithFrame:CGRectMake(Default_MenuItem_Label_Origin_X, Default_MenuItem_Label_Origin_Y, Default_MenuItem_Label_Width, Default_MenuItem_Label_Height)] autorelease];
    aboutLbl.text=@"关于应用";
    aboutLbl.backgroundColor=[UIColor clearColor];
    aboutLbl.font=[UIFont systemFontOfSize:Default_MenuItem_Label_FontSize];
    [self.aboutView addSubview:aboutLbl];
    
    //设置
    _settingView=[[UIView alloc] initWithFrame:CGRectMake(Default_MenuItem_View_Origin_X, Default_MenuItem_Margin_Top+5*Default_MenuItem_View_Height+5*Default_MenuItem_View_Line_Splitor, Default_MenuItem_View_Width, Default_MenuItem_View_Height)];
    self.settingView.backgroundColor=Default_MenuItem_NormalColor;
    
    UIImageView *settingImgView=[[[UIImageView alloc] initWithFrame:CGRectMake(Default_MenuItem_ImageView_Origin_X, Default_MenuItem_ImageView_Origin_Y, Default_MenuItem_ImageView_Width, Default_MenuItem_ImageView_Height)] autorelease];
    settingImgView.image=[UIImage imageNamed:@"setting.png"];
    [self.settingView addSubview:settingImgView];
    [self.settingView setTag:TAG_SETTING];
    [menuContainerView addSubview:self.settingView];
    
    UILabel *settingLbl=[[[UILabel alloc] initWithFrame:CGRectMake(Default_MenuItem_Label_Origin_X, Default_MenuItem_Label_Origin_Y, Default_MenuItem_Label_Width, Default_MenuItem_Label_Height)] autorelease];
    settingLbl.text=@"应用设置";
    settingLbl.backgroundColor=[UIColor clearColor];
    settingLbl.font=[UIFont systemFontOfSize:Default_MenuItem_Label_FontSize];
    [self.settingView addSubview:settingLbl];
    
    
    [self.view addSubview:menuContainerView];
    [menuContainerView release];
    
}

- (void)registerTapEventsForMenuItems{
    [self.busQueryMenuView addGestureRecognizer:[[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleGesture:)] autorelease]];
    
    [self.mapShowView addGestureRecognizer:[[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleGesture:)] autorelease]];
    
    [self.findFriendView addGestureRecognizer:[[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleGesture:)] autorelease]];
    
    [self.aboutView addGestureRecognizer:[[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleGesture:)] autorelease]];
    
    [self.myBusZoomView addGestureRecognizer:[[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleGesture:)] autorelease]];
    
    [self.settingView addGestureRecognizer:[[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleGesture:)] autorelease]];
}

- (void)handleGesture:(UISwipeGestureRecognizer*)gestureRecognizer{
    [self.view viewWithTag:self.tagOfCurrentSelectedMenuItem].backgroundColor=Default_MenuItem_NormalColor;
    
    if (gestureRecognizer.state==UIGestureRecognizerStateBegan) {
        [gestureRecognizer view].backgroundColor=Default_MenuItem_HighlightColor;
    }else if(gestureRecognizer.state==UIGestureRecognizerStateEnded){
        [gestureRecognizer view].backgroundColor=Default_MenuItem_HighlightColor;
    }else if (gestureRecognizer.state==UIGestureRecognizerStateCancelled){
        [gestureRecognizer view].backgroundColor=Default_MenuItem_NormalColor;
    }
    
    if (self.tagOfCurrentSelectedMenuItem==gestureRecognizer.view.tag) {
        return;
    }
    
    self.tagOfCurrentSelectedMenuItem=gestureRecognizer.view.tag;
    
    ((ZUUIRevealController*)((AppDelegate*)appDelegateObj).zuuiRevealCtrller).frontViewController=[self getMenuCtrllerFromMenuCtrllerDictionaryWithTag:gestureRecognizer.view.tag];
}


- (UINavigationController*)getMenuCtrllerFromMenuCtrllerDictionaryWithTag:(TAGS_OF_MENUITEM)tag{
    NSString *key=[NSString stringWithFormat:@"%d",tag];
    if(self.menuCtrllerDic[key]){
        return self.menuCtrllerDic[key];
    }

    //if not , create and return
    UINavigationController *navCtrller=nil;

    switch (tag) {
        case TAG_BUSQUERY:
        {
            BusQueryController *busQueryCtrller=[[[BusQueryController alloc] init] autorelease];
            navCtrller=[[[UINavigationController alloc] initWithRootViewController:busQueryCtrller] autorelease];
        }
            break;
            
        case TAG_MAP:
            NSLog(@"%d",TAG_MAP);
            break;
            
        case TAG_BUSZOOM:
        {
            FavoriteListController *followingStationListCtrller=[[[FavoriteListController alloc] init] autorelease];
            navCtrller=[[[UINavigationController alloc] initWithRootViewController:followingStationListCtrller] autorelease];
        }
            break;
            
        case TAG_FRIENDS:
            NSLog(@"%d",TAG_FRIENDS);
            break;
            
        case TAG_ABOUT:
            NSLog(@"%d",TAG_ABOUT);
            break;
            
        case TAG_SETTING:
        {
            SettingController *settingCtrller=[[[SettingController alloc] init] autorelease];
            navCtrller=[[[UINavigationController alloc] initWithRootViewController:settingCtrller] autorelease];
        }
            break;
            
        default:
            return nil;
            break;
    }
    
    [self.menuCtrllerDic setObject:navCtrller forKey:key];
    
    return navCtrller;
}

- (void)fetchLineInfoAsync{
    if (![LineDao checkIsInited]) {
        FetchLineInfoOperation *fenchLineInfoOperation=[[[FetchLineInfoOperation alloc] init] autorelease];
        [((AppDelegate*)appDelegateObj).operationQueueCenter addOperation:fenchLineInfoOperation];
    }
}

- (void)initBasicData{
    if (![ConfigCategoryDao checkIsInited]) {
        BasicDataOperation *basicDataOperation=[[[BasicDataOperation alloc] init] autorelease];
        [((AppDelegate*)appDelegateObj).operationQueueCenter addOperation:basicDataOperation];
    }
}


@end
