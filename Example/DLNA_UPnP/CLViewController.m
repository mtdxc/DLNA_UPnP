//
//  CLViewController.m
//  DLNA_UPnP
//
//  Created by ClaudeLi on 04/12/2019.
//  Copyright (c) 2019 ClaudeLi. All rights reserved.
//

#import "CLViewController.h"
#import "CLSearchDeviceController.h"

@interface CLViewController ()

@end

@implementation CLViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self sendTestRequest];

    UIButton* button = [UIButton new];
    button.backgroundColor = [UIColor redColor];
    [button setTitle:@" 搜索设备 " forState:UIControlStateNormal];
    [button addTarget:self action:@selector(clickButtonAction) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:button];
    [button sizeToFit];
    button.center = self.view.center;
}

- (void)clickButtonAction{
    CLSearchDeviceController *search = [[CLSearchDeviceController alloc] init];
    [self.navigationController pushViewController:search animated:YES];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/**
 DLNA功能只有在用户允许了网络权限后才能使用
 */
-(void)sendTestRequest{
    NSURL *url = [NSURL URLWithString:@"https://www.baidu.com"];
    NSMutableURLRequest *requst = [[NSMutableURLRequest alloc]initWithURL:url];
    requst.HTTPMethod = @"GET";
    requst.timeoutInterval = 5;
    
    [NSURLConnection sendAsynchronousRequest:requst queue:[[NSOperationQueue alloc]init] completionHandler:^(NSURLResponse * _Nullable response, NSData * _Nullable data, NSError * _Nullable connectionError) {
        if (!connectionError.description) {
            NSLog(@"网络正常");
        }else{
            NSLog(@"=========>网络异常");
        }
    }];
}

@end
