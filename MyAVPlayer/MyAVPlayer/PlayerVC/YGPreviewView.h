//
//  YGPreviewView.h
//  MyAVPlayer
//
//  Created by 邓家祥 on 2018/6/14.
//  Copyright © 2018年 邓家祥. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface YGPreviewView : UIView
@property (nonatomic, strong) UIImageView *previewImageView;
@property (nonatomic, strong) UILabel *previewtitleLabel;
@property (nonatomic, strong) UIActivityIndicatorView *loadingView;
@property (nonatomic, copy) NSString *title;
@property (nonatomic, strong) UIImage *image;
+ (instancetype)sharedPreviewView;
@end
