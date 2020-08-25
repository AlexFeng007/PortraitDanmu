//
//  KSPortraitDanmuView.h
//  KSDanmuViewDemo
//
//  Created by YaphetS on 2020/8/24.
//  Copyright © 2020 sapphire. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN
@class  KSDanMuModel;

@protocol KSPortraitDanmuViewDelegate <NSObject>
@optional
- (void)KSPortraitDanmuViewClickedDanmu:(KSDanMuModel *)danmuModel isChat:(BOOL)isChat;
@end

@interface KSPortraitDanmuView : UIView

@property (nonatomic, assign) id <KSPortraitDanmuViewDelegate> delegate;

/**
 *  刷新弹幕数据
 *
 *  @param model 弹幕model
 */
-(void)refreshChatTable:(KSDanMuModel*)model;

/**
 *  刷新弹幕table
 */
-(void)reloadChatTable;

/**
 *  清空弹幕
 */
-(void)cleanChats;

/**
 *  释放定时器
 */
-(void)releaseTimer;

/**
 *  唤醒定时器
 */
-(void)resumeTimer;

//从本地删除违规弹幕
- (void)deleteIllegalDanmu;

@end

NS_ASSUME_NONNULL_END
