//
//  PZXCityListController.h
//  PZXCityListController
//
//  Created by 彭祖鑫 on 2017/1/16.
//  Copyright © 2017年 PZX. All rights reserved.
//

#import <UIKit/UIKit.h>
@class PZXCityListController;

@protocol PZXCityListDelegate <NSObject>

-(void)cityListController:(PZXCityListController *)listController
            didSelectCity:(NSDictionary *)cityData;

-(void)cancelButtonPressed:(PZXCityListController *)listController;

@end

@interface PZXCityListController : UITableViewController
/*
 0
 
 cityData数据
 *@city_key 城市编号
 *@city_name 城市名字
 *@initials 城市
 *@pinyin 城市拼音
 *@short_name 城市短名
 */
@property(nonatomic,assign)id<PZXCityListDelegate> delegate;

@property(nonatomic,strong)NSMutableArray *hotCityArr;//热门城市数组


@end
