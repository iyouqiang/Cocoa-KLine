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
#define COLOR_RISECOLOR [UIColor colorWithRed:249.0/255.0 green:87.0/255.0 blue:92.0/255.0 alpha:1.0]

//跌
#define COLOR_FALLCOLOR [UIColor colorWithRed:36.0/255.0 green:165.0/255.0 blue:120.0/255.0 alpha:1.0]

//背景色
//#define COLOR_BACKGROUND [UIColor colorWithRed:30.0/255.0 green:33.0/255.0 blue:48.0/255.0 alpha:1.0]

#define COLOR_BACKGROUND [UIColor colorWithRed:30.0/255.0 green:33.0/255.0 blue:50.0/255.0 alpha:1.0]
#define COLOR_CROSSBACKGROUND [UIColor colorWithRed:38.0/255.0 green:42.0/255.0 blue:64.0/255.0 alpha:1.0]
#define COLOR_CROSSTEXT [UIColor colorWithRed:142.0/255.0 green:154.0/255.0 blue:183.0/255.0 alpha:1.0]

// 高亮色
#define COLOR_HIGHLIGHT [UIColor colorWithRed:36.0/255.0 green:133.0/255.0 blue:169.0/255.0 alpha:1.0]

// 文字警告色
#define COLOR_WARNINTEXT [UIColor colorWithRed:176.0/255.0 green:100.0/255.0 blue:75.0/255.0 alpha:1.0]

// 坐标线颜色
#define COLOR_COORDINATELINE [UIColor colorWithRed:15.0/255.0 green:17.0/255.0 blue:26.0/255.0 alpha:1.0]

// 坐标文字颜色
#define COLOR_COORDINATETEXT [UIColor colorWithRed:104.0/255.0 green:105.0/255.0 blue:112.0/255.0 alpha:1.0]

// 文字标题色
#define COLOR_TITLECOLOR [UIColor colorWithRed:179.0/255.0 green:179.0/255.0 blue:179.0/255.0 alpha:1.0]

// 5 10 30 日均线
#define COLOR_MA5 [UIColor colorWithRed:204.0/255.0 green:114.0/255.0 blue:24.0/255.0 alpha:1.0]
#define COLOR_MA10 [UIColor colorWithRed:38.0/255.0 green:144.0/255.0 blue:182.0/255.0 alpha:1.0]
#define COLOR_MA30 [UIColor colorWithRed:153.0/255.0 green:82.0/255.0 blue:149.0/255.0 alpha:1.0]

#endif /* Cocoa_ChartStylesheet_h */
