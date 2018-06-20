//
//  YGPlayerView.m
//  Demo
//
//  Created by LiYugang on 2018/3/5.
//  Copyright © 2018年 LiYugang. All rights reserved.
//

#import "PlayerVC.h"
#import <AVFoundation/AVFoundation.h>
#import "YGPlayInfo.h"
#import "YGVideoTool.h"
#import "NSString+Time.h"
#import "YGBrightnessAndVolumeView.h"
#import "YGLoadingView.h"
#import "YGPreviewView.h"


@interface PlayerVC ()
@property (nonatomic, strong) AVPlayer *player;
@property (nonatomic, strong) AVPlayerItem *playerItem;
@property (nonatomic, strong) AVURLAsset *asset;
@property (nonatomic, strong) AVPlayerLayer *playerLayer;
@property (nonatomic, strong) id timeObserver;
@property (weak, nonatomic) IBOutlet UISlider *progressSlider;
@property (weak, nonatomic) IBOutlet UIProgressView *loadedView;
@property (weak, nonatomic) IBOutlet UIImageView *placeHolderView;
@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
@property (weak, nonatomic) IBOutlet UIView *topView;
@property (weak, nonatomic) IBOutlet UIView *bottomView;
@property (nonatomic, strong) YGLoadingView *waitingView;
@property (weak, nonatomic) IBOutlet UIButton *centerPlayBtn;

@property (weak, nonatomic) IBOutlet UIButton *playBtn;
@property (weak, nonatomic) IBOutlet UIButton *rotateBtn;
@property (weak, nonatomic) IBOutlet UIButton *episodeBtn;
@property (weak, nonatomic) IBOutlet UILabel *currentTimeLabel;
@property (weak, nonatomic) IBOutlet UILabel *totalTimeLabel;
@property (weak, nonatomic) IBOutlet UIButton *moreBtn;
@property (weak, nonatomic) IBOutlet UIView *videoView;

@property (nonatomic, assign, getter=isLandscape) BOOL landscape;
@property (nonatomic, assign, getter=controlPanelIsShowing) BOOL controlPanelShow;
@property (nonatomic, weak) UIView *cover;
@property (nonatomic, weak) UIButton *replayBtn;
@property (nonatomic, weak) YGBrightnessAndVolumeView *brightnessAndVolumeView;
@property (nonatomic, strong) UITapGestureRecognizer *tapGuesture;
@property (nonatomic, strong) UIPanGestureRecognizer *panGuesture;
@property (nonatomic, strong) YGPreviewView *previewView;
@property (nonatomic, strong) NSMutableArray *thumbImages;
@property (nonatomic, strong) AVAssetImageGenerator *imageGenerator;
@end

@implementation PlayerVC

#pragma mark - 懒加载


- (YGLoadingView *)waitingView
{
    if (_waitingView == nil) {
        _waitingView = [[YGLoadingView alloc] init];
        _waitingView.hidesWhenStopped = YES;
        [self.view addSubview:_waitingView];
    }
    return _waitingView;
}

- (YGPreviewView *)previewView
{
    if (_previewView == nil) {
        _previewView = [YGPreviewView sharedPreviewView];
        [self.view addSubview:_previewView];
    }
    return _previewView;
}

- (NSMutableArray *)thumbImages
{
    if (_thumbImages == nil) {
        _thumbImages = [NSMutableArray array];
        [self addObserver:self forKeyPath:@"thumbImages" options:NSKeyValueObservingOptionNew context:NULL];
    }
    return _thumbImages;
}

- (AVAssetImageGenerator *)imageGenerator {
    if (!_imageGenerator) {
        _imageGenerator = [AVAssetImageGenerator assetImageGeneratorWithAsset:self.asset];
    }
    return _imageGenerator;
}
-(BOOL)prefersStatusBarHidden{
    return YES;
}
-(void)viewDidLoad{
    [super viewDidLoad];
    [self initView];

    self.progressSlider.value = 0.f;
    self.loadedView.progress = 0.f;
    [self addGuesture];
    [self showOrHideControlPanel];
    [self setupBrightnessAndVolumeView];
    [self.progressSlider setThumbImage:[UIImage imageNamed:@"icmpv_thumb_light"] forState:UIControlStateNormal];
    self.progressSlider.value = .0f;
    self.loadedView.progress = .0f;
    self.currentTimeLabel.text = @"00:00";
    self.totalTimeLabel.text = @"00:00";
    
    [self.progressSlider addTarget:self action:@selector(progressDragEnd:) forControlEvents:UIControlEventTouchUpInside | UIControlEventTouchCancel];
}
- (void)initView
{
    [self.placeHolderView sd_setImageWithURL:[NSURL URLWithString:self.model.imguri]];

    self.cover.frame = [UIScreen mainScreen].bounds;
    self.replayBtn.frame = CGRectMake(0, 0, 200, 155);
    self.brightnessAndVolumeView.frame = [UIScreen mainScreen].bounds;
    
    [self.replayBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.center.equalTo(self.view);
    }];
    [self.previewView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.width.mas_equalTo(180.f);
        make.height.mas_equalTo(180.f);
        make.center.equalTo(self.view);
    }];
    
    [self.waitingView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.center.equalTo(self.view);
        make.width.height.mas_equalTo(80.f);
    }];
    
    [self.view bringSubviewToFront:self.brightnessAndVolumeView];
    [self.view bringSubviewToFront:self.topView];
    [self.view bringSubviewToFront:self.bottomView];
    [self.view bringSubviewToFront:self.centerPlayBtn];
    [self.view bringSubviewToFront:self.waitingView];
    [self.view bringSubviewToFront:self.previewView];
    [self.view bringSubviewToFront:self.cover];
}

- (void)playWithPlayInfo:(VideoModel *)playInfo
{
    // 清空缩略图数组
    [self.thumbImages removeAllObjects];
    
    // 重置player
    [self resetPlayer];
    
    // 设置预览缩略图透明度为0
    self.previewView.alpha = .0f;
    
//    // 存储当前播放URL到本地 以便后面选集时比较哪个是当前播放的曲目
//    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
//    [defaults setObject:playInfo.urk
//                 forKey:@"currentPlayingUrl"];
    
    // 因为replaceCurrentItemWithPlayerItem在使用时会卡住主线程 重新创建player解决
    self.player = [self setupPlayer];
    self.asset = [AVURLAsset assetWithURL:[NSURL URLWithString:playInfo.uri]];
    self.playerItem = [AVPlayerItem playerItemWithAsset:self.asset];
    
    // 添加时间周期OB、OB和通知
    [self addTimerObserver];
    [self addPlayItemObserverAndNotification];
    
    // 设置播放器标题
    self.titleLabel.text = playInfo.means;
//    self.placeHolderView.hidden = NO;
    
    [self.waitingView startAnimating];
    
    [self.player replaceCurrentItemWithPlayerItem:self.playerItem];
    
//    // 刚开始切换视频时 rate为0时显示视频海报(placeholder)
//    if (self.player.rate > 0) {
//        self.placeHolderView.hidden = YES;
//        [self.waitingView stopAnimating];
//    } else {
//        self.placeHolderView.hidden = NO;
//        [self.waitingView startAnimating];
//    }
    
    // 获取视频时长 网速慢可能会需要等待 卡住主线程
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        NSTimeInterval totalTime = CMTimeGetSeconds(self.asset.duration);
        // 截屏次数
        int captureTimes = totalTime;
        for (int i = 0; i < captureTimes; i++) {
            UIImage *image = [self thumbImageForVideo:[NSURL URLWithString:playInfo.uri] atTime:i];
            if (image) {
                [[self mutableArrayValueForKey:@"thumbImages"] addObject:image];
            }
        }
        // 添加视频最后一帧缩略图到数组
        UIImage *lastImage = [self thumbImageForVideo:[NSURL URLWithString:playInfo.uri] atTime:totalTime];
        if (lastImage) {
            [[self mutableArrayValueForKey:@"thumbImages"] addObject:lastImage];
        }
    });
}

// 创建播放器
- (AVPlayer *)setupPlayer
{
    AVPlayer *player = [[AVPlayer alloc] init];
    AVPlayerLayer *playerLayer = [AVPlayerLayer playerLayerWithPlayer:player];
    self.playerLayer = playerLayer;
    self.playerLayer.frame = [UIScreen mainScreen].bounds;
    [self.videoView.layer addSublayer:self.playerLayer];

    return player;
}

// 重置播放器
- (void)resetPlayer
{
    [self removePlayItemObserverAndNotification];
    [self removeTimeObserver];
    [self.player pause];
    [self.player seekToTime:kCMTimeZero];
    [self.playerLayer removeFromSuperlayer];
    self.playerLayer = nil;
    self.asset = nil;
    self.playerItem = nil;
    self.player = nil;
    self.imageGenerator = nil;
    self.placeHolderView.image = nil;
}

// 添加亮度和音量调节View
- (void)setupBrightnessAndVolumeView
{
    YGBrightnessAndVolumeView *brightnessAndVolumeView = [YGBrightnessAndVolumeView sharedBrightnessAndAudioView];
    [self.view addSubview:brightnessAndVolumeView];
    self.brightnessAndVolumeView = brightnessAndVolumeView;
}

// 给playItem添加观察者KVO
- (void)addPlayItemObserverAndNotification
{
    [self.playerItem addObserver:self forKeyPath:@"status" options:NSKeyValueObservingOptionNew context:NULL];
    [self.playerItem addObserver:self forKeyPath:@"loadedTimeRanges" options:NSKeyValueObservingOptionNew context:NULL];
    [self.playerItem addObserver:self forKeyPath:@"playbackBufferEmpty" options:NSKeyValueObservingOptionNew context:NULL];
    [self.playerItem addObserver:self forKeyPath:@"playbackLikelyToKeepUp" options:NSKeyValueObservingOptionNew context:NULL];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(playFinished:) name:AVPlayerItemDidPlayToEndTimeNotification object:nil];
}

// 移除观察者和通知
- (void)removePlayItemObserverAndNotification
{
    [self.playerItem removeObserver:self forKeyPath:@"status"];
    [self.playerItem removeObserver:self forKeyPath:@"loadedTimeRanges"];
    [self.playerItem removeObserver:self forKeyPath:@"playbackBufferEmpty"];
    [self.playerItem removeObserver:self forKeyPath:@"playbackLikelyToKeepUp"];
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

// 给进度条Slider添加时间OB
- (void)addTimerObserver
{
    __weak typeof(self) weakSelf = self;
    self.timeObserver = [self.player addPeriodicTimeObserverForInterval:CMTimeMake(1, 1) queue:dispatch_get_main_queue() usingBlock:^(CMTime time) {
        weakSelf.currentTimeLabel.text = [NSString stringWithTime:CMTimeGetSeconds(weakSelf.player.currentTime)];
        weakSelf.progressSlider.value = CMTimeGetSeconds(weakSelf.player.currentTime);
    }];
}

// 移除时间OB
- (void)removeTimeObserver
{
    if (self.timeObserver) {
        [self.player removeTimeObserver:self.timeObserver];
        self.timeObserver = nil;
    }
}

// KVO监测到播放完调用
- (void)playFinished:(NSNotification *)note {
    self.placeHolderView.hidden = NO;
    UIView *cover = [[UIView alloc] init];
    self.cover = cover;
    [self.view addSubview:cover];
    cover.backgroundColor = [UIColor blackColor];
    cover.alpha = 0.7;
    
    UIButton *replayBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [self.cover addSubview:replayBtn];
    [replayBtn setImage:[UIImage imageNamed:@"replay"] forState:UIControlStateNormal];
    replayBtn.titleLabel.font = [UIFont systemFontOfSize:24];
    [replayBtn setTitle:@"重播" forState:UIControlStateNormal];
    [replayBtn setTitleColor:[UIColor colorWithRed:190/255.0 green:190/255.0 blue:190/255.0 alpha:1.0] forState:UIControlStateNormal];
    replayBtn.contentEdgeInsets = UIEdgeInsetsMake(0, 15, 0, 0);
    replayBtn.imageEdgeInsets = UIEdgeInsetsMake(0, 0, 0, 15);
    [replayBtn addTarget:self action:@selector(replay) forControlEvents:UIControlEventTouchUpInside];
    self.replayBtn = replayBtn;
    self.playerItem = [note object];
    [self.view removeGestureRecognizer:self.tapGuesture];
}

// 播放完后重播
- (void)replay
{
    [self.cover removeFromSuperview];
    [self hideControlPanel];
    [self.playerItem seekToTime:kCMTimeZero completionHandler:nil];
    [self.player play];
    [self addGuesture];
}

// KVO检测播放器各种状态
- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSKeyValueChangeKey,id> *)change context:(void *)context
{
    AVPlayerItem *playItem = (AVPlayerItem *)object;
    NSTimeInterval totalTime = CMTimeGetSeconds(self.asset.duration);
    if ([keyPath isEqualToString:@"status"]) { // 检测播放器状态
        AVPlayerStatus status = [[change objectForKey:@"new"] intValue];
        if (status == AVPlayerStatusReadyToPlay) { // 达到能播放的状态
            self.totalTimeLabel.text = [NSString stringWithTime:totalTime];
//            self.placeHolderView.hidden = YES;
            self.placeHolderView.image = nil;
            self.progressSlider.maximumValue = totalTime;
            [self playOrPauseAction];
        } else if (status == AVPlayerStatusFailed) { // 播放错误 资源不存在 网络问题等等
            [self.waitingView stopAnimating];
            UILabel *busyLabel = [[UILabel alloc] init];
            busyLabel.font = [UIFont systemFontOfSize:13];
            busyLabel.textColor = [UIColor whiteColor];
            busyLabel.backgroundColor = [UIColor clearColor];
            busyLabel.textAlignment = NSTextAlignmentCenter;
            busyLabel.text = @"资源不存在...";
            [self.view addSubview:busyLabel];
            [busyLabel mas_makeConstraints:^(MASConstraintMaker *make) {
                make.center.width.equalTo(self.view);
                make.height.mas_equalTo(30);
            }];
        } else if (status == AVPlayerStatusUnknown) { // 未知错误
            [self.waitingView stopAnimating];
            UILabel *errorLabel = [[UILabel alloc] init];
            errorLabel.font = [UIFont systemFontOfSize:13];
            errorLabel.textColor = [UIColor whiteColor];
            errorLabel.backgroundColor = [UIColor clearColor];
            errorLabel.textAlignment = NSTextAlignmentCenter;
            errorLabel.text = @"网络错误，请检查手机网络...";
            [self.view addSubview:errorLabel];
            [errorLabel mas_makeConstraints:^(MASConstraintMaker *make) {
                make.center.width.equalTo(self.view);
                make.height.mas_equalTo(30);
            }];
        }
    } else if ([keyPath isEqualToString:@"loadedTimeRanges"]) { // 检测缓存状态
        NSArray *loadedTimeRanges = [playItem loadedTimeRanges];
        CMTimeRange timeRange = [[loadedTimeRanges firstObject] CMTimeRangeValue];
        NSTimeInterval bufferingTime = CMTimeGetSeconds(timeRange.start) + CMTimeGetSeconds(timeRange.duration);
        NSTimeInterval totalTime = CMTimeGetSeconds(playItem.duration);
        [self.loadedView setProgress:bufferingTime / totalTime animated:YES];
        if (bufferingTime > CMTimeGetSeconds(playItem.currentTime) + 5.f) {
            
            [self.waitingView stopAnimating];
        } else if (self.player.rate == 0) {
            [self.waitingView startAnimating];
        }
    } else if ([keyPath isEqualToString:@"playbackBufferEmpty"]) {  // 缓存为空
        if (playItem.playbackBufferEmpty) {
            [self.waitingView startAnimating];
        }
    } else if ([keyPath isEqualToString:@"playbackLikelyToKeepUp"]) { // 缓存足够能播放
        if (playItem.playbackLikelyToKeepUp) {
            [self.waitingView stopAnimating];
        }
    } else if ([keyPath isEqualToString:@"thumbImages"]) {
        dispatch_async(dispatch_get_main_queue(), ^{
            int imageIndex = (int)self.progressSlider.value / 10;
            if (imageIndex < self.thumbImages.count) {
                self.previewView.image = self.thumbImages[imageIndex];
            }
        });
    }
}


// 播放或暂停按钮点击
- (IBAction)playOrPauseAction
{
    [self playOrPause];
}

// 中间大的播放或站厅按钮点击
- (IBAction)centerPlayOrPauseAction
{
    [self playOrPause];
}
// 拖拽进度条
- (IBAction)dragProgressAction:(UISlider *)sender {
    // 取消之前的隐藏播放控制面板的操作
    [NSObject cancelPreviousPerformRequestsWithTarget:self];
    
    [self.player pause];
    [self removeTimeObserver];
    self.currentTimeLabel.text = [NSString stringWithTime:sender.value];
    int imageIndex = sender.value / 10;
    self.previewView.alpha = 1.f;
    self.previewView.title = [NSString stringWithTime:sender.value];
    
    if (imageIndex < self.thumbImages.count) {
        self.previewView.image = self.thumbImages[imageIndex];
    } else {
        self.previewView.image = nil;
    }
}

// 进度条拖拽结束
- (void)progressDragEnd:(UISlider *)sender
{
    [UIView animateWithDuration:.5f animations:^{
        self.previewView.alpha = .0f;
    }];
    [self.player seekToTime:CMTimeMake(self.progressSlider.value, 1.0)];
    [self addTimerObserver];
    [self.player play];
    // 延迟10.0秒后隐藏播放控制面板
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(10.f * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [self hideControlPanel];
        [self hideStatusBar];
    });
}

// 获取AVURLAsset的任意一帧图片
- (UIImage *)thumbImageForVideo:(NSURL *)videoURL atTime:(NSTimeInterval)time {
    [self.imageGenerator cancelAllCGImageGeneration];
    self.imageGenerator.appliesPreferredTrackTransform = YES;
    self.imageGenerator.maximumSize = CGSizeMake(160, 90);
    
    CGImageRef thumbImageRef = NULL;
    NSError *thumbImageGenerationError = nil;
    thumbImageRef = [self.imageGenerator copyCGImageAtTime:CMTimeMake(time, 1) actualTime:NULL error:&thumbImageGenerationError];
    //    NSLog(@"%@", thumbImageGenerationError);
    if (thumbImageRef) {
        return [[UIImage alloc] initWithCGImage:thumbImageRef];
    } else {
        return nil;
    }
}



// 移除选集遮盖
- (void)removeEpisodeCover:(UIButton *)episodeCover
{
    [episodeCover removeFromSuperview];
    [self addGuesture];
}



// 播放或暂停
- (void)playOrPause
{
    self.placeHolderView.hidden = YES;
    [self playWithPlayInfo:self.model];
    if (self.player.timeControlStatus == AVPlayerTimeControlStatusPaused) {

        [self.player play];
        [self.playBtn setImage:[UIImage imageNamed:@"Stop"] forState:UIControlStateNormal];
        [self.centerPlayBtn setImage:[UIImage imageNamed:@"player_pause_iphone_fullscreen"] forState:UIControlStateNormal];
    } else if (self.player.timeControlStatus == AVPlayerTimeControlStatusPlaying) {
        [self.player pause];
        [self.playBtn setImage:[UIImage imageNamed:@"Play"] forState:UIControlStateNormal];
        [self.centerPlayBtn setImage:[UIImage imageNamed:@"player_start_iphone_fullscreen"] forState:UIControlStateNormal];
    }
}

// 添加手势识别器
- (void)addGuesture
{
    // 添加Tap手势
    UITapGestureRecognizer *tapGuesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(showOrHideControlPanel)];
    [self.view addGestureRecognizer:tapGuesture];
    self.tapGuesture = tapGuesture;
}

// 显示或隐藏播放器控制面板
- (void)showOrHideControlPanel
{
    if (self.controlPanelIsShowing) {
        [self hideControlPanel];
        if (self.isLandscape) {
            [self hideStatusBar];
        }
    } else {
        [NSObject cancelPreviousPerformRequestsWithTarget:self];
        [UIView animateWithDuration:.5f animations:^{
            [self showControlPanel];
            [self showStatusBar];
        } completion:^(BOOL finished) {
            [self autoFadeOutControlPanel];
            if (self.isLandscape) {
                [self performSelector:@selector(hideStatusBar) withObject:nil afterDelay:10.f];
            }
        }];
    }
}

// 显示播放控制面板
- (void)showControlPanel
{
    self.controlPanelShow = YES;
    self.topView.alpha = 1.f;
    self.bottomView.alpha = 1.f;
}

// 隐藏播放控制面板
- (void)hideControlPanel
{
    self.controlPanelShow = NO;
    self.topView.alpha = .0f;
    self.bottomView.alpha = .0f;
}

// 自动淡出播放控制面板
- (void)autoFadeOutControlPanel {
    [NSObject cancelPreviousPerformRequestsWithTarget:self];
    [self performSelector:@selector(hideControlPanel) withObject:nil afterDelay:10.f];
}


// 显示状态栏
- (void)showStatusBar
{
    UIView *statusBar = [[[UIApplication sharedApplication] valueForKey:@"statusBarWindow"] valueForKey:@"statusBar"];
    statusBar.alpha = 1.f;
}

// 隐藏状态栏
- (void)hideStatusBar
{
    UIView *statusBar = [[[UIApplication sharedApplication] valueForKey:@"statusBarWindow"] valueForKey:@"statusBar"];
    statusBar.alpha = .0f;
}
//点击返回按钮
- (IBAction)backBtnClick:(UIButton *)sender {
    [self dismissViewControllerAnimated:YES completion:^{
        [self removePlayItemObserverAndNotification];
        [self removeTimeObserver];
        [self removeObserver:self forKeyPath:@"thumbImages"];
    }];
}


@end
