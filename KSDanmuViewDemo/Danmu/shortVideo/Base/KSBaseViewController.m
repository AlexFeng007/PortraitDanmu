//
//  KSBaseViewController.m
//  KSDanmuViewDemo
//
//  Created by YaphetS on 2020/9/1.
//  Copyright © 2020 sapphire. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "KSBaseViewController.h"

@interface KSBaseViewController ()
@end

@implementation KSBaseViewController

- (void)viewDidLoad {
    [super viewDidLoad];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self initNavigationBarTransparent];
}

- (void)initNavigationBarTransparent {
    [self setNavigationBarTitleColor:[UIColor whiteColor]];
    [self setNavigationBarBackgroundImage:[UIImage new]];
    [self setStatusBarStyle:UIStatusBarStyleLightContent];
    [self setNavigationBarShadowImage:[UIImage new]];
    [self initLeftBarButton:@"icon_titlebar_whiteback"];
    //[self setBackgroundColor:ColorThemeBackground];
    [self setBackgroundColor:[UIColor clearColor]];
}


- (void) setBackgroundColor:(UIColor *)color {
    self.view.backgroundColor = color;
}

- (void) setTranslucentCover {
    UIBlurEffect *blurEffect =[UIBlurEffect effectWithStyle:UIBlurEffectStyleDark];
    UIVisualEffectView *visualEffectView = [[UIVisualEffectView alloc]initWithEffect:blurEffect];
    visualEffectView.frame = self.view.bounds;
    visualEffectView.alpha = 1;
    [self.view addSubview:visualEffectView];
}

- (void) initLeftBarButton:(NSString *)imageName {
    UIBarButtonItem *leftButton = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:imageName] style:UIBarButtonItemStylePlain target:self action:@selector(back)];
    leftButton.tintColor = [UIColor whiteColor];
    self.navigationItem.leftBarButtonItem = leftButton;
}

- (void) setStatusBarHidden:(BOOL) hidden {
    [[UIApplication sharedApplication] setStatusBarHidden:hidden];
}

- (void) setStatusBarBackgroundColor:(UIColor *)color {
    if (@available(iOS 13.0,*)) {
        UIView *statusBar = [[UIView alloc] initWithFrame:[UIApplication sharedApplication].keyWindow.windowScene.statusBarManager.statusBarFrame];
        [[UIApplication sharedApplication].keyWindow addSubview:statusBar];
        statusBar.backgroundColor= color;
    }
    else
    {
        UIView *statusBar = [[[UIApplication sharedApplication] valueForKey:@"statusBarWindow"] valueForKey:@"statusBar"];
        if ([statusBar respondsToSelector:@selector(setBackgroundColor:)]) {
            statusBar.backgroundColor = color;
        }
    }
}

- (void) setNavigationBarTitle:(NSString *)title {
    self.navigationItem.title = title;
}

- (void) setNavigationBarTitleColor:(UIColor *)color {
    [self.navigationController.navigationBar setTitleTextAttributes:@{NSForegroundColorAttributeName:color}];
}

- (void) setNavigationBarBackgroundColor:(UIColor *)color {
    [self.navigationController.navigationBar setBackgroundColor:color];
}

- (void) setNavigationBarBackgroundImage:(UIImage *)image {
    [self.navigationController.navigationBar setBackgroundImage:image forBarMetrics:UIBarMetricsDefault];
}

- (void) setStatusBarStyle:(UIStatusBarStyle)style {
    [UIApplication sharedApplication].statusBarStyle = style;
}

- (void) setNavigationBarShadowImage:(UIImage *)image {
    [self.navigationController.navigationBar setShadowImage:image];
}

- (void) back {
    [self.navigationController popViewControllerAnimated:true];
}

- (void) dismiss {
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (CGFloat) navagationBarHeight {
    return self.navigationController.navigationBar.frame.size.height;
}

- (void) setLeftButton:(NSString *)imageName {
    UIButton *leftButton = [UIButton buttonWithType:UIButtonTypeCustom];
    leftButton.frame = CGRectMake(15.0f, StatusBarHeight + 11, 20.0f, 20.0f);
    [leftButton setBackgroundImage:[UIImage imageNamed:imageName] forState:UIControlStateNormal];
    [leftButton addTarget:self action:@selector(dismiss) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:leftButton];
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [self.view bringSubviewToFront:leftButton];
    });
}

- (void) setBackgroundImage:(NSString *)imageName {
    UIImageView *background = [[UIImageView alloc] initWithFrame:self.view.bounds];
    background.clipsToBounds = YES;
    background.contentMode = UIViewContentModeScaleAspectFill;
    background.image = [UIImage imageNamed:imageName];
    [self.view addSubview:background];
}

@end
