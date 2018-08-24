//
//  Cocoa_ChartManager.m
//  Cocoa-KLine
//
//  Created by Yochi on 2018/7/31.
//  Copyright © 2018年 Yochi. All rights reserved.
//

#import "Cocoa_ChartManager.h"
#import "Cocoa_TecnnicalView.h"
#import "Cocoa_TecnnicalOptionsView.h"
#import "Cocoa_ChartProtocol.h"
#import "Cocoa_TradingVolumeView.h"
#import "Cocoa_CrossCurveView.h"
#import "Cocoa_CalculateCoordinate.h"
#import "Cocoa_MACDView.h"
#import "Cocoa_KDJView.h"
#import "Cocoa_OBVView.h"
#import "Cocoa_FullScreenController.h"
#import "Cocoa_WRView.h"

#define kCandleChartScale    0.65
#define kOpentionsHeight     40.0
#define kTecnnicalChartScale 0.35

@interface Cocoa_ChartManager ()<Cocoa_ChartProtocol>

/** parentView */
@property (nonatomic, strong) UIScrollView *mainScrollerView;

// 指标 界面
@property (nonatomic, strong) Cocoa_TecnnicalOptionsView *opentionsView;
@property (nonatomic, strong) Cocoa_TecnnicalView *tecnnicalView;
@property (nonatomic, strong) Cocoa_TradingVolumeView *tradingVolumeView;
@property (nonatomic, strong) Cocoa_MACDView *tradingMacdView;
@property (nonatomic, strong) Cocoa_KDJView *tecnnicalKDJView;
@property (nonatomic, strong) Cocoa_OBVView *tecnnicalOBVView;
@property (nonatomic, strong) Cocoa_WRView *tecnnicalWRView;
@property (nonatomic, strong) Cocoa_CrossCurveView *crossView;
@property (nonatomic, strong) NSMutableArray *tecnnicalArray;

@property (nonatomic, assign) id<Cocoa_ChartProtocol>temptecnnicalStateView;

// 界面高度
@property (nonatomic, assign) CGFloat topKViewHeight;
@property (nonatomic, assign) CGFloat centerOptionsHeight;
@property (nonatomic, assign) CGFloat bottomTecnnicaHeight;

// 手势
@property (nonatomic,strong) UILongPressGestureRecognizer *longPressGesture;
@property (nonatomic,strong) UIPinchGestureRecognizer *pinchPressGesture;
@property (nonatomic,strong) UITapGestureRecognizer *tapGesture;
@property (nonatomic, assign) CGFloat currentZoom;

// k线纵坐标值
@property (nonatomic, strong) CATextLayer *topTextLayer;
@property (nonatomic, strong) CATextLayer *centerTextLayer;
@property (nonatomic, strong) CATextLayer *bottomTextLayer;

// 横坐标值
@property (nonatomic, strong) CATextLayer *firstDateTextLayer;
@property (nonatomic, strong) CATextLayer *secondeDateTextLayer;
@property (nonatomic, strong) CATextLayer *thirdTextLayer;
@property (nonatomic, strong) CATextLayer *fourthTextLayer;
@property (nonatomic, strong) CATextLayer *fiveTextLayer;

// 指标 纵坐标值
@property (nonatomic, strong) CATextLayer *tecnnicalTextLayer;

@property (nonatomic, strong) CAShapeLayer *verificalLayer;

@property (nonatomic, assign) BOOL islandscape;

@end

@implementation Cocoa_ChartManager

- (void)dealloc
{
    // 移除观察者
    [_candleView removeAllObserver];
}

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    
    if (self) {
        
        self.backgroundColor = COLOR_BACKGROUND;

        CGFloat totalHeight = CGRectGetHeight(self.frame)-kOpentionsHeight;
        
        self.topKViewHeight       = totalHeight*kCandleChartScale;
        self.centerOptionsHeight  = kOpentionsHeight;
        self.bottomTecnnicaHeight = totalHeight*kTecnnicalChartScale;
        
        [self.layer addSublayer:self.verificalLayer];
        
        /** 绘制坐标系 */
        [self drawVerificalLine];
        
        /** k线的展示 */
        [self addSubview:self.mainScrollerView];
        
        /** k线图 */
        [self.mainScrollerView addSubview:self.candleView];
        
        /** 指标图  根据k线图联动*/
        [self.mainScrollerView addSubview:self.tecnnicalView];
        
        /** 加载图标 */
        [self addSubview:self.indicatorView];
        
        /** 展示悬浮指标 */
        [self addSubview:self.opentionsView];
        
        /******************************************/
        
        /** 加入成交量视图 */
        [self.tecnnicalArray addObject:self.tradingVolumeView];
        [self.tecnnicalArray addObject:self.tradingMacdView];
        [self.tecnnicalArray addObject:self.tecnnicalKDJView];
        [self.tecnnicalArray addObject:self.tecnnicalOBVView];
        [self.tecnnicalArray addObject:self.tecnnicalWRView];
        
        // 初始化进来 成交量
        [self.tecnnicalView addSubview:self.tradingVolumeView];
        self.temptecnnicalStateView = self.tradingVolumeView;
        
        __weak typeof(self) this = self;
        self.opentionsView.tecnnicalTypeBlock = ^(TecnnicalType tecnnicalType) {
          
            dispatch_async(dispatch_get_main_queue(), ^{
                if ((tecnnicalType - 100)<this.tecnnicalArray.count) {
                    
                    id<Cocoa_ChartProtocol> chartProtocol = this.tecnnicalArray[tecnnicalType - 100];
                    
                    UIView *tempView = (UIView *)chartProtocol;
                
                    [[this.tecnnicalView.subviews firstObject] removeFromSuperview];
                    [this.tecnnicalView addSubview:tempView];
                    this.temptecnnicalStateView = chartProtocol;
                    
                    tempView.frame = this.tecnnicalView.bounds;
                    tempView.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
                    
                    [this displayScreenleftPostion:this.leftPostion startIndex:this.startIndex count:this.displayCount];
                }
            });
        };
        
        /******************************************/
        
        [self.layer addSublayer:self.topTextLayer];
        [self.layer addSublayer:self.centerTextLayer];
        [self.layer addSublayer:self.bottomTextLayer];
        [self.layer addSublayer:self.tecnnicalTextLayer];

        [self.layer addSublayer:self.firstDateTextLayer];
        [self.layer addSublayer:self.secondeDateTextLayer];
        [self.layer addSublayer:self.thirdTextLayer];
        [self.layer addSublayer:self.fourthTextLayer];
        [self.layer addSublayer:self.fiveTextLayer];
        
        /** 布局 */
        [self main_layoutsubview];
        
        /** 添加手势 */
        [self addGestureToCandleView];
        
        /** 十字线 */
        [self addSubview:self.crossView];
    }
    
    return self;
}

/** 刷新k线 */
- (void)refreshChartView
{
    if (self.dataArray.count <=0 ) {
        
        return;
    }
    
    /** 刷新k线 保证其他指标赋值完成，再刷新界面 */
    [self.candleView.dataArray removeAllObjects];
    [self.candleView.dataArray addObjectsFromArray:self.dataArray];
    
    // 计算指标值
    computeMACDData(self.dataArray);
    computeMAData(self.dataArray, 5);
    computeMAData(self.dataArray, 10);
    computeMAData(self.dataArray, 20);
    computeKDJData(self.dataArray);
    computeWRData(self.dataArray, 14);
    computeOBVData(self.dataArray);
    
    for (id<Cocoa_ChartProtocol> tecnnical in self.tecnnicalArray) {
        [tecnnical.dataArray removeAllObjects];
        [tecnnical.dataArray addObjectsFromArray:self.dataArray];
    }
    
    // 刷新k线界面 核心界面，带动其它界面
    [self.candleView refreshChartView];
}

#pragma mark - 界面绘制

/** 绘制坐标轴 */
- (void)drawVerificalLine
{
    /**
      绘制横坐标五根线
     */

    /***************/
    [self drawAbscissalineDashPattern:nil lineWidth:0.7 moveToPoint:CGPointMake(0.0,0.0) addLineToPoint:CGPointMake(CGRectGetWidth(self.frame),0.0)];
    
    /***************/
    [self drawAbscissalineDashPattern:@[@3, @2] lineWidth:0.7 moveToPoint:CGPointMake(0,self.topKViewHeight/2.0f) addLineToPoint:CGPointMake(CGRectGetWidth(self.frame),self.topKViewHeight/2.0)];
    
    /***************/
    [self drawAbscissalineDashPattern:nil lineWidth:0.7 moveToPoint:CGPointMake(0, self.topKViewHeight) addLineToPoint:CGPointMake(CGRectGetWidth(self.frame), self.topKViewHeight)];
    
    /***************/
    [self drawAbscissalineDashPattern:nil lineWidth:0.7 moveToPoint:CGPointMake(0, self.topKViewHeight+self.centerOptionsHeight) addLineToPoint:CGPointMake(CGRectGetWidth(self.frame), self.topKViewHeight+self.centerOptionsHeight)];
    
    /***************/
    [self drawAbscissalineDashPattern:@[@3, @2] lineWidth:0.7 moveToPoint:CGPointMake(0, self.topKViewHeight+self.centerOptionsHeight + self.bottomTecnnicaHeight/2.0) addLineToPoint:CGPointMake(CGRectGetWidth(self.frame), self.topKViewHeight+self.centerOptionsHeight + self.bottomTecnnicaHeight/2.0)];
    
    /**
     绘制纵坐标 5根线
     */
    CGFloat coordinateHeight = _topKViewHeight+_bottomTecnnicaHeight+_centerOptionsHeight;
    coordinateHeight = CGRectGetHeight(self.frame);
    /**中间*************/
     [self drawAbscissalineDashPattern:@[@3, @2] lineWidth:0.7 moveToPoint:CGPointMake(CGRectGetWidth(self.frame)/2, 0) addLineToPoint:CGPointMake(CGRectGetWidth(self.frame)/2, coordinateHeight)];
    
    /**左一*************/
    [self drawAbscissalineDashPattern:@[@3, @2] lineWidth:0.7 moveToPoint:CGPointMake(CGRectGetWidth(self.frame)/4, 0) addLineToPoint:CGPointMake(CGRectGetWidth(self.frame)/4, coordinateHeight)];
    
    /**右一*************/
    [self drawAbscissalineDashPattern:@[@3, @2] lineWidth:0.7 moveToPoint:CGPointMake(CGRectGetWidth(self.frame)*3/4, 0) addLineToPoint:CGPointMake(CGRectGetWidth(self.frame)*3/4, coordinateHeight)];
}

/** 绘制横坐标 */
- (void)drawAbscissalineDashPattern:(NSArray *)lineDashPattern
                          lineWidth:(CGFloat)lineWidth
                        moveToPoint:(CGPoint)moveToPoint
                     addLineToPoint:(CGPoint)addLineToPoint
{
    CAShapeLayer *XLayer = [CAShapeLayer layer];
    XLayer.strokeColor = [UIColor grayColor].CGColor;
    XLayer.fillColor = [[UIColor clearColor] CGColor];
    XLayer.contentsScale = [UIScreen mainScreen].scale;
    XLayer.lineWidth = lineWidth;
    XLayer.lineDashPattern = lineDashPattern;
    
    UIBezierPath *xpath = [UIBezierPath bezierPath];
    [xpath moveToPoint:moveToPoint];
    [xpath addLineToPoint:addLineToPoint];
    XLayer.path = xpath.CGPath;
    [self.verificalLayer addSublayer:XLayer];
}

#pragma mark 添加手势

- (void)addGestureToCandleView
{
    _longPressGesture = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(longGesture:)];
    [self.mainScrollerView addGestureRecognizer:_longPressGesture];
    
    _pinchPressGesture = [[UIPinchGestureRecognizer alloc] initWithTarget:self action:@selector(pinchesView:)];
    [self.mainScrollerView addGestureRecognizer:_pinchPressGesture];
    
    _tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapGesture:)];
    _tapGesture.numberOfTapsRequired = 2;
    [self.mainScrollerView addGestureRecognizer:_tapGesture];
}

- (void)longGesture:(UILongPressGestureRecognizer*)longPress
{
    if (self.dataArray.count == 0) {
        [self.crossView removeFromSuperview];
        return;
    }

    CGPoint originlocation = [longPress locationInView:self];
    CGPoint location = [longPress locationInView:self.crossView];
    CGFloat y = location.y;
    static CGFloat oldPositionX = 0;
    
    if (UIGestureRecognizerStateBegan == longPress.state) {
        
        [self addSubview:self.crossView];
    }
    
    NSInteger temp_x = ((location.x - self.candleView.padding.left) / (self.candleView.candleWidth + self.candleView.candleSpace));
    
    temp_x = temp_x < 0 ? 0 : temp_x;
    
    temp_x = temp_x >= self.candleView.displayCount ? self.candleView.displayCount - 1 : temp_x;

    Cocoa_ChartModel *model = (self.candleView.startIndex + temp_x < self.dataArray.count) ? [self.dataArray objectAtIndex:self.candleView.startIndex + temp_x] : self.dataArray.lastObject;
    
    CGFloat x = ((self.candleView.candleWidth) / 2) + model.highPoint.x - self.mainScrollerView.contentOffset.x;
    
    // y轴坐标让用户控制
    if (UIGestureRecognizerStateChanged == longPress.state ||
        UIGestureRecognizerStateBegan   == longPress.state) {
        
        self.crossView.touchPoint = location;
        
        NSString *crossValueStr = nil;
        
        CGFloat tecnnicalValueY = originlocation.y - (self.topKViewHeight+self.centerOptionsHeight);
        

        if (originlocation.y >= self.topKViewHeight+self.centerOptionsHeight) {
        
            crossValueStr = [NSString stringWithFormat:@"%0.8f", (self.bottomTecnnicaHeight - tecnnicalValueY)/self.tradingVolumeView.scaleValue + self.tradingVolumeView.coordinateminValue];
        }else {
            
            crossValueStr = [NSString stringWithFormat:@"%0.8f", (self.topKViewHeight-y)/self.candleView.scaleValue + self.candleView.coordinateminValue];
        }
        
        [self.crossView drawCrossLineWithPoint:CGPointMake(x, y) inofStr:crossValueStr chartModel:model];
        
        self.mainScrollerView.scrollEnabled = NO;
        
        oldPositionX = location.x;
    }
    
    if(longPress.state == UIGestureRecognizerStateEnded) {
        
        self.mainScrollerView.scrollEnabled = YES;
        self.crossView.touchPoint = location;
        [self.crossView removeFromSuperview];
    }
}

- (void)tapGesture:(UITapGestureRecognizer*)tapGesture
{
//    CGFloat duration = [UIApplication sharedApplication].statusBarOrientationAnimationDuration;
//    [UIView animateWithDuration:duration animations:^{
//
//        [[UIApplication sharedApplication] setStatusBarOrientation:!self.islandscape? UIInterfaceOrientationLandscapeRight:UIInterfaceOrientationPortrait];
//        self.transform =  !self.islandscape? CGAffineTransformMakeRotation(M_PI_2) : CGAffineTransformIdentity;
//        self.frame = CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width, [UIScreen mainScreen].bounds.size.height);
//        /** 布局 */
//        [self main_layoutsubview];
//
//        /** 绘制坐标系 */
//        [self drawVerificalLine];
//
//        [self refreshChartView];
//
//        self.islandscape = !self.islandscape;
//
//    }];
}

- (void)pinchesView:(UIPinchGestureRecognizer *)pinchTap
{
    
    if (pinchTap.state == UIGestureRecognizerStateEnded) {
        
        self.mainScrollerView.scrollEnabled = YES;
    }
    else if (pinchTap.state == UIGestureRecognizerStateBegan && _currentZoom != 0.0f)
    {
        self.mainScrollerView.scrollEnabled = NO;
        pinchTap.scale = _currentZoom;
    }
    else if (pinchTap.state == UIGestureRecognizerStateChanged)
    {
        self.mainScrollerView.scrollEnabled = NO;
        
        if (isnan(_currentZoom)) {
            return;
        }

        [self.candleView pinGesture:pinchTap];
    }
}

#pragma mark - delegate
- (void)displayMoreData
{
    if (self.indicatorView.isAnimating) {
        return;
    }
    
    if (self.loadmoredataBlock) {
        
        self.loadmoredataBlock(nil);
    }
}

- (void)displayScreenleftPostion:(CGFloat)leftPostion startIndex:(NSInteger)index count:(NSInteger)count
{
    [self showIndexLineView:leftPostion startIndex:index count:count];
    
    // k线价格更新
    self.topTextLayer.string = [NSString stringWithFormat:@"%0.8f",self.candleView.coordinateMaxValue];
    self.centerTextLayer.string = [NSString stringWithFormat:@"%0.8f",(self.candleView.maxValue - self.candleView.minValue)/2.0 + self.candleView.minValue];
    self.bottomTextLayer.string = [NSString stringWithFormat:@"%0.8f",self.candleView.coordinateminValue];
    
    // 获取纵坐标做 中 右 三个数据
    if (self.candleView.currentDisplayArray.count > 0) {
        Cocoa_ChartModel *firstModel = [self.candleView.currentDisplayArray firstObject];
        Cocoa_ChartModel *thirModel = self.candleView.currentDisplayArray[self.candleView.displayCount/2];
        Cocoa_ChartModel *fiveModel = [self.candleView.currentDisplayArray lastObject];
        
        // 底部日期更新
        self.firstDateTextLayer.string = firstModel.date;
        //self.secondeDateTextLayer.string = secondModel.date;
        self.thirdTextLayer.string = thirModel.date;
        //self.fourthTextLayer.string = fourthModel.date;
        self.fiveTextLayer.string = fiveModel.date;
    }

    // 数据指标更新
    //self.tecnnicalTextLayer.string = [NSString stringWithFormat:@"vol(%0.8f)",self.tradingVolumeView.maxValue];
    self.tecnnicalTextLayer.string = [NSString stringWithFormat:@"%0.8f",self.temptecnnicalStateView.maxValue];
    
    if (CGRectGetWidth(self.tecnnicalView.frame) == CGRectGetWidth(self.candleView.frame)) {
        return;
    }
     self.tecnnicalView.frame = CGRectMake(0, self.tecnnicalView.frame.origin.y, CGRectGetWidth(self.candleView.frame), self.bottomTecnnicaHeight);
}


- (void)showIndexLineView:(CGFloat)leftPostion startIndex:(NSInteger)index count:(NSInteger)count
{
    self.leftPostion = leftPostion;
    self.startIndex = index;
    self.displayCount = count;
    
    self.temptecnnicalStateView.candleSpace = self.candleView.candleSpace;
    self.temptecnnicalStateView.candleWidth = self.candleView.candleWidth;
    self.temptecnnicalStateView.leftPostion = leftPostion;
    self.temptecnnicalStateView.startIndex  = index;
    self.temptecnnicalStateView.displayCount = count;
    self.temptecnnicalStateView.padding = self.candleView.padding;

    if ([self.temptecnnicalStateView respondsToSelector:@selector(refreshChartView)]) {

        [self.temptecnnicalStateView refreshChartView];
    }
}

#pragma mark - 布局
- (void)main_layoutsubview
{

    _candleView.frame = CGRectMake(0, 0, CGRectGetWidth(self.frame), self.topKViewHeight);
    _opentionsView.frame = CGRectMake(0, self.topKViewHeight, CGRectGetWidth(self.frame), self.centerOptionsHeight);
    _tecnnicalView.frame = CGRectMake(0,  self.topKViewHeight+self.centerOptionsHeight, CGRectGetWidth(_candleView.frame), self.bottomTecnnicaHeight);
    _indicatorView.center = CGPointMake(10, _candleView.center.y);
    
    [self layoutcoordinate];
}

- (void)layoutcoordinate
{
    self.topTextLayer.frame = CGRectMake(CGRectGetWidth(self.frame)-100, 0, 100, 15);
    self.bottomTextLayer.frame = CGRectMake(CGRectGetWidth(self.frame)-100, _topKViewHeight-15, 100, 15);
    self.centerTextLayer.frame = CGRectMake(CGRectGetWidth(self.frame)-100, _topKViewHeight/2.0f - 15, 100, 15);
    self.tecnnicalTextLayer.frame = CGRectMake(CGRectGetWidth(self.frame)-100, _topKViewHeight +_centerOptionsHeight + _bottomTecnnicaHeight/2.0 - 15, 100, 15);
    
    self.firstDateTextLayer.frame = CGRectMake(0, CGRectGetHeight(self.frame)-15, 80, 15);
    self.thirdTextLayer.frame = CGRectMake(CGRectGetWidth(self.frame)/2 - 40, CGRectGetHeight(self.frame)-15, 80, 15);
    self.fiveTextLayer.frame = CGRectMake(CGRectGetWidth(self.frame)-80, CGRectGetHeight(self.frame)-15, 80, 15);
}

#pragma mark - lazy View
- (Cocoa_MACDView *)tradingMacdView
{
    if (!_tradingMacdView) {
        
        _tradingMacdView = [[Cocoa_MACDView alloc] init];
        _tradingMacdView.clipsToBounds = YES;
    }
    
    return _tradingMacdView;
}

- (Cocoa_TradingVolumeView *)tradingVolumeView
{
    if (!_tradingVolumeView) {
        
        _tradingVolumeView = [[Cocoa_TradingVolumeView alloc] init];
        _tradingVolumeView.clipsToBounds = YES;
        
        _tradingVolumeView.frame = self.tecnnicalView.bounds;
        _tradingVolumeView.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
    }
    
    return _tradingVolumeView;
}

- (Cocoa_KDJView *)tecnnicalKDJView
{
    if (!_tecnnicalKDJView) {
        
        _tecnnicalKDJView = [[Cocoa_KDJView alloc] init];
        _tecnnicalKDJView.clipsToBounds = YES;
    }
    
    return _tecnnicalKDJView;
}

- (Cocoa_OBVView *)tecnnicalOBVView
{
    if (!_tecnnicalOBVView) {
        
        _tecnnicalOBVView = [[Cocoa_OBVView alloc] init];
        _tecnnicalOBVView.clipsToBounds = YES;

    }
    
    return _tecnnicalOBVView;
}

- (Cocoa_WRView *)tecnnicalWRView
{
    if (!_tecnnicalWRView) {
        
        _tecnnicalWRView = [[Cocoa_WRView alloc] init];
        _tecnnicalWRView.clipsToBounds = YES;
        
    }
    
    return _tecnnicalWRView;
}

- (UIScrollView *)mainScrollerView
{
    if (!_mainScrollerView) {
        
        _mainScrollerView = [[UIScrollView alloc] initWithFrame:self.bounds];
        _mainScrollerView.userInteractionEnabled = YES;
        _mainScrollerView.showsVerticalScrollIndicator = NO;
        _mainScrollerView.showsHorizontalScrollIndicator = NO;
    }
    return _mainScrollerView;
}

- (Cocoa_TecnnicalOptionsView *)opentionsView
{
    if (!_opentionsView) {
        
        _opentionsView = [[Cocoa_TecnnicalOptionsView alloc] init];
    }
    
    return _opentionsView ;
}

- (Cocoa_CandleLineView *)candleView
{
    if (!_candleView) {
        
        _candleView = [[Cocoa_CandleLineView alloc] init];
        _candleView.delegate = self;
        _candleView.userInteractionEnabled = NO;
        _candleView.clipsToBounds = YES;
        _candleView.padding = UIEdgeInsetsMake(10, 10, 20, 10);
    }
    
    return _candleView;
}

- (Cocoa_TecnnicalView *)tecnnicalView
{
    if (!_tecnnicalView) {
        
        _tecnnicalView = [[Cocoa_TecnnicalView alloc] init];
        _tecnnicalView.userInteractionEnabled = NO;
        _tecnnicalView.clipsToBounds = YES;
    }
    
    return _tecnnicalView;
}

- (NSMutableArray *)dataArray
{
    if (!_dataArray) {
        
        _dataArray = [NSMutableArray array];
    }
    
    return _dataArray;
}

- (NSMutableArray *)tecnnicalArray
{
    if (!_tecnnicalArray) {
        _tecnnicalArray = [NSMutableArray array];
    }
    
    return _tecnnicalArray;
}

- (UIActivityIndicatorView *)indicatorView
{
    if (!_indicatorView) {
        _indicatorView = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:(UIActivityIndicatorViewStyleWhite)];
        _indicatorView.hidesWhenStopped = YES;
    }
    
    return _indicatorView;
}

- (Cocoa_CrossCurveView *)crossView
{
    if (!_crossView) {
        _crossView = [[Cocoa_CrossCurveView alloc] initWithFrame:CGRectMake(0, 0, CGRectGetWidth(self.frame), _topKViewHeight+_bottomTecnnicaHeight + _centerOptionsHeight)];
        _crossView.clipsToBounds = YES;
        _crossView.userInteractionEnabled = NO;
    }
    
    return _crossView;
}

- (CAShapeLayer*)verificalLayer
{
    if (!_verificalLayer) {
        
        _verificalLayer = [CAShapeLayer layer];
    }
    return _verificalLayer;
}

- (CATextLayer *)topTextLayer
{
    if (!_topTextLayer) {
        
        _topTextLayer = [CATextLayer layer];
        _topTextLayer.contentsScale = [UIScreen mainScreen].scale;
        _topTextLayer.fontSize = 10.f;
        _topTextLayer.alignmentMode = kCAAlignmentRight;
        _topTextLayer.foregroundColor =
        [UIColor whiteColor].CGColor;
        _topTextLayer.string = @"0.00000000";
    }
    
    return _topTextLayer;
}

- (CATextLayer *)bottomTextLayer
{
    if (!_bottomTextLayer) {
        
        _bottomTextLayer = [CATextLayer layer];
        _bottomTextLayer.contentsScale = [UIScreen mainScreen].scale;
        _bottomTextLayer.fontSize = 10.f;
        _bottomTextLayer.alignmentMode = kCAAlignmentRight;
        _bottomTextLayer.foregroundColor =
        [UIColor whiteColor].CGColor;
        _bottomTextLayer.string = @"0.00000000";
        
    }
    
    return _bottomTextLayer;
}

- (CATextLayer *)centerTextLayer
{
    if (!_centerTextLayer) {
        
        _centerTextLayer = [CATextLayer layer];
        _centerTextLayer.contentsScale = [UIScreen mainScreen].scale;
        _centerTextLayer.fontSize = 10.f;
        _centerTextLayer.alignmentMode = kCAAlignmentRight;
        _centerTextLayer.foregroundColor =
        [UIColor whiteColor].CGColor;
        _centerTextLayer.string = @"0.00000000";
    }
    
    return _centerTextLayer;
}

- (CATextLayer *)firstDateTextLayer
{
    if (!_firstDateTextLayer) {
        
        _firstDateTextLayer = [CATextLayer layer];
        _firstDateTextLayer.contentsScale = [UIScreen mainScreen].scale;
        _firstDateTextLayer.fontSize = 10.f;
        _firstDateTextLayer.alignmentMode = kCAAlignmentLeft;
        _firstDateTextLayer.foregroundColor =
        [UIColor whiteColor].CGColor;
        _firstDateTextLayer.string = @"";
    }
    
    return _firstDateTextLayer;
}

- (CATextLayer *)secondeDateTextLayer
{
    if (!_secondeDateTextLayer) {
        
        _secondeDateTextLayer = [CATextLayer layer];
        _secondeDateTextLayer.contentsScale = [UIScreen mainScreen].scale;
        _secondeDateTextLayer.fontSize = 10.f;
        _secondeDateTextLayer.alignmentMode = kCAAlignmentCenter;
        _secondeDateTextLayer.foregroundColor =
        [UIColor whiteColor].CGColor;
        _secondeDateTextLayer.string = @"";
    }
    
    return _secondeDateTextLayer;
}

- (CATextLayer *)thirdTextLayer
{
    if (!_thirdTextLayer) {
        
        _thirdTextLayer = [CATextLayer layer];
        _thirdTextLayer.contentsScale = [UIScreen mainScreen].scale;
        _thirdTextLayer.fontSize = 10.f;
        _thirdTextLayer.alignmentMode = kCAAlignmentCenter;
        _thirdTextLayer.foregroundColor =
        [UIColor whiteColor].CGColor;
        _thirdTextLayer.string = @"";
    }
    
    return _thirdTextLayer;
}

- (CATextLayer *)fourthTextLayer
{
    if (!_fourthTextLayer) {
        
        _fourthTextLayer = [CATextLayer layer];
        _fourthTextLayer.contentsScale = [UIScreen mainScreen].scale;
        _fourthTextLayer.fontSize = 10.f;
        _fourthTextLayer.alignmentMode = kCAAlignmentCenter;
        _fourthTextLayer.foregroundColor =
        [UIColor whiteColor].CGColor;
        _fourthTextLayer.string = @"";
    }
    
    return _fourthTextLayer;
}

- (CATextLayer *)fiveTextLayer
{
    if (!_fiveTextLayer) {
        
        _fiveTextLayer = [CATextLayer layer];
        _fiveTextLayer.contentsScale = [UIScreen mainScreen].scale;
        _fiveTextLayer.fontSize = 10.f;
        _fiveTextLayer.alignmentMode = kCAAlignmentRight;
        _fiveTextLayer.foregroundColor =
        [UIColor whiteColor].CGColor;
        _fiveTextLayer.string = @"";
    }
    
    return _fiveTextLayer;
}

- (CATextLayer *)tecnnicalTextLayer
{
    if (!_tecnnicalTextLayer) {
        
        _tecnnicalTextLayer = [CATextLayer layer];
        _tecnnicalTextLayer.contentsScale = [UIScreen mainScreen].scale;
        _tecnnicalTextLayer.fontSize = 10.f;
        _tecnnicalTextLayer.alignmentMode = kCAAlignmentRight;
        _tecnnicalTextLayer.foregroundColor =
        [UIColor whiteColor].CGColor;
        _tecnnicalTextLayer.string = @"";
    }
    
    return _tecnnicalTextLayer;
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

@end
