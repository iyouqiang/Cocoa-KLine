//
//  ViewController.m
//  Cocoa-KLine
//
//  Created by Yochi on 2018/7/31.
//  Copyright © 2018年 Yochi. All rights reserved.
//

#import "ViewController.h"
#import "Cocoa_KLine.h"

@interface ViewController ()

@property (nonatomic, strong) NSString *stockCode;
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
    [self getOneDayStockData];
}

#pragma mark - loadData

- (NSArray *)getOneDayStockData
{
    self.stockCode = @"sh603067";
    NSString *requestStr = [NSString stringWithFormat:@"http://web.ifzq.gtimg.cn/appstock/app/fqkline/get?_var=kline_dayqfq&param=%@,day,,,320,qfq&r=0.14639775198884308", self.stockCode];
    NSLog(@"requestStr ： %@", requestStr);
    NSData *data = [NSData dataWithContentsOfURL:[NSURL URLWithString:requestStr]];
    NSStringEncoding enc = CFStringConvertEncodingToNSStringEncoding(kCFStringEncodingGB_18030_2000);
    NSString *str = [[NSString alloc] initWithData:data encoding:enc];
    NSString *regularStr = @"^[^=]*=";
    NSError *error = nil;
    NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:regularStr options:NSRegularExpressionCaseInsensitive error:&error];
    NSArray <NSTextCheckingResult *>*resultArray = [regex matchesInString:str options:0 range:NSMakeRange(0, str.length)];
    NSTextCheckingResult *result = [resultArray firstObject];
    str = [str stringByReplacingOccurrencesOfString:[str substringWithRange:result.range] withString:@""];
    NSDictionary *dict = [NSJSONSerialization JSONObjectWithData:[str dataUsingEncoding:NSUTF8StringEncoding] options:NSJSONReadingMutableContainers error:nil];
    NSArray *array = dict[@"data"][self.stockCode][@"day"];
    if (array == nil || array.count == 0) {
        array = dict[@"data"][self.stockCode][@"qfqday"];
    }
    
    NSMutableArray *modelArray = [NSMutableArray array];
    
    //解析model
    for (int i = 0; i < array.count; i ++) {
        NSArray *tempArr = array[i];
        Cocoa_ChartModel *model = [[Cocoa_ChartModel alloc] init];
        // 对模型进行赋值
        model.open = [tempArr[1] doubleValue]; // 开盘价
        model.close = [tempArr[2] doubleValue];// 收盘价
        model.high = [tempArr[3] doubleValue]; // 最高价
        model.low = [tempArr[4] doubleValue];  // 最低价
        model.volume = [tempArr[5] integerValue]; // 成交量
        model.date = tempArr[0]; // 日期
        [modelArray addObject:model];   // 添加模型到数组
    }
    
    /** 获取了到了股票数据 */
    Cocoa_ChartManager *manager = [[Cocoa_ChartManager alloc] initWithFrame:CGRectMake(0, 64, kSCREENWIDTH, kSCREENWIDTH)];
    [manager.dataArray addObjectsFromArray:modelArray];
    [manager refreshChartView];
    [self.view addSubview:manager];
    
    manager.changeCompleteBlock = ^(id DataInfo) {
        
        NSLog(@"回调当前数据的价格 : %@", DataInfo);
    };
    
    return array;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
