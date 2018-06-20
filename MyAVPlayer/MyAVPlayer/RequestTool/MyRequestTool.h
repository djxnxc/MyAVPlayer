//
//  MyRequestTool.h
//  MyAVPlayer
//
//  Created by 邓家祥 on 2018/6/13.
//  Copyright © 2018年 邓家祥. All rights reserved.
//

#import <Foundation/Foundation.h>
typedef void (^SuccessBlock)(id result);
typedef void (^ErrorBlock)(id error);
@interface MyRequestTool : NSObject
+(instancetype)shareManger;
/**
 *  发送post请求
 *
 *  URLStr  请求的网址字符串
 *  parameters 请求的参数
 *  success    请求成功的回调
 *  failure    请求失败的回调
 */
+ (void)postRequestWithURLStr:(NSString *)urlString
                   parameters:(id)parameters
                      success:(SuccessBlock)successBlock
                      failure:(ErrorBlock)failureBlock;
@end
