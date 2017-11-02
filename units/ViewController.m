//
//  ViewController.m
//  units
//
//  Created by Fly on 2017/10/22.
//  Copyright © 2017年 air. All rights reserved.
//

#import "ViewController.h"
#import "HttpRequestManager.h"
#import "AFRememberingSecurityPolicy.h"

@interface ViewController ()

@property (nonatomic, strong) NSMutableArray *list;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self getSitemapsbyUrl];
    // Do any additional setup after loading the view, typically from a nib.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

//http请求实例
- (void)getSitemapsbyUrl{
    NSString *aaa;
    NSString *sitemapsUrlString = [NSString stringWithFormat:@"%@/rest/sitemaps", @"https://192.168.6.43:3000"];
    HttpRequestManager *httpManager = [HttpRequestManager manager];
    [httpManager.requestSerializer setAuthorizationHeaderFieldWithUsername:self.openHABUsername password:self.openHABPassword];
    AFRememberingSecurityPolicy *policy = [AFRememberingSecurityPolicy policyWithPinningMode:0];
    httpManager.securityPolicy = policy;
    if (self.ignoreSSLCertificate) {
        NSLog(@"Warning - ignoring invalid certificates");
        httpManager.securityPolicy.allowInvalidCertificates = YES;
    }
    [httpManager requestDataTaskWithServicePath:sitemapsUrlString requestMethod:OpenHABRequestMethodGet authorizationUsername:self.openHABUsername uathorizationPassword:self.openHABPassword httpHeader:nil parameters:nil successBlock:^(NSURLSessionTask *task, NSDictionary *responseObject) {
        NSData *response = (NSData*)responseObject;
        NSLog(@"%@",response);
            // Newer versions speak JSON!
        
    } failureBlock:^(NSURLSessionTask *task, NSError *error) {
        NSLog(@"Error:------>%@", [error description]);
        NSLog(@"error code %ld",(long)error.code);
    }];
    
}

@end
