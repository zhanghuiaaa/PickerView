//
//  JMClient.h
//  JMCashierDesk
//
//  Created by 骊蘅 on 2018/1/31.
//  Copyright © 2018年 骊蘅. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "AFNetworking.h"
#define kTimeOutInterval 30  //请求超时时间
@interface JMClient : NSObject
+(JMClient *)shareSingletonClasss;

#pragma mark  Get 请求数据
- (void)GetParsingDataSourceWithUrl:(NSString *)url WithVC:(UIViewController *)VC success:(void(^)(id responseObject))success fail:(void(^)(void))fail;

#pragma mark  post上传数据
- (void)PostParsingDataSourceWithUrl:(NSString *)url parameters:(NSDictionary *)parameters  WithVC:(UIViewController * )VC success:(void(^)(id responseObject))success fail:(void(^)())fail;



#pragma mark 上传图片 Method

- (void)uploadWithUser:(NSString *)userId UrlString:(NSString *)urlString upImg:(UIImage *)upImg success:(void(^)(id responseObject))success fail:(void(^)())fail;



#pragma mark 下载

- (void)downLoadWithUrlString:(NSString * )urlString;



- (NSMutableDictionary * )getWillPOSTData;

- (NSString *)convertToJsonData:(NSDictionary *)dict;

//#pragma mark  GET  请求数据

//- (void)GetParsingDataSoucrceWithUrl:(NSString * )url success:(void(^)(id responseObject))success fail:(void(^)())fail;
@end
