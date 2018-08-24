//
//  Cocoa_KDJView.m
//  PurCowExchange
//
//  Created by Yochi on 2018/8/21.
//  Copyright © 2018年 Yochi. All rights reserved.
//

#import "Cocoa_KDJView.h"

@interface Cocoa_KDJView()

@property (nonatomic,strong) CAShapeLayer *kLineLayer;
@property (nonatomic,strong) CAShapeLayer *dLineLayer;
@property (nonatomic,strong) CAShapeLayer *jLineLayer;
@property (nonatomic,strong) NSMutableArray *displayArray;

@end

@implementation Cocoa_KDJView

- (void)initLayer
{
    if (self.kLineLayer) {
        
        [self.kLineLayer removeFromSuperlayer];
        self.kLineLayer = nil;
    }
    
    if (!self.kLineLayer) {
        self.kLineLayer = [CAShapeLayer layer];
        self.kLineLayer.frame = CGRectMake(0, 0, CGRectGetWidth(self.frame), CGRectGetHeight(self.frame));
        self.kLineLayer.lineWidth = 1;
        self.kLineLayer.lineCap = kCALineCapRound;
        self.kLineLayer.lineJoin = kCALineJoinRound;
    }
    [self.layer addSublayer:self.kLineLayer];
    
    if (self.dLineLayer) {
        
        [self.dLineLayer removeFromSuperlayer];
        self.dLineLayer = nil;
    }
    
    if (!self.dLineLayer) {
        self.dLineLayer = [CAShapeLayer layer];
        self.dLineLayer.frame = CGRectMake(0, 0, CGRectGetWidth(self.frame), CGRectGetHeight(self.frame));
        self.dLineLayer.lineCap = kCALineCapRound;
        self.dLineLayer.lineJoin = kCALineJoinRound;
    }
    
    [self.layer addSublayer:self.dLineLayer];
    
    if (self.jLineLayer) {
        
        [self.jLineLayer removeFromSuperlayer];
        self.jLineLayer = nil;
    }
    
    if (!self.jLineLayer) {
        
        self.jLineLayer = [CAShapeLayer layer];
        self.jLineLayer.frame = CGRectMake(0, 0, CGRectGetWidth(self.frame), CGRectGetHeight(self.frame));
        self.jLineLayer.lineWidth = 1;
        self.jLineLayer.lineCap = kCALineCapRound;
        self.jLineLayer.lineJoin = kCALineJoinRound;
    }
    [self.layer addSublayer:self.jLineLayer];
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
    self.maxValue  = CGFLOAT_MIN;
    self.minValue  = CGFLOAT_MAX;
    
    for (Cocoa_ChartModel *model in self.displayArray) {
        
        self.minValue = MIN(self.minValue, MIN(model.KValue, MIN(model.DValue, model.JValue)));
        self.maxValue = MAX(self.maxValue, MAX(model.KValue, MAX(model.DValue, model.JValue)));
    }
    
    if (self.maxValue - self.minValue < 0.000000005) {
        
        self.maxValue  += 0.000000005;
        self.minValue  += 0.000000005;
    }
    
    self.scaleValue = (CGRectGetHeight(self.frame) - self.padding.top - self.padding.bottom)/(self.maxValue - self.minValue);
    
    self.coordinateMaxValue = self.minValue - self.padding.bottom/self.scaleValue;
    
    self.coordinateminValue =  CGRectGetHeight(self.frame)/self.scaleValue + self.coordinateminValue;
}

// 绘制k线
- (void)drawChartView
{
    UIBezierPath *kPath = [UIBezierPath bezierPath];
    UIBezierPath *dPath = [UIBezierPath bezierPath];
    UIBezierPath *jPath = [UIBezierPath bezierPath];
    
    __weak typeof(self) weakSelf = self;
    [self.displayArray enumerateObjectsUsingBlock:^(Cocoa_ChartModel * model, NSUInteger idx, BOOL * _Nonnull stop) {
        __strong typeof(self) self = weakSelf;

        // 绘制 k d j 线
        CGFloat xPosition = self.leftPostion + ((self.candleWidth  + self.candleSpace) * idx) + self.candleWidth/2 + self.padding.left;
        CGFloat yKPosition = ((self.maxValue - model.KValue) *self.scaleValue) + self.padding.top;

        CGFloat yDPosition = ((self.maxValue - model.DValue) *self.scaleValue) + self.padding.top;

        CGFloat yJPosition = ((self.maxValue - model.JValue) *self.scaleValue) + self.padding.top;

        if (idx == 0)
        {
            [kPath moveToPoint:CGPointMake(xPosition,yKPosition)];
            [dPath moveToPoint:CGPointMake(xPosition,yDPosition)];
            [jPath moveToPoint:CGPointMake(xPosition,yJPosition)];
        }

        else
        {
            [kPath addLineToPoint:CGPointMake(xPosition,yKPosition)];
            [dPath addLineToPoint:CGPointMake(xPosition,yDPosition)];
            [jPath addLineToPoint:CGPointMake(xPosition,yJPosition)];
        }


    }];
    
    self.kLineLayer.path = kPath.CGPath;
    self.kLineLayer.strokeColor = [UIColor redColor].CGColor;
    self.kLineLayer.fillColor = [[UIColor clearColor] CGColor];
    self.kLineLayer.contentsScale = [UIScreen mainScreen].scale;
    
    self.dLineLayer.path = dPath.CGPath;
    self.dLineLayer.strokeColor = [UIColor orangeColor].CGColor;
    self.dLineLayer.fillColor = [[UIColor clearColor] CGColor];
    self.dLineLayer.contentsScale = [UIScreen mainScreen].scale;
    
    self.jLineLayer.path = jPath.CGPath;
    self.jLineLayer.strokeColor = [UIColor purpleColor].CGColor;
    self.jLineLayer.fillColor = [[UIColor clearColor] CGColor];
    self.jLineLayer.contentsScale = [UIScreen mainScreen].scale;
}

#pragma mark - lazy
- (NSMutableArray *)displayArray
{
    if (!_displayArray) {
        
        _displayArray = [NSMutableArray array];
    }
    
    return _displayArray;
}

- (NSMutableArray *)dataArray
{
    if (!_dataArray) {
        
        _dataArray = [NSMutableArray array];
    }
    
    return _dataArray;
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
