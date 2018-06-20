//
//  VideoModel.h
//  MyAVPlayer
//
//  Created by 邓家祥 on 2018/6/13.
//  Copyright © 2018年 邓家祥. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface VideoModel : NSObject
//名称
@property(nonatomic,copy)NSString *means;
//图片URL
@property(nonatomic,copy)NSString *imguri;
//视频URL
@property(nonatomic,copy)NSString *uri;
@end
