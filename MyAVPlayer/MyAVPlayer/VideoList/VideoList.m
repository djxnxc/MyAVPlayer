//
//  VideoList.m
//  MyAVPlayer
//
//  Created by 邓家祥 on 2018/6/13.
//  Copyright © 2018年 邓家祥. All rights reserved.
//

#import "VideoList.h"
//#import "MyAVPlayerVC.h"

#define SCREEN_WIDTH  [UIScreen mainScreen].bounds.size.width
#define SCREEN_HEIGHT [UIScreen mainScreen].bounds.size.height
@interface VideoList ()<UICollectionViewDelegate,UICollectionViewDataSource,UICollectionViewDelegateFlowLayout>
@property (weak, nonatomic) IBOutlet UICollectionView *videoList;
@property (strong, nonatomic) IBOutlet UIButton *backBtn;
@property(nonatomic,copy)NSArray *arrData;
@end

@implementation VideoList

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"我的视频";
    [self initView];
    [self requestVideoList];
    // Do any additional setup after loading the view from its nib.
}
-(void)initView{
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc]initWithCustomView:self.backBtn];
    self.videoList.delegate = self;
    self.videoList.dataSource = self;
    self.videoList.showsVerticalScrollIndicator = NO;
    self.videoList.showsHorizontalScrollIndicator = NO;
    
    [self.videoList registerNib:[UINib nibWithNibName:@"VideoCell" bundle:nil] forCellWithReuseIdentifier:@"cellID"];
}
-(void)requestVideoList{
    self.arrData = [NSArray array];
    [[MyRequestTool shareManger]postRequestWithURLStr:@"http://116.62.168.251:8080/VideoOperation/video/queryList.do"parameters:nil success:^(id result) {
        self.arrData = result;
        [self.videoList reloadData];
    } failure:^(id error) {
        
    }];
}
- (IBAction)backBtnClick:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
}
#pragma mark - UICollectionView代理
-(NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section{
    return self.arrData.count;
}
-(UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath{
    VideoCell *cell =[collectionView dequeueReusableCellWithReuseIdentifier:@"cellID" forIndexPath:indexPath];
    if (self.arrData.count>0) {
        cell.model = [VideoModel yy_modelWithDictionary:self.arrData[indexPath.row]];
    }
    return cell;
    
}
-(CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath{
    return CGSizeMake((SCREEN_WIDTH-30)/3, (SCREEN_WIDTH-20)/3*1.5);
}
-(UIEdgeInsets)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout insetForSectionAtIndex:(NSInteger)section{
    return UIEdgeInsetsMake(5, 5, 5, 5);
}
-(void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath{
//    NSLog(@"--->%ld",indexPath.row);
    PlayerVC *vc = [[PlayerVC alloc]initWithNibName:@"PlayerVC" bundle:nil];
    vc.model =[VideoModel yy_modelWithDictionary:self.arrData[indexPath.row]];
    [self presentViewController:vc animated:YES completion:nil];
//    MyAVPlayerVC *vc = [[MyAVPlayerVC alloc]initWithNibName:@"MyAVPlayerVC" bundle:nil];
//    vc.model =[VideoModel yy_modelWithDictionary:self.arrData[indexPath.row]];
//    [self presentViewController:vc animated:YES completion:nil];
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
