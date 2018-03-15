//
//  PickerView.m
//  PickerView
//
//  Created by 骊蘅 on 2018/3/13.
//  Copyright © 2018年 ZYH. All rights reserved.
//

#import "PickerView.h"
#import "JMClient.h"
static NSString * const JMHost =  @"http://120.55.60.249:8888";//测试环境
static NSString * const JMRegionList = @"/area/regionList";// 大区列表查询
static NSString * const JMSonAreaInfoList = @"/area/sonAreaInfoList";// 子地区列表查询
@interface PickerView()<UIPickerViewDelegate,UIPickerViewDataSource>
@property (nonatomic, strong) UIPickerView * pickView;
@property (nonatomic, assign) CGFloat pickerViewHeight;
@property (nonatomic, strong) NSMutableArray *areaArr; // 省列表
@property (nonatomic, strong) NSMutableArray *cityArr; // 市列表
@property (nonatomic, strong) NSMutableArray *quArr; // 区列表
@property (nonatomic, strong) NSArray *nameArray;
@property (nonatomic, copy) NSString * cityCode;// 市级code
@property (nonatomic, copy) NSString * regionCode; //区
@property (nonatomic, copy) NSString * provinceCode;// 省

@property (nonatomic, copy) NSString * cityStr;// 市
@property (nonatomic, copy) NSString * regionStr; //区
@property (nonatomic, copy) NSString * provinceStr;// 省

@property (assign, nonatomic) NSInteger integer;
@end
@implementation PickerView


- (instancetype)initWithFrame:(CGRect)frame{
    if (self = [super initWithFrame:frame]) {
        
        
        
        [self initUI];
        [self setUI];
    }
    return self;
    
}
#pragma mark - 弹出视图方法
- (void)showWithAnimation:(BOOL)animation {
    //1. 获取当前应用的主窗口
    UIWindow *keyWindow = [[UIApplication sharedApplication] keyWindow];
    [keyWindow addSubview:self];
    if (animation) {
        // 动画前初始位置
        CGRect rect = self.alertView.frame;
        rect.origin.y = SCREEN_HEIGHT;
        self.alertView.frame = rect;
        
        // 浮现动画
        [UIView animateWithDuration:0.3 animations:^{
            CGRect rect = self.alertView.frame;
            rect.origin.y -= kDatePicHeight + kTopViewHeight;
            self.alertView.frame = rect;
        }];
    }
}

#pragma mark - 关闭视图方法
- (void)dismissWithAnimation:(BOOL)animation {
    // 关闭动画
    [UIView animateWithDuration:0.2 animations:^{
        CGRect rect = self.alertView.frame;
        rect.origin.y += kDatePicHeight + kTopViewHeight;
        self.alertView.frame = rect;
        
        self.backgroundView.alpha = 0;
    } completion:^(BOOL finished) {
        [self.leftBtn removeFromSuperview];
        [self.rightBtn removeFromSuperview];
        [self.titleLabel removeFromSuperview];
        [self.lineView removeFromSuperview];
        [self.topView removeFromSuperview];
        [self.pickView removeFromSuperview];
        [self.alertView removeFromSuperview];
        [self.backgroundView removeFromSuperview];
        [self removeFromSuperview];
        
        self.leftBtn = nil;
        self.rightBtn = nil;
        self.titleLabel = nil;
        self.lineView = nil;
        self.topView = nil;
        self.pickView = nil;
        self.alertView = nil;
        self.backgroundView = nil;
    }];
}

#pragma mark - 取消按钮的点击事件
- (void)clickLeftBtn {
    [self dismissWithAnimation:YES];
}

#pragma mark - 确定按钮的点击事件
- (void)clickRightBtn {
    
    
    // 获得第一列选中值
    NSInteger selectedHeightIndex = [self.pickView selectedRowInComponent:0];
    self.provinceStr = [self.areaArr objectAtIndex:selectedHeightIndex][@"areaName"];
    self.provinceCode = [self.areaArr objectAtIndex:selectedHeightIndex][@"areaCode"];
    // 获得第二列选中值
    NSInteger selectedHeightIndex1 = [self.pickView selectedRowInComponent:1];
    self.cityStr = [self.cityArr objectAtIndex:selectedHeightIndex1][@"areaName"];
    self.cityCode = [self.cityArr objectAtIndex:selectedHeightIndex1][@"areaCode"];
    // 获得第三列选中值
    //判断是否是直辖市 直辖市没有第三级。防止崩溃
    if (self.quArr.count > 0) {
        NSInteger selectedHeightIndex2 = [self.pickView selectedRowInComponent:2];
        self.regionStr = [self.quArr objectAtIndex:selectedHeightIndex2][@"areaName"];
        self.regionCode = [self.quArr objectAtIndex:selectedHeightIndex2][@"areaCode"];
    }

    [self dismissWithAnimation:YES];
  
}

- (void)setUI{
    
    
    [self requestSonAreaInfoListData];
    self.areaArr = [NSMutableArray array];
    self.cityArr = [NSMutableArray array];
    self.quArr   = [NSMutableArray array];
    self.provinceCode = @"";
    self.cityCode = @"";
    self.integer = 0;
    
    self.pickerViewHeight = 224.0f;
    
    UIPickerView * pickView = [[UIPickerView alloc] initWithFrame:CGRectMake(0, kTopViewHeight + 0.5, SCREEN_WIDTH, kDatePicHeight)];
    pickView.dataSource = self;
    pickView.delegate = self;
    self.pickView = pickView;
    
    [self showWithAnimation:YES];
    [self.alertView addSubview:pickView];
    
    
    
}
#pragma mark pickerview function

// 返回几列
- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView{
    return 3;
    
}

// 返回指定列的行数
- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component{

    if (component == 0) {
        return self.areaArr.count;
    }else if (component == 1){
        
        return self.cityArr.count;
    }else{
        return self.quArr.count;
    }
    
}

//被选择的行
- (void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component{
    
    switch (component) {
        case 0:
            if (self.areaArr.count > 0) {
                // 省级地区码
                self.provinceCode = self.areaArr[row][@"areaCode"];
                self.provinceStr = self.areaArr[row][@"areaName"];

            }
            //**** 刷新市
            [self requestCityInfoListData:row];
            break;
        case 1:
            
            if (self.cityArr.count > 0) {
                // 市级地区码
                self.cityCode = self.cityArr[row][@"areaCode"];
                self.cityStr  = self.cityArr[row][@"areaName"];

            }
            //**** 刷新区
            [self requestDistrictInfoListData:row];
            break;
        case 2:
            if (self.quArr.count> 0) {
                // 市级地区码
                self.regionCode = self.quArr[row][@"areaCode"];
                self.regionStr = self.quArr[row][@"areaName"];
                
            }
            break;
        default:
            break;
    }
}
//建瓯市
// 自定义指定列的每行的视图，即指定列的每行的视图行为一致
- (UIView *)pickerView:(UIPickerView *)pickerView viewForRow:(NSInteger)row forComponent:(NSInteger)component reusingView:(UIView *)view{
    
    if (!view){
        
        view = [[UIView alloc]init];
        
    }
    
    UILabel *text = [[UILabel alloc]initWithFrame:CGRectMake(0, 0, self.frame.size.width/3, 20)];
    
    text.textAlignment = NSTextAlignmentCenter;
    
    if (component == 0) {
        text.text = _areaArr[row][@"areaFullname"];

    }else if (component == 1){
        
        text.text = _cityArr[row][@"areaName"];

    }else{
        text.text = _quArr[row][@"areaName"];

    }
    [view addSubview:text];
    
    return view;
    
}
#pragma mark - requestRegionData

#pragma mark - SonAreaInfoList

// 请求省
- (void)requestSonAreaInfoListData{
    
    JMClient * request = [[JMClient alloc] init];
    
    NSString *url = [NSString stringWithFormat:@"%@%@",JMHost,JMSonAreaInfoList];
    
    NSDictionary* parametersDic = @{
                                    @"parentAreaCode":@"003224"
                                    };
    
    [request PostParsingDataSourceWithUrl:url parameters:parametersDic WithVC:self success:^(id responseObject) {
        
        NSLog(@"JMSonAreaInfoList JMSonAreaInfoList  %@",responseObject);
        NSString * success = [NSString stringWithFormat:@"%@",responseObject[@"success"]];
        if ([success isEqualToString:@"1"]) {
            
            NSArray * list = responseObject[@"list"];
            [self.areaArr removeAllObjects];
            if ([list isKindOfClass:[NSArray class]]) {
                [self.areaArr addObjectsFromArray:responseObject[@"list"]];
            }
            
             [self.pickView reloadAllComponents];//刷新UIPickerView
            [self requestCityInfoListData:0];
        }else{
            
            NSLog(@"失败原因%@",responseObject[@"errorMsg"]);
            
        }
        
    } fail:^{
        
        
    }];
    
    
}
// 请求市
- (void)requestCityInfoListData:(NSInteger )row{
    
    JMClient * request = [[JMClient alloc] init];
    
    NSString *url = [NSString stringWithFormat:@"%@%@",JMHost,JMSonAreaInfoList];
   
    self.provinceCode = self.areaArr[row][@"areaCode"];
    
    NSDictionary* parametersDic = @{
                                    @"parentAreaCode":self.provinceCode
                                    };
    
    [request PostParsingDataSourceWithUrl:url parameters:parametersDic WithVC:self success:^(id responseObject) {
        
        NSString * success = [NSString stringWithFormat:@"%@",responseObject[@"success"]];
        if ([success isEqualToString:@"1"]) {
            NSArray * list = responseObject[@"list"];
            
            [self.cityArr removeAllObjects];
            if ([list isKindOfClass:[NSArray class]]) {
                [self.cityArr addObjectsFromArray:responseObject[@"list"]];
            }
            //刷新UIPickerView
            [self.pickView reloadAllComponents];
            [self requestDistrictInfoListData:row];
     
        }else{
            
            NSLog(@"失败原因%@",responseObject[@"errorMsg"]);
            
        }
        
    } fail:^{
        
        
    }];

}
// 请求区
- (void)requestDistrictInfoListData:(NSInteger )row{

    JMClient * request = [[JMClient alloc] init];
    
    NSString *url = [NSString stringWithFormat:@"%@%@",JMHost,JMSonAreaInfoList];
    
     NSLog(@"cityArr self.cityArr  %@",self.cityArr);
    

    self.cityCode = self.cityArr[row][@"areaCode"];

 
    NSLog(@"self.cityCode self.cityCode******  %@",self.cityCode);
    NSDictionary* parametersDic = @{
                                    @"parentAreaCode":self.cityCode
                                    };
    
    [request PostParsingDataSourceWithUrl:url parameters:parametersDic WithVC:self success:^(id responseObject) {
        
        NSString * success = [NSString stringWithFormat:@"%@",responseObject[@"success"]];
        if ([success isEqualToString:@"1"]) {
            
            
            NSLog(@")))))))  %@",responseObject);
            NSArray * list = responseObject[@"list"];
            
            [self.quArr removeAllObjects];
            if ([list isKindOfClass:[NSArray class]]) {
                
                [self.quArr addObjectsFromArray:responseObject[@"list"]];
            }
            
            
            //刷新UIPickerView
            [self.pickView reloadAllComponents];
            
        }else{
            NSLog(@"失败原因%@",responseObject[@"errorMsg"]);
            
        }
        
    } fail:^{
        
        
    }];
    
}



@end
