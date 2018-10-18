//
//  Cocoa_FullScreenController.h
//  PurCowExchange
//
//  Created by Yochi on 2018/8/23.
//  Copyright © 2018年 Yochi. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Cocoa_KLine.h"


@interface Cocoa_FullScreenController : UIViewController

@property (nonatomic, strong) UIView *chartsuperView;

@property (nonatomic, weak) Cocoa_ChartManager *chartManager;

@end
