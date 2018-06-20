//
//  ViewController.m
//  MyAVPlayer
//
//  Created by 邓家祥 on 2018/6/13.
//  Copyright © 2018年 邓家祥. All rights reserved.
//

#import "ViewController.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"我的视频";
    // Do any additional setup after loading the view, typically from a nib.
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
//进入视频列表
- (IBAction)enterVideoList:(UIButton *)sender {
    VideoList *videoList = [[VideoList alloc]initWithNibName:@"VideoList" bundle:nil];
    
    [self.navigationController pushViewController:videoList animated:YES];
}


@end
