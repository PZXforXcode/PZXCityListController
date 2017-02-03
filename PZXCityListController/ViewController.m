//
//  ViewController.m
//  PZXCityListController
//
//  Created by 彭祖鑫 on 2017/1/16.
//  Copyright © 2017年 PZX. All rights reserved.
//

#import "ViewController.h"
#import "PZXCityListController.h"

@interface ViewController ()<PZXCityListDelegate>
- (IBAction)interButtonPressed:(UIButton *)sender;
@property (strong, nonatomic) IBOutlet UIButton *interButton;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    

}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


- (IBAction)interButtonPressed:(UIButton *)sender {
    
    PZXCityListController *vc = [[PZXCityListController alloc]init];
//    [self presentViewController:vc animated:YES completion:nil];
    vc.delegate = self;
    [self presentViewController:[[UINavigationController alloc] initWithRootViewController:vc] animated:YES completion:^{
        
    }];

}

#pragma mark - PZXCityListDelegate
-(void)cityListController:(PZXCityListController *)listController didSelectCity:(NSDictionary *)cityData{


    NSLog(@"%@",cityData);
    /*
     *@city_key 城市编号
     *@city_name 城市名字
     *@initials 城市
     *@pinyin 城市拼音
     *@short_name 城市短名
     */
    [self.interButton setTitle:[NSString stringWithFormat:@"%@",cityData[@"city_name"]] forState:UIControlStateNormal];
    [listController dismissViewControllerAnimated:YES completion:nil];
    
}
-(void)cancelButtonPressed:(PZXCityListController *)listController{
    
    [listController dismissViewControllerAnimated:YES completion:nil];

}
@end
