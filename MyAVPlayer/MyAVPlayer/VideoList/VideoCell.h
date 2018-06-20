//
//  VideoCell.h
//  MyAVPlayer
//
//  Created by 邓家祥 on 2018/6/13.
//  Copyright © 2018年 邓家祥. All rights reserved.
//

#import <UIKit/UIKit.h>
@class VideoModel;
@interface VideoCell : UICollectionViewCell
//封面图
@property (weak, nonatomic) IBOutlet UIImageView *imageV;
//视频名称
@property (weak, nonatomic) IBOutlet UILabel *titleLab;
@property(nonatomic,strong)VideoModel *model;

@end
