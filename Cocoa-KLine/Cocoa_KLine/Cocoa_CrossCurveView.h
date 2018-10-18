//
//  Cocoa_CrossCurveView.h
//  Cocoa-KLine
//
//  Created by Yochi on 2018/8/4.
//  Copyright © 2018年 Yochi. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Cocoa_ChartModel.h"
#import "Cocoa_ChartStylesheet.h"
@interface Cocoa_CrossCurveView : UIView

@property (nonatomic, assign) CGPoint touchPoint;
@property (nonatomic, strong) UIColor *crossLineColor;
@property (nonatomic, assign) UIEdgeInsets padding;
@property (nonatomic, strong) CAShapeLayer *crossLayer;
@property (nonatomic, strong) Cocoa_ChartModel *chartModel;
@property (nonatomic, strong) UILabel *suspendDateL;

- (void)drawCrossLineWithPoint:(CGPoint)point inofStr:(NSString *)infoStr chartModel:(Cocoa_ChartModel*)chartModel;

@end
