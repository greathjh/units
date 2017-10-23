//
//  HttpRequestManager.h
//  openHAB
//
//  Created by XMYY-25 on 2017/10/17.
//  Copyright © 2017年 openHAB e.V. All rights reserved.
//
@class AFRememberingSecurityPolicy;

#import <AFNetworking/AFNetworking.h>
/**
 网络请求的方式
 
 - PMRequestMethodGet: get
 - PMRequestMethodPost: post
 - PMRequestMethodPut: put
 - PMRequestMethodDelete: delete
 */
typedef NS_ENUM(NSInteger, PMRequestMethod) {
    OpenHABRequestMethodGet,
    OpenHABRequestMethodPost,
    OpenHABRequestMethodPut,
    OpenHABRequestMethodDelete
};

@interface HttpRequestManager : AFHTTPSessionManager

/**
 同时进行网络请求的最大数，默认是 10
 */
@property (nonatomic, assign) NSUInteger maxConcurrentOperationCount;
/**
 默认超时时间的初始化，默认是 20 秒
 
 @return PMRequestManager
 */
//+ (instancetype)initialManager;

/**
 自定义超时时间的初始化
 
 @param timeoutInterval 超时时间
 @return PMRequestManager
 */
+ (instancetype)initialManagerWithTimeoutInterval:(NSTimeInterval)timeoutInterval authorizationUsername:(NSString *)username
                           uathorizationPassword:(NSString *)password;

/**
 设置类函数
 */
- (void)setSecurityPolicy:(AFRememberingSecurityPolicy *)policy isSecurity:(BOOL)isSecurity;
- (void)setAtmosphereTrackingId:(NSString *)atmosphereTrackingId;
- (void)setLongPolling:(BOOL)isLongPolling;

/**
 请求数据 (地址的形式)
 
 @param servicePath 服务器 API 地址
 @param requestMethod 请求方式
 @param authorizationUsername 用户名
 @param uathorizationPassword 密码
 @param httpHeader 请求头
 @param parameters 参数
 @param acquirePolicy 读取数据策略
 @param successBlock 请求成功回调
 @param failureBlock 请求失败回调
 @return NSURLSessionTask
 */
- (NSURLSessionTask *)requestDataTaskWithServicePath:(NSString *)servicePath
                                       requestMethod:(PMRequestMethod)requestMethod
                               authorizationUsername:(NSString *)username
                               uathorizationPassword:(NSString *)password
                                          httpHeader:(NSDictionary *)httpHeader
                                          parameters:(NSDictionary *)parameters
                                        successBlock:(void (^)(NSURLSessionTask *task, NSDictionary *responseObject))successBlock
                                        failureBlock:(void (^)(NSURLSessionTask *task, NSError *error))failureBlock;

/**
 请求数据 (地址的形式 带httpBody)
 
 @param servicePath 请求servicePath
 @param httpBody 请求httpBody
 @param authorizationUsername 请求用户名
 @param uathorizationPassword 密码
 @return NSURLSessionTask
 */
- (void)dataTaskWithServicePath:(NSURL *)servicePath
                       httpBody:(NSString *)httpBody
          authorizationUsername:(NSString *)username
          uathorizationPassword:(NSString *)password
              completionHandler:(void (^)(NSURLResponse * response, id  responseObject, NSError * error))handler;

@end
