# PZXCityListController
封装城市选择列表支持最近选择城市和定位城市，热门城市。以及搜索功能
## 使用方法:
```Objective-C

    PZXCityListController *vc = [[PZXCityListController alloc]init];
//    [self presentViewController:vc animated:YES completion:nil];
    vc.delegate = self;
    [self presentViewController:[[UINavigationController alloc] initWithRootViewController:vc] animated:YES completion:^{
        
    }];

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

```
## 效果图:
![image](https://github.com/PZXforXcode/PZXCityListController/blob/master/PZXCityListController/cityList.gif) 

