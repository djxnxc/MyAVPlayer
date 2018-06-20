//
//  YGPreviewView.m
//  MyAVPlayer
//
//  Created by 邓家祥 on 2018/6/14.
//  Copyright © 2018年 邓家祥. All rights reserved.
//

#import "YGPreviewView.h"



@implementation YGPreviewView
// 单例
static id _instance;
+ (instancetype)allocWithZone:(struct _NSZone *)zone
{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _instance = [super allocWithZone:zone];
    });
    return _instance;
}

+ (instancetype)sharedPreviewView
{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _instance = [[self alloc] init];
    });
    return _instance;
}

#pragma mark - 懒加载
// 视频缩略图
- (UIImageView *)previewImageView
{
    if (_previewImageView == nil) {
        _previewImageView = [[UIImageView alloc] init];
        _previewImageView.layer.cornerRadius = 5;
        _previewImageView.clipsToBounds = YES;
        _previewImageView.backgroundColor = [UIColor colorWithRed:.0f green:.0f blue:.0f alpha:.5f];
        [self addSubview:_previewImageView];
    }
    return _previewImageView;
}

// 进度标签
- (UILabel *)previewtitleLabel
{
    if (_previewtitleLabel == nil) {
        _previewtitleLabel = [[UILabel alloc] init];
        _previewtitleLabel.font = [UIFont systemFontOfSize:20];
        _previewtitleLabel.textColor = [UIColor whiteColor];
        _previewtitleLabel.textAlignment = NSTextAlignmentCenter;
        [self addSubview:_previewtitleLabel];
    }
    return _previewtitleLabel;
}

// 等待菊花
- (UIActivityIndicatorView *)loadingView
{
    if (_loadingView == nil) {
        _loadingView = [[UIActivityIndicatorView alloc] init];
        _loadingView.activityIndicatorViewStyle = UIActivityIndicatorViewStyleWhite;
        _loadingView.hidesWhenStopped = YES;
        [self.previewImageView addSubview:_loadingView];
    }
    return _loadingView;
}

- (void)setTitle:(NSString *)title
{
    _title = title;
    self.previewtitleLabel.text = title;
}

- (void)setImage:(UIImage *)image
{
    _image = image;
    if (image == nil) {
        [self.loadingView startAnimating];
        self.previewImageView.image = nil;
    } else {
        [self.loadingView stopAnimating];
        self.previewImageView.image = image;
    }
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    [self.previewImageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.top.equalTo(self);
        make.height.equalTo(self).multipliedBy(9/16.0);
    }];
    
    [self.previewtitleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.equalTo(self);
        make.top.equalTo(self.previewImageView).offset(110.f);
        make.height.mas_equalTo(20.f);
    }];
    
    [self.loadingView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.center.equalTo(self.previewImageView);
        make.width.height.mas_equalTo(20);
    }];
}
@end
