//
//  Cocoa_ChartStylesheet.h
//  Cocoa-KLine
//
//  Created by Yochi on 2018/8/1.
//  Copyright © 2018年 Yochi. All rights reserved.
//

#ifndef Cocoa_ChartStylesheet_h
#define Cocoa_ChartStylesheet_h

/** 屏幕横竖屏尺寸  */
#define kSCREENWIDTH [UIScreen mainScreen].bounds.size.width

#define kSCREENHEIGHT [UIScreen mainScreen].bounds.size.height

#define kSTATUSHEIGHT [[UIApplication sharedApplication] statusBarFrame].size.height

#define kNAVIGATIONHEIGHT (kSTATUSHEIGHT + 44)

#define kTABBARHEIGHT (PCiPhoneX ? 83.0 : 49.0)

//涨
#define COLOR_RISECOLOR [UIColor colorWithRed:249.0/255.0 green:22.0/255.0 blue:40.0/255.0 alpha:1.0]

//跌
#define COLOR_FALLCOLOR [UIColor colorWithRed:25.0/255.0 green:126.0/255.0 blue:28.0/255.0 alpha:1.0]

//背景色
#define COLOR_BACKGROUND [UIColor colorWithRed:30.0/255.0 green:33.0/255.0 blue:48.0/255.0 alpha:1.0]

// 高亮色
#define COLOR_HIGHLIGHT [UIColor colorWithRed:75.0/255.0 green:159.0/255.0 blue:243.0/255.0 alpha:1.0]

// 坐标线颜色
#define COLOR_COORDINATELINE [UIColor colorWithRed:246.0/255.0 green:246.0/255.0 blue:246.0/255.0 alpha:1.0]

#endif /* Cocoa_ChartStylesheet_h */
