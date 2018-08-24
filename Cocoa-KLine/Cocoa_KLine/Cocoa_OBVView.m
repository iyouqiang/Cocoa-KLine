//
//  Cocoa_OBVView.m
//  PurCowExchange
//
//  Created by Yochi on 2018/8/21.
//  Copyright © 2018年 Yochi. All rights reserved.
//

#import "Cocoa_OBVView.h"

@interface Cocoa_OBVView()

@property (nonatomic,strong) NSMutableArray *displayArray;
@property (nonatomic,strong) CAShapeLayer   *obvLineLayer;

@end

@implementation Cocoa_OBVView

- (void)initLayer
{
    if (self.obvLineLayer)
    {
        [self.obvLineLayer removeFromSuperlayer];
        self.obvLineLayer = nil;
    }
    
    if (!self.obvLineLayer) {
        
        self.obvLineLayer = [CAShapeLayer layer];
        self.obvLineLayer.frame = CGRectMake(0, 0, CGRectGetWidth(self.frame), CGRectGetHeight(self.frame));
        self.obvLineLayer.lineWidth = 1;
        self.obvLineLayer.lineCap = kCALineCapRound;
        self.obvLineLayer.lineJoin = kCALineJoinRound;
    }
    [self.layer addSublayer:self.obvLineLayer];
}

- (void)refreshChartView
{
    [self.displayArray removeAllObjects];
    
    NSInteger count = self.startIndex + self.displayCount <= self.dataArray.count?self.displayCount:self.displayCount -1;
    
    [self.displayArray addObjectsFromArray:[self.dataArray subarrayWithRange:NSMakeRange(self.startIndex,count)]];
    
    [self calcuteMaxAndMinValue];
    
    [CATransaction begin];
    [CATransaction setDisableActions:YES];
    [self initLayer];
    [self drawChartView];
    [CATransaction commit];
}

// 计算最大最小值
- (void)calcuteMaxAndMinValue
{
    [self layoutIfNeeded];
    self.maxValue = CGFLOAT_MIN;
    self.minValue  = CGFLOAT_MAX;
    
    for (Cocoa_ChartModel *model in self.displayArray) {
        
        self.maxValue = MAX(self.maxValue, model.OBVValue);
        self.minValue = MIN(self.minValue, model.OBVValue);
    }
    
    self.scaleValue = (CGRectGetHeight(self.frame) - self.padding.top - self.padding.bottom)/(self.maxValue - self.minValue);
    
    self.coordinateMaxValue = self.minValue - self.padding.bottom/self.scaleValue;
    
    self.coordinateminValue =  CGRectGetHeight(self.frame)/self.scaleValue + self.coordinateminValue;
}

// 绘制k线
- (void)drawChartView
{
    UIBezierPath *obvPath = [UIBezierPath bezierPath];
    
    __weak typeof(self) weakSelf = self;
    [self.displayArray enumerateObjectsUsingBlock:^(Cocoa_ChartModel *model, NSUInteger idx, BOOL * _Nonnull stop) {
        __strong typeof(self) self = weakSelf;
        
        CGFloat xPosition = self.leftPostion + ((self.candleWidth  + self.candleSpace) * idx) + self.candleWidth/2;
        CGFloat yPosition = ((self.maxValue - model.OBVValue)*self.scaleValue) + self.padding.top;
        
        if (idx == 0) {
            
            [obvPath moveToPoint:CGPointMake(xPosition, yPosition)];
        }else {
            
            [obvPath addLineToPoint:CGPointMake(xPosition, yPosition)];
        }
    }];
    
    self.obvLineLayer.path = obvPath.CGPath;
    self.obvLineLayer.strokeColor = [UIColor redColor].CGColor;
    self.obvLineLayer.fillColor = [[UIColor clearColor] CGColor];
    self.obvLineLayer.contentsScale = [UIScreen mainScreen].scale;
}

#pragma mark - layz
- (NSMutableArray *)dataArray
{
    if (!_dataArray) {
        
        _dataArray = [NSMutableArray array];
    }
    
    return _dataArray;
}

- (NSMutableArray *)displayArray
{
    if (!_displayArray) {
        
        _displayArray = [NSMutableArray array];
    }
    
    return _displayArray;
}

@synthesize coordinateMaxValue;
@synthesize coordinateminValue;
@synthesize maxValue;
@synthesize minValue;
@synthesize padding;
@synthesize scaleValue;
@synthesize leftPostion;
@synthesize startIndex;
@synthesize displayCount;
@synthesize candleWidth;
@synthesize candleSpace;

@end
