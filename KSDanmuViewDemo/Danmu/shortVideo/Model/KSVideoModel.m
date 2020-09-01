//
//  KSVideoModel.m
//  KSDanmuViewDemo
//
//  Created by YaphetS on 2020/9/1.
//  Copyright © 2020 sapphire. All rights reserved.
//

#import "KSVideoModel.h"
#import "MJExtension.h"

@implementation KSVideoModel
+ (NSDictionary *)mj_replacedKeyFromPropertyName
{
    return @{
        @"videoUrl":@"video_url",
        @"videoName":@"video_name",
    };
}
@end
