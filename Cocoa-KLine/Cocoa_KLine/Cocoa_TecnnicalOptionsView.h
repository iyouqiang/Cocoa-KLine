//
//  Cocoa_TecnnicalOptionsView.h
//  Cocoa-KLine
//
//  Created by Yochi on 2018/8/1.
//  Copyright © 2018年 Yochi. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Cocoa_ChartProtocol.h"

typedef void(^TecnnicalTypeBlock)(TecnnicalType tecnnicalType);

@interface Cocoa_TecnnicalOptionsView : UIView
@property (nonatomic, strong) NSArray *optionArray;
@property (nonatomic, assign) TecnnicalType tecnnicalType;
@property (nonatomic, copy) TecnnicalTypeBlock  tecnnicalTypeBlock;

@end
