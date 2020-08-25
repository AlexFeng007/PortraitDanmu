//
//  KSDanmuViewCell.h
//  KSDanmuViewDemo
//
//  Created by YaphetS on 2020/8/24.
//  Copyright © 2020 sapphire. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "KSDanMuModel.h"

@class KSDanMuModel;
NS_ASSUME_NONNULL_BEGIN

@interface KSDanmuViewCell : UITableViewCell
- (void)configWithModel:(KSDanMuModel *)model;
+ (NSString *)cellIdentifier;
@end

NS_ASSUME_NONNULL_END
