//
//  Cocoa_KDJView.h
//  PurCowExchange
//
//  Created by Yochi on 2018/8/21.
//  Copyright © 2018年 Yochi. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Cocoa_ChartProtocol.h"
@interface Cocoa_KDJView : UIView<Cocoa_ChartProtocol>

/** 数据模型 */
@property (nonatomic,strong) NSMutableArray<__kindof Cocoa_ChartModel*> *dataArray;

@end
