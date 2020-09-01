//
//  KSShortVideoCell.h
//  KSDanmuViewDemo
//
//  Created by YaphetS on 2020/9/1.
//  Copyright © 2020 sapphire. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AVFoundation/AVFoundation.h>

typedef void (^OnPlayerReady)(void);
NS_ASSUME_NONNULL_BEGIN
@class KSVideoModel;
@class AVPlayerView;
@interface KSShortVideoCell : UITableViewCell
// data
@property (nonatomic, strong) KSVideoModel *playModel;
@property (nonatomic, strong) AVPlayerView *playerView;

@property (nonatomic, strong) OnPlayerReady   onPlayerReady;
@property (nonatomic, assign) BOOL            isPlayerReady;

// Play Methods
- (void)initData:(KSVideoModel *)model;
- (void)play;
- (void)pause;
- (void)replay;
- (void)startDownloadBackgroundTask;
- (void)startDownloadHighPriorityTask;

//Tesing Methods
- (void)playVideoWithItem:(AVPlayerItem *)item;

// Static Methods
+ (NSString *)reuseIdentifier;
@end
NS_ASSUME_NONNULL_END
