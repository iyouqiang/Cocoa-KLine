//
//  Cocoa_ChartModel.h
//  Cocoa-KLine
//
//  Created by Yochi on 2018/8/1.
//  Copyright © 2018年 Yochi. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface Cocoa_ChartModel : NSObject

//-------------------------------
/** 外部必传参数 */
//-------------------------------

// 成交量
@property (nonatomic, assign) double volume;
// 开盘价
@property (nonatomic, assign) double open;
// 收盘价
@property (nonatomic, assign) double close;
// 最高价
@property (nonatomic, assign) double high;
// 最低价
@property (nonatomic, assign) double low;
// 日期时间
@property (nonatomic, copy) NSString *date;

@property (nonatomic, copy) NSString *timestampStr;

//-------------------------------
/** 内部计算参数 */
//-------------------------------

/********************坐标位置******************************/

/** 开盘点 */
@property (nonatomic, assign) CGPoint openPoint;

/** 收盘点 */
@property (nonatomic, assign) CGPoint closePoint;

/** 最高点 */
@property (nonatomic, assign) CGPoint highPoint;

/** 最低点 */
@property (nonatomic, assign) CGPoint lowPoint;

/** 当前k线位置 */
@property (assign, nonatomic) NSInteger localIndex;

/********************k线图均线******************************/
/** 5日均线 */
@property (nonatomic, assign) CGFloat ma5;
/** 10日均线 */
@property (nonatomic, assign) CGFloat ma10;
/** 20日均线 */
@property (nonatomic, assign) CGFloat ma20;

/********************成交量均线******************************/
/** 5日成交量均线 */
@property (nonatomic, assign) CGFloat ma5Volume;

/** 10日成交量均线 */
@property (nonatomic, assign) CGFloat ma10Volume;

/********************MACD值******************************/
@property(assign, nonatomic) CGFloat dea;
@property(assign, nonatomic) CGFloat diff;
@property(assign, nonatomic) CGFloat macd;

/********************KDJ值******************************/
@property(assign, nonatomic) CGFloat KValue;
@property(assign, nonatomic) CGFloat DValue;
@property(assign, nonatomic) CGFloat JValue;

/********************WR值******************************/
@property(assign, nonatomic) CGFloat WRValue;

/********************OBV值******************************/
@property(assign, nonatomic) CGFloat OBVValue;

@end
