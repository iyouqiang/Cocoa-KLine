//
//  Cocoa_CandleLineView.h
//  Cocoa-KLine
//
//  Created by Yochi on 2018/7/31.
//  Copyright © 2018年 Yochi. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Cocoa_ChartModel.h"
#import "Cocoa_ChartProtocol.h"

@interface Cocoa_CandleLineView : UIView<Cocoa_ChartProtocol>

/** 当前屏幕范围内显示的k线模型数组 */
@property (nonatomic,strong) NSMutableArray *currentDisplayArray;
@property (nonatomic,assign) NSInteger displayCount;

/** 均线宽度(默认:1.0) **/
@property (nonatomic, assign) CGFloat avgLineWidth;

/** K线宽度(蜡烛实体宽度)(默认:8.0) **/
@property (nonatomic, assign) CGFloat candleWidth;
@property (nonatomic, assign) NSInteger startIndex;

@property (nonatomic, strong) UIColor *candleRiseColor;
@property (nonatomic, strong) UIColor *candleFallColor;

/** 最大宽度(默认:10.0) **/
@property (nonatomic, assign) CGFloat maxCandleWidth;

/** 最小K线宽度(默认:1.0) **/
@property (nonatomic, assign) CGFloat minCandleWidth;

/** 5日均线颜色(默认:白色)  由小到大排列 **/
@property (nonatomic, strong) UIColor *ma1AvgLineColor;

/** 10日均线颜色(默认:黄色) **/
@property (nonatomic, strong) UIColor *ma2AvgLineColor;

/** 20日均线颜色(默认:紫色) **/
@property (nonatomic, strong) UIColor *ma3AvgLineColor;

/** 数据模型 */
@property (nonatomic,strong) NSMutableArray<__kindof Cocoa_ChartModel*> *dataArray;

@property (nonatomic, assign) id<Cocoa_ChartProtocol> delegate;

- (void)pinGesture:(UIPinchGestureRecognizer *)pin;

- (void)refreshChartView;

- (void)removeAllObserver;

@end
