//
//  KSDanMuModel.h
//  KSDanmuViewDemo
//
//  Created by YaphetS on 2020/8/24.
//  Copyright © 2020 sapphire. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "KSDanmuMessageType.h"

NS_ASSUME_NONNULL_BEGIN

@interface KSDanMuModel : NSObject
@property (nonatomic, assign) KSMessageType  type;           //消息类型
@property (nonatomic, assign) BOOL         isSelf;         //是否是自己发送的消息或礼物

@property (nonatomic, copy)   NSString     *color;         //消息显示颜色RGB值
@property (nonatomic, strong) NSString     *nickname;      //非系统消息时，发送弹幕或送礼物的用户昵称
@property (nonatomic, strong) NSString     *giverNickName;  //给予者昵称
@property (nonatomic, copy)   NSString     *ownerName;      //接收礼物主播/跳转房间的主播名

@property (nonatomic, strong) NSString     *content;       //显示正文
@property (nonatomic, strong) NSString     *giftName;      //礼物名称
@property (nonatomic, strong) NSString     *giftId;      //礼物id
@property (nonatomic, strong) NSString     *giftUrl;       //礼物图标

//布局相关
@property (nonatomic, assign) CGFloat danmuRowHeight;   //cell 高度缓存
@end

NS_ASSUME_NONNULL_END
