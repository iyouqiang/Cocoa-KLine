//
//  Cocoa_TecnnicalOptionsView.m
//  Cocoa-KLine
//
//  Created by Yochi on 2018/8/1.
//  Copyright © 2018年 Yochi. All rights reserved.
//

#import "Cocoa_TecnnicalOptionsView.h"
#import "Cocoa_ChartStylesheet.h"
@interface Cocoa_TecnnicalOptionsView ()

@property (nonatomic, strong) UIButton *lastBtn;

@end

@implementation Cocoa_TecnnicalOptionsView

- (instancetype)init
{
    self = [super init];
    
    if (self) {
        
        self.backgroundColor = COLOR_BACKGROUND;
        _optionArray = @[@"VOL", @"MACD", @"KDJ", @"OBV", @"WR"];
        [self setup];
    }
    
    return self;
}

- (void)setup
{
    CGFloat gap = 5;
    CGFloat btnWidth = (kSCREENWIDTH - (_optionArray.count  + 1) * gap)/_optionArray.count;
    
    [_optionArray enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
       
        dispatch_async(dispatch_get_main_queue(), ^{
           
            UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
            button.tag = 100 + idx;
            button.frame = CGRectMake(gap + idx*(gap + btnWidth), 0, btnWidth, CGRectGetHeight(self.frame));
            [button setTitle:self->_optionArray[idx] forState:UIControlStateNormal];
            button.titleLabel.font = [UIFont systemFontOfSize:14];
            [button setTitleColor:COLOR_COORDINATETEXT forState:UIControlStateNormal];
            [button setTitleColor:COLOR_WARNINTEXT forState:UIControlStateSelected];
            [button addTarget:self action:@selector(changeTecnnicalView:) forControlEvents:UIControlEventTouchUpInside];
            [self addSubview:button];
            
            if (idx == 0) {
                self.lastBtn = button;
                self.lastBtn.selected = YES;
            }
        });
    }];
}
//@[@"VOL", @"MACD", @"KDJ", @"OBV", @"RSI", @"WR"];
- (void)changeTecnnicalView:(UIButton *)btn
{
    if ([self.lastBtn isEqual:btn]) {
        return;
    }
    self.lastBtn.selected = NO;
    btn.selected = YES;
    self.lastBtn = btn;
    
    NSString *tecnnicalStr = _optionArray[btn.tag - 100];
    
    if ([tecnnicalStr isEqualToString:@"VOL"]) {
        
        self.tecnnicalType = TecnnicalType_VOL;
    }else if ([tecnnicalStr isEqualToString:@"MACD"]) {
        
        self.tecnnicalType = TecnnicalType_MACD;
    }else if ([tecnnicalStr isEqualToString:@"KDJ"]) {
        
        self.tecnnicalType = TecnnicalType_KDJ;
    }else if ([tecnnicalStr isEqualToString:@"OBV"]) {
        
        self.tecnnicalType = TecnnicalType_OBV;
    }else if ([tecnnicalStr isEqualToString:@"WR"]) {
        
        self.tecnnicalType = TecnnicalType_WR;
    }
    
    if (self.tecnnicalTypeBlock) {
        
        self.tecnnicalTypeBlock(self.tecnnicalType);
    }
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
