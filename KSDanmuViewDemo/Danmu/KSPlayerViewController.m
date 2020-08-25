//
//  KSPlayerViewController.m
//  KSDanmuViewDemo
//
//  Created by YaphetS on 2020/8/24.
//  Copyright © 2020 sapphire. All rights reserved.
//

#import "KSPlayerViewController.h"
#import "KSPortraitDanmuView.h"
#import "UIColor+Utils.h"
#import "Masonry.h"

@interface KSPlayerViewController ()
@property (nonatomic, strong) KSPortraitDanmuView *danmuView;
@end

@implementation KSPlayerViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor colorFromHexRGB:@"#040320"];;
    self.navigationController.navigationBarHidden = YES;
    
    [self.view addSubview:self.danmuView];
    self.danmuView.backgroundColor = [UIColor clearColor];
}

- (KSPortraitDanmuView *)danmuView
{
    if (!_danmuView) {
        _danmuView = [[KSPortraitDanmuView alloc] initWithFrame:CGRectMake(0, 400, CGRectGetWidth(self.view.bounds), CGRectGetHeight(self.view.bounds)-400)];
    }
    return _danmuView;
}

@end
