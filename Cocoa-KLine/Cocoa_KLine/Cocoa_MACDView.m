//
//  Cocoa_MACDView.m
//  PurCowExchange
//
//  Created by Yochi on 2018/8/21.
//  Copyright © 2018年 Yochi. All rights reserved.
//

#import "Cocoa_MACDView.h"
#import "Cocoa_ChartStylesheet.h"
@interface Cocoa_MACDView ()

@property (nonatomic,strong) NSMutableArray *displayArray;
@property (nonatomic,strong) CAShapeLayer   *macdLayer;

@end

@implementation Cocoa_MACDView

- (void)refreshChartView
{
    [self.displayArray removeAllObjects];
    
    NSInteger count = self.startIndex + self.displayCount <= self.dataArray.count?self.displayCount:self.displayCount -1;
    
    [self.displayArray addObjectsFromArray:[self.dataArray subarrayWithRange:NSMakeRange(self.startIndex,count)]];
    
    [self calcuteMaxAndMinValue];

    [CATransaction begin];
    [CATransaction setDisableActions:YES];
    [self removeFromSubLayer];
    [self drawChartView];
    [CATransaction commit];
 
}

- (void)calcuteMaxAndMinValue
{
    CGFloat maxValue = 0;
    CGFloat minValue = 0;
    
    Cocoa_ChartModel *first = [self.displayArray objectAtIndex:0];
    maxValue = MAX(first.dea, MAX(first.diff, first.macd));
    minValue = MIN(first.dea, MIN(first.diff, first.macd));
    
    for (NSInteger i = 1; i<self.displayArray.count;i++) {
        
        Cocoa_ChartModel *macdData = [self.displayArray objectAtIndex:i];
        maxValue = MAX(maxValue, MAX(macdData.dea, MAX(macdData.diff, macdData.macd)));
        minValue = MIN(minValue, MIN(macdData.dea, MIN(macdData.diff, macdData.macd)));
    }
    self.maxValue = maxValue;
    self.minValue = minValue;
    if (self.maxValue - self.minValue < 0.000000005) {
        
        self.maxValue += 0.000000005;
        self.minValue += 0.000000005;
    }
    
    self.scaleValue = (CGRectGetHeight(self.frame) - self.padding.top - self.padding.bottom)/(self.maxValue - self.minValue);
    
    self.coordinateminValue = self.minValue - self.padding.bottom/self.scaleValue;
    
    self.coordinateMaxValue =  CGRectGetHeight(self.frame)/self.scaleValue + self.coordinateminValue;
}

- (void)drawChartView
{
    UIBezierPath *deaPath = [UIBezierPath bezierPath];
    UIBezierPath *diffPath = [UIBezierPath bezierPath];
    
    for (NSInteger i = 0;i < self.displayArray.count;i++) {

        Cocoa_ChartModel *macdData = [self.displayArray objectAtIndex:i];

        CGFloat xPosition = self.leftPostion + ((self.candleSpace+self.candleWidth) * i) + self.padding.left;
        CGFloat yPosition = ABS((self.maxValue - macdData.macd)*self.scaleValue) + self.padding.top;

        //macd
        CGPoint endPoint = CGPointMake(xPosition, yPosition);
        CGPoint startPoint = CGPointMake(xPosition, self.maxValue*self.scaleValue + self.padding.top);

        float x = startPoint.y - endPoint.y;

        if (isEqualZero(x)) {

            //柱线的最小高度
            endPoint = CGPointMake(xPosition,self.maxValue*self.scaleValue+1);
        }

        /**************/
        [self drawMacdLayermacdstartPoint:startPoint endPoint:endPoint macdModel:macdData];

        /**************/
        CGFloat difdeaXPoint = xPosition+self.candleWidth/2;

        //diff
        CGFloat diffPostion = ABS((self.maxValue - macdData.diff)*self.scaleValue) +self.padding.top;
        CGPoint diffPoint = CGPointMake(difdeaXPoint, diffPostion);

        //dea
        CGFloat deayPostion = ABS((self.maxValue - macdData.dea)*self.scaleValue) +self.padding.top;
        CGPoint deaPoint = CGPointMake(difdeaXPoint,deayPostion);

        if (i == 0) {
            
            if (diffPoint.y > CGRectGetHeight(self.frame)) {
                diffPoint.y = CGRectGetHeight(self.frame);
            }
            if (deaPoint.y > CGRectGetHeight(self.frame)) {
                deaPoint.y = CGRectGetHeight(self.frame);
            }
            [deaPath moveToPoint:CGPointMake(diffPoint.x,diffPoint.y)];
            [diffPath moveToPoint:CGPointMake(deaPoint.x,deaPoint.y)];
        }else {
            
            if (diffPoint.y > CGRectGetHeight(self.frame)) {
                diffPoint.y = CGRectGetHeight(self.frame);
            }
            if (deaPoint.y > CGRectGetHeight(self.frame)) {
                deaPoint.y = CGRectGetHeight(self.frame);
            }
            [deaPath addLineToPoint:CGPointMake(diffPoint.x,diffPoint.y)];
            [diffPath addLineToPoint:CGPointMake(deaPoint.x,deaPoint.y)];
        }
    }
    
    CAShapeLayer *deaLayer = [CAShapeLayer layer];
    deaLayer.path = deaPath.CGPath;
    deaLayer.strokeColor = [UIColor redColor].CGColor;
    deaLayer.fillColor = [[UIColor clearColor] CGColor];
    deaLayer.contentsScale = [UIScreen mainScreen].scale;
    [self.macdLayer addSublayer:deaLayer];
    
    CAShapeLayer *diffLayer = [CAShapeLayer layer];
    diffLayer.path = diffPath.CGPath;
    diffLayer.strokeColor = [UIColor orangeColor].CGColor;
    diffLayer.fillColor = [[UIColor clearColor] CGColor];
    diffLayer.contentsScale = [UIScreen mainScreen].scale;
    [self.macdLayer addSublayer:diffLayer];
}

#pragma mark - drawLayer
- (void)removeFromSubLayer
{
    for (NSInteger i = 0 ; i < self.macdLayer.sublayers.count; i++) {
        
        CAShapeLayer *layer = (CAShapeLayer*)self.macdLayer.sublayers[i];
        [layer removeFromSuperlayer];
        layer = nil;
    }
    
    [self.macdLayer removeFromSuperlayer];
    
    self.macdLayer = nil;
    
    [self.layer addSublayer:self.macdLayer];
}

- (void)drawMacdLayermacdstartPoint:(CGPoint)startPoint endPoint:(CGPoint)endPoint macdModel:(Cocoa_ChartModel *)macdModel
{
    CGRect rect = CGRectZero;
    CGFloat y = self.maxValue*self.scaleValue + self.padding.top;
    
    if (macdModel.macd > 0) {
        
        rect = CGRectMake(startPoint.x, endPoint.y, self.candleWidth, ABS(y - endPoint.y));
        
    }else {
        
        rect = CGRectMake(startPoint.x,y, self.candleWidth, ABS(endPoint.y - startPoint.y));
    }
    
    UIBezierPath *path = [UIBezierPath bezierPathWithRect:rect];
    CAShapeLayer *subLayer = [CAShapeLayer layer];
    subLayer.path = path.CGPath;
    
    if (macdModel.macd > 0) {
        subLayer.strokeColor = COLOR_RISECOLOR.CGColor;
        subLayer.fillColor   = COLOR_RISECOLOR.CGColor;
    } else {
        subLayer.strokeColor = COLOR_FALLCOLOR.CGColor;
        subLayer.fillColor   = COLOR_FALLCOLOR.CGColor;
    }
    
    [self.macdLayer addSublayer:subLayer];
}

#pragma mark lazyLoad

- (NSMutableArray *)dataArray
{
    if (!_dataArray) {
        
        _dataArray = [NSMutableArray array];
    }
    
    return _dataArray;
}

- (NSMutableArray*)displayArray
{
    if (!_displayArray) {
        
        _displayArray = [NSMutableArray array];
    }
    return _displayArray;
}

- (CAShapeLayer*)macdLayer
{
    if (!_macdLayer) {
        
        _macdLayer = [CAShapeLayer layer];
        _macdLayer.lineWidth = 1;
        _macdLayer.strokeColor = [UIColor clearColor].CGColor;
        _macdLayer.fillColor = [UIColor clearColor].CGColor;
    }
    return _macdLayer;
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
