//
//  Cocoa_CalculateCoordinate.m
//  Cocoa-KLine
//
//  Created by Yochi on 2018/8/4.
//  Copyright © 2018年 Yochi. All rights reserved.
//

#import "Cocoa_CalculateCoordinate.h"

@implementation Cocoa_CalculateCoordinate

/** 均值计算 */
void computeMAData(NSArray *items,int period)
{
    // 获取收盘价格
    NSMutableArray *arrCls = [[NSMutableArray alloc] init];
    for (NSUInteger index = 0; index < items.count; index++) {
        Cocoa_ChartModel *item = [items objectAtIndex:items.count - 1 - index];
        [arrCls addObject:[NSString stringWithFormat:@"%0.8f",item.close]];
    }
    
    // 转为c数组
    double *inCls = malloc(sizeof(double) * items.count);
    NSArrayToCArray(arrCls, inCls);
    
    int outBegIdx = 0, outNBElement = 0;
    double *outReal = malloc(sizeof(double) * items.count);
    
    // talib函数库，计算算术移动平均线
    TA_RetCode ta_retCode = TA_MA(0,
                                  (int) (items.count - 1),
                                  inCls,
                                  period,
                                  TA_MAType_SMA,
                                  &outBegIdx,
                                  &outNBElement,
                                  outReal);
    
    if (TA_SUCCESS == ta_retCode) {
        
        NSArray *arr = MDCArrayToNSArray(outReal, (int) items.count, outBegIdx, outNBElement, items);

        for (NSInteger index = 0; index < arrCls.count; index++) {
            
            Cocoa_ChartModel *item = [items objectAtIndex:items.count - 1 - index];
            
            if (period == 5) {
                item.ma5 = [arr[index] doubleValue];
            }
            
            if (period == 10) {
                item.ma10 = [arr[index] doubleValue];
            }
            
            if (period == 20) {
                item.ma20 = [arr[index] doubleValue];
            }
        }
    }
}

/** macd 计算 */
void computeMACDData(NSArray *items)
{
    NSMutableArray *arrCls = [[NSMutableArray alloc] init];
    for (NSUInteger index = 0; index < items.count; index++) {
        Cocoa_ChartModel *item = [items objectAtIndex:items.count - 1 - index];
        [arrCls addObject:[NSString stringWithFormat:@"%0.8f",item.close]];
    }
    double *inCls = malloc(sizeof(double) * items.count);
    NSArrayToCArray(arrCls, inCls);
    
    int outBegIdx = 0, outNBElement = 0;
    double *outMACD = malloc(sizeof(double) * items.count);
    double *outMACDSignal = malloc(sizeof(double) * items.count);
    double *outMACDHist = malloc(sizeof(double) * items.count);
    
    TA_RetCode ta_retCode = TA_MACD(0,
                                    (int) (items.count - 1),
                                    inCls,
                                    12,
                                    26,
                                    9,
                                    &outBegIdx,
                                    &outNBElement,
                                    outMACD,
                                    outMACDSignal,
                                    outMACDHist);
    if (TA_SUCCESS == ta_retCode) {
        //  DEA
        NSArray *arrMACDSignal = MACDCArrayToNSArray(outMACDSignal, (int)items.count, outBegIdx, outNBElement, items, MACDParameterDEA);
        //  DIFF
        NSArray *arrMACD = MACDCArrayToNSArray(outMACD, (int)items.count, outBegIdx, outNBElement, items, MACDParameterDIFF);
        //  MACD
        NSArray *arrMACDHist = MACDCArrayToNSArray(outMACDHist, (int)items.count, outBegIdx, outNBElement, items, MACDParameterMACD);
        for (NSInteger index = 0; index < items.count; index++) {
            
            //两倍表示MACD 快线 - 慢线 * 2 macd柱
            Cocoa_ChartModel *item = [items objectAtIndex:items.count - 1 - index];
            if (index == 0 || index == 1) {
                item.dea = 0.0f;
                item.diff = 0.0f;
                item.macd = 0.0f;

            } else{
                
                item.dea = [(NSString *) [arrMACDSignal objectAtIndex:index] doubleValue];
                item.diff = [(NSString *) [arrMACD objectAtIndex:index] doubleValue];
                item.macd = [(NSString *) [arrMACDHist objectAtIndex:index] doubleValue] * 2;
                
            }
        }
    }
    
    freeAndSetNULL(inCls);
    freeAndSetNULL(outMACD);
    freeAndSetNULL(outMACDSignal);
    freeAndSetNULL(outMACDHist);
}

/** kdj计算 */
void computeKDJData(NSArray *items)
{
    NSMutableArray *arrHigval = [[NSMutableArray alloc] init];
    for (NSUInteger index = 0; index < items.count; index++) {
        Cocoa_ChartModel *item = [items objectAtIndex:items.count - 1 - index];
        [arrHigval addObject:[NSString stringWithFormat:@"%0.8f",item.high]];
    }
    double *inHigval = malloc(sizeof(double) * items.count);
    NSArrayToCArray(arrHigval, inHigval);
    
    NSMutableArray *arrLowval = [[NSMutableArray alloc] init];
    for (NSUInteger index = 0; index < items.count; index++) {
        Cocoa_ChartModel *item = [items objectAtIndex:items.count - 1 - index];
        [arrLowval addObject:[NSString stringWithFormat:@"%0.8f",item.low]];
    }
    double *inLowval = malloc(sizeof(double) * items.count);
    NSArrayToCArray(arrLowval, inLowval);
    
    NSMutableArray *arrCls = [[NSMutableArray alloc] init];
    for (NSUInteger index = 0; index < items.count; index++) {
        Cocoa_ChartModel *item = [items objectAtIndex:items.count - 1 - index];
        [arrCls addObject:[NSString stringWithFormat:@"%0.8f",item.close]];
    }
    double *inCls = malloc(sizeof(double) * items.count);
    NSArrayToCArray(arrCls, inCls);
    
    int outBegIdx = 0, outNBElement = 0;
    double *outSlowK = malloc(sizeof(double) * items.count);
    double *outSlowD = malloc(sizeof(double) * items.count);
    
    TA_RetCode ta_retCode = TA_STOCH(0,
                                     (int) (items.count - 1),
                                     inHigval,
                                     inLowval,
                                     inCls,
                                     9,
                                     3,
                                     TA_MAType_EMA,
                                     3,
                                     TA_MAType_EMA,
                                     &outBegIdx,
                                     &outNBElement,
                                     outSlowK,
                                     outSlowD);
    
    /*
     计算公式：rsv =（收盘价– n日内最低价）/（n日内最高价– n日内最低价）×100
     　　K = rsv的m天移动平均值
     　　D = K的m1天的移动平均值
     　　J = 3K - 2D
     　　rsv:未成熟随机值
     */
    
    if (TA_SUCCESS == ta_retCode) {

        for (NSInteger index = 0; index < arrCls.count; index++) {
            Cocoa_ChartModel *item = [items objectAtIndex:items.count - 1 - index];
            
            item.KValue = outSlowK[index - outBegIdx];
            
            item.DValue = outSlowD[index - outBegIdx];
            
            double slowKLine3k2d = 3 *  item.KValue - 2 * item.DValue;
            
            item.JValue = slowKLine3k2d;
        }
    }
    
    freeAndSetNULL(inHigval);
    freeAndSetNULL(inLowval);
    freeAndSetNULL(inCls);
    freeAndSetNULL(outSlowK);
    freeAndSetNULL(outSlowD);
}

/** OBV计算 计算OBV非常简单。当今日收盘价高于昨日收盘价是，今日的成交量为“正值”。而当今日收盘价地域昨日收盘价时，则今日的成交量为“负值”。一连串时间的正负值成交量累积相加，即为OBV值。 */
void computeOBVData(NSArray *items)
{
    NSMutableArray *arrClose = [[NSMutableArray alloc] init];
    for (NSUInteger index = 0; index < items.count; index++) {
        Cocoa_ChartModel *item = [items objectAtIndex:items.count - 1 - index];
        [arrClose addObject:[NSString stringWithFormat:@"%0.8f",item.close]];
    }
    double *inHigval = malloc(sizeof(double) * items.count);
    NSArrayToCArray(arrClose, inHigval);
    
    NSMutableArray *arrVolume = [[NSMutableArray alloc] init];
    for (NSUInteger index = 0; index < items.count; index++) {
        Cocoa_ChartModel *item = [items objectAtIndex:items.count - 1 - index];
        [arrVolume addObject:[NSString stringWithFormat:@"%0.8f",item.volume]];
    }
    double *inVolume = malloc(sizeof(double) * items.count);
    NSArrayToCArray(arrVolume, inVolume);
    
    int outBegIdx = 0, outNBElement = 0;
    double *outReal = malloc(sizeof(double) * items.count);
    TA_RetCode ta_retCode = TA_OBV(0, (int) (items.count - 1), inHigval, inVolume, &outBegIdx, &outNBElement, outReal);
    
    if (TA_SUCCESS == ta_retCode) {
        
        for (NSInteger index = 0; index < arrClose.count; index++) {
            Cocoa_ChartModel *item = [items objectAtIndex:items.count - 1 - index];
            item.OBVValue = outReal[index - outBegIdx];
        }
    }
    
    freeAndSetNULL(inHigval);
    freeAndSetNULL(outReal);
    freeAndSetNULL(inVolume);
}

/** WR计算 */
NSMutableArray *computeWRData(NSArray *items,int period)
{
    NSMutableArray *arrHigval = [[NSMutableArray alloc] init];
    for (NSUInteger index = 0; index < items.count; index++) {
        Cocoa_ChartModel *item = [items objectAtIndex:items.count - 1 - index];
        [arrHigval addObject:[NSString stringWithFormat:@"%0.8f",item.high]];
    }
    double *inHigval = malloc(sizeof(double) * items.count);
    NSArrayToCArray(arrHigval, inHigval);
    
    NSMutableArray *arrLowval = [[NSMutableArray alloc] init];
    for (NSUInteger index = 0; index < items.count; index++) {
        Cocoa_ChartModel *item = [items objectAtIndex:items.count - 1 - index];
        [arrLowval addObject:[NSString stringWithFormat:@"%0.8f",item.low]];
    }
    double *inLowval = malloc(sizeof(double) * items.count);
    NSArrayToCArray(arrLowval, inLowval);
    
    NSMutableArray *arrCls = [[NSMutableArray alloc] init];
    for (NSUInteger index = 0; index < items.count; index++) {
        Cocoa_ChartModel *item = [items objectAtIndex:items.count - 1 - index];
        [arrCls addObject:[NSString stringWithFormat:@"%0.8f",item.close]];
    }
    double *inCls = malloc(sizeof(double) * items.count);
    NSArrayToCArray(arrCls, inCls);
    
    int outBegIdx = 0, outNBElement = 0;
    double *outReal = malloc(sizeof(double) * items.count);
    
    /**
     威廉指标主要是通过分析一段时间内股价最高价、最低价和收盘价之间的关系，
     　　来判断股市的超买超卖现象，预测股价中短期的走势。它主要是利用振荡点来反
     */
    
    TA_RetCode ta_retCode = TA_WILLR(0,
                                     (int) (items.count - 1),
                                     inHigval,
                                     inLowval,
                                     inCls,
                                     period,
                                     &outBegIdx,
                                     &outNBElement,
                                     outReal);
    
    if (TA_SUCCESS == ta_retCode) {
        
        for (NSInteger index = 0; index < arrCls.count; index++) {
            Cocoa_ChartModel *item = [items objectAtIndex:items.count - 1 - index];
            item.WRValue = outReal[index - outBegIdx];
        }
    }
    
    freeAndSetNULL(inHigval);
    freeAndSetNULL(inLowval);
    freeAndSetNULL(inCls);
    freeAndSetNULL(outReal);
    
    return nil;
}

/**********************************************/
void NSArrayToCArray(NSArray *array, double outCArray[])
{
    if (NULL == outCArray)
    {
        return;
    }
    
    NSInteger index = 0;
    for (NSString *str in array)
    {
        outCArray[index] = [str doubleValue];
        index++;
    }
}

NSArray *CArrayToNSArray(const double inCArray[], int length, int outBegIdx, int outNBElement)
{
    if (NULL == inCArray)
    {
        return nil;
    }
    
    NSMutableArray *outNSArray = [[NSMutableArray alloc] initWithCapacity:length];
    
    for (NSInteger index = 0; index < length; index++)
    {
        if (index >= outBegIdx && index < outBegIdx + outNBElement)
        {
            [outNSArray addObject:[NSString stringWithFormat:@"%.8f", inCArray[index - outBegIdx]]];
        } else{
            
            [outNSArray addObject:[NSString stringWithFormat:@"%.8f", 0.0f]];
        }
    }
    return outNSArray;
}

NSArray *MACDCArrayToNSArray(const double inCArray[], int length, int outBegIdx, int outNBElement, NSArray *items, MACDParameter parameter){
    if (NULL == inCArray) {
        return nil;
    }
    
    NSMutableArray *outNSArray = [[NSMutableArray alloc] initWithCapacity:length];
    //  EMA
    CGFloat EMA12Value = 0.0f;
    CGFloat EMA26Value = 0.0f;
    //  DIFF
    CGFloat DIFFValue = 0.0f;
    //  DEA
    CGFloat DEAValue = 0.0f;
    //  MACD
    CGFloat MACDValue = 0.0f;
    
    for (NSInteger index = 0; index < length; index++) {
        if (index >= outBegIdx && index < outBegIdx + outNBElement) {
            [outNSArray addObject:[NSString stringWithFormat:@"%0.8f", inCArray[index - outBegIdx]]];
            if (parameter == MACDParameterMACD) {
            }
            
        } else {
            
            //  当前天数
            NSUInteger nowIndex = length - index - 1;
                        
            //  当前蜡烛图数据
            Cocoa_ChartModel *item = items[nowIndex];
            if (nowIndex <= 0) {
                return nil;
            }
            
            //  前一日数据
            Cocoa_ChartModel *lastItem = items[nowIndex - 1];
            //  第一天
            if (index == 0) {
                [outNSArray addObject:[NSString stringWithFormat:@"%.8f", 0.0f]];
                continue;
            }
            
            //  第二天
            else if (index == 1) {
                [outNSArray addObject:[NSString stringWithFormat:@"%.8f", 0.0f]];
                
                EMA12Value = lastItem.close + (item.close  - lastItem.close ) * 2.0 / 13;
                EMA26Value = lastItem.close  + (item.close  - lastItem.close ) * 2.0 / 27;
                DIFFValue = EMA12Value - EMA26Value;
                DEAValue = DEAValue * 8.0 / 10 + DIFFValue * 2.0 / 10;
                MACDValue = (DIFFValue - DEAValue);
                continue;
            }
            
            else{
                EMA12Value = (EMA12Value * 11.0 / 13 + item.close  * 2.0 / 13);
                EMA26Value = (EMA26Value * 25.0 / 27 + item.close  * 2.0 / 27);
                DIFFValue = EMA12Value - EMA26Value;
                DEAValue = DEAValue * 8.0 / 10 + DIFFValue * 2.0 / 10;
                MACDValue = (DIFFValue - DEAValue);
            }
            
            switch (parameter) {
                case MACDParameterMACD:
                    [outNSArray addObject:[NSString stringWithFormat:@"%.8f",MACDValue]];
                    break;
                case MACDParameterDIFF:
                    [outNSArray addObject:[NSString stringWithFormat:@"%.8f",DIFFValue]];
                    break;
                case MACDParameterDEA:
                    [outNSArray addObject:[NSString stringWithFormat:@"%.8f",DEAValue]];
                    break;
                default:
                    [outNSArray addObject:[NSString stringWithFormat:@"%.8f", 0.0f]];
                    break;
            }
        }
    }
    return outNSArray;
}

NSArray *MDCArrayToNSArray(const double inCArray[], int length, int outBegIdx, int outNBElement, NSArray *items){
    if (NULL == inCArray) {
        return nil;
    }
    NSMutableArray *outNSArray = [[NSMutableArray alloc] initWithCapacity:length];
    for (NSInteger index = 0; index < length; index++) {
        if (index >= outBegIdx && index < outBegIdx + outNBElement) {
            
            [outNSArray addObject:[NSString stringWithFormat:@"%0.8f", inCArray[index - outBegIdx]]];
        } else {
            //  当前天数
            NSUInteger nowIndex = length - index - 1;
            //  当前蜡烛图数据
            Cocoa_ChartModel *item = items[nowIndex];
            //  添加5,10,20均线下md5数据
            if (index == 0) {
                [outNSArray addObject:[NSString stringWithFormat:@"%.8f",item.close]];
            }
            else{
                [outNSArray addObject:[NSString stringWithFormat:@"%.8f",customComputeMA(items, index + 1)]];
            }
        }
    }
    return outNSArray;
}

CGFloat customComputeMA(NSArray *items, NSInteger days)
{
    CGFloat totalPrice = 0.0;
    for (int i = 0; i < days; i ++ ) {
        Cocoa_ChartModel *item = items[items.count - i - 1];
        totalPrice = totalPrice + item.close;
    }
    return totalPrice/days;
}

void freeAndSetNULL(void *ptr) {
    free(ptr);
    ptr = NULL;
}


@end
