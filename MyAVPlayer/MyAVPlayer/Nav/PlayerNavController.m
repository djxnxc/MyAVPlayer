//
//  PlayerNavController.m
//  MyAVPlayer
//
//  Created by 邓家祥 on 2018/6/13.
//  Copyright © 2018年 邓家祥. All rights reserved.
//

#import "PlayerNavController.h"

@interface PlayerNavController ()

@end

@implementation PlayerNavController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.navigationBar.translucent = NO;
    self.navigationBar.barTintColor = [UIColor colorWithRed:220/255.0f green:66/255.0f blue:78/255.0f alpha:1];
    [self.navigationBar setTitleTextAttributes:@{NSFontAttributeName:[UIFont systemFontOfSize:20],NSForegroundColorAttributeName:[UIColor whiteColor]}];
    
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
