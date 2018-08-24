//
//  Cocoa_CalculateCoordinate.h
//  Cocoa-KLine
//
//  Created by Yochi on 2018/8/4.
//  Copyright © 2018年 Yochi. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ta_libc.h"
#import "Cocoa_ChartModel.h"

typedef NS_ENUM(NSUInteger, MACDParameter) {
    MACDParameterDIFF,
    MACDParameterMACD,
    MACDParameterDEA,
};

@interface Cocoa_CalculateCoordinate : NSObject

/** 均值计算 */
void computeMAData(NSArray *items,int period);

/** macd 计算 */
void computeMACDData(NSArray *items);

/** kdj计算 */
void computeKDJData(NSArray *items);

/** WR计算 */
NSMutableArray *computeWRData(NSArray *items,int period);

/** OBV计算 */
void computeOBVData(NSArray *items);

/** ... */

/** iOS 转 c数组 */
void NSArrayToCArray(NSArray *array, double outCArray[]);

/** c数组转iOS数组 */
NSArray *CArrayToNSArray(const double inCArray[], int length, int outBegIdx, int outNBElement);

//  MACD类型
NSArray *MACDCArrayToNSArray(const double inCArray[], int length, int outBegIdx, int outNBElement, NSArray *items, MACDParameter parameter);

NSArray *MDCArrayToNSArray(const double inCArray[], int length, int outBegIdx, int outNBElement, NSArray *items);

void freeAndSetNULL(void *ptr);

CGFloat customComputeMA(NSArray *items, NSInteger days);

@end
