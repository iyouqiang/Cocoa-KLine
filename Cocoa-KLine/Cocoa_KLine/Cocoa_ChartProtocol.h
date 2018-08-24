//
//  Cocoa_ChartProtocol.h
//  Cocoa-KLine
//
//  Created by Yochi on 2018/7/31.
//  Copyright © 2018年 Yochi. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Cocoa_ChartModel.h"
typedef enum
{
    TecnnicalType_VOL = 100,
    TecnnicalType_MACD,
    TecnnicalType_KDJ,
    TecnnicalType_OBV,
    TecnnicalType_WR,
    
}TecnnicalType;

typedef NS_ENUM(NSInteger, StockStyleState){
    StockStateRise = 1,
    StockStateFall
};

static inline bool isEqualZero(float value) {
    
    return fabsf(value) <= 0.00001f;
}

/** 所有指标，遵循次协议 */
@protocol Cocoa_ChartProtocol <NSObject>

/** 数据模型 */
@property (nonatomic,strong) NSMutableArray<__kindof Cocoa_ChartModel*> *dataArray;
/** 数据模型最大值 */
@property (nonatomic, assign) CGFloat maxValue;
/** 数据模型最小值 */
@property (nonatomic, assign) CGFloat minValue;
/** 坐标最大值 */
@property (nonatomic, assign) CGFloat coordinateMaxValue;
/** 坐标最小值 */
@property (nonatomic, assign) CGFloat coordinateminValue;
/** 坐标比例 */
@property (nonatomic, assign) CGFloat scaleValue;
/** 边距 */
@property (nonatomic, assign) UIEdgeInsets padding;

// @synthesize xxx 将@property中定义的属性自动生成get/set的实现方法而且默认访问成员变量xxx

@optional

@property (nonatomic,assign) CGFloat    leftPostion;
@property (nonatomic,assign) NSInteger  startIndex;
@property (nonatomic,assign) NSInteger  displayCount;
@property (nonatomic,assign) CGFloat    candleWidth;
@property (nonatomic,assign) CGFloat    candleSpace;

// 刷新k线界面
- (void)refreshChartView;

// 计算最大最小值
- (void)calcuteMaxAndMinValue;

// 绘制k线
- (void)drawChartView;

// 加载更多数据
- (void)displayMoreData;

// 蜡烛柱，位置，index，带动底部指标
- (void)displayScreenleftPostion:(CGFloat)leftPostion startIndex:(NSInteger)index count:(NSInteger)count;

@end
