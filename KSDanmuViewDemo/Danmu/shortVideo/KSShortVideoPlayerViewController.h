//
//  KSShortVideoPlayerViewController.h
//  KSDanmuViewDemo
//
//  Created by YaphetS on 2020/9/1.
//  Copyright © 2020 sapphire. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "KSBaseViewController.h"

NS_ASSUME_NONNULL_BEGIN
@interface KSShortVideoPlayerViewController : KSBaseViewController
@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, assign) NSInteger   currentIndex;
@end
NS_ASSUME_NONNULL_END
