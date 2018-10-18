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

#define kCandleChartScale    0.75
#define kOpentionsHeight     30.0
#define kTecnnicalChartScale 0.25

@interface Cocoa_ChartManager ()<Cocoa_ChartProtocol>

// 三层基础界面
@property (nonatomic, strong) Cocoa_CandleLineView *candleView;
@property (nonatomic, strong) Cocoa_TecnnicalOptionsView *opentionsView;
@property (nonatomic, strong) Cocoa_TecnnicalView *tecnnicalView;

// 指标界面
@property (nonatomic, strong) Cocoa_TradingVolumeView *tradingVolumeView;
@property (nonatomic, strong) Cocoa_MACDView *tradingMacdView;
@property (nonatomic, strong) Cocoa_KDJView  *tecnnicalKDJView;
@property (nonatomic, strong) Cocoa_OBVView  *tecnnicalOBVView;
@property (nonatomic, strong) Cocoa_WRView   *tecnnicalWRView;
@property (nonatomic, assign) id<Cocoa_ChartProtocol>temptecnnicalStateView;
@property (nonatomic, strong) NSMutableArray *tecnnicalArray;
@property (nonatomic, assign) TecnnicalType tecnnicalType;

// 长按十字线界面
@property (nonatomic, strong) Cocoa_CrossCurveView *crossView;
@property (nonatomic, strong) Cocoa_ChartModel *lastModel;

// 界面高度
@property (nonatomic, assign) CGFloat topKViewHeight;
@property (nonatomic, assign) CGFloat centerOptionsHeight;
@property (nonatomic, assign) CGFloat bottomTecnnicaHeight;

// 手势
@property (nonatomic,strong) UILongPressGestureRecognizer *longPressGesture;
@property (nonatomic,strong) UIPinchGestureRecognizer *pinchPressGesture;
@property (nonatomic,strong) UITapGestureRecognizer *tapGesture;
@property (nonatomic, assign) CGFloat currentZoom;

// 坐标线
@property (nonatomic, strong) CAShapeLayer *verificalLayer;

// 纵坐标值文字
@property (nonatomic, strong) CATextLayer *topTextLayer;
@property (nonatomic, strong) CATextLayer *topSecTextLayer;
@property (nonatomic, strong) CATextLayer *centerTextLayer;
@property (nonatomic, strong) CATextLayer *bottomTextLayer;
@property (nonatomic, strong) CATextLayer *bottomSecTextLayer;

// 横坐标值文字
@property (nonatomic, strong) CATextLayer *firstDateTextLayer;
@property (nonatomic, strong) CATextLayer *secondeDateTextLayer;
@property (nonatomic, strong) CATextLayer *thirdTextLayer;
@property (nonatomic, strong) CATextLayer *fourthTextLayer;

// 底部指标文字
@property (nonatomic, strong) CATextLayer *tecnnicalTextLayer;

// 均值文字
@property (nonatomic, strong) CATextLayer *ma1DataLayer;
@property (nonatomic, strong) CATextLayer *ma2DataLayer;
@property (nonatomic, strong) CATextLayer *ma3DataLayer;

@end

@implementation Cocoa_ChartManager

- (void)dealloc
{
    // 移除观察者
    [_candleView removeAllObserver];
}

// 系统调用 界面显示发生变化是，移除长十字线
- (void)didMoveToWindow {
    dispatch_async(dispatch_get_main_queue(), ^{
        
        self.mainScrollerView.scrollEnabled = YES;
        [self.crossView removeFromSuperview];
        if (self.lastModel) {
            
            [self maassignment:self.lastModel];
        }
    });
}

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    
    if (self) {
        
        self.backgroundColor = COLOR_BACKGROUND;
        
        [self calculateHeight];
        
        [self.layer addSublayer:self.verificalLayer];
        
        __weak typeof(self) weakSelf = self;
        [[NSNotificationCenter defaultCenter] addObserverForName:UIApplicationWillResignActiveNotification object:nil queue:nil usingBlock:^(NSNotification * _Nonnull note) {
            __strong typeof(self) self = weakSelf;
            dispatch_async(dispatch_get_main_queue(), ^{
               
                self.mainScrollerView.scrollEnabled = YES;
                [self.crossView removeFromSuperview];
                if (self.lastModel) {
                    
                    [self maassignment:self.lastModel];
                }
            });
        }];
        
        /** 绘制坐标系 */
        [self drawVerificalLine];
        
        /** k线的展示 */
        [self addSubview:self.mainScrollerView];
        
        /** k线图 */
        [self.mainScrollerView addSubview:self.candleView];
        
        /** 指标图  根据k线图联动*/
        [self.mainScrollerView addSubview:self.tecnnicalView];
        
        /** 展示悬浮指标 */
        [self addSubview:self.opentionsView];
        
        /******************************************/
        
        /** 加入指标视图 */
        [self.tecnnicalArray addObject:self.tradingVolumeView];
        [self.tecnnicalArray addObject:self.tradingMacdView];
        [self.tecnnicalArray addObject:self.tecnnicalKDJView];
        [self.tecnnicalArray addObject:self.tecnnicalOBVView];
        [self.tecnnicalArray addObject:self.tecnnicalWRView];
        
        /** 初始化进来 成交量 */
        [self.tecnnicalView addSubview:self.tradingVolumeView];
        self.temptecnnicalStateView = self.tradingVolumeView;
        self.tecnnicalType = TecnnicalType_VOL;
        /******************************************/
        
        __weak typeof(self) this = self;
        self.opentionsView.tecnnicalTypeBlock = ^(TecnnicalType tecnnicalType) {
            this.tecnnicalType = tecnnicalType;
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
        
        /*******************坐标上显示的文本***********************/
        
        [self.layer addSublayer:self.topTextLayer];
        [self.layer addSublayer:self.topSecTextLayer];
        [self.layer addSublayer:self.centerTextLayer];
        [self.layer addSublayer:self.bottomTextLayer];
        [self.layer addSublayer:self.bottomSecTextLayer];
        [self.layer addSublayer:self.tecnnicalTextLayer];

        [self.layer addSublayer:self.firstDateTextLayer];
        [self.layer addSublayer:self.secondeDateTextLayer];
        [self.layer addSublayer:self.thirdTextLayer];
        [self.layer addSublayer:self.fourthTextLayer];
        
        [self.layer addSublayer:self.ma1DataLayer];
        [self.layer addSublayer:self.ma2DataLayer];
        [self.layer addSublayer:self.ma3DataLayer];
        
        /******************************************/
        
        /** 布局 */
        [self main_layoutsubview];
        
        /** 添加手势 */
        [self addGestureToCandleView];
        
    }
    
    return self;
}

/** socket追加数据 */
- (void)appendingChartView
{
    // 逻辑 最左侧，重新绘制，否则只追加数据
    if (fabs(self.mainScrollerView.contentOffset.x + CGRectGetWidth(self.mainScrollerView.frame)-self.mainScrollerView.contentSize.width) <= self.candleView.candleSpace) {
        [self refreshChartView];
        
    }else {
        
        /** 刷新k线 保证其他指标赋值完成，再刷新界面 */
        [self.candleView.dataArray removeAllObjects];
        [self.candleView.dataArray addObjectsFromArray:self.dataArray];
        
        for (id<Cocoa_ChartProtocol> tecnnical in self.tecnnicalArray) {
            [tecnnical.dataArray removeAllObjects];
            [tecnnical.dataArray addObjectsFromArray:self.dataArray];
        }

        self.candleView.socketFlag = YES;
        
        // 计算指标值
        [self calculationindicators];
    }
}

/** 刷新k线 */
- (void)refreshChartView
{
    if (self.dataArray.count <=0 ) {

        // 界面数据清空
        [self.candleView.dataArray removeAllObjects];
        [self.temptecnnicalStateView.dataArray removeAllObjects];
        [self.candleView clearChartView];
        [self.temptecnnicalStateView clearChartView];
        [self clearChartView];
        
        return;
    }
    
    /** 刷新k线 保证其他指标赋值完成，再刷新界面 */
    [self.candleView.dataArray removeAllObjects];
    [self.candleView.dataArray addObjectsFromArray:self.dataArray];
    
    // 计算指标值
    [self calculationindicators];

    // 指标视图重新赋值
    for (id<Cocoa_ChartProtocol> tecnnical in self.tecnnicalArray) {
        [tecnnical.dataArray removeAllObjects];
        [tecnnical.dataArray addObjectsFromArray:self.dataArray];
    }
    
    // 刷新k线界面 核心界面，带动其它界面
    [self.candleView refreshChartView];
}

- (void)calculationindicators
{
    computeMAData(self.dataArray, 5);
    computeMAData(self.dataArray, 10);
    computeMAData(self.dataArray, 30);
    computeMACDData(self.dataArray);
    computeKDJData(self.dataArray);
    computeWRData(self.dataArray, 14);
    computeOBVData(self.dataArray);
}

- (void)clearChartView
{
    self.firstDateTextLayer.string   = @"";
    self.secondeDateTextLayer.string = @"";
    self.thirdTextLayer.string       = @"";
    self.fourthTextLayer.string      = @"";
    
    _topTextLayer.string       = @"";
    _topSecTextLayer.string    = @"";
    _centerTextLayer.string    = @"";
    _bottomTextLayer.string    = @"";
    _bottomSecTextLayer.string = @"";
    _tecnnicalTextLayer.string = @"VOL:0.00";
    
    _ma1DataLayer.string = @"";
    _ma2DataLayer.string = @"";
    _ma3DataLayer.string = @"";
}

- (void)maassignment:(Cocoa_ChartModel *)model
{
    self.ma1DataLayer.string = [NSString stringWithFormat:@"MA5:%@",klineValue(model.ma5, model.priceaccuracy)];
    self.ma2DataLayer.string = [NSString stringWithFormat:@"MA10:%@",klineValue(model.ma10, model.priceaccuracy)];
    self.ma3DataLayer.string = [NSString stringWithFormat:@"MA30:%@",klineValue(model.ma20, model.priceaccuracy)];
}

- (void)updatecoordinateValue:(Cocoa_ChartModel *)model
{
    // k线坐标值更新 model精度isLoadingMore
    self.topTextLayer.string = [NSString stringWithFormat:@"%@",klineValue(self.candleView.coordinateMaxValue, model.priceaccuracy)];
    
    self.centerTextLayer.string = [NSString stringWithFormat:@"%@",klineValue((self.candleView.coordinateMaxValue - self.candleView.coordinateminValue)/2.0 + self.candleView.coordinateminValue, model.priceaccuracy)];
    
    self.topSecTextLayer.string = [NSString stringWithFormat:@"%@",klineValue((self.candleView.coordinateMaxValue - self.candleView.coordinateminValue)*3/4.0 + self.candleView.coordinateminValue, model.priceaccuracy)];
    
    self.bottomSecTextLayer.string = [NSString stringWithFormat:@"%@",klineValue((self.candleView.coordinateMaxValue - self.candleView.coordinateminValue)/4.0 + self.candleView.coordinateminValue, model.priceaccuracy)];
    
    self.bottomTextLayer.string = [NSString stringWithFormat:@"%@",klineValue(self.candleView.coordinateminValue, model.priceaccuracy)];
}

#pragma mark - 界面绘制

/** 绘制坐标轴 */
- (void)drawVerificalLine
{
    /** 绘制横坐标五根线 */

    if (_verificalLayer) {
        [_verificalLayer removeFromSuperlayer];
        _verificalLayer = nil;
        [self.layer insertSublayer:self.verificalLayer atIndex:0];
    }
    
    /*******k线图第一条坐标线********/
    [self drawAbscissalineDashPattern:nil lineWidth:0.5 moveToPoint:CGPointMake(0.0,0.0) addLineToPoint:CGPointMake(CGRectGetWidth(self.frame),0.0)];
    
    /*******k线图中间坐标线*******@[@3, @2]*/
    [self drawAbscissalineDashPattern:nil lineWidth:0.5 moveToPoint:CGPointMake(0,self.topKViewHeight/2.0f) addLineToPoint:CGPointMake(CGRectGetWidth(self.frame),self.topKViewHeight/2.0)];
    
    /*******k线图第二根坐标线********/
    [self drawAbscissalineDashPattern:nil lineWidth:0.5 moveToPoint:CGPointMake(0,self.topKViewHeight/4.0f) addLineToPoint:CGPointMake(CGRectGetWidth(self.frame),self.topKViewHeight/4.0)];
    
    /*******k线图第四条坐标线********/
    [self drawAbscissalineDashPattern:nil lineWidth:0.5 moveToPoint:CGPointMake(0,self.topKViewHeight*3/4.0f) addLineToPoint:CGPointMake(CGRectGetWidth(self.frame),self.topKViewHeight*3/4.0)];
    
    /*******k线图最下面坐标线********/
    [self drawAbscissalineDashPattern:nil lineWidth:0.5 moveToPoint:CGPointMake(0, self.topKViewHeight) addLineToPoint:CGPointMake(CGRectGetWidth(self.frame), self.topKViewHeight)];
    
    /********指标图最下面坐标线*******/
    [self drawAbscissalineDashPattern:nil lineWidth:0.5 moveToPoint:CGPointMake(0, CGRectGetHeight(self.frame)) addLineToPoint:CGPointMake(CGRectGetWidth(self.frame), CGRectGetHeight(self.frame))];
    
    /*******指标图最上面坐标线********/
    [self drawAbscissalineDashPattern:nil lineWidth:0.5 moveToPoint:CGPointMake(0, self.topKViewHeight + self.centerOptionsHeight) addLineToPoint:CGPointMake(CGRectGetWidth(self.frame), self.topKViewHeight + self.centerOptionsHeight)];
    
    /*******指标图中间坐标线********/
    [self drawAbscissalineDashPattern:nil lineWidth:0.5 moveToPoint:CGPointMake(0, self.topKViewHeight+self.centerOptionsHeight + self.bottomTecnnicaHeight/2.0) addLineToPoint:CGPointMake(CGRectGetWidth(self.frame), self.topKViewHeight+self.centerOptionsHeight + self.bottomTecnnicaHeight/2.0)];
    
    /**
     绘制纵坐标 5根线
     */
    CGFloat coordinateHeight = _topKViewHeight+_bottomTecnnicaHeight+_centerOptionsHeight;
    coordinateHeight = CGRectGetHeight(self.frame);
    /**中间******@[@3, @2]*******/
     [self drawAbscissalineDashPattern:nil lineWidth:0.5 moveToPoint:CGPointMake(CGRectGetWidth(self.frame)/3, 0) addLineToPoint:CGPointMake(CGRectGetWidth(self.frame)/3, coordinateHeight)];
    
    /**左一*******@[@3, @2]******/
    [self drawAbscissalineDashPattern:nil lineWidth:0.5 moveToPoint:CGPointMake(CGRectGetWidth(self.frame)*2/3, 0) addLineToPoint:CGPointMake(CGRectGetWidth(self.frame)*2/3, coordinateHeight)];
}

/** 绘制横坐标 */
- (void)drawAbscissalineDashPattern:(NSArray *)lineDashPattern
                          lineWidth:(CGFloat)lineWidth
                        moveToPoint:(CGPoint)moveToPoint
                     addLineToPoint:(CGPoint)addLineToPoint
{
    CAShapeLayer *XLayer = [CAShapeLayer layer];
    XLayer.strokeColor = COLOR_COORDINATELINE.CGColor;
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
    
    if (UIGestureRecognizerStateBegan == longPress.state) {
        
        [self addSubview:self.crossView];
    }

    CGPoint originlocation = [longPress locationInView:self];
    CGPoint location = [longPress locationInView:self.crossView];
    CGFloat y = location.y;
    static CGFloat oldPositionX = 0;
    
    NSInteger temp_x = ((location.x - self.candleView.padding.left) / (self.candleView.candleWidth + self.candleView.candleSpace));
    
    temp_x = temp_x < 0 ? 0 : temp_x;
    
    temp_x = temp_x >= self.candleView.displayCount ? self.candleView.displayCount - 1 : temp_x;

    Cocoa_ChartModel *model = (self.candleView.startIndex + temp_x < self.dataArray.count) ? [self.dataArray objectAtIndex:self.candleView.startIndex + temp_x] : self.dataArray.lastObject;
    
    Cocoa_ChartModel *lastModel = [self.candleView.currentDisplayArray lastObject];
    
    self.lastModel = lastModel;
    
    CGFloat x = ((self.candleView.candleWidth) / 2) + model.highPoint.x - self.mainScrollerView.contentOffset.x;

    model.priceChangeRatio = (model.close-model.open)/model.close;
    if (model.localIndex > 1) {
     
        Cocoa_ChartModel *previousModel = self.dataArray[model.localIndex-1];
        model.priceChangeRatio = (model.close - previousModel.close)/previousModel.close;
    }
    
    // y轴坐标让用户控制
    if (UIGestureRecognizerStateChanged == longPress.state ||
        UIGestureRecognizerStateBegan   == longPress.state) {
        
        /*********/
        
        [self maassignment:model];
        
        /*********/
        
        self.crossView.touchPoint = location;
        CGFloat suspendDateLWidth = self.crossView.suspendDateL.frame.size.width;
        CGFloat centerPointX = x;
        
        if (x < suspendDateLWidth/2.0) {
            
            self.crossView.suspendDateL.center = CGPointMake(suspendDateLWidth/2.0, CGRectGetMaxY(self.crossView.frame)-8);
        }else if (x > CGRectGetWidth(self.frame) - suspendDateLWidth/2.0) {
            
             self.crossView.suspendDateL.center = CGPointMake(CGRectGetWidth(self.frame)-suspendDateLWidth/2.0, CGRectGetMaxY(self.crossView.frame)-8);
        }else {
            
             self.crossView.suspendDateL.center = CGPointMake(centerPointX, CGRectGetMaxY(self.crossView.frame)-8);
        }
        
        NSString *crossValueStr = nil;
        
        CGFloat tecnnicalValueY = originlocation.y - (self.topKViewHeight+self.centerOptionsHeight);
        
        if (originlocation.y >= self.topKViewHeight+self.centerOptionsHeight) {
        
            crossValueStr = [NSString stringWithFormat:@"%@", klineValue((self.bottomTecnnicaHeight - tecnnicalValueY)/self.temptecnnicalStateView.scaleValue + self.temptecnnicalStateView.coordinateminValue, model.volumaccuracy)];
        }
        else {

            crossValueStr = [NSString stringWithFormat:@"%@", klineValue((self.topKViewHeight-y)/self.candleView.scaleValue + self.candleView.coordinateminValue, model.priceaccuracy)];
        }
        
        [self.crossView drawCrossLineWithPoint:CGPointMake(x, y) inofStr:crossValueStr chartModel:model];
        
        self.mainScrollerView.scrollEnabled = NO;
        
        oldPositionX = location.x;
    }
    
    if(longPress.state == UIGestureRecognizerStateEnded) {
        
        self.mainScrollerView.scrollEnabled = YES;
        self.crossView.touchPoint = location;
        [self.crossView removeFromSuperview];
        
        [self maassignment:self.lastModel];
    }
}

- (void)tapGesture:(UITapGestureRecognizer*)tapGesture
{
    // 双击
    if ([self isfullScreenShow]) {
     
        if (self.landscapeSwitchBlock) {
            
            self.landscapeSwitchBlock();
        }
        
        return;
     }
     
     UIWindow *chartWindow = [[UIApplication sharedApplication] keyWindow];
     //如果window已有弹出的视图，会导致界面无法弹出，页面卡死，这里需要先把视图关闭，再弹出
     
     if (chartWindow.rootViewController.presentedViewController != nil) {
         
         [chartWindow.rootViewController dismissViewControllerAnimated:NO completion:nil];
     }
     
     Cocoa_FullScreenController *fullScreenVC = [[Cocoa_FullScreenController alloc] init];
     
     fullScreenVC.modalTransitionStyle = UIModalTransitionStyleCrossDissolve;
     
     fullScreenVC.chartManager = self;
     fullScreenVC.chartsuperView = self.superview;
     [chartWindow.rootViewController presentViewController:fullScreenVC animated:YES completion:nil];
}

/** 横竖屏切换 */
- (void)landscapeSwitch
{
    [self calculateHeight];
    [self drawVerificalLine];
    [self main_layoutsubview];
    [self refreshChartView];
}

- (BOOL)isfullScreenShow
{
    UIWindow *fK = [[UIApplication sharedApplication] keyWindow];
    if ( [fK.rootViewController.presentedViewController isKindOfClass:NSClassFromString(@"Cocoa_FullScreenController")]) {
        return YES;
    }
    
    return NO;
}

- (void)pinchesView:(UIPinchGestureRecognizer *)pinchTap
{
    
    if (pinchTap.state == UIGestureRecognizerStateEnded) {
        
        self.mainScrollerView.scrollEnabled = YES;
        
    }else if (pinchTap.state == UIGestureRecognizerStateBegan && _currentZoom != 0.0f) {
        
        self.mainScrollerView.scrollEnabled = NO;
        pinchTap.scale = _currentZoom;
        
    }else if (pinchTap.state == UIGestureRecognizerStateChanged) {
        
        self.mainScrollerView.scrollEnabled = NO;
        
        if (isnan(_currentZoom)) {
            return;
        }

        [self.candleView pinGesture:pinchTap];
    }
}

#pragma mark - Cocoa_ChartProtocol delegate
- (void)displayMoreData
{
    if (self.loadmoredataBlock) {
        
        self.loadmoredataBlock(nil);
    }
}

- (void)displayScreenleftPostion:(CGFloat)leftPostion startIndex:(NSInteger)index count:(NSInteger)count
{
    [self showIndexLineView:leftPostion startIndex:index count:count];
    
    CGFloat showContentWidth = self.candleView.displayCount * (self.candleView.candleSpace + self.candleView.candleWidth);
    
    // 获取纵坐标做 中 右 三个数据 // 底部日期更新
    if (self.candleView.currentDisplayArray.count > 0) {
        
        Cocoa_ChartModel *firstModel = [self.candleView.currentDisplayArray firstObject];
        self.firstDateTextLayer.string = firstModel.date;
        CGFloat kcontentWidth = CGRectGetWidth(self.frame) - self.candleView.padding.left - self.candleView.padding.right;
        CGFloat ksingleWidth = self.candleView.candleSpace + self.candleView.candleWidth;
        if (self.candleView.displayCount/3 < self.candleView.currentDisplayArray.count && showContentWidth > CGRectGetWidth(self.frame)/3.0) {
            NSInteger kmodelCount = kcontentWidth/(3*ksingleWidth);
            Cocoa_ChartModel *secondModel = self.candleView.currentDisplayArray[kmodelCount];
            self.secondeDateTextLayer.string = secondModel.date;
        }else {
            self.secondeDateTextLayer.string = nil;
        }
        
        if (self.candleView.displayCount*2/3 < self.candleView.currentDisplayArray.count && showContentWidth > CGRectGetWidth(self.frame)*2.0/3.0) {
        
            NSInteger kmodelCount = (kcontentWidth*2)/(3*ksingleWidth);
            Cocoa_ChartModel *thirdModel = self.candleView.currentDisplayArray[kmodelCount];
            self.thirdTextLayer.string = thirdModel.date;
        }else {
            self.thirdTextLayer.string = nil;
        }
        
        if (showContentWidth >= CGRectGetWidth(self.frame) - self.candleView.padding.left - self.candleView.padding.right) {
         
            Cocoa_ChartModel *fourthModel = [self.candleView.currentDisplayArray lastObject];
            self.fourthTextLayer.string = fourthModel.date;
        }else {
            self.fourthTextLayer.string = nil;
        }
    }
    
    // 均值数据更新
    Cocoa_ChartModel *lastModel = [self.candleView.currentDisplayArray lastObject];
    [self maassignment:lastModel];

    // 数据指标更新
    NSInteger accuracy = lastModel.priceaccuracy;
    if (self.tecnnicalType == TecnnicalType_VOL) {
        accuracy = lastModel.volumaccuracy;
    }
    self.tecnnicalTextLayer.string = [NSString stringWithFormat:@"%@:%@",self.opentionsView.optionArray[self.tecnnicalType-100],klineValue(self.temptecnnicalStateView.maxValue, accuracy)];
    
    // 坐标更新
    [self updatecoordinateValue:[self.dataArray firstObject]];
    
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
- (void)calculateHeight
{
    CGFloat totalHeight = CGRectGetHeight(self.frame)-kOpentionsHeight;
    
    self.topKViewHeight       = totalHeight*kCandleChartScale;
    self.centerOptionsHeight  = kOpentionsHeight;
    self.bottomTecnnicaHeight = totalHeight*kTecnnicalChartScale;
}

- (void)main_layoutsubview
{
    _mainScrollerView.frame = self.bounds;
    _crossView.frame = self.bounds;
    _candleView.frame = CGRectMake(0, 0, CGRectGetWidth(self.frame), self.topKViewHeight);
    _opentionsView.frame = CGRectMake(0, self.topKViewHeight, CGRectGetWidth(self.frame), self.centerOptionsHeight);
    _tecnnicalView.frame = CGRectMake(0,  self.topKViewHeight+self.centerOptionsHeight, CGRectGetWidth(_candleView.frame), self.bottomTecnnicaHeight);
    [self layoutcoordinate];
}

- (void)layoutcoordinate
{
    self.topTextLayer.frame = CGRectMake(CGRectGetWidth(self.frame)-100, 0, 100, 15);
    self.topSecTextLayer.frame = CGRectMake(CGRectGetWidth(self.frame)-100, _topKViewHeight/4.0f - 15, 100, 15);
    
    self.bottomTextLayer.frame = CGRectMake(CGRectGetWidth(self.frame)-100, _topKViewHeight-15, 100, 15);
    self.bottomSecTextLayer.frame = CGRectMake(CGRectGetWidth(self.frame)-100, _topKViewHeight*3/4.0f - 15, 100, 15);
    self.centerTextLayer.frame = CGRectMake(CGRectGetWidth(self.frame)-100, _topKViewHeight/2.0f - 15, 100, 15);
    self.tecnnicalTextLayer.frame = CGRectMake(0, _topKViewHeight +_centerOptionsHeight + _bottomTecnnicaHeight/4.0 - 15, 100, 15);
    
    CGFloat textLayerY = _topKViewHeight + _centerOptionsHeight + _bottomTecnnicaHeight - self.candleView.padding.bottom;
    self.firstDateTextLayer.frame = CGRectMake(0, textLayerY, 100, 16);
    self.secondeDateTextLayer.frame = CGRectMake(CGRectGetWidth(self.frame)/3-50, textLayerY, 100, 16);
    self.thirdTextLayer.frame = CGRectMake(CGRectGetWidth(self.frame)*2/3 - 50, textLayerY, 100, 16);
    self.fourthTextLayer.frame = CGRectMake(CGRectGetWidth(self.frame)-100, textLayerY, 100, 16);
    
    /** 均值布局 */
    self.ma1DataLayer.frame = CGRectMake(0, -16, 85, 16);
    self.ma2DataLayer.frame = CGRectMake(90, -16, 85, 16);
    self.ma3DataLayer.frame = CGRectMake(180, -16, 85, 16);
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
        _opentionsView.backgroundColor = [UIColor clearColor];
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
        _candleView.padding = UIEdgeInsetsMake(20, 5, 12, 5);
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
        COLOR_COORDINATETEXT.CGColor;
        _topTextLayer.string = @"";
    }
    
    return _topTextLayer;
}

- (CATextLayer *)topSecTextLayer
{
    if (!_topSecTextLayer) {
        
        _topSecTextLayer = [CATextLayer layer];
        _topSecTextLayer.contentsScale = [UIScreen mainScreen].scale;
        _topSecTextLayer.fontSize = 10.f;
        _topSecTextLayer.alignmentMode = kCAAlignmentRight;
        _topSecTextLayer.foregroundColor =
        COLOR_COORDINATETEXT.CGColor;
        _topSecTextLayer.string = @"";
    }
    
    return _topSecTextLayer;
}

- (CATextLayer *)bottomTextLayer
{
    if (!_bottomTextLayer) {
        
        _bottomTextLayer = [CATextLayer layer];
        _bottomTextLayer.contentsScale = [UIScreen mainScreen].scale;
        _bottomTextLayer.fontSize = 10.f;
        _bottomTextLayer.alignmentMode = kCAAlignmentRight;
        _bottomTextLayer.foregroundColor =
        COLOR_COORDINATETEXT.CGColor;
        _bottomTextLayer.string = @"";
        
    }
    
    return _bottomTextLayer;
}

- (CATextLayer *)bottomSecTextLayer
{
    if (!_bottomSecTextLayer) {
        
        _bottomSecTextLayer = [CATextLayer layer];
        _bottomSecTextLayer.contentsScale = [UIScreen mainScreen].scale;
        _bottomSecTextLayer.fontSize = 10.f;
        _bottomSecTextLayer.alignmentMode = kCAAlignmentRight;
        _bottomSecTextLayer.foregroundColor =
        COLOR_COORDINATETEXT.CGColor;
        _bottomSecTextLayer.string = @"";
        
    }
    
    return _bottomSecTextLayer;
}

- (CATextLayer *)centerTextLayer
{
    if (!_centerTextLayer) {
        
        _centerTextLayer = [CATextLayer layer];
        _centerTextLayer.contentsScale = [UIScreen mainScreen].scale;
        _centerTextLayer.fontSize = 10.f;
        _centerTextLayer.alignmentMode = kCAAlignmentRight;
        _centerTextLayer.foregroundColor =
        COLOR_COORDINATETEXT.CGColor;
        _centerTextLayer.string = @"";
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
        COLOR_COORDINATETEXT.CGColor;
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
        COLOR_COORDINATETEXT.CGColor;
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
        COLOR_COORDINATETEXT.CGColor;
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
        _fourthTextLayer.alignmentMode = kCAAlignmentRight;
        _fourthTextLayer.foregroundColor =
        COLOR_COORDINATETEXT.CGColor;
        _fourthTextLayer.string = @"";
    }
    
    return _fourthTextLayer;
}

- (CATextLayer *)tecnnicalTextLayer
{
    if (!_tecnnicalTextLayer) {
        
        _tecnnicalTextLayer = [CATextLayer layer];
        _tecnnicalTextLayer.contentsScale = [UIScreen mainScreen].scale;
        _tecnnicalTextLayer.fontSize = 10.f;
        _tecnnicalTextLayer.alignmentMode = kCAGravityLeft;
        _tecnnicalTextLayer.foregroundColor =
        COLOR_COORDINATETEXT.CGColor;
        _tecnnicalTextLayer.string = @"";
    }
    
    return _tecnnicalTextLayer;
}

- (CATextLayer *)ma1DataLayer
{
    if (!_ma1DataLayer) {
        
        _ma1DataLayer = [CATextLayer layer];
        _ma1DataLayer.contentsScale = [UIScreen mainScreen].scale;
        _ma1DataLayer.fontSize = 10.f;
        _ma1DataLayer.alignmentMode = kCAGravityLeft;
        _ma1DataLayer.foregroundColor =
        _candleView.ma1AvgLineColor.CGColor;
        _ma1DataLayer.string = @"";
    }
    
    return _ma1DataLayer;
}

- (CATextLayer *)ma2DataLayer
{
    if (!_ma2DataLayer) {
        
        _ma2DataLayer = [CATextLayer layer];
        _ma2DataLayer.contentsScale = [UIScreen mainScreen].scale;
        _ma2DataLayer.fontSize = 10.f;
        _ma2DataLayer.alignmentMode = kCAGravityLeft;
        _ma2DataLayer.foregroundColor =
        _candleView.ma2AvgLineColor.CGColor;
        _ma2DataLayer.string = @"";
    }
    
    return _ma2DataLayer;
}

- (CATextLayer *)ma3DataLayer
{
    if (!_ma3DataLayer) {
        
        _ma3DataLayer = [CATextLayer layer];
        _ma3DataLayer.contentsScale = [UIScreen mainScreen].scale;
        _ma3DataLayer.fontSize = 10.f;
        _ma3DataLayer.alignmentMode = kCAGravityLeft;
        _ma3DataLayer.foregroundColor =
        _candleView.ma3AvgLineColor.CGColor;
        _ma3DataLayer.string = @"";
    }
    
    return _ma3DataLayer;
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
