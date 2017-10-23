//
//  HttpRequestManager.m
//  openHAB
//
//  Created by XMYY-25 on 2017/10/17.
//  Copyright © 2017年 openHAB e.V. All rights reserved.
//

#import "HttpRequestManager.h"
#import "AFRememberingSecurityPolicy.h"
#import "NSMutableURLRequest+Auth.h"
#import "Command.h"

#define Default_Request_Timeout_Interval 20.0       // 默认请求超时时间
#define Default_Max_Concurrent_Operation_Count 10   // 默认同时请求最大数

@implementation HttpRequestManager

#pragma mark -
+ (instancetype)initialManagerWithTimeoutInterval:(NSTimeInterval)timeoutInterval
                           authorizationUsername:(NSString *)username
                           uathorizationPassword:(NSString *)password{
    return [[self alloc] initWithBaseURL:nil authorizationUsername:username uathorizationPassword:password withTimeoutInterval:timeoutInterval];
}

#pragma mark - initial method

- (instancetype)initWithBaseURL:(NSURL *)url
          authorizationUsername:(NSString *)username
          uathorizationPassword:(NSString *)password{
    return [self initWithBaseURL:url
           authorizationUsername:username
           uathorizationPassword:password
            sessionConfiguration:[NSURLSessionConfiguration defaultSessionConfiguration]
                 timeoutInterval:Default_Request_Timeout_Interval];
}

- (instancetype)initWithBaseURL:(NSURL *)url
          authorizationUsername:(NSString *)username
          uathorizationPassword:(NSString *)password
            withTimeoutInterval:(NSTimeInterval)timeoutInterval {
    return [self initWithBaseURL:url
           authorizationUsername:username
           uathorizationPassword:password
            sessionConfiguration:[NSURLSessionConfiguration defaultSessionConfiguration]
                 timeoutInterval:timeoutInterval];
}

- (instancetype)initWithBaseURL:(NSURL *)url
          authorizationUsername:(NSString *)username
          uathorizationPassword:(NSString *)password
           sessionConfiguration:(NSURLSessionConfiguration *)configuration
                timeoutInterval:(NSTimeInterval)timeoutInterval {
    self = [super initWithBaseURL:url sessionConfiguration:configuration];
    if (self) {
        self.operationQueue.maxConcurrentOperationCount = self.maxConcurrentOperationCount == 0 ? Default_Max_Concurrent_Operation_Count : self.maxConcurrentOperationCount;
        self.requestSerializer = [AFHTTPRequestSerializer serializer];
        self.responseSerializer = [AFHTTPResponseSerializer serializer];
        [self.requestSerializer setAuthorizationHeaderFieldWithUsername:username password:password];
        self.requestSerializer.timeoutInterval = timeoutInterval;
    }
    return  self;
}

#pragma mark - 设置securityPolicy
- (void)setSecurityPolicy:(AFRememberingSecurityPolicy *)policy isSecurity:(BOOL)isSecurity{
    self.securityPolicy = policy;
    if (isSecurity) {
        NSLog(@"Warning - ignoring invalid certificates");
        self.securityPolicy.allowInvalidCertificates = YES;
    } else {
        self.securityPolicy.allowInvalidCertificates = NO;
    }
}

#pragma mark - 设置atmosphereTrackingId
- (void)setAtmosphereTrackingId:(NSString *)atmosphereTrackingId{
    if (atmosphereTrackingId != nil) {
        [self.requestSerializer setValue:atmosphereTrackingId forHTTPHeaderField:@"X-Atmosphere-tracking-id"];
    } else {
        [self.requestSerializer setValue:@"0" forHTTPHeaderField:@"X-Atmosphere-tracking-id"];
    }
}

#pragma mark - 设置longPolling
- (void)setLongPolling:(BOOL)isLongPolling{
    if (isLongPolling) {
        NSLog(@"long polling, so setting atmosphere transport");
        [self.requestSerializer setValue:@"long-polling" forHTTPHeaderField:@"X-Atmosphere-Transport"];
        [self.requestSerializer setValue:@"Connection" forHTTPHeaderField:@"Keep-alive"];
        [self.requestSerializer setTimeoutInterval:300.0];
    } else {
        self.atmosphereTrackingId = nil;
        [UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
        [self.requestSerializer setTimeoutInterval:10.0];
    }
}

#pragma mark - 请求数据 不带httpBody参数
- (NSURLSessionTask *)requestDataTaskWithServicePath:(NSString *)servicePath
                                       requestMethod:(PMRequestMethod)requestMethod
                               authorizationUsername:(NSString *)username
                               uathorizationPassword:(NSString *)password
                                          httpHeader:(NSDictionary *)httpHeader
                                          parameters:(NSDictionary *)parameters
                                        successBlock:(void (^)(NSURLSessionTask *task, NSDictionary *responseObject))successBlock
                                        failureBlock:(void (^)(NSURLSessionTask *task, NSError *error))failureBlock {
    
    return [self requestDataTaskWithServicePath:servicePath
                                       cacheKey:servicePath
                                  requestMethod:requestMethod
                          authorizationUsername:username
                          uathorizationPassword:password
                                     httpHeader:httpHeader
                                     parameters:parameters
                                   successBlock:successBlock
                                   failureBlock:failureBlock];
    
}

#pragma mark - 带httpBody参数
- (void)dataTaskWithServicePath:(NSURL *)servicePath
                       httpBody:(NSString *)httpBody
          authorizationUsername:(NSString *)username
          uathorizationPassword:(NSString *)password
             completionHandler:(void (^)(NSURLResponse * response, id  responseObject, NSError * error))handler{
    
    NSMutableURLRequest *commandRequest = [NSMutableURLRequest requestWithURL:servicePath];
    [commandRequest setHTTPMethod:@"POST"];
    [commandRequest setValue:@"text/plain" forHTTPHeaderField:@"Content-type"];
    [commandRequest setHTTPBody:[httpBody dataUsingEncoding:NSUTF8StringEncoding]];
    [commandRequest setAuthCredentials:username andPassword:password];
    
    NSURLSessionDataTask *dataTask = [self dataTaskWithRequest:commandRequest completionHandler:^(NSURLResponse * _Nonnull response, id  _Nullable responseObject, NSError * _Nullable error) {
        SB(handler, response,responseObject, error);
    }];
    [dataTask resume];
}

- (NSURLSessionTask *)requestDataTaskWithServicePath:(NSString *)servicePath
                                            cacheKey:(NSString *)cacheKey
                                       requestMethod:(PMRequestMethod)requestMethod
                               authorizationUsername:(NSString *)username
                               uathorizationPassword:(NSString *)password
                                          httpHeader:(NSDictionary *)httpHeader
                                          parameters:(NSDictionary *)parameters
                                        successBlock:(void (^)(NSURLSessionTask *task, NSDictionary *responseObject))success
                                        failureBlock:(void (^)(NSURLSessionTask *task, NSError *error))failure {
    // 处理请求成功的回调方法，将成功的信息返回上一层, 需要业务层判断是真的成功还是失败
    void (^successBlock)(NSURLSessionTask *, NSData *) = ^(NSURLSessionTask *task, id data){
        // 同步网络时间
        
        if (!success) {
            return;
        }
        
        if (!data) {
            if (!failure) {
                return;
            }
        }
        
        NSError *error = nil;
        
        NSData *responseData = [NSJSONSerialization dataWithJSONObject:data
                                                               options:NSJSONWritingPrettyPrinted
                                                                 error:&error];
        NSString *responseString = [[NSString alloc] initWithData:responseData encoding:NSUTF8StringEncoding];
        
        if (error) {
            SB(failure,task,error);
        } else {
            // 打印成功日志
            NSLog(@"request URL:%@\n\nrequest Header:%@\n\nrequest Parameters:%@\n\nError description:%@", task.currentRequest.URL.absoluteString, task.currentRequest.allHTTPHeaderFields, responseString, error.localizedDescription);
            SB(success, task, data);
        }
    };
    
    // 处理请求失败的回调方法，直接返回错误
    void (^failureBlock)(NSURLSessionTask *, NSError *) = ^(NSURLSessionTask *task, NSError *error){
        if (!failure) {
            return;
        }
        // 手动取消, 不产生回调
        if (error.code != NSURLErrorCancelled) {
            SB(failure, nil, error);
        }
    };
    
    // 设置请求头
    if (httpHeader) {
        [httpHeader enumerateKeysAndObjectsUsingBlock:^(id  _Nonnull key, id  _Nonnull obj, BOOL * _Nonnull stop) {
            [self.requestSerializer setValue:obj forHTTPHeaderField:key];
        }];
    }
    // 用户名和密码
    if (username.length && password.length) {
        [self.requestSerializer setAuthorizationHeaderFieldWithUsername:username password:password];
    }
    
    // 请求类型
    switch (requestMethod) {
        case OpenHABRequestMethodGet:
            return [self GET:servicePath parameters:parameters progress:nil success:successBlock failure:failureBlock];
            break;
            
        case OpenHABRequestMethodPost:
            return [self POST:servicePath parameters:parameters progress:nil success:successBlock failure:failureBlock];
            break;
            
        case OpenHABRequestMethodPut:
            return [self PUT:servicePath parameters:parameters success:successBlock failure:failureBlock];
            break;
            
        case OpenHABRequestMethodDelete:
            return [self DELETE:servicePath parameters:parameters success:successBlock failure:failureBlock];
            break;
    }
}
@end
