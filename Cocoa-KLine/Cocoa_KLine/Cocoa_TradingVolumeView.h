//
//  Cocoa_TradingVolumeView.h
//  Cocoa-KLine
//
//  Created by Yochi on 2018/7/31.
//  Copyright © 2018年 Yochi. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Cocoa_ChartProtocol.h"

@interface Cocoa_TradingVolumeView : UIView<Cocoa_ChartProtocol>

/** 数据模型 */
@property (nonatomic,strong) NSMutableArray<__kindof Cocoa_ChartModel*> *dataArray;

- (void)refreshChartView;

@end
