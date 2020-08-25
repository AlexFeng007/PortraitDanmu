//
//  KSPortraitDanmuView.m
//  KSDanmuViewDemo
//
//  Created by YaphetS on 2020/8/24.
//  Copyright © 2020 sapphire. All rights reserved.
//
#import <UIKit/UIKit.h>
#import "KSPortraitDanmuView.h"
#import "HWWeakTimer.h"
#import "Masonry.h"
#import "KSDanMuModel.h"
#import "KSDanmuViewCell.h"
#import "MJExtension.h"


static CGFloat const kDanmuViewCellHorizontalMargin = 6;

@interface KSPortraitDanmuView () <UITableViewDelegate,UITableViewDataSource>
@property (nonatomic, strong) UITableView *danmuTable;

@property (nonatomic, strong) NSMutableArray *arrayChat;               //保存当前table显示的coretext封装后的弹幕数组
@property (nonatomic, strong) NSMutableArray *arrayDanmuModels;        //保存原始弹幕数据，举报违规时用
@property (nonatomic, strong) NSMutableArray *arrayCurrentDanmuModels; //保存当前table显示的对应弹幕

@property (nonatomic, strong) NSTimer        *reloadTimer;             //定时器更新弹幕table
@property (nonatomic, strong) UIButton       *btnHasNew;               //新消息Btn
@property (nonatomic, assign) BOOL           hasNewMessage;            //是否有新消息
@property (nonatomic, assign) BOOL           canAutoScroll;            //弹幕table是否能自动滚动到底部

//Test
@property (nonatomic, copy) NSArray *danmuDateSource;
@property (nonatomic, assign) NSInteger indexCount;
@end

@implementation KSPortraitDanmuView

- (id)initWithFrame:(CGRect)frame{
    self = [super initWithFrame:frame];
    if (self) {
        _canAutoScroll = YES;
        _arrayChat               = [[NSMutableArray alloc] init];
        _arrayDanmuModels        = [[NSMutableArray alloc] init];
        _arrayCurrentDanmuModels = [[NSMutableArray alloc] init];

        //_reloadTimer = [HWWeakTimer scheduledTimerWithTimeInterval:1 target:self selector:@selector(reloadChatTable) userInfo:nil repeats:YES];
        
        [self addSubview:self.danmuTable];
        self.danmuTable.backgroundColor = [UIColor clearColor];
        [self.danmuTable mas_makeConstraints:^(MASConstraintMaker *make) {
            make.edges.equalTo(self);
        }];
        
        
        //TodoTest:load DataSource
        _arrayChat = [KSDanMuModel mj_objectArrayWithKeyValuesArray:self.danmuDateSource];
        _hasNewMessage = YES;
        _indexCount = 0;
        
        _reloadTimer = [HWWeakTimer scheduledTimerWithTimeInterval:1.0 target:self selector:@selector(addDanmuModel) userInfo:nil repeats:YES];
    }
    return self;
}

- (void)dealloc
{
    [_reloadTimer invalidate];
    _reloadTimer = nil;
}

#pragma mark: lazy
- (UITableView *)danmuTable{
    if (!_danmuTable) {
        _danmuTable = [[UITableView alloc] initWithFrame:self.bounds];
        _danmuTable.delegate        = self;
        _danmuTable.dataSource      = self;
        _danmuTable.separatorStyle  = UITableViewCellSeparatorStyleNone;
        _danmuTable.backgroundColor = [UIColor clearColor];
        _danmuTable.bounces = NO;
        _danmuTable.showsHorizontalScrollIndicator = NO;
        _danmuTable.showsVerticalScrollIndicator = NO;
        _danmuTable.allowsSelection = NO;
        
        //去掉UITableviewCell左侧15像素空白
        if ([_danmuTable respondsToSelector:@selector(setSeparatorInset:)]) {
            [_danmuTable setSeparatorInset:UIEdgeInsetsZero];
        }
        
        if ([_danmuTable respondsToSelector:@selector(setLayoutMargins:)]) {
            [_danmuTable setLayoutMargins:UIEdgeInsetsZero];
        }
    }
    return _danmuTable;
}

- (UIButton *)btnHasNew{
    if (!_btnHasNew) {
        _btnHasNew = [[UIButton alloc] init];
        _btnHasNew.hidden = YES;
        [self addSubview:_btnHasNew];
        [_btnHasNew mas_makeConstraints:^(MASConstraintMaker *make) {
            make.bottom.equalTo(self.mas_bottom).with.offset(-10);
            make.right.equalTo(self.mas_right).with.offset(-10);
        }];
        [_btnHasNew setImage:[UIImage imageNamed:@"btnHasNewMessage"] forState:UIControlStateNormal];
        [_btnHasNew addTarget:self action:@selector(actionScrollToBottom:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _btnHasNew;
}

- (void)actionScrollToBottom:(UIButton*)btn{
    if (_arrayChat.count) {
        
        [_arrayChat removeAllObjects];
        
        [_arrayCurrentDanmuModels removeAllObjects];
        [_arrayCurrentDanmuModels addObjectsFromArray:_arrayDanmuModels];
        
        [self.danmuTable reloadData];
        if (_arrayChat.count) {
            [self.danmuTable scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:_arrayChat.count - 1 inSection:0] atScrollPosition:UITableViewScrollPositionBottom animated:NO];
        }
        _canAutoScroll    = YES;
        self.btnHasNew.hidden = YES;
    }
}

#pragma mark: 弹幕显示相关
-(void)releaseTimer{
    if(_reloadTimer){
        [_reloadTimer invalidate];
        _reloadTimer = nil;
    }
}

-(void)resumeTimer{
    if (!_reloadTimer) {
        _reloadTimer = [HWWeakTimer scheduledTimerWithTimeInterval:0.2 target:self selector:@selector(reloadChatTable) userInfo:nil repeats:YES];
    }
}

//测试增加Danmu刷新
- (void)addDanmuModel
{
    // 模拟socket 收到弹幕推送消息
    KSDanMuModel *model = [self.arrayChat objectAtIndex:self.indexCount];
    self.indexCount++;
    [self.arrayDanmuModels addObject:model];
    [self refreshChatTable];
}

//更新弹幕列表数据
-(void)refreshChatTable{
    
    if (_canAutoScroll) {
        [_arrayCurrentDanmuModels removeAllObjects];
        [_arrayCurrentDanmuModels addObjectsFromArray:_arrayDanmuModels];
        
        [self.danmuTable reloadData];
        
        if (_arrayCurrentDanmuModels.count) {
            NSIndexPath *indexPath = [NSIndexPath indexPathForRow:_arrayCurrentDanmuModels.count - 1 inSection:0];
            [self.danmuTable scrollToRowAtIndexPath:indexPath atScrollPosition:UITableViewScrollPositionBottom animated:NO];
        }
    }
}

-(void)reloadChatTable{
    if (_hasNewMessage) {
        _hasNewMessage = NO;
        
        if (_canAutoScroll) {
            [_arrayChat removeAllObjects];
            
            [_arrayCurrentDanmuModels removeAllObjects];
            [_arrayCurrentDanmuModels addObjectsFromArray:_arrayDanmuModels];
            
            [self.danmuTable reloadData];
            // 3、滚动至当前行
            if (_arrayChat.count) {
                
                NSIndexPath *indexPath = [NSIndexPath indexPathForRow:_arrayChat.count - 1 inSection:0];
                [self.danmuTable scrollToRowAtIndexPath:indexPath atScrollPosition:UITableViewScrollPositionBottom animated:NO];
            }
        }else{
            if (self.danmuTable.contentSize.height < self.danmuTable.bounds.size.height) {
                [_arrayChat removeAllObjects];
                
                [_arrayCurrentDanmuModels removeAllObjects];
                [_arrayCurrentDanmuModels addObjectsFromArray:_arrayDanmuModels];
                
                [self.danmuTable reloadData];
            }else{
                self.btnHasNew.hidden = NO;
            }
            
        }
    }
}

//切换房间时清空上一个直播间的聊天记录
-(void)cleanChats{
    [_arrayChat removeAllObjects];
    [_arrayDanmuModels removeAllObjects];
    
    self.btnHasNew.hidden = YES;
    [self.danmuTable reloadData];
}

#pragma mark: Delegate && DataSource
-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 1;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return [_arrayCurrentDanmuModels count];
    
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    KSDanMuModel *model = [_arrayCurrentDanmuModels objectAtIndex:indexPath.row];
    return model.danmuRowHeight + 5.f;
}

-(UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    NSString *reuseIdentifier = @"KSDanmuViewCell";
    
    KSDanmuViewCell *cell = [tableView dequeueReusableCellWithIdentifier:reuseIdentifier];
    if (!cell) {
        cell = [[KSDanmuViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:reuseIdentifier];
        cell.backgroundColor = [UIColor clearColor];
        cell.selectionStyle  = UITableViewCellSelectionStyleNone;
    }

    for (UIView *aV in cell.contentView.subviews) {
        [aV removeFromSuperview];
    }
    
    KSDanMuModel *model = [_arrayDanmuModels objectAtIndex:indexPath.row];
    [cell configWithModel:model];
    
    cell.backgroundColor = [UIColor redColor];
    
    if (indexPath.row % 2 == 0) {
        cell.contentView.backgroundColor = [UIColor greenColor];
    }else{
        cell.contentView.backgroundColor = [UIColor brownColor];
    }
    
    //UIView *backGroundView = [[UIView alloc] init];

    return cell;
}

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if ([cell respondsToSelector:@selector(setSeparatorInset:)]) {
        [cell setSeparatorInset:UIEdgeInsetsZero];
    }
    
    if ([cell respondsToSelector:@selector(setLayoutMargins:)]) {
        [cell setLayoutMargins:UIEdgeInsetsZero];
    }
}

#pragma mark - UIScrollViewDelegate
//-(void)scrollViewWillBeginDragging:(UIScrollView *)scrollView{
//    if (scrollView == self.danmuTable) {
//        _canAutoScroll = NO;
//    }
//}
//
//- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate{
//    if (scrollView == self.danmuTable) {
//        CGPoint offset = scrollView.contentOffset;
//        CGRect bounds = scrollView.bounds;
//        CGSize size = scrollView.contentSize;
//        UIEdgeInsets inset = scrollView.contentInset;
//        float y = offset.y + bounds.size.height - inset.bottom;
//        float h = size.height;
//        // 手动滚到地步后打开自动滚动
//        if(y >= h ) {
//            if(!_canAutoScroll){
//
//                [_arrayChat removeAllObjects];
//
//                [_arrayCurrentDanmuModels removeAllObjects];
//                [_arrayCurrentDanmuModels addObjectsFromArray:_arrayDanmuModels];
//
//                [self.danmuTable reloadData];
//                if(_arrayChat.count){
//                    [self.danmuTable scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:_arrayChat.count - 1 inSection:0] atScrollPosition:UITableViewScrollPositionBottom animated:NO];
//
//                }
//                _canAutoScroll    = YES;
//                self.btnHasNew.hidden = YES;
//
//            }
//        }
//
//    }
//
//}


//-(void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView{
//    if (scrollView == self.danmuTable) {
//        CGPoint offset = scrollView.contentOffset;
//        CGRect bounds = scrollView.bounds;
//        CGSize size = scrollView.contentSize;
//        UIEdgeInsets inset = scrollView.contentInset;
//        float y = offset.y + bounds.size.height - inset.bottom;
//        float h = size.height;
//        // 手动滚到地步后打开自动滚动
//        if(y >= h ) {
//            if(!_canAutoScroll){
//
//                [_arrayChat removeAllObjects];
//
//                [_arrayCurrentDanmuModels removeAllObjects];
//                [_arrayCurrentDanmuModels addObjectsFromArray:_arrayDanmuModels];
//
//
//                [self.danmuTable reloadData];
//
//                if(_arrayChat.count){
//                     [self.danmuTable scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:_arrayChat.count - 1 inSection:0] atScrollPosition:UITableViewScrollPositionBottom animated:NO];
//                }
//
//                _canAutoScroll    = YES;
//                self.btnHasNew.hidden = YES;
//
//            }
//        }
//
//    }
//
//}

//从本地删除违规弹幕
- (void)deleteIllegalDanmu{
    //判断违规弹幕逻辑
    
    [self.danmuTable reloadData];
}

#pragma mark: DanmuModel dataSource
- (NSArray *)danmuDateSource
{
    if (!_danmuDateSource) {
        _danmuDateSource = @[
        @{
            @"nickname": @"fengbofeng",
            @"content": @"主播能加你一个微信么？主播能加你一个微信么？主播能加你一个微信么？主播能加你一个微信么？主播能加你一个微信么?",
            },
        @{
            @"nickname": @"fengbofeng",
            @"content": @"献上一束花,献上一束花,献上一束花,献上一束花献上一束花,献上一束花献上一束花,献上一束花献上一束花,献上一束花献上一束花,献上一束花",
            },
        @{
            @"nickname": @"果汁果汁",
            @"content": @"递上果汁,递上果汁,递上果汁😄",
            },
        @{
            @"nickname": @"棒棒糖棒棒糖棒棒糖棒",
            @"content": @"递上棒棒糖",
            },
        @{
            @"nickname": @"泡泡糖泡泡糖泡泡糖",
            @"content": @"一起吃泡泡糖吧,今晚一起吃泡泡糖吗？？？？？？？？？？？？？",
            },
        @{
            @"nickname": @"fengbo11",
            @"content": @"主播能加你一个微信么？",
            },
        @{
            @"nickname": @"jack",
            @"content": @"献上一束花,献上一束花",
           },
        @{
            @"nickname": @"果汁",
            @"content": @"递上果汁,递上果汁,递上果汁😄",
           },
        @{
            @"nickname": @"棒棒糖",
            @"content": @"递上棒棒糖",
           },
        @{
            @"nickname": @"泡泡糖",
            @"content": @"一起吃泡泡糖吧,今晚一起吃泡泡糖吗？？？？？？？？？？？？？",
           },
        @{
            @"nickname": @"fengbo22",
            @"content": @"主播能加你一个微信么？",
            },
        @{
            @"nickname": @"jack",
            @"content": @"献上一束花,献上一束花",
            },
        @{
            @"nickname": @"果汁",
            @"content": @"递上果汁,递上果汁,递上果汁😄",
            },
        @{
            @"nickname": @"棒棒糖",
            @"content": @"递上棒棒糖",
            },
        @{
            @"nickname": @"泡泡糖",
            @"content": @"一起吃泡泡糖吧,今晚一起吃泡泡糖吗？？？？？？？？？？？？？",
            },
        @{
            @"nickname": @"fengbo33",
            @"content": @"主播能加你一个微信么？",
            },
        @{
            @"nickname": @"jack",
            @"content": @"献上一束花,献上一束花",
           },
        @{
            @"nickname": @"果汁",
            @"content": @"递上果汁,递上果汁,递上果汁😄",
           },
        @{
            @"nickname": @"棒棒糖",
            @"content": @"递上棒棒糖",
           },
        @{
            @"nickname": @"泡泡糖",
            @"content": @"一起吃泡泡糖吧,今晚一起吃泡泡糖吗？？？？？？？？？？？？？",
           },
        @{
            @"nickname": @"fengbo44",
            @"content": @"主播能加你一个微信么？",
            },
        @{
            @"nickname": @"jack",
            @"content": @"献上一束花,献上一束花",
            },
        @{
            @"nickname": @"果汁",
            @"content": @"递上果汁,递上果汁,递上果汁😄",
            },
        @{
            @"nickname": @"棒棒糖",
            @"content": @"递上棒棒糖",
            },
        @{
            @"nickname": @"泡泡糖",
            @"content": @"一起吃泡泡糖吧,今晚一起吃泡泡糖吗？？？？？？？？？？？？？",
            },
        @{
            @"nickname": @"fengbo55",
            @"content": @"主播能加你一个微信么？",
            },
        @{
            @"nickname": @"jack",
            @"content": @"献上一束花,献上一束花",
           },
        @{
            @"nickname": @"果汁",
            @"content": @"递上果汁,递上果汁,递上果汁😄",
           },
        @{
            @"nickname": @"棒棒糖",
            @"content": @"递上棒棒糖",
           },
        @{
            @"nickname": @"泡泡糖",
            @"content": @"一起吃泡泡糖吧,今晚一起吃泡泡糖吗？？？？？？？？？？？？？",
           },
        @{
            @"nickname": @"fengbo66",
            @"content": @"主播能加你一个微信么？",
            },
        @{
            @"nickname": @"jack",
            @"content": @"献上一束花,献上一束花",
            },
        @{
            @"nickname": @"果汁",
            @"content": @"递上果汁,递上果汁,递上果汁😄",
            },
        @{
            @"nickname": @"棒棒糖",
            @"content": @"递上棒棒糖",
            },
        @{
            @"nickname": @"泡泡糖",
            @"content": @"一起吃泡泡糖吧,今晚一起吃泡泡糖吗？？？？？？？？？？？？？",
            },
        @{
            @"nickname": @"fengbo77",
            @"content": @"主播能加你一个微信么？",
            },
        @{
            @"nickname": @"jack",
            @"content": @"献上一束花,献上一束花",
           },
        @{
            @"nickname": @"果汁",
            @"content": @"递上果汁,递上果汁,递上果汁😄",
           },
        @{
            @"nickname": @"棒棒糖",
            @"content": @"递上棒棒糖",
           },
        @{
            @"nickname": @"泡泡糖",
            @"content": @"一起吃泡泡糖吧,今晚一起吃泡泡糖吗？？？？？？？？？？？？？",
           },
        @{
            @"nickname": @"fengbo88",
            @"content": @"主播能加你一个微信么？",
            },
        @{
            @"nickname": @"jack",
            @"content": @"献上一束花,献上一束花",
            },
        @{
            @"nickname": @"果汁",
            @"content": @"递上果汁,递上果汁,递上果汁😄",
            },
        @{
            @"nickname": @"棒棒糖",
            @"content": @"递上棒棒糖",
            },
        @{
            @"nickname": @"泡泡糖",
            @"content": @"一起吃泡泡糖吧,今晚一起吃泡泡糖吗？？？？？？？？？？？？？",
            },
        @{
            @"nickname": @"fengbo99",
            @"content": @"主播能加你一个微信么？",
            },
        @{
            @"nickname": @"jack",
            @"content": @"献上一束花,献上一束花",
           },
        @{
            @"nickname": @"果汁",
            @"content": @"递上果汁,递上果汁,递上果汁😄",
           },
        @{
            @"nickname": @"棒棒糖",
            @"content": @"递上棒棒糖",
           },
        @{
            @"nickname": @"泡泡糖",
            @"content": @"一起吃泡泡糖吧,今晚一起吃泡泡糖吗？？？？？？？？？？？？？",
           },
        @{
            @"nickname": @"棒棒糖",
            @"content": @"递上棒棒糖",
           },
        @{
            @"nickname": @"泡泡糖",
            @"content": @"一起吃泡泡糖吧,今晚一起吃泡泡糖吗？？？？？？？？？？？？？",
           },
        @{
            @"nickname": @"fengbo101",
            @"content": @"主播能加你一个微信么？",
            },
        @{
            @"nickname": @"fengbo",
            @"content": @"主播能加你一个微信么？",
            },
        @{
            @"nickname": @"jack",
            @"content": @"献上一束花,献上一束花",
            },
        @{
            @"nickname": @"果汁",
            @"content": @"递上果汁,递上果汁,递上果汁😄",
            },
        @{
            @"nickname": @"棒棒糖",
            @"content": @"递上棒棒糖",
            },
        @{
            @"nickname": @"泡泡糖",
            @"content": @"一起吃泡泡糖吧,今晚一起吃泡泡糖吗？？？？？？？？？？？？？",
            },
        @{
            @"nickname": @"fengbo11",
            @"content": @"主播能加你一个微信么？",
            },
        @{
            @"nickname": @"jack",
            @"content": @"献上一束花,献上一束花",
           },
        @{
            @"nickname": @"果汁",
            @"content": @"递上果汁,递上果汁,递上果汁😄",
           },
        @{
            @"nickname": @"棒棒糖",
            @"content": @"递上棒棒糖",
           },
        @{
            @"nickname": @"泡泡糖",
            @"content": @"一起吃泡泡糖吧,今晚一起吃泡泡糖吗？？？？？？？？？？？？？",
           },
        @{
            @"nickname": @"fengbo22",
            @"content": @"主播能加你一个微信么？",
            },
        @{
            @"nickname": @"jack",
            @"content": @"献上一束花,献上一束花",
            },
        @{
            @"nickname": @"果汁",
            @"content": @"递上果汁,递上果汁,递上果汁😄",
            },
        @{
            @"nickname": @"棒棒糖",
            @"content": @"递上棒棒糖",
            },
        @{
            @"nickname": @"泡泡糖",
            @"content": @"一起吃泡泡糖吧,今晚一起吃泡泡糖吗？？？？？？？？？？？？？",
            },
        @{
            @"nickname": @"fengbo33",
            @"content": @"主播能加你一个微信么？",
            },
        @{
            @"nickname": @"jack",
            @"content": @"献上一束花,献上一束花",
           },
        @{
            @"nickname": @"果汁",
            @"content": @"递上果汁,递上果汁,递上果汁😄",
           },
        @{
            @"nickname": @"棒棒糖",
            @"content": @"递上棒棒糖",
           },
        @{
            @"nickname": @"泡泡糖",
            @"content": @"一起吃泡泡糖吧,今晚一起吃泡泡糖吗？？？？？？？？？？？？？",
           },
        @{
            @"nickname": @"fengbo44",
            @"content": @"主播能加你一个微信么？",
            },
        @{
            @"nickname": @"jack",
            @"content": @"献上一束花,献上一束花",
            },
        @{
            @"nickname": @"果汁",
            @"content": @"递上果汁,递上果汁,递上果汁😄",
            },
        @{
            @"nickname": @"棒棒糖",
            @"content": @"递上棒棒糖",
            },
        @{
            @"nickname": @"泡泡糖",
            @"content": @"一起吃泡泡糖吧,今晚一起吃泡泡糖吗？？？？？？？？？？？？？",
            },
        @{
            @"nickname": @"fengbo55",
            @"content": @"主播能加你一个微信么？",
            },
        @{
            @"nickname": @"jack",
            @"content": @"献上一束花,献上一束花",
           },
        @{
            @"nickname": @"果汁",
            @"content": @"递上果汁,递上果汁,递上果汁😄",
           },
        @{
            @"nickname": @"棒棒糖",
            @"content": @"递上棒棒糖",
           },
        @{
            @"nickname": @"泡泡糖",
            @"content": @"一起吃泡泡糖吧,今晚一起吃泡泡糖吗？？？？？？？？？？？？？",
           },
        @{
            @"nickname": @"fengbo66",
            @"content": @"主播能加你一个微信么？",
            },
        @{
            @"nickname": @"jack",
            @"content": @"献上一束花,献上一束花",
            },
        @{
            @"nickname": @"果汁",
            @"content": @"递上果汁,递上果汁,递上果汁😄",
            },
        @{
            @"nickname": @"棒棒糖",
            @"content": @"递上棒棒糖",
            },
        @{
            @"nickname": @"泡泡糖",
            @"content": @"一起吃泡泡糖吧,今晚一起吃泡泡糖吗？？？？？？？？？？？？？",
            },
        @{
            @"nickname": @"fengbo77",
            @"content": @"主播能加你一个微信么？",
            },
        @{
            @"nickname": @"jack",
            @"content": @"献上一束花,献上一束花",
           },
        @{
            @"nickname": @"果汁",
            @"content": @"递上果汁,递上果汁,递上果汁😄",
           },
        @{
            @"nickname": @"棒棒糖",
            @"content": @"递上棒棒糖",
           },
        @{
            @"nickname": @"泡泡糖",
            @"content": @"一起吃泡泡糖吧,今晚一起吃泡泡糖吗？？？？？？？？？？？？？",
           },
        @{
            @"nickname": @"fengbo88",
            @"content": @"主播能加你一个微信么？",
            },
        @{
            @"nickname": @"jack",
            @"content": @"献上一束花,献上一束花",
            },
        @{
            @"nickname": @"果汁",
            @"content": @"递上果汁,递上果汁,递上果汁😄",
            },
        @{
            @"nickname": @"棒棒糖",
            @"content": @"递上棒棒糖",
            },
        @{
            @"nickname": @"泡泡糖",
            @"content": @"一起吃泡泡糖吧,今晚一起吃泡泡糖吗？？？？？？？？？？？？？",
            },
        @{
            @"nickname": @"fengbo99",
            @"content": @"主播能加你一个微信么？",
            },
        @{
            @"nickname": @"jack",
            @"content": @"献上一束花,献上一束花",
           },
        @{
            @"nickname": @"果汁",
            @"content": @"递上果汁,递上果汁,递上果汁😄",
           },
        @{
            @"nickname": @"棒棒糖",
            @"content": @"递上棒棒糖",
           },
        @{
            @"nickname": @"泡泡糖",
            @"content": @"一起吃泡泡糖吧,今晚一起吃泡泡糖吗？？？？？？？？？？？？？",
           },
        @{
            @"nickname": @"棒棒糖",
            @"content": @"递上棒棒糖",
           },
        @{
            @"nickname": @"泡泡糖",
            @"content": @"一起吃泡泡糖吧,今晚一起吃泡泡糖吗？？？？？？？？？？？？？",
           },
        @{
            @"nickname": @"fengbo101",
            @"content": @"主播能加你一个微信么？",
            },
        @{
            @"nickname": @"fengbo",
            @"content": @"主播能加你一个微信么？",
            },
        @{
            @"nickname": @"jack",
            @"content": @"献上一束花,献上一束花",
            },
        @{
            @"nickname": @"果汁",
            @"content": @"递上果汁,递上果汁,递上果汁😄",
            },
        @{
            @"nickname": @"棒棒糖",
            @"content": @"递上棒棒糖",
            },
        @{
            @"nickname": @"泡泡糖",
            @"content": @"一起吃泡泡糖吧,今晚一起吃泡泡糖吗？？？？？？？？？？？？？",
            },
        @{
            @"nickname": @"fengbo11",
            @"content": @"主播能加你一个微信么？",
            },
        @{
            @"nickname": @"jack",
            @"content": @"献上一束花,献上一束花",
           },
        @{
            @"nickname": @"果汁",
            @"content": @"递上果汁,递上果汁,递上果汁😄",
           },
        @{
            @"nickname": @"棒棒糖",
            @"content": @"递上棒棒糖",
           },
        @{
            @"nickname": @"泡泡糖",
            @"content": @"一起吃泡泡糖吧,今晚一起吃泡泡糖吗？？？？？？？？？？？？？",
           },
        @{
            @"nickname": @"fengbo22",
            @"content": @"主播能加你一个微信么？",
            },
        @{
            @"nickname": @"jack",
            @"content": @"献上一束花,献上一束花",
            },
        @{
            @"nickname": @"果汁",
            @"content": @"递上果汁,递上果汁,递上果汁😄",
            },
        @{
            @"nickname": @"棒棒糖",
            @"content": @"递上棒棒糖",
            },
        @{
            @"nickname": @"泡泡糖",
            @"content": @"一起吃泡泡糖吧,今晚一起吃泡泡糖吗？？？？？？？？？？？？？",
            },
        @{
            @"nickname": @"fengbo33",
            @"content": @"主播能加你一个微信么？",
            },
        @{
            @"nickname": @"jack",
            @"content": @"献上一束花,献上一束花",
           },
        @{
            @"nickname": @"果汁",
            @"content": @"递上果汁,递上果汁,递上果汁😄",
           },
        @{
            @"nickname": @"棒棒糖",
            @"content": @"递上棒棒糖",
           },
        @{
            @"nickname": @"泡泡糖",
            @"content": @"一起吃泡泡糖吧,今晚一起吃泡泡糖吗？？？？？？？？？？？？？",
           },
        @{
            @"nickname": @"fengbo44",
            @"content": @"主播能加你一个微信么？",
            },
        @{
            @"nickname": @"jack",
            @"content": @"献上一束花,献上一束花",
            },
        @{
            @"nickname": @"果汁",
            @"content": @"递上果汁,递上果汁,递上果汁😄",
            },
        @{
            @"nickname": @"棒棒糖",
            @"content": @"递上棒棒糖",
            },
        @{
            @"nickname": @"泡泡糖",
            @"content": @"一起吃泡泡糖吧,今晚一起吃泡泡糖吗？？？？？？？？？？？？？",
            },
        @{
            @"nickname": @"fengbo55",
            @"content": @"主播能加你一个微信么？",
            },
        @{
            @"nickname": @"jack",
            @"content": @"献上一束花,献上一束花",
           },
        @{
            @"nickname": @"果汁",
            @"content": @"递上果汁,递上果汁,递上果汁😄",
           },
        @{
            @"nickname": @"棒棒糖",
            @"content": @"递上棒棒糖",
           },
        @{
            @"nickname": @"泡泡糖",
            @"content": @"一起吃泡泡糖吧,今晚一起吃泡泡糖吗？？？？？？？？？？？？？",
           },
        @{
            @"nickname": @"fengbo66",
            @"content": @"主播能加你一个微信么？",
            },
        @{
            @"nickname": @"jack",
            @"content": @"献上一束花,献上一束花",
            },
        @{
            @"nickname": @"果汁",
            @"content": @"递上果汁,递上果汁,递上果汁😄",
            },
        @{
            @"nickname": @"棒棒糖",
            @"content": @"递上棒棒糖",
            },
        @{
            @"nickname": @"泡泡糖",
            @"content": @"一起吃泡泡糖吧,今晚一起吃泡泡糖吗？？？？？？？？？？？？？",
            },
        @{
            @"nickname": @"fengbo77",
            @"content": @"主播能加你一个微信么？",
            },
        @{
            @"nickname": @"jack",
            @"content": @"献上一束花,献上一束花",
           },
        @{
            @"nickname": @"果汁",
            @"content": @"递上果汁,递上果汁,递上果汁😄",
           },
        @{
            @"nickname": @"棒棒糖",
            @"content": @"递上棒棒糖",
           },
        @{
            @"nickname": @"泡泡糖",
            @"content": @"一起吃泡泡糖吧,今晚一起吃泡泡糖吗？？？？？？？？？？？？？",
           },
        @{
            @"nickname": @"fengbo88",
            @"content": @"主播能加你一个微信么？",
            },
        @{
            @"nickname": @"jack",
            @"content": @"献上一束花,献上一束花",
            },
        @{
            @"nickname": @"果汁",
            @"content": @"递上果汁,递上果汁,递上果汁😄",
            },
        @{
            @"nickname": @"棒棒糖",
            @"content": @"递上棒棒糖",
            },
        @{
            @"nickname": @"泡泡糖",
            @"content": @"一起吃泡泡糖吧,今晚一起吃泡泡糖吗？？？？？？？？？？？？？",
            },
        @{
            @"nickname": @"fengbo99",
            @"content": @"主播能加你一个微信么？",
            },
        @{
            @"nickname": @"jack",
            @"content": @"献上一束花,献上一束花",
           },
        @{
            @"nickname": @"果汁",
            @"content": @"递上果汁,递上果汁,递上果汁😄",
           },
        @{
            @"nickname": @"棒棒糖",
            @"content": @"递上棒棒糖",
           },
        @{
            @"nickname": @"泡泡糖",
            @"content": @"一起吃泡泡糖吧,今晚一起吃泡泡糖吗？？？？？？？？？？？？？",
           },
        @{
            @"nickname": @"棒棒糖",
            @"content": @"递上棒棒糖",
           },
        @{
            @"nickname": @"泡泡糖",
            @"content": @"一起吃泡泡糖吧,今晚一起吃泡泡糖吗？？？？？？？？？？？？？",
           },
        @{
            @"nickname": @"fengbo101",
            @"content": @"主播能加你一个微信么？",
            },
        @{
            @"nickname": @"fengbo",
            @"content": @"主播能加你一个微信么？",
            },
        @{
            @"nickname": @"jack",
            @"content": @"献上一束花,献上一束花",
            },
        @{
            @"nickname": @"果汁",
            @"content": @"递上果汁,递上果汁,递上果汁😄",
            },
        @{
            @"nickname": @"棒棒糖",
            @"content": @"递上棒棒糖",
            },
        @{
            @"nickname": @"泡泡糖",
            @"content": @"一起吃泡泡糖吧,今晚一起吃泡泡糖吗？？？？？？？？？？？？？",
            },
        @{
            @"nickname": @"fengbo11",
            @"content": @"主播能加你一个微信么？",
            },
        @{
            @"nickname": @"jack",
            @"content": @"献上一束花,献上一束花",
           },
        @{
            @"nickname": @"果汁",
            @"content": @"递上果汁,递上果汁,递上果汁😄",
           },
        @{
            @"nickname": @"棒棒糖",
            @"content": @"递上棒棒糖",
           },
        @{
            @"nickname": @"泡泡糖",
            @"content": @"一起吃泡泡糖吧,今晚一起吃泡泡糖吗？？？？？？？？？？？？？",
           },
        @{
            @"nickname": @"fengbo22",
            @"content": @"主播能加你一个微信么？",
            },
        @{
            @"nickname": @"jack",
            @"content": @"献上一束花,献上一束花",
            },
        @{
            @"nickname": @"果汁",
            @"content": @"递上果汁,递上果汁,递上果汁😄",
            },
        @{
            @"nickname": @"棒棒糖",
            @"content": @"递上棒棒糖",
            },
        @{
            @"nickname": @"泡泡糖",
            @"content": @"一起吃泡泡糖吧,今晚一起吃泡泡糖吗？？？？？？？？？？？？？",
            },
        @{
            @"nickname": @"fengbo33",
            @"content": @"主播能加你一个微信么？",
            },
        @{
            @"nickname": @"jack",
            @"content": @"献上一束花,献上一束花",
           },
        @{
            @"nickname": @"果汁",
            @"content": @"递上果汁,递上果汁,递上果汁😄",
           },
        @{
            @"nickname": @"棒棒糖",
            @"content": @"递上棒棒糖",
           },
        @{
            @"nickname": @"泡泡糖",
            @"content": @"一起吃泡泡糖吧,今晚一起吃泡泡糖吗？？？？？？？？？？？？？",
           },
        @{
            @"nickname": @"fengbo44",
            @"content": @"主播能加你一个微信么？",
            },
        @{
            @"nickname": @"jack",
            @"content": @"献上一束花,献上一束花",
            },
        @{
            @"nickname": @"果汁",
            @"content": @"递上果汁,递上果汁,递上果汁😄",
            },
        @{
            @"nickname": @"棒棒糖",
            @"content": @"递上棒棒糖",
            },
        @{
            @"nickname": @"泡泡糖",
            @"content": @"一起吃泡泡糖吧,今晚一起吃泡泡糖吗？？？？？？？？？？？？？",
            },
        @{
            @"nickname": @"fengbo55",
            @"content": @"主播能加你一个微信么？",
            },
        @{
            @"nickname": @"jack",
            @"content": @"献上一束花,献上一束花",
           },
        @{
            @"nickname": @"果汁",
            @"content": @"递上果汁,递上果汁,递上果汁😄",
           },
        @{
            @"nickname": @"棒棒糖",
            @"content": @"递上棒棒糖",
           },
        @{
            @"nickname": @"泡泡糖",
            @"content": @"一起吃泡泡糖吧,今晚一起吃泡泡糖吗？？？？？？？？？？？？？",
           },
        @{
            @"nickname": @"fengbo66",
            @"content": @"主播能加你一个微信么？",
            },
        @{
            @"nickname": @"jack",
            @"content": @"献上一束花,献上一束花",
            },
        @{
            @"nickname": @"果汁",
            @"content": @"递上果汁,递上果汁,递上果汁😄",
            },
        @{
            @"nickname": @"棒棒糖",
            @"content": @"递上棒棒糖",
            },
        @{
            @"nickname": @"泡泡糖",
            @"content": @"一起吃泡泡糖吧,今晚一起吃泡泡糖吗？？？？？？？？？？？？？",
            },
        @{
            @"nickname": @"fengbo77",
            @"content": @"主播能加你一个微信么？",
            },
        @{
            @"nickname": @"jack",
            @"content": @"献上一束花,献上一束花",
           },
        @{
            @"nickname": @"果汁",
            @"content": @"递上果汁,递上果汁,递上果汁😄",
           },
        @{
            @"nickname": @"棒棒糖",
            @"content": @"递上棒棒糖",
           },
        @{
            @"nickname": @"泡泡糖",
            @"content": @"一起吃泡泡糖吧,今晚一起吃泡泡糖吗？？？？？？？？？？？？？",
           },
        @{
            @"nickname": @"fengbo88",
            @"content": @"主播能加你一个微信么？",
            },
        @{
            @"nickname": @"jack",
            @"content": @"献上一束花,献上一束花",
            },
        @{
            @"nickname": @"果汁",
            @"content": @"递上果汁,递上果汁,递上果汁😄",
            },
        @{
            @"nickname": @"棒棒糖",
            @"content": @"递上棒棒糖",
            },
        @{
            @"nickname": @"泡泡糖",
            @"content": @"一起吃泡泡糖吧,今晚一起吃泡泡糖吗？？？？？？？？？？？？？",
            },
        @{
            @"nickname": @"fengbo99",
            @"content": @"主播能加你一个微信么？",
            },
        @{
            @"nickname": @"jack",
            @"content": @"献上一束花,献上一束花",
           },
        @{
            @"nickname": @"果汁",
            @"content": @"递上果汁,递上果汁,递上果汁😄",
           },
        @{
            @"nickname": @"棒棒糖",
            @"content": @"递上棒棒糖",
           },
        @{
            @"nickname": @"泡泡糖",
            @"content": @"一起吃泡泡糖吧,今晚一起吃泡泡糖吗？？？？？？？？？？？？？",
           },
        @{
            @"nickname": @"棒棒糖",
            @"content": @"递上棒棒糖",
           },
        @{
            @"nickname": @"泡泡糖",
            @"content": @"一起吃泡泡糖吧,今晚一起吃泡泡糖吗？？？？？？？？？？？？？",
           },
        @{
            @"nickname": @"fengbo101",
            @"content": @"主播能加你一个微信么？",
            },
        @{
            @"nickname": @"fengbo",
            @"content": @"主播能加你一个微信么？",
            },
        @{
            @"nickname": @"jack",
            @"content": @"献上一束花,献上一束花",
            },
        @{
            @"nickname": @"果汁",
            @"content": @"递上果汁,递上果汁,递上果汁😄",
            },
        @{
            @"nickname": @"棒棒糖",
            @"content": @"递上棒棒糖",
            },
        @{
            @"nickname": @"泡泡糖",
            @"content": @"一起吃泡泡糖吧,今晚一起吃泡泡糖吗？？？？？？？？？？？？？",
            },
        @{
            @"nickname": @"fengbo11",
            @"content": @"主播能加你一个微信么？",
            },
        @{
            @"nickname": @"jack",
            @"content": @"献上一束花,献上一束花",
           },
        @{
            @"nickname": @"果汁",
            @"content": @"递上果汁,递上果汁,递上果汁😄",
           },
        @{
            @"nickname": @"棒棒糖",
            @"content": @"递上棒棒糖",
           },
        @{
            @"nickname": @"泡泡糖",
            @"content": @"一起吃泡泡糖吧,今晚一起吃泡泡糖吗？？？？？？？？？？？？？",
           },
        @{
            @"nickname": @"fengbo22",
            @"content": @"主播能加你一个微信么？",
            },
        @{
            @"nickname": @"jack",
            @"content": @"献上一束花,献上一束花",
            },
        @{
            @"nickname": @"果汁",
            @"content": @"递上果汁,递上果汁,递上果汁😄",
            },
        @{
            @"nickname": @"棒棒糖",
            @"content": @"递上棒棒糖",
            },
        @{
            @"nickname": @"泡泡糖",
            @"content": @"一起吃泡泡糖吧,今晚一起吃泡泡糖吗？？？？？？？？？？？？？",
            },
        @{
            @"nickname": @"fengbo33",
            @"content": @"主播能加你一个微信么？",
            },
        @{
            @"nickname": @"jack",
            @"content": @"献上一束花,献上一束花",
           },
        @{
            @"nickname": @"果汁",
            @"content": @"递上果汁,递上果汁,递上果汁😄",
           },
        @{
            @"nickname": @"棒棒糖",
            @"content": @"递上棒棒糖",
           },
        @{
            @"nickname": @"泡泡糖",
            @"content": @"一起吃泡泡糖吧,今晚一起吃泡泡糖吗？？？？？？？？？？？？？",
           },
        @{
            @"nickname": @"fengbo44",
            @"content": @"主播能加你一个微信么？",
            },
        @{
            @"nickname": @"jack",
            @"content": @"献上一束花,献上一束花",
            },
        @{
            @"nickname": @"果汁",
            @"content": @"递上果汁,递上果汁,递上果汁😄",
            },
        @{
            @"nickname": @"棒棒糖",
            @"content": @"递上棒棒糖",
            },
        @{
            @"nickname": @"泡泡糖",
            @"content": @"一起吃泡泡糖吧,今晚一起吃泡泡糖吗？？？？？？？？？？？？？",
            },
        @{
            @"nickname": @"fengbo55",
            @"content": @"主播能加你一个微信么？",
            },
        @{
            @"nickname": @"jack",
            @"content": @"献上一束花,献上一束花",
           },
        @{
            @"nickname": @"果汁",
            @"content": @"递上果汁,递上果汁,递上果汁😄",
           },
        @{
            @"nickname": @"棒棒糖",
            @"content": @"递上棒棒糖",
           },
        @{
            @"nickname": @"泡泡糖",
            @"content": @"一起吃泡泡糖吧,今晚一起吃泡泡糖吗？？？？？？？？？？？？？",
           },
        @{
            @"nickname": @"fengbo66",
            @"content": @"主播能加你一个微信么？",
            },
        @{
            @"nickname": @"jack",
            @"content": @"献上一束花,献上一束花",
            },
        @{
            @"nickname": @"果汁",
            @"content": @"递上果汁,递上果汁,递上果汁😄",
            },
        @{
            @"nickname": @"棒棒糖",
            @"content": @"递上棒棒糖",
            },
        @{
            @"nickname": @"泡泡糖",
            @"content": @"一起吃泡泡糖吧,今晚一起吃泡泡糖吗？？？？？？？？？？？？？",
            },
        @{
            @"nickname": @"fengbo77",
            @"content": @"主播能加你一个微信么？",
            },
        @{
            @"nickname": @"jack",
            @"content": @"献上一束花,献上一束花",
           },
        @{
            @"nickname": @"果汁",
            @"content": @"递上果汁,递上果汁,递上果汁😄",
           },
        @{
            @"nickname": @"棒棒糖",
            @"content": @"递上棒棒糖",
           },
        @{
            @"nickname": @"泡泡糖",
            @"content": @"一起吃泡泡糖吧,今晚一起吃泡泡糖吗？？？？？？？？？？？？？",
           },
        @{
            @"nickname": @"fengbo88",
            @"content": @"主播能加你一个微信么？",
            },
        @{
            @"nickname": @"jack",
            @"content": @"献上一束花,献上一束花",
            },
        @{
            @"nickname": @"果汁",
            @"content": @"递上果汁,递上果汁,递上果汁😄",
            },
        @{
            @"nickname": @"棒棒糖",
            @"content": @"递上棒棒糖",
            },
        @{
            @"nickname": @"泡泡糖",
            @"content": @"一起吃泡泡糖吧,今晚一起吃泡泡糖吗？？？？？？？？？？？？？",
            },
        @{
            @"nickname": @"fengbo99",
            @"content": @"主播能加你一个微信么？",
            },
        @{
            @"nickname": @"jack",
            @"content": @"献上一束花,献上一束花",
           },
        @{
            @"nickname": @"果汁",
            @"content": @"递上果汁,递上果汁,递上果汁😄",
           },
        @{
            @"nickname": @"棒棒糖",
            @"content": @"递上棒棒糖",
           },
        @{
            @"nickname": @"泡泡糖",
            @"content": @"一起吃泡泡糖吧,今晚一起吃泡泡糖吗？？？？？？？？？？？？？",
           },
        @{
            @"nickname": @"棒棒糖",
            @"content": @"递上棒棒糖",
           },
        @{
            @"nickname": @"泡泡糖",
            @"content": @"一起吃泡泡糖吧,今晚一起吃泡泡糖吗？？？？？？？？？？？？？",
           },
        @{
            @"nickname": @"fengbo101",
            @"content": @"主播能加你一个微信么？",
            },
        @{
            @"nickname": @"fengbo",
            @"content": @"主播能加你一个微信么？",
            },
        @{
            @"nickname": @"jack",
            @"content": @"献上一束花,献上一束花",
            },
        @{
            @"nickname": @"果汁",
            @"content": @"递上果汁,递上果汁,递上果汁😄",
            },
        @{
            @"nickname": @"棒棒糖",
            @"content": @"递上棒棒糖",
            },
        @{
            @"nickname": @"泡泡糖",
            @"content": @"一起吃泡泡糖吧,今晚一起吃泡泡糖吗？？？？？？？？？？？？？",
            },
        @{
            @"nickname": @"fengbo11",
            @"content": @"主播能加你一个微信么？",
            },
        @{
            @"nickname": @"jack",
            @"content": @"献上一束花,献上一束花",
           },
        @{
            @"nickname": @"果汁",
            @"content": @"递上果汁,递上果汁,递上果汁😄",
           },
        @{
            @"nickname": @"棒棒糖",
            @"content": @"递上棒棒糖",
           },
        @{
            @"nickname": @"泡泡糖",
            @"content": @"一起吃泡泡糖吧,今晚一起吃泡泡糖吗？？？？？？？？？？？？？",
           },
        @{
            @"nickname": @"fengbo22",
            @"content": @"主播能加你一个微信么？",
            },
        @{
            @"nickname": @"jack",
            @"content": @"献上一束花,献上一束花",
            },
        @{
            @"nickname": @"果汁",
            @"content": @"递上果汁,递上果汁,递上果汁😄",
            },
        @{
            @"nickname": @"棒棒糖",
            @"content": @"递上棒棒糖",
            },
        @{
            @"nickname": @"泡泡糖",
            @"content": @"一起吃泡泡糖吧,今晚一起吃泡泡糖吗？？？？？？？？？？？？？",
            },
        @{
            @"nickname": @"fengbo33",
            @"content": @"主播能加你一个微信么？",
            },
        @{
            @"nickname": @"jack",
            @"content": @"献上一束花,献上一束花",
           },
        @{
            @"nickname": @"果汁",
            @"content": @"递上果汁,递上果汁,递上果汁😄",
           },
        @{
            @"nickname": @"棒棒糖",
            @"content": @"递上棒棒糖",
           },
        @{
            @"nickname": @"泡泡糖",
            @"content": @"一起吃泡泡糖吧,今晚一起吃泡泡糖吗？？？？？？？？？？？？？",
           },
        @{
            @"nickname": @"fengbo44",
            @"content": @"主播能加你一个微信么？",
            },
        @{
            @"nickname": @"jack",
            @"content": @"献上一束花,献上一束花",
            },
        @{
            @"nickname": @"果汁",
            @"content": @"递上果汁,递上果汁,递上果汁😄",
            },
        @{
            @"nickname": @"棒棒糖",
            @"content": @"递上棒棒糖",
            },
        @{
            @"nickname": @"泡泡糖",
            @"content": @"一起吃泡泡糖吧,今晚一起吃泡泡糖吗？？？？？？？？？？？？？",
            },
        @{
            @"nickname": @"fengbo55",
            @"content": @"主播能加你一个微信么？",
            },
        @{
            @"nickname": @"jack",
            @"content": @"献上一束花,献上一束花",
           },
        @{
            @"nickname": @"果汁",
            @"content": @"递上果汁,递上果汁,递上果汁😄",
           },
        @{
            @"nickname": @"棒棒糖",
            @"content": @"递上棒棒糖",
           },
        @{
            @"nickname": @"泡泡糖",
            @"content": @"一起吃泡泡糖吧,今晚一起吃泡泡糖吗？？？？？？？？？？？？？",
           },
        @{
            @"nickname": @"fengbo66",
            @"content": @"主播能加你一个微信么？",
            },
        @{
            @"nickname": @"jack",
            @"content": @"献上一束花,献上一束花",
            },
        @{
            @"nickname": @"果汁",
            @"content": @"递上果汁,递上果汁,递上果汁😄",
            },
        @{
            @"nickname": @"棒棒糖",
            @"content": @"递上棒棒糖",
            },
        @{
            @"nickname": @"泡泡糖",
            @"content": @"一起吃泡泡糖吧,今晚一起吃泡泡糖吗？？？？？？？？？？？？？",
            },
        @{
            @"nickname": @"fengbo77",
            @"content": @"主播能加你一个微信么？",
            },
        @{
            @"nickname": @"jack",
            @"content": @"献上一束花,献上一束花",
           },
        @{
            @"nickname": @"果汁",
            @"content": @"递上果汁,递上果汁,递上果汁😄",
           },
        @{
            @"nickname": @"棒棒糖",
            @"content": @"递上棒棒糖",
           },
        @{
            @"nickname": @"泡泡糖",
            @"content": @"一起吃泡泡糖吧,今晚一起吃泡泡糖吗？？？？？？？？？？？？？",
           },
        @{
            @"nickname": @"fengbo88",
            @"content": @"主播能加你一个微信么？",
            },
        @{
            @"nickname": @"jack",
            @"content": @"献上一束花,献上一束花",
            },
        @{
            @"nickname": @"果汁",
            @"content": @"递上果汁,递上果汁,递上果汁😄",
            },
        @{
            @"nickname": @"棒棒糖",
            @"content": @"递上棒棒糖",
            },
        @{
            @"nickname": @"泡泡糖",
            @"content": @"一起吃泡泡糖吧,今晚一起吃泡泡糖吗？？？？？？？？？？？？？",
            },
        @{
            @"nickname": @"fengbo99",
            @"content": @"主播能加你一个微信么？",
            },
        @{
            @"nickname": @"jack",
            @"content": @"献上一束花,献上一束花",
           },
        @{
            @"nickname": @"果汁",
            @"content": @"递上果汁,递上果汁,递上果汁😄",
           },
        @{
            @"nickname": @"棒棒糖",
            @"content": @"递上棒棒糖",
           },
        @{
            @"nickname": @"泡泡糖",
            @"content": @"一起吃泡泡糖吧,今晚一起吃泡泡糖吗？？？？？？？？？？？？？",
           },
        @{
            @"nickname": @"棒棒糖",
            @"content": @"递上棒棒糖",
           },
        @{
            @"nickname": @"泡泡糖",
            @"content": @"一起吃泡泡糖吧,今晚一起吃泡泡糖吗？？？？？？？？？？？？？",
           },
        @{
            @"nickname": @"fengbo101",
            @"content": @"主播能加你一个微信么？",
            },
        @{
            @"nickname": @"fengbo",
            @"content": @"主播能加你一个微信么？",
            },
        @{
            @"nickname": @"jack",
            @"content": @"献上一束花,献上一束花",
            },
        @{
            @"nickname": @"果汁",
            @"content": @"递上果汁,递上果汁,递上果汁😄",
            },
        @{
            @"nickname": @"棒棒糖",
            @"content": @"递上棒棒糖",
            },
        @{
            @"nickname": @"泡泡糖",
            @"content": @"一起吃泡泡糖吧,今晚一起吃泡泡糖吗？？？？？？？？？？？？？",
            },
        @{
            @"nickname": @"fengbo11",
            @"content": @"主播能加你一个微信么？",
            },
        @{
            @"nickname": @"jack",
            @"content": @"献上一束花,献上一束花",
           },
        @{
            @"nickname": @"果汁",
            @"content": @"递上果汁,递上果汁,递上果汁😄",
           },
        @{
            @"nickname": @"棒棒糖",
            @"content": @"递上棒棒糖",
           },
        @{
            @"nickname": @"泡泡糖",
            @"content": @"一起吃泡泡糖吧,今晚一起吃泡泡糖吗？？？？？？？？？？？？？",
           },
        @{
            @"nickname": @"fengbo22",
            @"content": @"主播能加你一个微信么？",
            },
        @{
            @"nickname": @"jack",
            @"content": @"献上一束花,献上一束花",
            },
        @{
            @"nickname": @"果汁",
            @"content": @"递上果汁,递上果汁,递上果汁😄",
            },
        @{
            @"nickname": @"棒棒糖",
            @"content": @"递上棒棒糖",
            },
        @{
            @"nickname": @"泡泡糖",
            @"content": @"一起吃泡泡糖吧,今晚一起吃泡泡糖吗？？？？？？？？？？？？？",
            },
        @{
            @"nickname": @"fengbo33",
            @"content": @"主播能加你一个微信么？",
            },
        @{
            @"nickname": @"jack",
            @"content": @"献上一束花,献上一束花",
           },
        @{
            @"nickname": @"果汁",
            @"content": @"递上果汁,递上果汁,递上果汁😄",
           },
        @{
            @"nickname": @"棒棒糖",
            @"content": @"递上棒棒糖",
           },
        @{
            @"nickname": @"泡泡糖",
            @"content": @"一起吃泡泡糖吧,今晚一起吃泡泡糖吗？？？？？？？？？？？？？",
           },
        @{
            @"nickname": @"fengbo44",
            @"content": @"主播能加你一个微信么？",
            },
        @{
            @"nickname": @"jack",
            @"content": @"献上一束花,献上一束花",
            },
        @{
            @"nickname": @"果汁",
            @"content": @"递上果汁,递上果汁,递上果汁😄",
            },
        @{
            @"nickname": @"棒棒糖",
            @"content": @"递上棒棒糖",
            },
        @{
            @"nickname": @"泡泡糖",
            @"content": @"一起吃泡泡糖吧,今晚一起吃泡泡糖吗？？？？？？？？？？？？？",
            },
        @{
            @"nickname": @"fengbo55",
            @"content": @"主播能加你一个微信么？",
            },
        @{
            @"nickname": @"jack",
            @"content": @"献上一束花,献上一束花",
           },
        @{
            @"nickname": @"果汁",
            @"content": @"递上果汁,递上果汁,递上果汁😄",
           },
        @{
            @"nickname": @"棒棒糖",
            @"content": @"递上棒棒糖",
           },
        @{
            @"nickname": @"泡泡糖",
            @"content": @"一起吃泡泡糖吧,今晚一起吃泡泡糖吗？？？？？？？？？？？？？",
           },
        @{
            @"nickname": @"fengbo66",
            @"content": @"主播能加你一个微信么？",
            },
        @{
            @"nickname": @"jack",
            @"content": @"献上一束花,献上一束花",
            },
        @{
            @"nickname": @"果汁",
            @"content": @"递上果汁,递上果汁,递上果汁😄",
            },
        @{
            @"nickname": @"棒棒糖",
            @"content": @"递上棒棒糖",
            },
        @{
            @"nickname": @"泡泡糖",
            @"content": @"一起吃泡泡糖吧,今晚一起吃泡泡糖吗？？？？？？？？？？？？？",
            },
        @{
            @"nickname": @"fengbo77",
            @"content": @"主播能加你一个微信么？",
            },
        @{
            @"nickname": @"jack",
            @"content": @"献上一束花,献上一束花",
           },
        @{
            @"nickname": @"果汁",
            @"content": @"递上果汁,递上果汁,递上果汁😄",
           },
        @{
            @"nickname": @"棒棒糖",
            @"content": @"递上棒棒糖",
           },
        @{
            @"nickname": @"泡泡糖",
            @"content": @"一起吃泡泡糖吧,今晚一起吃泡泡糖吗？？？？？？？？？？？？？",
           },
        @{
            @"nickname": @"fengbo88",
            @"content": @"主播能加你一个微信么？",
            },
        @{
            @"nickname": @"jack",
            @"content": @"献上一束花,献上一束花",
            },
        @{
            @"nickname": @"果汁",
            @"content": @"递上果汁,递上果汁,递上果汁😄",
            },
        @{
            @"nickname": @"棒棒糖",
            @"content": @"递上棒棒糖",
            },
        @{
            @"nickname": @"泡泡糖",
            @"content": @"一起吃泡泡糖吧,今晚一起吃泡泡糖吗？？？？？？？？？？？？？",
            },
        @{
            @"nickname": @"fengbo99",
            @"content": @"主播能加你一个微信么？",
            },
        @{
            @"nickname": @"jack",
            @"content": @"献上一束花,献上一束花",
           },
        @{
            @"nickname": @"果汁",
            @"content": @"递上果汁,递上果汁,递上果汁😄",
           },
        @{
            @"nickname": @"棒棒糖",
            @"content": @"递上棒棒糖",
           },
        @{
            @"nickname": @"泡泡糖",
            @"content": @"一起吃泡泡糖吧,今晚一起吃泡泡糖吗？？？？？？？？？？？？？",
           },
        @{
            @"nickname": @"棒棒糖",
            @"content": @"递上棒棒糖",
           },
        @{
            @"nickname": @"泡泡糖",
            @"content": @"一起吃泡泡糖吧,今晚一起吃泡泡糖吗？？？？？？？？？？？？？",
           },
        @{
            @"nickname": @"fengbo101",
            @"content": @"主播能加你一个微信么？",
            },
        @{
            @"nickname": @"fengbo",
            @"content": @"主播能加你一个微信么？",
            },
        @{
            @"nickname": @"jack",
            @"content": @"献上一束花,献上一束花",
            },
        @{
            @"nickname": @"果汁",
            @"content": @"递上果汁,递上果汁,递上果汁😄",
            },
        @{
            @"nickname": @"棒棒糖",
            @"content": @"递上棒棒糖",
            },
        @{
            @"nickname": @"泡泡糖",
            @"content": @"一起吃泡泡糖吧,今晚一起吃泡泡糖吗？？？？？？？？？？？？？",
            },
        @{
            @"nickname": @"fengbo11",
            @"content": @"主播能加你一个微信么？",
            },
        @{
            @"nickname": @"jack",
            @"content": @"献上一束花,献上一束花",
           },
        @{
            @"nickname": @"果汁",
            @"content": @"递上果汁,递上果汁,递上果汁😄",
           },
        @{
            @"nickname": @"棒棒糖",
            @"content": @"递上棒棒糖",
           },
        @{
            @"nickname": @"泡泡糖",
            @"content": @"一起吃泡泡糖吧,今晚一起吃泡泡糖吗？？？？？？？？？？？？？",
           },
        @{
            @"nickname": @"fengbo22",
            @"content": @"主播能加你一个微信么？",
            },
        @{
            @"nickname": @"jack",
            @"content": @"献上一束花,献上一束花",
            },
        @{
            @"nickname": @"果汁",
            @"content": @"递上果汁,递上果汁,递上果汁😄",
            },
        @{
            @"nickname": @"棒棒糖",
            @"content": @"递上棒棒糖",
            },
        @{
            @"nickname": @"泡泡糖",
            @"content": @"一起吃泡泡糖吧,今晚一起吃泡泡糖吗？？？？？？？？？？？？？",
            },
        @{
            @"nickname": @"fengbo33",
            @"content": @"主播能加你一个微信么？",
            },
        @{
            @"nickname": @"jack",
            @"content": @"献上一束花,献上一束花",
           },
        @{
            @"nickname": @"果汁",
            @"content": @"递上果汁,递上果汁,递上果汁😄",
           },
        @{
            @"nickname": @"棒棒糖",
            @"content": @"递上棒棒糖",
           },
        @{
            @"nickname": @"泡泡糖",
            @"content": @"一起吃泡泡糖吧,今晚一起吃泡泡糖吗？？？？？？？？？？？？？",
           },
        @{
            @"nickname": @"fengbo44",
            @"content": @"主播能加你一个微信么？",
            },
        @{
            @"nickname": @"jack",
            @"content": @"献上一束花,献上一束花",
            },
        @{
            @"nickname": @"果汁",
            @"content": @"递上果汁,递上果汁,递上果汁😄",
            },
        @{
            @"nickname": @"棒棒糖",
            @"content": @"递上棒棒糖",
            },
        @{
            @"nickname": @"泡泡糖",
            @"content": @"一起吃泡泡糖吧,今晚一起吃泡泡糖吗？？？？？？？？？？？？？",
            },
        @{
            @"nickname": @"fengbo55",
            @"content": @"主播能加你一个微信么？",
            },
        @{
            @"nickname": @"jack",
            @"content": @"献上一束花,献上一束花",
           },
        @{
            @"nickname": @"果汁",
            @"content": @"递上果汁,递上果汁,递上果汁😄",
           },
        @{
            @"nickname": @"棒棒糖",
            @"content": @"递上棒棒糖",
           },
        @{
            @"nickname": @"泡泡糖",
            @"content": @"一起吃泡泡糖吧,今晚一起吃泡泡糖吗？？？？？？？？？？？？？",
           },
        @{
            @"nickname": @"fengbo66",
            @"content": @"主播能加你一个微信么？",
            },
        @{
            @"nickname": @"jack",
            @"content": @"献上一束花,献上一束花",
            },
        @{
            @"nickname": @"果汁",
            @"content": @"递上果汁,递上果汁,递上果汁😄",
            },
        @{
            @"nickname": @"棒棒糖",
            @"content": @"递上棒棒糖",
            },
        @{
            @"nickname": @"泡泡糖",
            @"content": @"一起吃泡泡糖吧,今晚一起吃泡泡糖吗？？？？？？？？？？？？？",
            },
        @{
            @"nickname": @"fengbo77",
            @"content": @"主播能加你一个微信么？",
            },
        @{
            @"nickname": @"jack",
            @"content": @"献上一束花,献上一束花",
           },
        @{
            @"nickname": @"果汁",
            @"content": @"递上果汁,递上果汁,递上果汁😄",
           },
        @{
            @"nickname": @"棒棒糖",
            @"content": @"递上棒棒糖",
           },
        @{
            @"nickname": @"泡泡糖",
            @"content": @"一起吃泡泡糖吧,今晚一起吃泡泡糖吗？？？？？？？？？？？？？",
           },
        @{
            @"nickname": @"fengbo88",
            @"content": @"主播能加你一个微信么？",
            },
        @{
            @"nickname": @"jack",
            @"content": @"献上一束花,献上一束花",
            },
        @{
            @"nickname": @"果汁",
            @"content": @"递上果汁,递上果汁,递上果汁😄",
            },
        @{
            @"nickname": @"棒棒糖",
            @"content": @"递上棒棒糖",
            },
        @{
            @"nickname": @"泡泡糖",
            @"content": @"一起吃泡泡糖吧,今晚一起吃泡泡糖吗？？？？？？？？？？？？？",
            },
        @{
            @"nickname": @"fengbo99",
            @"content": @"主播能加你一个微信么？",
            },
        @{
            @"nickname": @"jack",
            @"content": @"献上一束花,献上一束花",
           },
        @{
            @"nickname": @"果汁",
            @"content": @"递上果汁,递上果汁,递上果汁😄",
           },
        @{
            @"nickname": @"棒棒糖",
            @"content": @"递上棒棒糖",
           },
        @{
            @"nickname": @"泡泡糖",
            @"content": @"一起吃泡泡糖吧,今晚一起吃泡泡糖吗？？？？？？？？？？？？？",
           },
        @{
            @"nickname": @"棒棒糖",
            @"content": @"递上棒棒糖",
           },
        @{
            @"nickname": @"泡泡糖",
            @"content": @"一起吃泡泡糖吧,今晚一起吃泡泡糖吗？？？？？？？？？？？？？",
           },
        @{
            @"nickname": @"fengbo101",
            @"content": @"主播能加你一个微信么？",
            },
        @{
            @"nickname": @"fengbo",
            @"content": @"主播能加你一个微信么？",
            },
        @{
            @"nickname": @"jack",
            @"content": @"献上一束花,献上一束花",
            },
        @{
            @"nickname": @"果汁",
            @"content": @"递上果汁,递上果汁,递上果汁😄",
            },
        @{
            @"nickname": @"棒棒糖",
            @"content": @"递上棒棒糖",
            },
        @{
            @"nickname": @"泡泡糖",
            @"content": @"一起吃泡泡糖吧,今晚一起吃泡泡糖吗？？？？？？？？？？？？？",
            },
        @{
            @"nickname": @"fengbo11",
            @"content": @"主播能加你一个微信么？",
            },
        @{
            @"nickname": @"jack",
            @"content": @"献上一束花,献上一束花",
           },
        @{
            @"nickname": @"果汁",
            @"content": @"递上果汁,递上果汁,递上果汁😄",
           },
        @{
            @"nickname": @"棒棒糖",
            @"content": @"递上棒棒糖",
           },
        @{
            @"nickname": @"泡泡糖",
            @"content": @"一起吃泡泡糖吧,今晚一起吃泡泡糖吗？？？？？？？？？？？？？",
           },
        @{
            @"nickname": @"fengbo22",
            @"content": @"主播能加你一个微信么？",
            },
        @{
            @"nickname": @"jack",
            @"content": @"献上一束花,献上一束花",
            },
        @{
            @"nickname": @"果汁",
            @"content": @"递上果汁,递上果汁,递上果汁😄",
            },
        @{
            @"nickname": @"棒棒糖",
            @"content": @"递上棒棒糖",
            },
        @{
            @"nickname": @"泡泡糖",
            @"content": @"一起吃泡泡糖吧,今晚一起吃泡泡糖吗？？？？？？？？？？？？？",
            },
        @{
            @"nickname": @"fengbo33",
            @"content": @"主播能加你一个微信么？",
            },
        @{
            @"nickname": @"jack",
            @"content": @"献上一束花,献上一束花",
           },
        @{
            @"nickname": @"果汁",
            @"content": @"递上果汁,递上果汁,递上果汁😄",
           },
        @{
            @"nickname": @"棒棒糖",
            @"content": @"递上棒棒糖",
           },
        @{
            @"nickname": @"泡泡糖",
            @"content": @"一起吃泡泡糖吧,今晚一起吃泡泡糖吗？？？？？？？？？？？？？",
           },
        @{
            @"nickname": @"fengbo44",
            @"content": @"主播能加你一个微信么？",
            },
        @{
            @"nickname": @"jack",
            @"content": @"献上一束花,献上一束花",
            },
        @{
            @"nickname": @"果汁",
            @"content": @"递上果汁,递上果汁,递上果汁😄",
            },
        @{
            @"nickname": @"棒棒糖",
            @"content": @"递上棒棒糖",
            },
        @{
            @"nickname": @"泡泡糖",
            @"content": @"一起吃泡泡糖吧,今晚一起吃泡泡糖吗？？？？？？？？？？？？？",
            },
        @{
            @"nickname": @"fengbo55",
            @"content": @"主播能加你一个微信么？",
            },
        @{
            @"nickname": @"jack",
            @"content": @"献上一束花,献上一束花",
           },
        @{
            @"nickname": @"果汁",
            @"content": @"递上果汁,递上果汁,递上果汁😄",
           },
        @{
            @"nickname": @"棒棒糖",
            @"content": @"递上棒棒糖",
           },
        @{
            @"nickname": @"泡泡糖",
            @"content": @"一起吃泡泡糖吧,今晚一起吃泡泡糖吗？？？？？？？？？？？？？",
           },
        @{
            @"nickname": @"fengbo66",
            @"content": @"主播能加你一个微信么？",
            },
        @{
            @"nickname": @"jack",
            @"content": @"献上一束花,献上一束花",
            },
        @{
            @"nickname": @"果汁",
            @"content": @"递上果汁,递上果汁,递上果汁😄",
            },
        @{
            @"nickname": @"棒棒糖",
            @"content": @"递上棒棒糖",
            },
        @{
            @"nickname": @"泡泡糖",
            @"content": @"一起吃泡泡糖吧,今晚一起吃泡泡糖吗？？？？？？？？？？？？？",
            },
        @{
            @"nickname": @"fengbo77",
            @"content": @"主播能加你一个微信么？",
            },
        @{
            @"nickname": @"jack",
            @"content": @"献上一束花,献上一束花",
           },
        @{
            @"nickname": @"果汁",
            @"content": @"递上果汁,递上果汁,递上果汁😄",
           },
        @{
            @"nickname": @"棒棒糖",
            @"content": @"递上棒棒糖",
           },
        @{
            @"nickname": @"泡泡糖",
            @"content": @"一起吃泡泡糖吧,今晚一起吃泡泡糖吗？？？？？？？？？？？？？",
           },
        @{
            @"nickname": @"fengbo88",
            @"content": @"主播能加你一个微信么？",
            },
        @{
            @"nickname": @"jack",
            @"content": @"献上一束花,献上一束花",
            },
        @{
            @"nickname": @"果汁",
            @"content": @"递上果汁,递上果汁,递上果汁😄",
            },
        @{
            @"nickname": @"棒棒糖",
            @"content": @"递上棒棒糖",
            },
        @{
            @"nickname": @"泡泡糖",
            @"content": @"一起吃泡泡糖吧,今晚一起吃泡泡糖吗？？？？？？？？？？？？？",
            },
        @{
            @"nickname": @"fengbo99",
            @"content": @"主播能加你一个微信么？",
            },
        @{
            @"nickname": @"jack",
            @"content": @"献上一束花,献上一束花",
           },
        @{
            @"nickname": @"果汁",
            @"content": @"递上果汁,递上果汁,递上果汁😄",
           },
        @{
            @"nickname": @"棒棒糖",
            @"content": @"递上棒棒糖",
           },
        @{
            @"nickname": @"泡泡糖",
            @"content": @"一起吃泡泡糖吧,今晚一起吃泡泡糖吗？？？？？？？？？？？？？",
           },
        @{
            @"nickname": @"棒棒糖",
            @"content": @"递上棒棒糖",
           },
        @{
            @"nickname": @"泡泡糖",
            @"content": @"一起吃泡泡糖吧,今晚一起吃泡泡糖吗？？？？？？？？？？？？？",
           },
        @{
            @"nickname": @"fengbo101",
            @"content": @"主播能加你一个微信么？",
            },
        @{
            @"nickname": @"fengbo",
            @"content": @"主播能加你一个微信么？",
            },
        @{
            @"nickname": @"jack",
            @"content": @"献上一束花,献上一束花",
            },
        @{
            @"nickname": @"果汁",
            @"content": @"递上果汁,递上果汁,递上果汁😄",
            },
        @{
            @"nickname": @"棒棒糖",
            @"content": @"递上棒棒糖",
            },
        @{
            @"nickname": @"泡泡糖",
            @"content": @"一起吃泡泡糖吧,今晚一起吃泡泡糖吗？？？？？？？？？？？？？",
            },
        @{
            @"nickname": @"fengbo11",
            @"content": @"主播能加你一个微信么？",
            },
        @{
            @"nickname": @"jack",
            @"content": @"献上一束花,献上一束花",
           },
        @{
            @"nickname": @"果汁",
            @"content": @"递上果汁,递上果汁,递上果汁😄",
           },
        @{
            @"nickname": @"棒棒糖",
            @"content": @"递上棒棒糖",
           },
        @{
            @"nickname": @"泡泡糖",
            @"content": @"一起吃泡泡糖吧,今晚一起吃泡泡糖吗？？？？？？？？？？？？？",
           },
        @{
            @"nickname": @"fengbo22",
            @"content": @"主播能加你一个微信么？",
            },
        @{
            @"nickname": @"jack",
            @"content": @"献上一束花,献上一束花",
            },
        @{
            @"nickname": @"果汁",
            @"content": @"递上果汁,递上果汁,递上果汁😄",
            },
        @{
            @"nickname": @"棒棒糖",
            @"content": @"递上棒棒糖",
            },
        @{
            @"nickname": @"泡泡糖",
            @"content": @"一起吃泡泡糖吧,今晚一起吃泡泡糖吗？？？？？？？？？？？？？",
            },
        @{
            @"nickname": @"fengbo33",
            @"content": @"主播能加你一个微信么？",
            },
        @{
            @"nickname": @"jack",
            @"content": @"献上一束花,献上一束花",
           },
        @{
            @"nickname": @"果汁",
            @"content": @"递上果汁,递上果汁,递上果汁😄",
           },
        @{
            @"nickname": @"棒棒糖",
            @"content": @"递上棒棒糖",
           },
        @{
            @"nickname": @"泡泡糖",
            @"content": @"一起吃泡泡糖吧,今晚一起吃泡泡糖吗？？？？？？？？？？？？？",
           },
        @{
            @"nickname": @"fengbo44",
            @"content": @"主播能加你一个微信么？",
            },
        @{
            @"nickname": @"jack",
            @"content": @"献上一束花,献上一束花",
            },
        @{
            @"nickname": @"果汁",
            @"content": @"递上果汁,递上果汁,递上果汁😄",
            },
        @{
            @"nickname": @"棒棒糖",
            @"content": @"递上棒棒糖",
            },
        @{
            @"nickname": @"泡泡糖",
            @"content": @"一起吃泡泡糖吧,今晚一起吃泡泡糖吗？？？？？？？？？？？？？",
            },
        @{
            @"nickname": @"fengbo55",
            @"content": @"主播能加你一个微信么？",
            },
        @{
            @"nickname": @"jack",
            @"content": @"献上一束花,献上一束花",
           },
        @{
            @"nickname": @"果汁",
            @"content": @"递上果汁,递上果汁,递上果汁😄",
           },
        @{
            @"nickname": @"棒棒糖",
            @"content": @"递上棒棒糖",
           },
        @{
            @"nickname": @"泡泡糖",
            @"content": @"一起吃泡泡糖吧,今晚一起吃泡泡糖吗？？？？？？？？？？？？？",
           },
        @{
            @"nickname": @"fengbo66",
            @"content": @"主播能加你一个微信么？",
            },
        @{
            @"nickname": @"jack",
            @"content": @"献上一束花,献上一束花",
            },
        @{
            @"nickname": @"果汁",
            @"content": @"递上果汁,递上果汁,递上果汁😄",
            },
        @{
            @"nickname": @"棒棒糖",
            @"content": @"递上棒棒糖",
            },
        @{
            @"nickname": @"泡泡糖",
            @"content": @"一起吃泡泡糖吧,今晚一起吃泡泡糖吗？？？？？？？？？？？？？",
            },
        @{
            @"nickname": @"fengbo77",
            @"content": @"主播能加你一个微信么？",
            },
        @{
            @"nickname": @"jack",
            @"content": @"献上一束花,献上一束花",
           },
        @{
            @"nickname": @"果汁",
            @"content": @"递上果汁,递上果汁,递上果汁😄",
           },
        @{
            @"nickname": @"棒棒糖",
            @"content": @"递上棒棒糖",
           },
        @{
            @"nickname": @"泡泡糖",
            @"content": @"一起吃泡泡糖吧,今晚一起吃泡泡糖吗？？？？？？？？？？？？？",
           },
        @{
            @"nickname": @"fengbo88",
            @"content": @"主播能加你一个微信么？",
            },
        @{
            @"nickname": @"jack",
            @"content": @"献上一束花,献上一束花",
            },
        @{
            @"nickname": @"果汁",
            @"content": @"递上果汁,递上果汁,递上果汁😄",
            },
        @{
            @"nickname": @"棒棒糖",
            @"content": @"递上棒棒糖",
            },
        @{
            @"nickname": @"泡泡糖",
            @"content": @"一起吃泡泡糖吧,今晚一起吃泡泡糖吗？？？？？？？？？？？？？",
            },
        @{
            @"nickname": @"fengbo99",
            @"content": @"主播能加你一个微信么？",
            },
        @{
            @"nickname": @"jack",
            @"content": @"献上一束花,献上一束花",
           },
        @{
            @"nickname": @"果汁",
            @"content": @"递上果汁,递上果汁,递上果汁😄",
           },
        @{
            @"nickname": @"棒棒糖",
            @"content": @"递上棒棒糖",
           },
        @{
            @"nickname": @"泡泡糖",
            @"content": @"一起吃泡泡糖吧,今晚一起吃泡泡糖吗？？？？？？？？？？？？？",
           },
        @{
            @"nickname": @"棒棒糖",
            @"content": @"递上棒棒糖",
           },
        @{
            @"nickname": @"泡泡糖",
            @"content": @"一起吃泡泡糖吧,今晚一起吃泡泡糖吗？？？？？？？？？？？？？",
           },
        @{
            @"nickname": @"fengbo101",
            @"content": @"主播能加你一个微信么？",
            },
        @{
            @"nickname": @"fengbo",
            @"content": @"主播能加你一个微信么？",
            },
        @{
            @"nickname": @"jack",
            @"content": @"献上一束花,献上一束花",
            },
        @{
            @"nickname": @"果汁",
            @"content": @"递上果汁,递上果汁,递上果汁😄",
            },
        @{
            @"nickname": @"棒棒糖",
            @"content": @"递上棒棒糖",
            },
        @{
            @"nickname": @"泡泡糖",
            @"content": @"一起吃泡泡糖吧,今晚一起吃泡泡糖吗？？？？？？？？？？？？？",
            },
        @{
            @"nickname": @"fengbo11",
            @"content": @"主播能加你一个微信么？",
            },
        @{
            @"nickname": @"jack",
            @"content": @"献上一束花,献上一束花",
           },
        @{
            @"nickname": @"果汁",
            @"content": @"递上果汁,递上果汁,递上果汁😄",
           },
        @{
            @"nickname": @"棒棒糖",
            @"content": @"递上棒棒糖",
           },
        @{
            @"nickname": @"泡泡糖",
            @"content": @"一起吃泡泡糖吧,今晚一起吃泡泡糖吗？？？？？？？？？？？？？",
           },
        @{
            @"nickname": @"fengbo22",
            @"content": @"主播能加你一个微信么？",
            },
        @{
            @"nickname": @"jack",
            @"content": @"献上一束花,献上一束花",
            },
        @{
            @"nickname": @"果汁",
            @"content": @"递上果汁,递上果汁,递上果汁😄",
            },
        @{
            @"nickname": @"棒棒糖",
            @"content": @"递上棒棒糖",
            },
        @{
            @"nickname": @"泡泡糖",
            @"content": @"一起吃泡泡糖吧,今晚一起吃泡泡糖吗？？？？？？？？？？？？？",
            },
        @{
            @"nickname": @"fengbo33",
            @"content": @"主播能加你一个微信么？",
            },
        @{
            @"nickname": @"jack",
            @"content": @"献上一束花,献上一束花",
           },
        @{
            @"nickname": @"果汁",
            @"content": @"递上果汁,递上果汁,递上果汁😄",
           },
        @{
            @"nickname": @"棒棒糖",
            @"content": @"递上棒棒糖",
           },
        @{
            @"nickname": @"泡泡糖",
            @"content": @"一起吃泡泡糖吧,今晚一起吃泡泡糖吗？？？？？？？？？？？？？",
           },
        @{
            @"nickname": @"fengbo44",
            @"content": @"主播能加你一个微信么？",
            },
        @{
            @"nickname": @"jack",
            @"content": @"献上一束花,献上一束花",
            },
        @{
            @"nickname": @"果汁",
            @"content": @"递上果汁,递上果汁,递上果汁😄",
            },
        @{
            @"nickname": @"棒棒糖",
            @"content": @"递上棒棒糖",
            },
        @{
            @"nickname": @"泡泡糖",
            @"content": @"一起吃泡泡糖吧,今晚一起吃泡泡糖吗？？？？？？？？？？？？？",
            },
        @{
            @"nickname": @"fengbo55",
            @"content": @"主播能加你一个微信么？",
            },
        @{
            @"nickname": @"jack",
            @"content": @"献上一束花,献上一束花",
           },
        @{
            @"nickname": @"果汁",
            @"content": @"递上果汁,递上果汁,递上果汁😄",
           },
        @{
            @"nickname": @"棒棒糖",
            @"content": @"递上棒棒糖",
           },
        @{
            @"nickname": @"泡泡糖",
            @"content": @"一起吃泡泡糖吧,今晚一起吃泡泡糖吗？？？？？？？？？？？？？",
           },
        @{
            @"nickname": @"fengbo66",
            @"content": @"主播能加你一个微信么？",
            },
        @{
            @"nickname": @"jack",
            @"content": @"献上一束花,献上一束花",
            },
        @{
            @"nickname": @"果汁",
            @"content": @"递上果汁,递上果汁,递上果汁😄",
            },
        @{
            @"nickname": @"棒棒糖",
            @"content": @"递上棒棒糖",
            },
        @{
            @"nickname": @"泡泡糖",
            @"content": @"一起吃泡泡糖吧,今晚一起吃泡泡糖吗？？？？？？？？？？？？？",
            },
        @{
            @"nickname": @"fengbo77",
            @"content": @"主播能加你一个微信么？",
            },
        @{
            @"nickname": @"jack",
            @"content": @"献上一束花,献上一束花",
           },
        @{
            @"nickname": @"果汁",
            @"content": @"递上果汁,递上果汁,递上果汁😄",
           },
        @{
            @"nickname": @"棒棒糖",
            @"content": @"递上棒棒糖",
           },
        @{
            @"nickname": @"泡泡糖",
            @"content": @"一起吃泡泡糖吧,今晚一起吃泡泡糖吗？？？？？？？？？？？？？",
           },
        @{
            @"nickname": @"fengbo88",
            @"content": @"主播能加你一个微信么？",
            },
        @{
            @"nickname": @"jack",
            @"content": @"献上一束花,献上一束花",
            },
        @{
            @"nickname": @"果汁",
            @"content": @"递上果汁,递上果汁,递上果汁😄",
            },
        @{
            @"nickname": @"棒棒糖",
            @"content": @"递上棒棒糖",
            },
        @{
            @"nickname": @"泡泡糖",
            @"content": @"一起吃泡泡糖吧,今晚一起吃泡泡糖吗？？？？？？？？？？？？？",
            },
        @{
            @"nickname": @"fengbo99",
            @"content": @"主播能加你一个微信么？",
            },
        @{
            @"nickname": @"jack",
            @"content": @"献上一束花,献上一束花",
           },
        @{
            @"nickname": @"果汁",
            @"content": @"递上果汁,递上果汁,递上果汁😄",
           },
        @{
            @"nickname": @"棒棒糖",
            @"content": @"递上棒棒糖",
           },
        @{
            @"nickname": @"泡泡糖",
            @"content": @"一起吃泡泡糖吧,今晚一起吃泡泡糖吗？？？？？？？？？？？？？",
           },
        @{
            @"nickname": @"棒棒糖",
            @"content": @"递上棒棒糖",
           },
        @{
            @"nickname": @"泡泡糖",
            @"content": @"一起吃泡泡糖吧,今晚一起吃泡泡糖吗？？？？？？？？？？？？？",
           },
        @{
            @"nickname": @"fengbo101",
            @"content": @"主播能加你一个微信么？",
            },
        @{
            @"nickname": @"fengbo",
            @"content": @"主播能加你一个微信么？",
            },
        @{
            @"nickname": @"jack",
            @"content": @"献上一束花,献上一束花",
            },
        @{
            @"nickname": @"果汁",
            @"content": @"递上果汁,递上果汁,递上果汁😄",
            },
        @{
            @"nickname": @"棒棒糖",
            @"content": @"递上棒棒糖",
            },
        @{
            @"nickname": @"泡泡糖",
            @"content": @"一起吃泡泡糖吧,今晚一起吃泡泡糖吗？？？？？？？？？？？？？",
            },
        @{
            @"nickname": @"fengbo11",
            @"content": @"主播能加你一个微信么？",
            },
        @{
            @"nickname": @"jack",
            @"content": @"献上一束花,献上一束花",
           },
        @{
            @"nickname": @"果汁",
            @"content": @"递上果汁,递上果汁,递上果汁😄",
           },
        @{
            @"nickname": @"棒棒糖",
            @"content": @"递上棒棒糖",
           },
        @{
            @"nickname": @"泡泡糖",
            @"content": @"一起吃泡泡糖吧,今晚一起吃泡泡糖吗？？？？？？？？？？？？？",
           },
        @{
            @"nickname": @"fengbo22",
            @"content": @"主播能加你一个微信么？",
            },
        @{
            @"nickname": @"jack",
            @"content": @"献上一束花,献上一束花",
            },
        @{
            @"nickname": @"果汁",
            @"content": @"递上果汁,递上果汁,递上果汁😄",
            },
        @{
            @"nickname": @"棒棒糖",
            @"content": @"递上棒棒糖",
            },
        @{
            @"nickname": @"泡泡糖",
            @"content": @"一起吃泡泡糖吧,今晚一起吃泡泡糖吗？？？？？？？？？？？？？",
            },
        @{
            @"nickname": @"fengbo33",
            @"content": @"主播能加你一个微信么？",
            },
        @{
            @"nickname": @"jack",
            @"content": @"献上一束花,献上一束花",
           },
        @{
            @"nickname": @"果汁",
            @"content": @"递上果汁,递上果汁,递上果汁😄",
           },
        @{
            @"nickname": @"棒棒糖",
            @"content": @"递上棒棒糖",
           },
        @{
            @"nickname": @"泡泡糖",
            @"content": @"一起吃泡泡糖吧,今晚一起吃泡泡糖吗？？？？？？？？？？？？？",
           },
        @{
            @"nickname": @"fengbo44",
            @"content": @"主播能加你一个微信么？",
            },
        @{
            @"nickname": @"jack",
            @"content": @"献上一束花,献上一束花",
            },
        @{
            @"nickname": @"果汁",
            @"content": @"递上果汁,递上果汁,递上果汁😄",
            },
        @{
            @"nickname": @"棒棒糖",
            @"content": @"递上棒棒糖",
            },
        @{
            @"nickname": @"泡泡糖",
            @"content": @"一起吃泡泡糖吧,今晚一起吃泡泡糖吗？？？？？？？？？？？？？",
            },
        @{
            @"nickname": @"fengbo55",
            @"content": @"主播能加你一个微信么？",
            },
        @{
            @"nickname": @"jack",
            @"content": @"献上一束花,献上一束花",
           },
        @{
            @"nickname": @"果汁",
            @"content": @"递上果汁,递上果汁,递上果汁😄",
           },
        @{
            @"nickname": @"棒棒糖",
            @"content": @"递上棒棒糖",
           },
        @{
            @"nickname": @"泡泡糖",
            @"content": @"一起吃泡泡糖吧,今晚一起吃泡泡糖吗？？？？？？？？？？？？？",
           },
        @{
            @"nickname": @"fengbo66",
            @"content": @"主播能加你一个微信么？",
            },
        @{
            @"nickname": @"jack",
            @"content": @"献上一束花,献上一束花",
            },
        @{
            @"nickname": @"果汁",
            @"content": @"递上果汁,递上果汁,递上果汁😄",
            },
        @{
            @"nickname": @"棒棒糖",
            @"content": @"递上棒棒糖",
            },
        @{
            @"nickname": @"泡泡糖",
            @"content": @"一起吃泡泡糖吧,今晚一起吃泡泡糖吗？？？？？？？？？？？？？",
            },
        @{
            @"nickname": @"fengbo77",
            @"content": @"主播能加你一个微信么？",
            },
        @{
            @"nickname": @"jack",
            @"content": @"献上一束花,献上一束花",
           },
        @{
            @"nickname": @"果汁",
            @"content": @"递上果汁,递上果汁,递上果汁😄",
           },
        @{
            @"nickname": @"棒棒糖",
            @"content": @"递上棒棒糖",
           },
        @{
            @"nickname": @"泡泡糖",
            @"content": @"一起吃泡泡糖吧,今晚一起吃泡泡糖吗？？？？？？？？？？？？？",
           },
        @{
            @"nickname": @"fengbo88",
            @"content": @"主播能加你一个微信么？",
            },
        @{
            @"nickname": @"jack",
            @"content": @"献上一束花,献上一束花",
            },
        @{
            @"nickname": @"果汁",
            @"content": @"递上果汁,递上果汁,递上果汁😄",
            },
        @{
            @"nickname": @"棒棒糖",
            @"content": @"递上棒棒糖",
            },
        @{
            @"nickname": @"泡泡糖",
            @"content": @"一起吃泡泡糖吧,今晚一起吃泡泡糖吗？？？？？？？？？？？？？",
            },
        @{
            @"nickname": @"fengbo99",
            @"content": @"主播能加你一个微信么？",
            },
        @{
            @"nickname": @"jack",
            @"content": @"献上一束花,献上一束花",
           },
        @{
            @"nickname": @"果汁",
            @"content": @"递上果汁,递上果汁,递上果汁😄",
           },
        @{
            @"nickname": @"棒棒糖",
            @"content": @"递上棒棒糖",
           },
        @{
            @"nickname": @"泡泡糖",
            @"content": @"一起吃泡泡糖吧,今晚一起吃泡泡糖吗？？？？？？？？？？？？？",
           },
        @{
            @"nickname": @"棒棒糖",
            @"content": @"递上棒棒糖",
           },
        @{
            @"nickname": @"泡泡糖",
            @"content": @"一起吃泡泡糖吧,今晚一起吃泡泡糖吗？？？？？？？？？？？？？",
           },
        @{
            @"nickname": @"fengbo101",
            @"content": @"主播能加你一个微信么？",
            },
        @{
            @"nickname": @"fengbo",
            @"content": @"主播能加你一个微信么？",
            },
        @{
            @"nickname": @"jack",
            @"content": @"献上一束花,献上一束花",
            },
        @{
            @"nickname": @"果汁",
            @"content": @"递上果汁,递上果汁,递上果汁😄",
            },
        @{
            @"nickname": @"棒棒糖",
            @"content": @"递上棒棒糖",
            },
        @{
            @"nickname": @"泡泡糖",
            @"content": @"一起吃泡泡糖吧,今晚一起吃泡泡糖吗？？？？？？？？？？？？？",
            },
        @{
            @"nickname": @"fengbo11",
            @"content": @"主播能加你一个微信么？",
            },
        @{
            @"nickname": @"jack",
            @"content": @"献上一束花,献上一束花",
           },
        @{
            @"nickname": @"果汁",
            @"content": @"递上果汁,递上果汁,递上果汁😄",
           },
        @{
            @"nickname": @"棒棒糖",
            @"content": @"递上棒棒糖",
           },
        @{
            @"nickname": @"泡泡糖",
            @"content": @"一起吃泡泡糖吧,今晚一起吃泡泡糖吗？？？？？？？？？？？？？",
           },
        @{
            @"nickname": @"fengbo22",
            @"content": @"主播能加你一个微信么？",
            },
        @{
            @"nickname": @"jack",
            @"content": @"献上一束花,献上一束花",
            },
        @{
            @"nickname": @"果汁",
            @"content": @"递上果汁,递上果汁,递上果汁😄",
            },
        @{
            @"nickname": @"棒棒糖",
            @"content": @"递上棒棒糖",
            },
        @{
            @"nickname": @"泡泡糖",
            @"content": @"一起吃泡泡糖吧,今晚一起吃泡泡糖吗？？？？？？？？？？？？？",
            },
        @{
            @"nickname": @"fengbo33",
            @"content": @"主播能加你一个微信么？",
            },
        @{
            @"nickname": @"jack",
            @"content": @"献上一束花,献上一束花",
           },
        @{
            @"nickname": @"果汁",
            @"content": @"递上果汁,递上果汁,递上果汁😄",
           },
        @{
            @"nickname": @"棒棒糖",
            @"content": @"递上棒棒糖",
           },
        @{
            @"nickname": @"泡泡糖",
            @"content": @"一起吃泡泡糖吧,今晚一起吃泡泡糖吗？？？？？？？？？？？？？",
           },
        @{
            @"nickname": @"fengbo44",
            @"content": @"主播能加你一个微信么？",
            },
        @{
            @"nickname": @"jack",
            @"content": @"献上一束花,献上一束花",
            },
        @{
            @"nickname": @"果汁",
            @"content": @"递上果汁,递上果汁,递上果汁😄",
            },
        @{
            @"nickname": @"棒棒糖",
            @"content": @"递上棒棒糖",
            },
        @{
            @"nickname": @"泡泡糖",
            @"content": @"一起吃泡泡糖吧,今晚一起吃泡泡糖吗？？？？？？？？？？？？？",
            },
        @{
            @"nickname": @"fengbo55",
            @"content": @"主播能加你一个微信么？",
            },
        @{
            @"nickname": @"jack",
            @"content": @"献上一束花,献上一束花",
           },
        @{
            @"nickname": @"果汁",
            @"content": @"递上果汁,递上果汁,递上果汁😄",
           },
        @{
            @"nickname": @"棒棒糖",
            @"content": @"递上棒棒糖",
           },
        @{
            @"nickname": @"泡泡糖",
            @"content": @"一起吃泡泡糖吧,今晚一起吃泡泡糖吗？？？？？？？？？？？？？",
           },
        @{
            @"nickname": @"fengbo66",
            @"content": @"主播能加你一个微信么？",
            },
        @{
            @"nickname": @"jack",
            @"content": @"献上一束花,献上一束花",
            },
        @{
            @"nickname": @"果汁",
            @"content": @"递上果汁,递上果汁,递上果汁😄",
            },
        @{
            @"nickname": @"棒棒糖",
            @"content": @"递上棒棒糖",
            },
        @{
            @"nickname": @"泡泡糖",
            @"content": @"一起吃泡泡糖吧,今晚一起吃泡泡糖吗？？？？？？？？？？？？？",
            },
        @{
            @"nickname": @"fengbo77",
            @"content": @"主播能加你一个微信么？",
            },
        @{
            @"nickname": @"jack",
            @"content": @"献上一束花,献上一束花",
           },
        @{
            @"nickname": @"果汁",
            @"content": @"递上果汁,递上果汁,递上果汁😄",
           },
        @{
            @"nickname": @"棒棒糖",
            @"content": @"递上棒棒糖",
           },
        @{
            @"nickname": @"泡泡糖",
            @"content": @"一起吃泡泡糖吧,今晚一起吃泡泡糖吗？？？？？？？？？？？？？",
           },
        @{
            @"nickname": @"fengbo88",
            @"content": @"主播能加你一个微信么？",
            },
        @{
            @"nickname": @"jack",
            @"content": @"献上一束花,献上一束花",
            },
        @{
            @"nickname": @"果汁",
            @"content": @"递上果汁,递上果汁,递上果汁😄",
            },
        @{
            @"nickname": @"棒棒糖",
            @"content": @"递上棒棒糖",
            },
        @{
            @"nickname": @"泡泡糖",
            @"content": @"一起吃泡泡糖吧,今晚一起吃泡泡糖吗？？？？？？？？？？？？？",
            },
        @{
            @"nickname": @"fengbo99",
            @"content": @"主播能加你一个微信么？",
            },
        @{
            @"nickname": @"jack",
            @"content": @"献上一束花,献上一束花",
           },
        @{
            @"nickname": @"果汁",
            @"content": @"递上果汁,递上果汁,递上果汁😄",
           },
        @{
            @"nickname": @"棒棒糖",
            @"content": @"递上棒棒糖",
           },
        @{
            @"nickname": @"泡泡糖",
            @"content": @"一起吃泡泡糖吧,今晚一起吃泡泡糖吗？？？？？？？？？？？？？",
           },
        @{
            @"nickname": @"棒棒糖",
            @"content": @"递上棒棒糖",
           },
        @{
            @"nickname": @"泡泡糖",
            @"content": @"一起吃泡泡糖吧,今晚一起吃泡泡糖吗？？？？？？？？？？？？？",
           },
        @{
            @"nickname": @"fengbo101",
            @"content": @"主播能加你一个微信么？",
            },
        @{
            @"nickname": @"fengbo",
            @"content": @"主播能加你一个微信么？",
            },
        @{
            @"nickname": @"jack",
            @"content": @"献上一束花,献上一束花",
            },
        @{
            @"nickname": @"果汁",
            @"content": @"递上果汁,递上果汁,递上果汁😄",
            },
        @{
            @"nickname": @"棒棒糖",
            @"content": @"递上棒棒糖",
            },
        @{
            @"nickname": @"泡泡糖",
            @"content": @"一起吃泡泡糖吧,今晚一起吃泡泡糖吗？？？？？？？？？？？？？",
            },
        @{
            @"nickname": @"fengbo11",
            @"content": @"主播能加你一个微信么？",
            },
        @{
            @"nickname": @"jack",
            @"content": @"献上一束花,献上一束花",
           },
        @{
            @"nickname": @"果汁",
            @"content": @"递上果汁,递上果汁,递上果汁😄",
           },
        @{
            @"nickname": @"棒棒糖",
            @"content": @"递上棒棒糖",
           },
        @{
            @"nickname": @"泡泡糖",
            @"content": @"一起吃泡泡糖吧,今晚一起吃泡泡糖吗？？？？？？？？？？？？？",
           },
        @{
            @"nickname": @"fengbo22",
            @"content": @"主播能加你一个微信么？",
            },
        @{
            @"nickname": @"jack",
            @"content": @"献上一束花,献上一束花",
            },
        @{
            @"nickname": @"果汁",
            @"content": @"递上果汁,递上果汁,递上果汁😄",
            },
        @{
            @"nickname": @"棒棒糖",
            @"content": @"递上棒棒糖",
            },
        @{
            @"nickname": @"泡泡糖",
            @"content": @"一起吃泡泡糖吧,今晚一起吃泡泡糖吗？？？？？？？？？？？？？",
            },
        @{
            @"nickname": @"fengbo33",
            @"content": @"主播能加你一个微信么？",
            },
        @{
            @"nickname": @"jack",
            @"content": @"献上一束花,献上一束花",
           },
        @{
            @"nickname": @"果汁",
            @"content": @"递上果汁,递上果汁,递上果汁😄",
           },
        @{
            @"nickname": @"棒棒糖",
            @"content": @"递上棒棒糖",
           },
        @{
            @"nickname": @"泡泡糖",
            @"content": @"一起吃泡泡糖吧,今晚一起吃泡泡糖吗？？？？？？？？？？？？？",
           },
        @{
            @"nickname": @"fengbo44",
            @"content": @"主播能加你一个微信么？",
            },
        @{
            @"nickname": @"jack",
            @"content": @"献上一束花,献上一束花",
            },
        @{
            @"nickname": @"果汁",
            @"content": @"递上果汁,递上果汁,递上果汁😄",
            },
        @{
            @"nickname": @"棒棒糖",
            @"content": @"递上棒棒糖",
            },
        @{
            @"nickname": @"泡泡糖",
            @"content": @"一起吃泡泡糖吧,今晚一起吃泡泡糖吗？？？？？？？？？？？？？",
            },
        @{
            @"nickname": @"fengbo55",
            @"content": @"主播能加你一个微信么？",
            },
        @{
            @"nickname": @"jack",
            @"content": @"献上一束花,献上一束花",
           },
        @{
            @"nickname": @"果汁",
            @"content": @"递上果汁,递上果汁,递上果汁😄",
           },
        @{
            @"nickname": @"棒棒糖",
            @"content": @"递上棒棒糖",
           },
        @{
            @"nickname": @"泡泡糖",
            @"content": @"一起吃泡泡糖吧,今晚一起吃泡泡糖吗？？？？？？？？？？？？？",
           },
        @{
            @"nickname": @"fengbo66",
            @"content": @"主播能加你一个微信么？",
            },
        @{
            @"nickname": @"jack",
            @"content": @"献上一束花,献上一束花",
            },
        @{
            @"nickname": @"果汁",
            @"content": @"递上果汁,递上果汁,递上果汁😄",
            },
        @{
            @"nickname": @"棒棒糖",
            @"content": @"递上棒棒糖",
            },
        @{
            @"nickname": @"泡泡糖",
            @"content": @"一起吃泡泡糖吧,今晚一起吃泡泡糖吗？？？？？？？？？？？？？",
            },
        @{
            @"nickname": @"fengbo77",
            @"content": @"主播能加你一个微信么？",
            },
        @{
            @"nickname": @"jack",
            @"content": @"献上一束花,献上一束花",
           },
        @{
            @"nickname": @"果汁",
            @"content": @"递上果汁,递上果汁,递上果汁😄",
           },
        @{
            @"nickname": @"棒棒糖",
            @"content": @"递上棒棒糖",
           },
        @{
            @"nickname": @"泡泡糖",
            @"content": @"一起吃泡泡糖吧,今晚一起吃泡泡糖吗？？？？？？？？？？？？？",
           },
        @{
            @"nickname": @"fengbo88",
            @"content": @"主播能加你一个微信么？",
            },
        @{
            @"nickname": @"jack",
            @"content": @"献上一束花,献上一束花",
            },
        @{
            @"nickname": @"果汁",
            @"content": @"递上果汁,递上果汁,递上果汁😄",
            },
        @{
            @"nickname": @"棒棒糖",
            @"content": @"递上棒棒糖",
            },
        @{
            @"nickname": @"泡泡糖",
            @"content": @"一起吃泡泡糖吧,今晚一起吃泡泡糖吗？？？？？？？？？？？？？",
            },
        @{
            @"nickname": @"fengbo99",
            @"content": @"主播能加你一个微信么？",
            },
        @{
            @"nickname": @"jack",
            @"content": @"献上一束花,献上一束花",
           },
        @{
            @"nickname": @"果汁",
            @"content": @"递上果汁,递上果汁,递上果汁😄",
           },
        @{
            @"nickname": @"棒棒糖",
            @"content": @"递上棒棒糖",
           },
        @{
            @"nickname": @"泡泡糖",
            @"content": @"一起吃泡泡糖吧,今晚一起吃泡泡糖吗？？？？？？？？？？？？？",
           },
        @{
            @"nickname": @"棒棒糖",
            @"content": @"递上棒棒糖",
           },
        @{
            @"nickname": @"泡泡糖",
            @"content": @"一起吃泡泡糖吧,今晚一起吃泡泡糖吗？？？？？？？？？？？？？",
           },
        @{
            @"nickname": @"fengbo101",
            @"content": @"主播能加你一个微信么？",
            },
        @{
            @"nickname": @"fengbo",
            @"content": @"主播能加你一个微信么？",
            },
        @{
            @"nickname": @"jack",
            @"content": @"献上一束花,献上一束花",
            },
        @{
            @"nickname": @"果汁",
            @"content": @"递上果汁,递上果汁,递上果汁😄",
            },
        @{
            @"nickname": @"棒棒糖",
            @"content": @"递上棒棒糖",
            },
        @{
            @"nickname": @"泡泡糖",
            @"content": @"一起吃泡泡糖吧,今晚一起吃泡泡糖吗？？？？？？？？？？？？？",
            },
        @{
            @"nickname": @"fengbo11",
            @"content": @"主播能加你一个微信么？",
            },
        @{
            @"nickname": @"jack",
            @"content": @"献上一束花,献上一束花",
           },
        @{
            @"nickname": @"果汁",
            @"content": @"递上果汁,递上果汁,递上果汁😄",
           },
        @{
            @"nickname": @"棒棒糖",
            @"content": @"递上棒棒糖",
           },
        @{
            @"nickname": @"泡泡糖",
            @"content": @"一起吃泡泡糖吧,今晚一起吃泡泡糖吗？？？？？？？？？？？？？",
           },
        @{
            @"nickname": @"fengbo22",
            @"content": @"主播能加你一个微信么？",
            },
        @{
            @"nickname": @"jack",
            @"content": @"献上一束花,献上一束花",
            },
        @{
            @"nickname": @"果汁",
            @"content": @"递上果汁,递上果汁,递上果汁😄",
            },
        @{
            @"nickname": @"棒棒糖",
            @"content": @"递上棒棒糖",
            },
        @{
            @"nickname": @"泡泡糖",
            @"content": @"一起吃泡泡糖吧,今晚一起吃泡泡糖吗？？？？？？？？？？？？？",
            },
        @{
            @"nickname": @"fengbo33",
            @"content": @"主播能加你一个微信么？",
            },
        @{
            @"nickname": @"jack",
            @"content": @"献上一束花,献上一束花",
           },
        @{
            @"nickname": @"果汁",
            @"content": @"递上果汁,递上果汁,递上果汁😄",
           },
        @{
            @"nickname": @"棒棒糖",
            @"content": @"递上棒棒糖",
           },
        @{
            @"nickname": @"泡泡糖",
            @"content": @"一起吃泡泡糖吧,今晚一起吃泡泡糖吗？？？？？？？？？？？？？",
           },
        @{
            @"nickname": @"fengbo44",
            @"content": @"主播能加你一个微信么？",
            },
        @{
            @"nickname": @"jack",
            @"content": @"献上一束花,献上一束花",
            },
        @{
            @"nickname": @"果汁",
            @"content": @"递上果汁,递上果汁,递上果汁😄",
            },
        @{
            @"nickname": @"棒棒糖",
            @"content": @"递上棒棒糖",
            },
        @{
            @"nickname": @"泡泡糖",
            @"content": @"一起吃泡泡糖吧,今晚一起吃泡泡糖吗？？？？？？？？？？？？？",
            },
        @{
            @"nickname": @"fengbo55",
            @"content": @"主播能加你一个微信么？",
            },
        @{
            @"nickname": @"jack",
            @"content": @"献上一束花,献上一束花",
           },
        @{
            @"nickname": @"果汁",
            @"content": @"递上果汁,递上果汁,递上果汁😄",
           },
        @{
            @"nickname": @"棒棒糖",
            @"content": @"递上棒棒糖",
           },
        @{
            @"nickname": @"泡泡糖",
            @"content": @"一起吃泡泡糖吧,今晚一起吃泡泡糖吗？？？？？？？？？？？？？",
           },
        @{
            @"nickname": @"fengbo66",
            @"content": @"主播能加你一个微信么？",
            },
        @{
            @"nickname": @"jack",
            @"content": @"献上一束花,献上一束花",
            },
        @{
            @"nickname": @"果汁",
            @"content": @"递上果汁,递上果汁,递上果汁😄",
            },
        @{
            @"nickname": @"棒棒糖",
            @"content": @"递上棒棒糖",
            },
        @{
            @"nickname": @"泡泡糖",
            @"content": @"一起吃泡泡糖吧,今晚一起吃泡泡糖吗？？？？？？？？？？？？？",
            },
        @{
            @"nickname": @"fengbo77",
            @"content": @"主播能加你一个微信么？",
            },
        @{
            @"nickname": @"jack",
            @"content": @"献上一束花,献上一束花",
           },
        @{
            @"nickname": @"果汁",
            @"content": @"递上果汁,递上果汁,递上果汁😄",
           },
        @{
            @"nickname": @"棒棒糖",
            @"content": @"递上棒棒糖",
           },
        @{
            @"nickname": @"泡泡糖",
            @"content": @"一起吃泡泡糖吧,今晚一起吃泡泡糖吗？？？？？？？？？？？？？",
           },
        @{
            @"nickname": @"fengbo88",
            @"content": @"主播能加你一个微信么？",
            },
        @{
            @"nickname": @"jack",
            @"content": @"献上一束花,献上一束花",
            },
        @{
            @"nickname": @"果汁",
            @"content": @"递上果汁,递上果汁,递上果汁😄",
            },
        @{
            @"nickname": @"棒棒糖",
            @"content": @"递上棒棒糖",
            },
        @{
            @"nickname": @"泡泡糖",
            @"content": @"一起吃泡泡糖吧,今晚一起吃泡泡糖吗？？？？？？？？？？？？？",
            },
        @{
            @"nickname": @"fengbo99",
            @"content": @"主播能加你一个微信么？",
            },
        @{
            @"nickname": @"jack",
            @"content": @"献上一束花,献上一束花",
           },
        @{
            @"nickname": @"果汁",
            @"content": @"递上果汁,递上果汁,递上果汁😄",
           },
        @{
            @"nickname": @"棒棒糖",
            @"content": @"递上棒棒糖",
           },
        @{
            @"nickname": @"泡泡糖",
            @"content": @"一起吃泡泡糖吧,今晚一起吃泡泡糖吗？？？？？？？？？？？？？",
           },
        @{
            @"nickname": @"棒棒糖",
            @"content": @"递上棒棒糖",
           },
        @{
            @"nickname": @"泡泡糖",
            @"content": @"一起吃泡泡糖吧,今晚一起吃泡泡糖吗？？？？？？？？？？？？？",
           },
        @{
            @"nickname": @"fengbo101",
            @"content": @"主播能加你一个微信么？",
            },
        @{
            @"nickname": @"fengbo",
            @"content": @"主播能加你一个微信么？",
            },
        @{
            @"nickname": @"jack",
            @"content": @"献上一束花,献上一束花",
            },
        @{
            @"nickname": @"果汁",
            @"content": @"递上果汁,递上果汁,递上果汁😄",
            },
        @{
            @"nickname": @"棒棒糖",
            @"content": @"递上棒棒糖",
            },
        @{
            @"nickname": @"泡泡糖",
            @"content": @"一起吃泡泡糖吧,今晚一起吃泡泡糖吗？？？？？？？？？？？？？",
            },
        @{
            @"nickname": @"fengbo11",
            @"content": @"主播能加你一个微信么？",
            },
        @{
            @"nickname": @"jack",
            @"content": @"献上一束花,献上一束花",
           },
        @{
            @"nickname": @"果汁",
            @"content": @"递上果汁,递上果汁,递上果汁😄",
           },
        @{
            @"nickname": @"棒棒糖",
            @"content": @"递上棒棒糖",
           },
        @{
            @"nickname": @"泡泡糖",
            @"content": @"一起吃泡泡糖吧,今晚一起吃泡泡糖吗？？？？？？？？？？？？？",
           },
        @{
            @"nickname": @"fengbo22",
            @"content": @"主播能加你一个微信么？",
            },
        @{
            @"nickname": @"jack",
            @"content": @"献上一束花,献上一束花",
            },
        @{
            @"nickname": @"果汁",
            @"content": @"递上果汁,递上果汁,递上果汁😄",
            },
        @{
            @"nickname": @"棒棒糖",
            @"content": @"递上棒棒糖",
            },
        @{
            @"nickname": @"泡泡糖",
            @"content": @"一起吃泡泡糖吧,今晚一起吃泡泡糖吗？？？？？？？？？？？？？",
            },
        @{
            @"nickname": @"fengbo33",
            @"content": @"主播能加你一个微信么？",
            },
        @{
            @"nickname": @"jack",
            @"content": @"献上一束花,献上一束花",
           },
        @{
            @"nickname": @"果汁",
            @"content": @"递上果汁,递上果汁,递上果汁😄",
           },
        @{
            @"nickname": @"棒棒糖",
            @"content": @"递上棒棒糖",
           },
        @{
            @"nickname": @"泡泡糖",
            @"content": @"一起吃泡泡糖吧,今晚一起吃泡泡糖吗？？？？？？？？？？？？？",
           },
        @{
            @"nickname": @"fengbo44",
            @"content": @"主播能加你一个微信么？",
            },
        @{
            @"nickname": @"jack",
            @"content": @"献上一束花,献上一束花",
            },
        @{
            @"nickname": @"果汁",
            @"content": @"递上果汁,递上果汁,递上果汁😄",
            },
        @{
            @"nickname": @"棒棒糖",
            @"content": @"递上棒棒糖",
            },
        @{
            @"nickname": @"泡泡糖",
            @"content": @"一起吃泡泡糖吧,今晚一起吃泡泡糖吗？？？？？？？？？？？？？",
            },
        @{
            @"nickname": @"fengbo55",
            @"content": @"主播能加你一个微信么？",
            },
        @{
            @"nickname": @"jack",
            @"content": @"献上一束花,献上一束花",
           },
        @{
            @"nickname": @"果汁",
            @"content": @"递上果汁,递上果汁,递上果汁😄",
           },
        @{
            @"nickname": @"棒棒糖",
            @"content": @"递上棒棒糖",
           },
        @{
            @"nickname": @"泡泡糖",
            @"content": @"一起吃泡泡糖吧,今晚一起吃泡泡糖吗？？？？？？？？？？？？？",
           },
        @{
            @"nickname": @"fengbo66",
            @"content": @"主播能加你一个微信么？",
            },
        @{
            @"nickname": @"jack",
            @"content": @"献上一束花,献上一束花",
            },
        @{
            @"nickname": @"果汁",
            @"content": @"递上果汁,递上果汁,递上果汁😄",
            },
        @{
            @"nickname": @"棒棒糖",
            @"content": @"递上棒棒糖",
            },
        @{
            @"nickname": @"泡泡糖",
            @"content": @"一起吃泡泡糖吧,今晚一起吃泡泡糖吗？？？？？？？？？？？？？",
            },
        @{
            @"nickname": @"fengbo77",
            @"content": @"主播能加你一个微信么？",
            },
        @{
            @"nickname": @"jack",
            @"content": @"献上一束花,献上一束花",
           },
        @{
            @"nickname": @"果汁",
            @"content": @"递上果汁,递上果汁,递上果汁😄",
           },
        @{
            @"nickname": @"棒棒糖",
            @"content": @"递上棒棒糖",
           },
        @{
            @"nickname": @"泡泡糖",
            @"content": @"一起吃泡泡糖吧,今晚一起吃泡泡糖吗？？？？？？？？？？？？？",
           },
        @{
            @"nickname": @"fengbo88",
            @"content": @"主播能加你一个微信么？",
            },
        @{
            @"nickname": @"jack",
            @"content": @"献上一束花,献上一束花",
            },
        @{
            @"nickname": @"果汁",
            @"content": @"递上果汁,递上果汁,递上果汁😄",
            },
        @{
            @"nickname": @"棒棒糖",
            @"content": @"递上棒棒糖",
            },
        @{
            @"nickname": @"泡泡糖",
            @"content": @"一起吃泡泡糖吧,今晚一起吃泡泡糖吗？？？？？？？？？？？？？",
            },
        @{
            @"nickname": @"fengbo99",
            @"content": @"主播能加你一个微信么？",
            },
        @{
            @"nickname": @"jack",
            @"content": @"献上一束花,献上一束花",
           },
        @{
            @"nickname": @"果汁",
            @"content": @"递上果汁,递上果汁,递上果汁😄",
           },
        @{
            @"nickname": @"棒棒糖",
            @"content": @"递上棒棒糖",
           },
        @{
            @"nickname": @"泡泡糖",
            @"content": @"一起吃泡泡糖吧,今晚一起吃泡泡糖吗？？？？？？？？？？？？？",
           },
        @{
            @"nickname": @"棒棒糖",
            @"content": @"递上棒棒糖",
           },
        @{
            @"nickname": @"泡泡糖",
            @"content": @"一起吃泡泡糖吧,今晚一起吃泡泡糖吗？？？？？？？？？？？？？",
           },
        @{
            @"nickname": @"fengbo101",
            @"content": @"主播能加你一个微信么？",
            },
        @{
            @"nickname": @"fengbo",
            @"content": @"主播能加你一个微信么？",
            },
        @{
            @"nickname": @"jack",
            @"content": @"献上一束花,献上一束花",
            },
        @{
            @"nickname": @"果汁",
            @"content": @"递上果汁,递上果汁,递上果汁😄",
            },
        @{
            @"nickname": @"棒棒糖",
            @"content": @"递上棒棒糖",
            },
        @{
            @"nickname": @"泡泡糖",
            @"content": @"一起吃泡泡糖吧,今晚一起吃泡泡糖吗？？？？？？？？？？？？？",
            },
        @{
            @"nickname": @"fengbo11",
            @"content": @"主播能加你一个微信么？",
            },
        @{
            @"nickname": @"jack",
            @"content": @"献上一束花,献上一束花",
           },
        @{
            @"nickname": @"果汁",
            @"content": @"递上果汁,递上果汁,递上果汁😄",
           },
        @{
            @"nickname": @"棒棒糖",
            @"content": @"递上棒棒糖",
           },
        @{
            @"nickname": @"泡泡糖",
            @"content": @"一起吃泡泡糖吧,今晚一起吃泡泡糖吗？？？？？？？？？？？？？",
           },
        @{
            @"nickname": @"fengbo22",
            @"content": @"主播能加你一个微信么？",
            },
        @{
            @"nickname": @"jack",
            @"content": @"献上一束花,献上一束花",
            },
        @{
            @"nickname": @"果汁",
            @"content": @"递上果汁,递上果汁,递上果汁😄",
            },
        @{
            @"nickname": @"棒棒糖",
            @"content": @"递上棒棒糖",
            },
        @{
            @"nickname": @"泡泡糖",
            @"content": @"一起吃泡泡糖吧,今晚一起吃泡泡糖吗？？？？？？？？？？？？？",
            },
        @{
            @"nickname": @"fengbo33",
            @"content": @"主播能加你一个微信么？",
            },
        @{
            @"nickname": @"jack",
            @"content": @"献上一束花,献上一束花",
           },
        @{
            @"nickname": @"果汁",
            @"content": @"递上果汁,递上果汁,递上果汁😄",
           },
        @{
            @"nickname": @"棒棒糖",
            @"content": @"递上棒棒糖",
           },
        @{
            @"nickname": @"泡泡糖",
            @"content": @"一起吃泡泡糖吧,今晚一起吃泡泡糖吗？？？？？？？？？？？？？",
           },
        @{
            @"nickname": @"fengbo44",
            @"content": @"主播能加你一个微信么？",
            },
        @{
            @"nickname": @"jack",
            @"content": @"献上一束花,献上一束花",
            },
        @{
            @"nickname": @"果汁",
            @"content": @"递上果汁,递上果汁,递上果汁😄",
            },
        @{
            @"nickname": @"棒棒糖",
            @"content": @"递上棒棒糖",
            },
        @{
            @"nickname": @"泡泡糖",
            @"content": @"一起吃泡泡糖吧,今晚一起吃泡泡糖吗？？？？？？？？？？？？？",
            },
        @{
            @"nickname": @"fengbo55",
            @"content": @"主播能加你一个微信么？",
            },
        @{
            @"nickname": @"jack",
            @"content": @"献上一束花,献上一束花",
           },
        @{
            @"nickname": @"果汁",
            @"content": @"递上果汁,递上果汁,递上果汁😄",
           },
        @{
            @"nickname": @"棒棒糖",
            @"content": @"递上棒棒糖",
           },
        @{
            @"nickname": @"泡泡糖",
            @"content": @"一起吃泡泡糖吧,今晚一起吃泡泡糖吗？？？？？？？？？？？？？",
           },
        @{
            @"nickname": @"fengbo66",
            @"content": @"主播能加你一个微信么？",
            },
        @{
            @"nickname": @"jack",
            @"content": @"献上一束花,献上一束花",
            },
        @{
            @"nickname": @"果汁",
            @"content": @"递上果汁,递上果汁,递上果汁😄",
            },
        @{
            @"nickname": @"棒棒糖",
            @"content": @"递上棒棒糖",
            },
        @{
            @"nickname": @"泡泡糖",
            @"content": @"一起吃泡泡糖吧,今晚一起吃泡泡糖吗？？？？？？？？？？？？？",
            },
        @{
            @"nickname": @"fengbo77",
            @"content": @"主播能加你一个微信么？",
            },
        @{
            @"nickname": @"jack",
            @"content": @"献上一束花,献上一束花",
           },
        @{
            @"nickname": @"果汁",
            @"content": @"递上果汁,递上果汁,递上果汁😄",
           },
        @{
            @"nickname": @"棒棒糖",
            @"content": @"递上棒棒糖",
           },
        @{
            @"nickname": @"泡泡糖",
            @"content": @"一起吃泡泡糖吧,今晚一起吃泡泡糖吗？？？？？？？？？？？？？",
           },
        @{
            @"nickname": @"fengbo88",
            @"content": @"主播能加你一个微信么？",
            },
        @{
            @"nickname": @"jack",
            @"content": @"献上一束花,献上一束花",
            },
        @{
            @"nickname": @"果汁",
            @"content": @"递上果汁,递上果汁,递上果汁😄",
            },
        @{
            @"nickname": @"棒棒糖",
            @"content": @"递上棒棒糖",
            },
        @{
            @"nickname": @"泡泡糖",
            @"content": @"一起吃泡泡糖吧,今晚一起吃泡泡糖吗？？？？？？？？？？？？？",
            },
        @{
            @"nickname": @"fengbo99",
            @"content": @"主播能加你一个微信么？",
            },
        @{
            @"nickname": @"jack",
            @"content": @"献上一束花,献上一束花",
           },
        @{
            @"nickname": @"果汁",
            @"content": @"递上果汁,递上果汁,递上果汁😄",
           },
        @{
            @"nickname": @"棒棒糖",
            @"content": @"递上棒棒糖",
           },
        @{
            @"nickname": @"泡泡糖",
            @"content": @"一起吃泡泡糖吧,今晚一起吃泡泡糖吗？？？？？？？？？？？？？",
           },
        @{
            @"nickname": @"棒棒糖",
            @"content": @"递上棒棒糖",
           },
        @{
            @"nickname": @"泡泡糖",
            @"content": @"一起吃泡泡糖吧,今晚一起吃泡泡糖吗？？？？？？？？？？？？？",
           },
        @{
            @"nickname": @"fengbo101",
            @"content": @"主播能加你一个微信么？",
            },
        @{
            @"nickname": @"fengbo",
            @"content": @"主播能加你一个微信么？",
            },
        @{
            @"nickname": @"jack",
            @"content": @"献上一束花,献上一束花",
            },
        @{
            @"nickname": @"果汁",
            @"content": @"递上果汁,递上果汁,递上果汁😄",
            },
        @{
            @"nickname": @"棒棒糖",
            @"content": @"递上棒棒糖",
            },
        @{
            @"nickname": @"泡泡糖",
            @"content": @"一起吃泡泡糖吧,今晚一起吃泡泡糖吗？？？？？？？？？？？？？",
            },
        @{
            @"nickname": @"fengbo11",
            @"content": @"主播能加你一个微信么？",
            },
        @{
            @"nickname": @"jack",
            @"content": @"献上一束花,献上一束花",
           },
        @{
            @"nickname": @"果汁",
            @"content": @"递上果汁,递上果汁,递上果汁😄",
           },
        @{
            @"nickname": @"棒棒糖",
            @"content": @"递上棒棒糖",
           },
        @{
            @"nickname": @"泡泡糖",
            @"content": @"一起吃泡泡糖吧,今晚一起吃泡泡糖吗？？？？？？？？？？？？？",
           },
        @{
            @"nickname": @"fengbo22",
            @"content": @"主播能加你一个微信么？",
            },
        @{
            @"nickname": @"jack",
            @"content": @"献上一束花,献上一束花",
            },
        @{
            @"nickname": @"果汁",
            @"content": @"递上果汁,递上果汁,递上果汁😄",
            },
        @{
            @"nickname": @"棒棒糖",
            @"content": @"递上棒棒糖",
            },
        @{
            @"nickname": @"泡泡糖",
            @"content": @"一起吃泡泡糖吧,今晚一起吃泡泡糖吗？？？？？？？？？？？？？",
            },
        @{
            @"nickname": @"fengbo33",
            @"content": @"主播能加你一个微信么？",
            },
        @{
            @"nickname": @"jack",
            @"content": @"献上一束花,献上一束花",
           },
        @{
            @"nickname": @"果汁",
            @"content": @"递上果汁,递上果汁,递上果汁😄",
           },
        @{
            @"nickname": @"棒棒糖",
            @"content": @"递上棒棒糖",
           },
        @{
            @"nickname": @"泡泡糖",
            @"content": @"一起吃泡泡糖吧,今晚一起吃泡泡糖吗？？？？？？？？？？？？？",
           },
        @{
            @"nickname": @"fengbo44",
            @"content": @"主播能加你一个微信么？",
            },
        @{
            @"nickname": @"jack",
            @"content": @"献上一束花,献上一束花",
            },
        @{
            @"nickname": @"果汁",
            @"content": @"递上果汁,递上果汁,递上果汁😄",
            },
        @{
            @"nickname": @"棒棒糖",
            @"content": @"递上棒棒糖",
            },
        @{
            @"nickname": @"泡泡糖",
            @"content": @"一起吃泡泡糖吧,今晚一起吃泡泡糖吗？？？？？？？？？？？？？",
            },
        @{
            @"nickname": @"fengbo55",
            @"content": @"主播能加你一个微信么？",
            },
        @{
            @"nickname": @"jack",
            @"content": @"献上一束花,献上一束花",
           },
        @{
            @"nickname": @"果汁",
            @"content": @"递上果汁,递上果汁,递上果汁😄",
           },
        @{
            @"nickname": @"棒棒糖",
            @"content": @"递上棒棒糖",
           },
        @{
            @"nickname": @"泡泡糖",
            @"content": @"一起吃泡泡糖吧,今晚一起吃泡泡糖吗？？？？？？？？？？？？？",
           },
        @{
            @"nickname": @"fengbo66",
            @"content": @"主播能加你一个微信么？",
            },
        @{
            @"nickname": @"jack",
            @"content": @"献上一束花,献上一束花",
            },
        @{
            @"nickname": @"果汁",
            @"content": @"递上果汁,递上果汁,递上果汁😄",
            },
        @{
            @"nickname": @"棒棒糖",
            @"content": @"递上棒棒糖",
            },
        @{
            @"nickname": @"泡泡糖",
            @"content": @"一起吃泡泡糖吧,今晚一起吃泡泡糖吗？？？？？？？？？？？？？",
            },
        @{
            @"nickname": @"fengbo77",
            @"content": @"主播能加你一个微信么？",
            },
        @{
            @"nickname": @"jack",
            @"content": @"献上一束花,献上一束花",
           },
        @{
            @"nickname": @"果汁",
            @"content": @"递上果汁,递上果汁,递上果汁😄",
           },
        @{
            @"nickname": @"棒棒糖",
            @"content": @"递上棒棒糖",
           },
        @{
            @"nickname": @"泡泡糖",
            @"content": @"一起吃泡泡糖吧,今晚一起吃泡泡糖吗？？？？？？？？？？？？？",
           },
        @{
            @"nickname": @"fengbo88",
            @"content": @"主播能加你一个微信么？",
            },
        @{
            @"nickname": @"jack",
            @"content": @"献上一束花,献上一束花",
            },
        @{
            @"nickname": @"果汁",
            @"content": @"递上果汁,递上果汁,递上果汁😄",
            },
        @{
            @"nickname": @"棒棒糖",
            @"content": @"递上棒棒糖",
            },
        @{
            @"nickname": @"泡泡糖",
            @"content": @"一起吃泡泡糖吧,今晚一起吃泡泡糖吗？？？？？？？？？？？？？",
            },
        @{
            @"nickname": @"fengbo99",
            @"content": @"主播能加你一个微信么？",
            },
        @{
            @"nickname": @"jack",
            @"content": @"献上一束花,献上一束花",
           },
        @{
            @"nickname": @"果汁",
            @"content": @"递上果汁,递上果汁,递上果汁😄",
           },
        @{
            @"nickname": @"棒棒糖",
            @"content": @"递上棒棒糖",
           },
        @{
            @"nickname": @"泡泡糖",
            @"content": @"一起吃泡泡糖吧,今晚一起吃泡泡糖吗？？？？？？？？？？？？？",
           },
        @{
            @"nickname": @"棒棒糖",
            @"content": @"递上棒棒糖",
           },
        @{
            @"nickname": @"泡泡糖",
            @"content": @"一起吃泡泡糖吧,今晚一起吃泡泡糖吗？？？？？？？？？？？？？",
           },
        @{
            @"nickname": @"fengbo101",
            @"content": @"主播能加你一个微信么？",
            },
        ];
    }
    
    return _danmuDateSource;
}


@end
