//
//  KSShortVideoPlayerViewController.m
//  KSDanmuViewDemo
//
//  Created by YaphetS on 2020/9/1.
//  Copyright © 2020 sapphire. All rights reserved.
//

#import "KSShortVideoPlayerViewController.h"
#import "UIColor+Utils.h"
#import "KSVideoModel.h"
#import "KSShortVideoCell.h"
#import "MJExtension.h"
#import "AVPlayerManager.h"


@interface KSShortVideoPlayerViewController () <UITableViewDelegate, UITableViewDataSource, UIScrollViewDelegate>
@property (nonatomic, assign) BOOL         isCurPlayerPause;
@property (nonatomic, assign) NSInteger    pageIndex;
@property (nonatomic, assign) NSInteger    pageSize;

@property (nonatomic, strong) NSMutableArray<KSVideoModel *> *playArray;
@property (nonatomic, copy) NSArray *videoDataSource;
@end

@implementation KSShortVideoPlayerViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self loadData];
    [self setUpView];
   
}

- (void)loadData
{
    self.currentIndex = 0;
    _playArray = [NSMutableArray new];
    _playArray = [KSVideoModel mj_objectArrayWithKeyValuesArray:self.videoDataSource];
}

- (void)setUpView
{
    self.view.layer.masksToBounds = YES;
    _tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, -ScreenHeight, ScreenWidth, ScreenHeight * 3)];
    _tableView.contentInset = UIEdgeInsetsMake(ScreenHeight, 0, ScreenHeight * 1, 0);
    _tableView.backgroundColor = [UIColor clearColor];
    _tableView.delegate = self;
    _tableView.dataSource = self;
    _tableView.showsVerticalScrollIndicator = NO;
    _tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    [_tableView registerClass:[KSShortVideoCell class] forCellReuseIdentifier:[KSShortVideoCell reuseIdentifier]];
    
    if (@available(iOS 11.0, *)) {
        _tableView.contentInsetAdjustmentBehavior = UIScrollViewContentInsetAdjustmentNever;
    }
    else
    {
        self.automaticallyAdjustsScrollViewInsets = NO;
    }
    
    [self.view addSubview:self.tableView];
    
    //Add obsever
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [self.tableView reloadData];
        
        NSIndexPath *curIndexPath = [NSIndexPath indexPathForRow:self.currentIndex inSection:0];
        [self.tableView scrollToRowAtIndexPath:curIndexPath atScrollPosition:UITableViewScrollPositionMiddle
                                      animated:NO];
        [self addObserver:self forKeyPath:@"currentIndex" options:NSKeyValueObservingOptionInitial|NSKeyValueObservingOptionNew context:nil];
    });
}

#pragma mark: TableView Delegate && DataSource
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.playArray.count;
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return self.view.frame.size.height;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    //填充视频数据
    KSShortVideoCell *cell = [tableView dequeueReusableCellWithIdentifier:[KSShortVideoCell reuseIdentifier] forIndexPath:indexPath];
    [cell initData:self.playArray[indexPath.row]];
    //[cell startDownloadBackgroundTask];
    return cell;
}

#pragma mark: Pull && Drag Actions
- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate{
    dispatch_async(dispatch_get_main_queue(), ^{
        CGPoint translatedPoint = [scrollView.panGestureRecognizer translationInView:scrollView];
        //UITableView禁止响应其他滑动手势
        scrollView.panGestureRecognizer.enabled = NO;
    
        if(translatedPoint.y < -50 && self.currentIndex < (self.playArray.count - 1)) {
            self.currentIndex ++;   //向下滑动索引递增
        }
        if(translatedPoint.y > 50 && self.currentIndex > 0) {
            self.currentIndex --;   //向上滑动索引递减
        }
        [UIView animateWithDuration:0.15
                              delay:0.0
                            options:UIViewAnimationOptionCurveEaseOut animations:^{
                                //UITableView滑动到指定cell
                                [self.tableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:self.currentIndex inSection:0] atScrollPosition:UITableViewScrollPositionTop animated:NO];
                            } completion:^(BOOL finished) {
                                //UITableView可以响应其他滑动手势
                                scrollView.panGestureRecognizer.enabled = YES;
                            }];
        
    });
}

#pragma mark: KVO
- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSKeyValueChangeKey,id> *)change context:(void *)context
{
    // 观察currentIndex 的变化
    if ([keyPath isEqualToString:@"currentIndex"]) {
        _isCurPlayerPause = NO;
        KSShortVideoCell *cell = [self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:self.currentIndex inSection:0]];
        [cell startDownloadHighPriorityTask];
        
        __weak typeof(cell) wcell = cell;
        __weak typeof(self) wself = self;
        
        if (cell.isPlayerReady) {
            [cell replay];
        }else {
            [[AVPlayerManager shareManager] pauseAll];
            //当前cell的视频源还未准备好播放，则实现cell的OnPlayerReady Block 用于等待视频准备好后通知播放
//            cell.onPlayerReady = ^{
//                NSIndexPath *indexPath = [wself.tableView indexPathForCell:wcell];
//                if(!wself.isCurPlayerPause && indexPath && indexPath.row == wself.currentIndex) {
//                    [wcell play];
//                }};
            
            
            AVPlayerItem *item = [AVPlayerItem playerItemWithURL:[NSURL URLWithString:@"https://www.amemv.com/share/video/6544706799843413261/?mid=6499743036413577997"]];
            //[cell playVideoWithItem:item];
            [cell playVideoWithItem:item];
        }
    }
    else
    {
        return [super observeValueForKeyPath:keyPath ofObject:object change:change context:context];
    }
}

- (void)dealloc {
    NSLog(@"======== dealloc =======");
}

#pragma mark: datasource
- (NSArray *)videoDataSource
{
    if (!_videoDataSource) {
        _videoDataSource = @[
            @{
                @"video_url": @"https://www.amemv.com/share/video/6544706799843413261/?mid=6499743036413577997",
                @"video_name": @"不吃药药",
            },
            @{
                @"video_url": @"https://www.amemv.com/share/video/6547083424165809416/?mid=6489958276858563341",
                @"video_name": @"我就不吃药药",
            },
            @{
                @"video_url": @"https://www.amemv.com/share/video/6550157524467715335/?mid=6547592920445225736",
                @"video_name": @"小妞跳舞",
            },
            @{
                @"video_url": @"https://www.amemv.com/share/video/6544706799843413261/?mid=6499743036413577997",
                @"video_name": @"不吃药药",
            },
            @{
                @"video_url": @"https://www.amemv.com/share/video/6547083424165809416/?mid=6489958276858563341",
                @"video_name": @"我就不吃药药",
            },
            @{
                @"video_url": @"https://www.amemv.com/share/video/6550157524467715335/?mid=6547592920445225736",
                @"video_name": @"小妞跳舞",
            },
//            @{
//                @"video_url": @"https://videos.ptxwl.com.cn/1598440043.077259AD88831E-DF48-4D8D-97B8-B6D78F343930.mp4",
//                @"video_name": @"不吃药药",
//            },
//            @{
//                @"video_url": @"https://videos.ptxwl.com.cn/1598514531.720502CE47AF47-C745-47EC-89A5-5CC5BB63630D.mp4",
//                @"video_name": @"我就不吃药药",
//            },
//            @{
//                @"video_url": @"https://videos.ptxwl.com.cn/1598344104.78570205137D8E-9ADD-485C-B635-F6C400CBC176.mp4",
//                @"video_name": @"小妞跳舞",
//            },
//            @{
//                @"video_url": @" https://videos.ptxwl.com.cn/1598351087.24772489322715-506A-4B61-90B2-D93A75BF4319.mp4",
//                @"video_name": @"不吃药药",
//            },
//            @{
//                @"video_url": @"https://videos.ptxwl.com.cn/1598351087.24772489322715-506A-4B61-90B2-D93A75BF4319.mp4",
//                @"video_name": @"我就不吃药药",
//            },
        ];
    }
    
    return _videoDataSource;
}
@end
