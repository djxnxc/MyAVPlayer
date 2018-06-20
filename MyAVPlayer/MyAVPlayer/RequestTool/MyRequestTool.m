//
//  MyRequestTool.m
//  MyAVPlayer
//
//  Created by 邓家祥 on 2018/6/13.
//  Copyright © 2018年 邓家祥. All rights reserved.
//

#import "MyRequestTool.h"
static MyRequestTool *_requestManager=nil;
@implementation MyRequestTool
+(instancetype)shareManger{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _requestManager = [[MyRequestTool alloc]init];
    });
    return _requestManager;
}
+(void)postRequestWithURLStr:(NSString *)urlString parameters:(id)parameters success:(SuccessBlock)successBlock failure:(ErrorBlock)failureBlock{
    
    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
    manager.responseSerializer = [AFHTTPResponseSerializer serializer];
    //    manager.requestSerializer.timeoutInterval = 30;
    [manager POST:urlString parameters:parameters progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        if (successBlock) {
            NSDictionary *dic = [NSJSONSerialization JSONObjectWithData:responseObject options:NSJSONReadingMutableLeaves error:nil];
            successBlock(dic);
        }
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        if (failureBlock) {
            failureBlock(error);
            NSLog(@"网络异常 - T_T%@", error);
        }
    }];
}
@end
