//
//  Cocoa_WRView.m
//  PurCowExchange
//
//  Created by Yochi on 2018/8/22.
//  Copyright © 2018年 Yochi. All rights reserved.
//

#import "Cocoa_WRView.h"

@interface Cocoa_WRView ()

@property (nonatomic,strong) NSMutableArray *displayArray;
@property (nonatomic,strong) CAShapeLayer   *wrLineLayer;

@end

@implementation Cocoa_WRView

- (void)initLayer
{
    if (self.wrLineLayer) {
        
        [self.wrLineLayer removeFromSuperlayer];
        self.wrLineLayer = nil;
    }
    
    if (!self.wrLineLayer) {
        
        self.wrLineLayer = [CAShapeLayer layer];
        self.wrLineLayer.frame = CGRectMake(0, 0, CGRectGetWidth(self.frame), CGRectGetHeight(self.frame));
        self.wrLineLayer.lineWidth = 1;
        self.wrLineLayer.lineCap = kCALineCapRound;
        self.wrLineLayer.lineJoin = kCALineJoinRound;
    }
    [self.layer addSublayer:self.wrLineLayer];
}

// 刷新k线界面
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
        
        self.maxValue = MAX(self.maxValue, model.WRValue);
        self.minValue = MIN(self.minValue, model.WRValue);
    }
    
    self.scaleValue = (CGRectGetHeight(self.frame) - self.padding.top - self.padding.bottom)/(self.maxValue - self.minValue);
    
    self.coordinateminValue = self.minValue - self.padding.bottom/self.scaleValue;
    
    self.coordinateMaxValue =  CGRectGetHeight(self.frame)/self.scaleValue + self.coordinateminValue;
}

// 绘制k线
- (void)drawChartView
{
    UIBezierPath *wrPath = [UIBezierPath bezierPath];
    
    __weak typeof(self) weakSelf = self;
    [self.displayArray enumerateObjectsUsingBlock:^(Cocoa_ChartModel *model, NSUInteger idx, BOOL * _Nonnull stop) {
        __strong typeof(self) self = weakSelf;
        
        CGFloat xPosition = self.leftPostion + ((self.candleWidth  + self.candleSpace) * idx) + self.candleWidth/2;
        CGFloat yPosition = ((self.maxValue - model.WRValue)*self.scaleValue) + self.padding.top;
        
        if (idx == 0) {
            
            [wrPath moveToPoint:CGPointMake(xPosition, yPosition)];
        }else {
            
            [wrPath addLineToPoint:CGPointMake(xPosition, yPosition)];
        }
    }];
    
    self.wrLineLayer.path = wrPath.CGPath;
    self.wrLineLayer.strokeColor = [UIColor redColor].CGColor;
    self.wrLineLayer.fillColor = [[UIColor clearColor] CGColor];
    self.wrLineLayer.contentsScale = [UIScreen mainScreen].scale;
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
