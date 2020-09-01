//
//  KSShortVideoCell.m
//  KSDanmuViewDemo
//
//  Created by YaphetS on 2020/9/1.
//  Copyright © 2020 sapphire. All rights reserved.
//

#import "KSShortVideoCell.h"
#import "AVPlayerView.h"
#import "KSPreferHead.h"
#import "KSVideoModel.h"
#import "Masonry.h"
#import "UIWindow+Extension.h"

@interface KSShortVideoCell() <AVPlayerUpdateDelegate>
@property (nonatomic, strong) UIView                   *container;
@property (nonatomic ,strong) CAGradientLayer          *gradientLayer;
@property (nonatomic ,strong) UIImageView              *pauseIcon;
@property (nonatomic, strong) UIView                   *playerStatusBar;
@property (nonatomic ,strong) UIImageView              *musicIcon;
@property (nonatomic, strong) UITapGestureRecognizer   *singleTapGesture;
@property (nonatomic, assign) NSTimeInterval           lastTapTime;
@property (nonatomic, assign) CGPoint                  lastTapPoint;
@end

@implementation KSShortVideoCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if(self) {
        self.selectionStyle = UITableViewCellSelectionStyleNone;
        self.backgroundColor = [UIColor clearColor];
        _lastTapTime = 0;
        _lastTapPoint = CGPointZero;
        [self initSubViews];
    }
    return self;
}

- (void)initSubViews
{
    self.playerView = [AVPlayerView new];
    self.playerView.delegate = self;
    [self.contentView addSubview:self.playerView];
    
    _container = [UIView new];
    [self.contentView addSubview:_container];
    
    _singleTapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleGesture:)];
    [_container addGestureRecognizer:_singleTapGesture];
    
    _gradientLayer = [CAGradientLayer layer];
    _gradientLayer.colors = @[(__bridge id)ColorClear.CGColor, (__bridge id)ColorBlackAlpha20.CGColor, (__bridge id)ColorBlackAlpha40.CGColor];
    _gradientLayer.locations = @[@0.3, @0.6, @1.0];
    _gradientLayer.startPoint = CGPointMake(0.0f, 0.0f);
    _gradientLayer.endPoint = CGPointMake(0.0f, 1.0f);
    [_container.layer addSublayer:_gradientLayer];
    
    _pauseIcon = [[UIImageView alloc] init];
    _pauseIcon.image = [UIImage imageNamed:@"icon_play_pause"];
    _pauseIcon.contentMode = UIViewContentModeCenter;
    _pauseIcon.layer.zPosition = 3;
    _pauseIcon.hidden = YES;
    [_container addSubview:_pauseIcon];
    
    _playerStatusBar = [[UIView alloc]init];
    _playerStatusBar.backgroundColor = ColorWhite;
    [_playerStatusBar setHidden:YES];
    [_container addSubview:_playerStatusBar];
    
    _musicIcon = [[UIImageView alloc]init];
    _musicIcon.contentMode = UIViewContentModeCenter;
    _musicIcon.image = [UIImage imageNamed:@"icon_home_musicnote3"];
    [_container addSubview:_musicIcon];
    
    //LayOut
    [_playerView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self);
    }];
    [_container mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self);
    }];
    [_pauseIcon mas_makeConstraints:^(MASConstraintMaker *make) {
        make.center.equalTo(self);
        make.width.height.mas_equalTo(100);
    }];
}

-(void)prepareForReuse {
    [super prepareForReuse];
    
    _isPlayerReady = NO;
    [_playerView cancelLoading];
    [_pauseIcon setHidden:YES];
    
//    [_hoverTextView.textView setText:@""];
//    [_avatar setImage:[UIImage imageNamed:@"img_find_default"]];
//
//    [_musicAlum resetView];
//    [_favorite resetView];
//    [_focus resetView];
}

-(void)layoutSubviews {
    [super layoutSubviews];
    [CATransaction begin];
    [CATransaction setDisableActions:YES];
    _gradientLayer.frame = CGRectMake(0, self.frame.size.height - 500, self.frame.size.width, 500);
    [CATransaction commit];
}

- (void)onProgressUpdate:(CGFloat)current total:(CGFloat)total {
    //播放进度更新
}

-(void)onPlayItemStatusUpdate:(AVPlayerItemStatus)status {
    switch (status) {
        case AVPlayerItemStatusUnknown:
            [self startLoadingPlayItemAnim:YES];
            break;
        case AVPlayerItemStatusReadyToPlay:
            [self startLoadingPlayItemAnim:NO];
            
            _isPlayerReady = YES;
            //[_musicAlum startAnimation:_aweme.rate];
            
            if(_onPlayerReady) {
                _onPlayerReady();
            }
            break;
        case AVPlayerItemStatusFailed:
            [self startLoadingPlayItemAnim:NO];
            [UIWindow showTips:@"加载失败"];
            break;
        default:
            break;
    }
}

//加载动画
-(void)startLoadingPlayItemAnim:(BOOL)isStart {
    if (isStart) {
        _playerStatusBar.backgroundColor = ColorWhite;
        [_playerStatusBar setHidden:NO];
        [_playerStatusBar.layer removeAllAnimations];
        
        CAAnimationGroup *animationGroup = [[CAAnimationGroup alloc]init];
        animationGroup.duration = 0.5;
        animationGroup.beginTime = CACurrentMediaTime() + 0.5;
        animationGroup.repeatCount = MAXFLOAT;
        animationGroup.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
        
        CABasicAnimation * scaleAnimation = [CABasicAnimation animation];
        scaleAnimation.keyPath = @"transform.scale.x";
        scaleAnimation.fromValue = @(1.0f);
        scaleAnimation.toValue = @(1.0f * ScreenWidth);
        
        CABasicAnimation * alphaAnimation = [CABasicAnimation animation];
        alphaAnimation.keyPath = @"opacity";
        alphaAnimation.fromValue = @(1.0f);
        alphaAnimation.toValue = @(0.5f);
        [animationGroup setAnimations:@[scaleAnimation, alphaAnimation]];
        [self.playerStatusBar.layer addAnimation:animationGroup forKey:nil];
    } else {
        [self.playerStatusBar.layer removeAllAnimations];
        [self.playerStatusBar setHidden:YES];
    }
    
}

#pragma mark: Actions
//gesture
- (void)handleGesture:(UITapGestureRecognizer *)sender {
    NSLog(@"双击爱心");
}

#pragma mark: Player
- (void)initData:(KSVideoModel *)model {
    self.playModel = model;
}

- (void)play {
    [_playerView play];
    [_pauseIcon setHidden:YES];
}

- (void)pause {
    [_playerView pause];
    [_pauseIcon setHidden:NO];
}

- (void)replay {
    [_playerView replay];
    [_pauseIcon setHidden:YES];
}

- (void)startDownloadBackgroundTask {
//    NSString *playUrl = [NetworkHelper isWifiStatus] ? _aweme.video.play_addr.url_list.firstObject : _aweme.video.play_addr_lowbr.url_list.firstObject;
//    [_playerView setPlayerWithUrl:playUrl];
    
    NSString *playUrl = self.playModel.videoUrl;
    [_playerView setPlayerWithUrl:playUrl];
}

- (void)startDownloadHighPriorityTask {
    NSString *playUrl = self.playModel.videoUrl;
    [_playerView startDownloadTask:[[NSURL alloc] initWithString:playUrl] isBackground:NO];
}


- (void)awakeFromNib {
    [super awakeFromNib];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
}


+ (NSString *)reuseIdentifier {
    return @"KSShortVideoCell";
}


#pragma mark: Testing Methods
- (void)playVideoWithItem:(AVPlayerItem *)item
{
    [self.playerView playWithItem:item];
}

@end
