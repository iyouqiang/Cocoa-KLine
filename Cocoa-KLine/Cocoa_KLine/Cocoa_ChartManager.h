//
//  Cocoa_ChartManager.h
//  Cocoa-KLine
//
//  Created by Yochi on 2018/7/31.
//  Copyright © 2018年 Yochi. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "Cocoa_ChartModel.h"
#import "Cocoa_CandleLineView.h"

typedef void(^ChangeCompleteBlock)(id DataInfo);

typedef void(^LoadmoredataBlock)(id DataInfo);

typedef void(^LandscapeSwitchBlock)(void);

@interface Cocoa_ChartManager : UIView

@property (nonatomic, strong) UIScrollView *mainScrollerView;

/** 是否支持长按手势(默认:支持) **/
@property (nonatomic, assign) BOOL longPressEnabled;
/** 是否支持滑动手势(默认:支持) **/
@property (nonatomic, assign) BOOL panEnabled;
/** 是否支持啮合放大缩小手势(默认:支持) **/
@property (nonatomic, assign) BOOL pinEnabled;
/** 是否支持轻拍切换类型手势(默认:支持) **/
@property (nonatomic, assign) BOOL tapEnabled;

/** 数据回调 */
@property (nonatomic, strong) ChangeCompleteBlock changeCompleteBlock;

/** 刷新数据 */
@property (nonatomic, strong) LoadmoredataBlock loadmoredataBlock;

/** 全屏切换 */ 
@property (nonatomic, strong) LandscapeSwitchBlock landscapeSwitchBlock;

/** 初始化数据 */
@property (nonatomic,strong) NSMutableArray<__kindof Cocoa_ChartModel*> *dataArray;

/** 双击 横竖屏切换 */
- (void)landscapeSwitch;

/** 刷新数据 */
- (void)refreshChartView;

/** socket追加数据 */
- (void)appendingChartView;

@end
