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

@property (nonatomic, strong) Cocoa_ChartManager *chartsView;
@property (nonatomic, assign) NSInteger pageIndex;
@property (nonatomic, strong) NSDateFormatter *formatter;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
    self.view.backgroundColor = COLOR_BACKGROUND;
    _chartsView = [[Cocoa_ChartManager alloc] initWithFrame:CGRectMake(0, 64, kSCREENWIDTH, kSCREENWIDTH)];
    [self.view addSubview:_chartsView];
    _pageIndex = 1;
    [self getOneDayStockData];
}

#pragma mark - loadData

- (NSArray *)getOneDayStockData
{
    long long startValue = [[self timestampToString] longLongValue] - _pageIndex * 15*60*100*1000;
    
    NSString *requestStr = [NSString stringWithFormat:@"https://api.ziniu.io/www/kline/history?resolution=15&start=%@&symbol=XRP_BTC&to=%@", [NSString stringWithFormat:@"%lld",startValue],[self timestampToString]];
    
    NSLog(@"requestStr : %@ index : %ld", requestStr, self.pageIndex);
    
    NSData *data = [NSData dataWithContentsOfURL:[NSURL URLWithString:requestStr]];
    NSStringEncoding enc = CFStringConvertEncodingToNSStringEncoding(kCFStringEncodingGB_18030_2000);
    NSString *str = [[NSString alloc] initWithData:data encoding:enc];
    NSString *regularStr = @"^[^=]*=";
    NSError *error = nil;
    NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:regularStr options:NSRegularExpressionCaseInsensitive error:&error];
    NSArray <NSTextCheckingResult *>*resultArray = [regex matchesInString:str options:0 range:NSMakeRange(0, str.length)];
    NSTextCheckingResult *result = [resultArray firstObject];
    str = [str stringByReplacingOccurrencesOfString:[str substringWithRange:result.range] withString:@""];
    NSArray *klineData = [NSJSONSerialization JSONObjectWithData:[str dataUsingEncoding:NSUTF8StringEncoding] options:NSJSONReadingMutableContainers error:nil];
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [self.chartsView.dataArray removeAllObjects];
        [self assignmentKlineData:klineData isSocketLoading:NO];
    });
    
    /** 获取了到了股票数据 */
    __weak typeof(self) weakself = self;
    self.chartsView.loadmoredataBlock = ^(id DataInfo) {
        __strong typeof (self) self = weakself;
        
        [self getOneDayStockData];
        
    };
    
    return klineData;
}

- (void)assignmentKlineData:(NSArray *)resultData isSocketLoading:(BOOL)isSocketLoading
{
    NSMutableArray *tempArray = [NSMutableArray array];
    
    if ([resultData isKindOfClass:[NSArray class]]) {
        
        NSArray *dataArray = resultData;
        
        for (int i = 0; i <dataArray.count ; i++) {
            
            // %g
            NSArray *singleArray = dataArray[i];
            Cocoa_ChartModel *model = [[Cocoa_ChartModel alloc] init];
            model.volume = [NSDecimalNumber decimalNumberWithString:[NSString stringWithFormat:@"%@",singleArray[1]]].doubleValue;
            model.close  = [NSDecimalNumber decimalNumberWithString:[NSString stringWithFormat:@"%@",singleArray[2]]].doubleValue;
            model.high   = [NSDecimalNumber decimalNumberWithString:[NSString stringWithFormat:@"%@",singleArray[3]]].doubleValue;
            model.low    = [NSDecimalNumber decimalNumberWithString:[NSString stringWithFormat:@"%@",singleArray[4]]].doubleValue;
            model.open   = [NSDecimalNumber decimalNumberWithString:[NSString stringWithFormat:@"%@",singleArray[5]]].doubleValue;
            NSString *timeStr = [NSString stringWithFormat:@"%@", [NSString stringWithFormat:@"%@",singleArray[0]]];
            
            model.volumeStr = [NSString stringWithFormat:@"%@",singleArray[1]];
            model.closeStr  = [NSString stringWithFormat:@"%@",singleArray[2]];
            model.highStr   = [NSString stringWithFormat:@"%@",singleArray[3]];
            model.lowStr    = [NSString stringWithFormat:@"%@",singleArray[4]];
            model.openStr   = [NSString stringWithFormat:@"%@",singleArray[5]];
            
            if ([model.lowStr containsString:@"."]) {
                
                NSArray *decimalArray = [model.lowStr componentsSeparatedByString:@"."];
                NSString *decimalLength = [decimalArray lastObject];
                model.priceaccuracy = decimalLength.length;
            }else {
                model.priceaccuracy = 0;
            }
            
            if ([model.volumeStr containsString:@"."]) {
                
                NSArray *decimalArray = [ model.volumeStr componentsSeparatedByString:@"."];
                NSString *decimalLength = [decimalArray lastObject];
                model.volumaccuracy = decimalLength.length;
            }else {
                model.volumaccuracy = 0;
            }
            
            model.timestampStr = timeStr;
            model.date = [self handelklineDate:timeStr];
            [tempArray addObject:model];
        }
        
        self.pageIndex++;
        
        // 最后更新的k线， 时间戳相同，替换 不同追加
        Cocoa_ChartModel *chartModel = [self.chartsView.dataArray lastObject];
        Cocoa_ChartModel *newModel = [tempArray lastObject];
        
//        if ([chartModel.timestampStr isEqualToString:newModel.timestampStr]) {
//
//            [self.chartsView.dataArray replaceObjectAtIndex:self.chartsView.dataArray.count-1 withObject:newModel];
//        }else {
//
//            [self.chartsView.dataArray addObjectsFromArray:tempArray];
//        }
          [self.chartsView.dataArray addObjectsFromArray:tempArray];
    }
    
    if (isSocketLoading) {
        
        [self.chartsView appendingChartView];
    }else {
        
        [self.chartsView refreshChartView];
    }
}

- (NSString *)handelklineDate:(NSString *)timestamp
{
    NSDate *date   = [NSDate dateWithTimeIntervalSince1970:timestamp.doubleValue/1000];
    
    [self.formatter setDateFormat:@"MM-dd HH:mm"];
    
    return [self.formatter stringFromDate:date];
}

- (NSString *)configureFormat:(NSString *)format date:(NSDate*)date
{
    [self.formatter setDateFormat:format];
    return [self.formatter stringFromDate:date];
}

/** 获取时间戳 */
- (NSString *)timestampToString
{
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init] ;
    
    [formatter setDateStyle:NSDateFormatterMediumStyle];
    
    [formatter setTimeStyle:NSDateFormatterShortStyle];
    
    // ----------设置你想要的格式,hh与HH的区别:分别表示12小时制,24小时制
    [formatter setDateFormat:@"YYYY-MM-dd HH:mm:ss SS"];
    
    //现在时间,你可以输出来看下是什么格式
    NSDate *datenow = [NSDate date];
    
    NSString *timeSp = [NSString stringWithFormat:@"%ld", (long)[datenow timeIntervalSince1970]*1000];
    
    return timeSp;
}

- (NSDateFormatter *)formatter
{
    if (!_formatter) {
        
        _formatter = [[NSDateFormatter alloc] init];
    }
    
    return _formatter;
}


//设置样式
- (UIStatusBarStyle)preferredStatusBarStyle {
    return UIStatusBarStyleLightContent;
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
