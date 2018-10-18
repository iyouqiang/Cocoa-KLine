//
//  Cocoa_TradingVolumeView.m
//  Cocoa-KLine
//
//  Created by Yochi on 2018/7/31.
//  Copyright © 2018年 Yochi. All rights reserved.
//

#import "Cocoa_TradingVolumeView.h"
#import "Cocoa_ChartStylesheet.h"

@interface Cocoa_TradingVolumeView ()

/** 涨跌幅k线 */
@property (nonatomic,strong) CAShapeLayer *advancesLayer;

@property (nonatomic,strong) CAShapeLayer *declinesLayer;

@property (nonatomic,strong) NSMutableArray *displayArray;

@property (nonatomic, assign) StockStyleState stockState;

@end

@implementation Cocoa_TradingVolumeView

- (instancetype)init
{
    self = [super init];
    
    if (self) {
        
        [self.layer addSublayer:self.advancesLayer];
        [self.layer addSublayer:self.declinesLayer];
    }
    
    return self;
}

- (void)refreshChartView
{
    [self.displayArray removeAllObjects];
    
    NSInteger count = self.startIndex + self.displayCount <=self.dataArray.count?self.displayCount:self.displayCount -1;
    
    [self.displayArray addObjectsFromArray:[self.dataArray subarrayWithRange:NSMakeRange(self.startIndex,count)]];

    [self drawRectVolumeView];
}

- (void)clearChartView
{
    [self.advancesLayer removeFromSuperlayer];
    self.advancesLayer = nil;
    [self.declinesLayer removeFromSuperlayer];
    self.declinesLayer = nil;
    [self.layer addSublayer:self.advancesLayer];
    [self.layer addSublayer:self.declinesLayer];
}

- (void)drawRectVolumeView
{
    [self layoutIfNeeded];
    
    [self calcuteMaxAndMinValue];
    
    [self drawTradingVolumeLayer];
}

- (void)calcuteMaxAndMinValue
{
    CGFloat maxVolum = CGFLOAT_MIN;
    CGFloat minVolum = CGFLOAT_MAX;

    for (NSInteger i = 0;i<self.displayArray.count;i++) {
        
        Cocoa_ChartModel *model = [self.displayArray objectAtIndex:i];
        
        minVolum = MIN(minVolum, model.volume);
        maxVolum = MAX(maxVolum, model.volume);
    }
    
    self.maxValue = maxVolum;
    self.minValue = 0;
    
    if (self.maxValue - self.minValue < 0.000000005) {
        
        self.maxValue += 0.000000005;
        self.minValue += 0.000000005;
    }
    
     self.scaleValue = (CGRectGetHeight(self.frame)-self.padding.top - self.padding.bottom) / (maxValue - minValue);
    
    self.coordinateminValue = self.minValue - self.padding.bottom/self.scaleValue;
    
    self.coordinateMaxValue =  CGRectGetHeight(self.frame)/self.scaleValue + self.coordinateminValue;
}

- (void)drawTradingVolumeLayer
{
    CGMutablePathRef advancesRef = CGPathCreateMutable();
    CGMutablePathRef declinesRef = CGPathCreateMutable();
    
    __weak typeof(self) weakSelf = self;
    [self.displayArray enumerateObjectsUsingBlock:^(Cocoa_ChartModel *model, NSUInteger idx, BOOL * _Nonnull stop) {
    
        __strong typeof(self) strongSelf = weakSelf;
        
        CGFloat topPoint = (strongSelf.maxValue-model.volume)*strongSelf.scaleValue + self.padding.top;
        
        CGFloat left  = strongSelf.leftPostion + ((self.candleWidth + self.candleSpace) * idx) + strongSelf.padding.left;
        
        CGFloat contentheight = CGRectGetHeight(strongSelf.frame);
        
        CGRect rect = CGRectMake(left, topPoint, strongSelf.candleWidth,contentheight-topPoint-self.padding.bottom);
        
        CGMutablePathRef context = advancesRef;
        
        context = model.open <= model.close ? advancesRef : declinesRef;
        
        CGPathAddRect(context, NULL, rect);
        
        strongSelf.advancesLayer.path = advancesRef;
        strongSelf.declinesLayer.path = declinesRef;
    }];
}

#define mark - layz

- (CAShapeLayer *)advancesLayer
{
    if (!_advancesLayer) {
        
        _advancesLayer = [CAShapeLayer layer];
        
        
        _advancesLayer.strokeColor = COLOR_RISECOLOR.CGColor;
        _advancesLayer.fillColor = COLOR_RISECOLOR.CGColor;
    }
    
    return _advancesLayer;
}

- (CAShapeLayer *)declinesLayer
{
    if (!_declinesLayer) {
        
        _declinesLayer = [CAShapeLayer layer];
        _declinesLayer.strokeColor = COLOR_FALLCOLOR.CGColor;
        _declinesLayer.fillColor = COLOR_FALLCOLOR.CGColor;
    }
    
    return _declinesLayer;
}

- (NSMutableArray*)displayArray
{
    if (!_displayArray)
    {
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

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
