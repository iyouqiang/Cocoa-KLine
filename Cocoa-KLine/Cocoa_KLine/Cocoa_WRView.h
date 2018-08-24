//
//  Cocoa_WRView.h
//  PurCowExchange
//
//  Created by Yochi on 2018/8/22.
//  Copyright © 2018年 Yochi. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Cocoa_ChartProtocol.h"

@interface Cocoa_WRView : UIView<Cocoa_ChartProtocol>

@property (nonatomic,strong) NSMutableArray <__kindof Cocoa_ChartModel*>*dataArray;

- (void)refreshChartView;

@end
