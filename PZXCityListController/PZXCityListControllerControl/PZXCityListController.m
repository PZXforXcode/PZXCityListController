//
//  PZXCityListController.m
//  PZXCityListController
//
//  Created by 彭祖鑫 on 2017/1/16.
//  Copyright © 2017年 PZX. All rights reserved.
//

//header背景色
#define headerBackgroundColor [UIColor lightGrayColor]
//header文字颜色
#define headerTextColor [UIColor whiteColor]
//右边首字母检索颜色
#define indexColor [UIColor orangeColor]
//城市文字颜色
#define cityTextColor [UIColor blackColor]



#import "PZXCityListController.h"
#import <CoreLocation/CoreLocation.h>


@interface PZXCityListController ()<UITableViewDelegate,UITableViewDataSource,UISearchBarDelegate,CLLocationManagerDelegate>

@property(nonatomic,strong)NSArray *allList;

@property(nonatomic,strong)NSMutableArray *titleList;

@property(nonatomic,strong)NSMutableArray *justAllCity;//所有城市的数组，用于搜索
@property(nonatomic,strong)NSMutableArray *searchArr;//搜索数组
@property(nonatomic, assign) BOOL isSearch;//是否是搜索状态
@property(nonatomic, assign) BOOL isLocation;//是否是定位

@property (nonatomic, strong) NSMutableArray *hotCityData;
@property (nonatomic, strong) NSDictionary *lastTimeCity;
@property (nonatomic, strong) NSDictionary *locationCity;


@property (nonatomic, strong) UISearchBar *searchBar;
@property(nonatomic,retain)CLLocationManager *locationManager;

@property (nonatomic,strong)UILabel *locationLabel;
@property (nonatomic,strong)UIView *headerView;
@property (nonatomic,strong)UIView *helpView;


@end

@implementation PZXCityListController

- (void)viewDidLoad {
    [super viewDidLoad];
    _isLocation = NO;
    [self locationStart];
    UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
    [button setTitle:@"取消" forState:UIControlStateNormal];
    button.frame = CGRectMake(0, 0, 40, 40);
    [button.titleLabel setFont:[UIFont systemFontOfSize:14.f]];
    [button addTarget:self action:@selector(leftButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
    
    UIBarButtonItem *leftButton = [[UIBarButtonItem alloc]initWithCustomView:button];
    
    self.navigationItem.leftBarButtonItem = leftButton;
    
    self.isSearch = NO;
    
    
    NSArray *array = [NSArray arrayWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"CityData" ofType:@"plist"]];
    _allList  = [NSArray arrayWithArray:array];
    _titleList = [NSMutableArray array];
    _searchArr = [NSMutableArray array];
    _lastTimeCity = [NSDictionary dictionary];
    _locationCity = [NSDictionary dictionary];
    _justAllCity = [NSMutableArray arrayWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"justCityList" ofType:@"plist"]];
    _hotCityArr = [@[@"100010000", @"200010000",@"900010000", @"300210000", @"600010000", @"300110000"] mutableCopy];
    _hotCityData = [NSMutableArray array];
    
    [self loadLastCity];
    [self getHotCityData];
    [self getTitleList];
    

    self.tableView.delegate =self;
    [self.tableView registerClass:[UITableViewCell class] forCellReuseIdentifier:@"cityCell"];
    self.tableView.sectionIndexColor = indexColor;
    
    UIView *headerView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, 180.f)];
    _headerView = headerView;
    _helpView = [[UIView alloc]initWithFrame:CGRectMake(0, 44.f, self.view.frame.size.width, 136.f)];
    
    self.searchBar = [[UISearchBar alloc]initWithFrame:CGRectMake(0, 0, self.view.frame.size.width-25, 44.0f)];
    //    self.searchBar.barStyle     = UIBarStyleDefault;
    self.searchBar.translucent  = YES;
    self.searchBar.delegate     = self;
    self.searchBar.placeholder  = @"请输入城市名称或拼音";
    self.searchBar.keyboardType = UIKeyboardTypeDefault;
    [self.searchBar setBarTintColor:[UIColor colorWithWhite:0.95 alpha:1.0]];
    [self.searchBar.layer setBorderWidth:0.5f];
    [self.searchBar.layer setBorderColor:[UIColor colorWithWhite:0.7 alpha:1.0].CGColor];
    
    
    
    
    UIView *FWheader =[[UIView alloc]initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, 24)];
    FWheader.backgroundColor = headerBackgroundColor;
    UILabel *FWlabel = [[UILabel alloc]initWithFrame: CGRectMake(10, 0, 100, 24.f)];
    FWlabel.text = [NSString stringWithFormat:@"最近访问"];
    FWlabel.textColor = headerTextColor;
    [FWheader addSubview:FWlabel];
    
    UIView *DWheader =[[UIView alloc]initWithFrame:CGRectMake(0, 68.f, self.view.frame.size.width, 24)];
    DWheader.backgroundColor = headerBackgroundColor;
    UILabel *DWlabel = [[UILabel alloc]initWithFrame: CGRectMake(10, 0, 100, 24.f)];
    DWlabel.text = [NSString stringWithFormat:@"定位城市"];
    DWlabel.textColor = headerTextColor;
    [DWheader addSubview:DWlabel];
    
    UIView *locationView = [[UIView alloc]initWithFrame:CGRectMake(0, 92.f, self.view.frame.size.width, 44.f)];

    UILabel *locanLabel = [[UILabel alloc]initWithFrame:CGRectMake(16, 0, 200, 44.f)];
    if (_isLocation) {
        
        locanLabel.text = _locationCity[@"city_name"];
    }else{
    locanLabel.text = @"正在定位...";
   
    }
    
    _locationLabel = locanLabel;
    [locationView addSubview:locanLabel];
    
    UITapGestureRecognizer *locationTap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(locationTap:)];
    [locationView addGestureRecognizer:locationTap];
    
    UIView *lastView = [[UIView alloc]initWithFrame:CGRectMake(0, 24.f, self.view.frame.size.width, 44.f)];
    UILabel *cityLabel = [[UILabel alloc]initWithFrame:CGRectMake(16, 0, 200, 44.f)];
    if ([self loadLastCity] && [self loadLastCity] != nil && ![[self loadLastCity] isKindOfClass:[NSNull class]]) {
        
        cityLabel.text = [self loadLastCity][@"city_name"];

    }else{
        
        cityLabel.text = @"暂无最近访问";
    }
    [lastView addSubview:cityLabel];
    
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(viewTaped:)];
    [lastView addGestureRecognizer:tap];
    
    [_helpView addSubview:lastView];
    [_helpView addSubview:locationView];
    [_helpView addSubview:FWheader];
    [_helpView addSubview:DWheader];
    [_headerView addSubview:_helpView];
    [_headerView addSubview:self.searchBar];
    
    [self.tableView setTableHeaderView:_headerView];
    
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
#warning Incomplete implementation, return the number of sections
    if (self.isSearch) {
        return 1;
    }
    return _allList.count+1;
//    return _allList.count;

}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
#warning Incomplete implementation, return the number of rows
    if (self.isSearch) {
        return self.searchArr.count;
    }
    if (section <1) {
        
        return _hotCityData.count;
    
    }
//    return [_allList[section][@"citys"] count];
    return [_allList[section-1][@"citys"] count];

}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (self.isSearch) {
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cityCell"];
        [cell.textLabel setText:_searchArr[indexPath.row][@"city_name"]];
        [cell.textLabel setTextColor:cityTextColor];
        return cell;
    }
    if (indexPath.section < 1) {
            UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cityCell" forIndexPath:indexPath];
        
        cell.textLabel.text = [NSString stringWithFormat:@"%@",_hotCityData[indexPath.row][@"city_name"]];
        [cell.textLabel setTextColor:cityTextColor];

        return cell;
    }
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cityCell" forIndexPath:indexPath];
    
    cell.textLabel.text = [NSString stringWithFormat:@"%@",_allList[indexPath.section-1][@"citys"][indexPath.row][@"city_name"]];
    [cell.textLabel setTextColor:cityTextColor];

    
    return cell;
}

-(UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section{
    if (self.isSearch) {
        return nil;
    }
    UIView *view =[[UIView alloc]initWithFrame:CGRectMake(0, 0, self.tableView.frame.size.width, 24)];
    view.backgroundColor = headerBackgroundColor;
    UILabel *label = [[UILabel alloc]initWithFrame: CGRectMake(10, 0, 100, 24.f)];
    if (section <1) {
        label.text = @"热门城市";

    }else{
    label.text = [NSString stringWithFormat:@"%@",_allList[section-1][@"initial"]];
    }
    label.textColor = headerTextColor;
    [view addSubview:label];
    
    return view;
    
    
}
-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    
    return 24.f;
}

-(void)viewTaped:(UITapGestureRecognizer *)sender{
    
    if (_delegate && [_delegate respondsToSelector:@selector(cityListController:didSelectCity:)]) {
        [self.delegate cityListController:self didSelectCity:[self loadLastCity]];
    }
    

}
-(void)locationTap:(UITapGestureRecognizer *)sener{


    if (_isLocation) {
    
        if (_delegate && [_delegate respondsToSelector:@selector(cityListController:didSelectCity:)]) {
            [self.delegate cityListController:self didSelectCity:_locationCity];
            
            [self writeLastCityToFileWithDic:_locationCity];
        }
        
    }else{
        
        [self locationStart];
        
    
    }
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    if (self.isSearch) {
        [self.view endEditing:YES];
        if (_delegate && [_delegate respondsToSelector:@selector(cityListController:didSelectCity:)]) {
            [self.delegate cityListController:self didSelectCity:_searchArr[indexPath.row]];
            
            [self writeLastCityToFileWithDic:_searchArr[indexPath.row]];
        }
        
    }else{
        if (_delegate && [_delegate respondsToSelector:@selector(cityListController:didSelectCity:)]) {
            
            if (indexPath.section <1) {
                [self.delegate cityListController:self didSelectCity:_hotCityData[indexPath.row]];
                [self writeLastCityToFileWithDic:_hotCityData[indexPath.row]];

                
            }else{
            [self.delegate cityListController:self didSelectCity:_allList[indexPath.section-1][@"citys"][indexPath.row]];
            
                
                [self writeLastCityToFileWithDic:_allList[indexPath.section-1][@"citys"][indexPath.row]];
            }
            }
    }
    
    
}

-(NSArray<NSString *> *)sectionIndexTitlesForTableView:(UITableView *)tableView{
    
    if (self.isSearch) {
        return nil;
    }
    return _titleList;
    
}
-(void)leftButtonPressed:(UIButton *)sender{
    
    if (_delegate && [_delegate respondsToSelector:@selector(cancelButtonPressed:)]) {
        [self.delegate cancelButtonPressed:self];
    }
}
#pragma mark searchBarDelegete
-(void)searchBarTextDidBeginEditing:(UISearchBar *)searchBar{
    
    [searchBar setShowsCancelButton:YES animated:YES];
    UIButton *btn=[searchBar valueForKey:@"_cancelButton"];
    [btn setTitle:@"取消" forState:UIControlStateNormal];
    [btn.titleLabel setFont:[UIFont systemFontOfSize:16.0f]];
    
}

- (void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText
{
    [_searchArr removeAllObjects];
    
    if (searchText.length == 0) {
        self.isSearch = NO;
        _headerView.frame = CGRectMake(0, 0, self.view.frame.size.width,180.f);
        _helpView.hidden = NO;
    }else{
        self.isSearch = YES;
        _headerView.frame = CGRectMake(0, 0, self.view.frame.size.width, 44.f);
        _helpView.hidden = YES;

        for (NSDictionary *dic in _justAllCity) {
            
            NSRange chinese = [dic[@"city_name"] rangeOfString:searchText options:NSCaseInsensitiveSearch];
            NSRange letters = [dic[@"pinyin"] rangeOfString:searchText options:NSCaseInsensitiveSearch];
            NSRange initials = [dic[@"initials"] rangeOfString:searchText options:NSCaseInsensitiveSearch];
            
            if (chinese.location != NSNotFound || letters.location != NSNotFound || initials.location != NSNotFound) {
                [_searchArr addObject:dic];
            }
            
        }
    }
    
    
    
    [self.tableView reloadData];
}
-(void)searchBarSearchButtonClicked:(UISearchBar *)searchBar{

   [searchBar resignFirstResponder];
}
-(void)searchBarCancelButtonClicked:(UISearchBar *)searchBar{
    [searchBar setShowsCancelButton:NO animated:YES];
    searchBar.text=@"";
    [searchBar resignFirstResponder];
        self.isSearch = NO;
    _headerView.frame = CGRectMake(0, 0, self.view.frame.size.width,180.f);
    _helpView.hidden = NO;
    [self.tableView reloadData];
}


-(void)getHotCityData{
    
    for (NSString *cityID in _hotCityArr) {
        
        for (NSDictionary *dic in _justAllCity) {
            
            if ([dic[@"city_key"] isEqualToString:cityID]) {
                
                [_hotCityData addObject:dic];
                
            }else{
            

            }
        }
        
    }


}
-(void)getTitleList{
    [_titleList addObject:@"热门"];
    
    for (NSDictionary *dic in _allList) {
        
        [_titleList addObject:dic[@"initial"]];
    }

}

-(void)writeLastCityToFileWithDic:(NSDictionary *)dic{
    //获取应用程序沙盒的Documents目录
    NSArray *paths=NSSearchPathForDirectoriesInDomains(NSDocumentDirectory,NSUserDomainMask,YES);
    NSString *plistPath = [paths objectAtIndex:0];
    //得到完整的文件名
    NSString *filename=[plistPath stringByAppendingPathComponent:@"LastCity.plist"];
    [dic writeToFile:filename atomically:YES];
    

}
-( NSDictionary *)loadLastCity{

    NSArray *paths=NSSearchPathForDirectoriesInDomains(NSDocumentDirectory,NSUserDomainMask,YES);
    NSString *plistPath = [paths objectAtIndex:0];
    
    NSString *path = [plistPath stringByAppendingPathComponent:@"LastCity.plist"];
    NSDictionary *data = [[NSDictionary alloc] initWithContentsOfFile:path];
    
    return data;
    
}

//开始定位
-(void)locationStart{
    //判断定位操作是否被允许
    
    if([CLLocationManager locationServicesEnabled]) {
        self.locationManager = [[CLLocationManager alloc] init] ;
        self.locationManager.delegate = self;
        //设置定位精度
        self.locationManager.desiredAccuracy=kCLLocationAccuracyBest;
        self.locationManager.distanceFilter = kCLLocationAccuracyHundredMeters;//每隔多少米定位一次（这里的设置为每隔百米)
        if ([[[UIDevice currentDevice] systemVersion]floatValue]>=8.0) {
            //使用应用程序期间允许访问位置数据
            [self.locationManager requestWhenInUseAuthorization];
        }
        // 开始定位
        [self.locationManager startUpdatingLocation];
    }else {
        //提示用户无法进行定位操作
        NSLog(@"%@",@"定位服务当前可能尚未打开，请设置打开！");
        
    }
}

#pragma mark - CoreLocation Delegate

-(void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray *)locations

{
    _locationLabel.text = @"正在定位...";
    //系统会一直更新数据，直到选择停止更新，因为我们只需要获得一次经纬度即可，所以获取之后就停止更新
    [self.locationManager stopUpdatingLocation];
    //此处locations存储了持续更新的位置坐标值，取最后一个值为最新位置，如果不想让其持续更新位置，则在此方法中获取到一个值之后让locationManager stopUpdatingLocation
    CLLocation *currentLocation = [locations lastObject];
    
    //获取当前所在的城市名
    CLGeocoder *geocoder = [[CLGeocoder alloc] init];
    //根据经纬度反向地理编译出地址信息
    [geocoder reverseGeocodeLocation:currentLocation completionHandler:^(NSArray *array, NSError *error)
     {
         
         
         if (array.count >0)
         {
             CLPlacemark *placemark = [array objectAtIndex:0];
             //获取城市
             NSString *currCity = placemark.locality;
             NSLog(@"%@",currCity);
             if (!currCity) {
                 //四大直辖市的城市信息无法通过locality获得，只能通过获取省份的方法来获得（如果city为空，则可知为直辖市）
                 currCity = placemark.administrativeArea;

             }
             
             
             for (NSDictionary *dic in _justAllCity) {
                 
                 if ([dic[@"city_name"] isEqualToString:currCity]) {
                     
                     _isLocation = YES;
                     _locationCity = dic;
                     _locationLabel.text = dic[@"city_name"];

                     
                 }
             }
             
//             if (self.localCityData.count <= 0) {
//                 GYZCity *city = [[GYZCity alloc] init];
//                 city.cityName = currCity;
//                 city.shortName = currCity;
//                 [self.localCityData addObject:city];
//                 [self.tableView reloadData];
//             }
             
             
             
             
             
         } else if (error ==nil && [array count] == 0)
         {
             NSLog(@"No results were returned.");
             
             _isLocation = NO;
             _locationLabel.text = @"定位失败,点击重新定位";
         }else if (error !=nil)
         {
             
             NSLog(@"An error occurred = %@", error);
             _isLocation = NO;
             _locationLabel.text = @"定位失败,点击重新定位";

         }
         
     }];

}
- (void)locationManager:(CLLocationManager *)manager
       didFailWithError:(NSError *)error {
    if (error.code ==kCLErrorDenied) {
        // 提示用户出错原因，可按住Option键点击 KCLErrorDenied的查看更多出错信息，可打印error.code值查找原因所在
    }
    _locationLabel.text = @"定位失败,点击重新定位";

    
}
@end
