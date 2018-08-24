//
//  Cocoa_CrossCurveView.m
//  Cocoa-KLine
//
//  Created by Yochi on 2018/8/4.
//  Copyright © 2018年 Yochi. All rights reserved.
//

#import "Cocoa_CrossCurveView.h"
@interface Cocoa_CrossCurveView ()
@property (nonatomic, strong) UILabel *infoLabel;
@property (nonatomic, strong) UIView *markView;
@property (nonatomic, strong) UILabel *dateL;
@property (nonatomic, strong) UILabel *openL;
@property (nonatomic, strong) UILabel *closeL;
@property (nonatomic, strong) UILabel *highL;
@property (nonatomic, strong) UILabel *lowL;
@property (nonatomic, strong) UILabel *tradingVolumeL;
@property (nonatomic, strong) UIView *shadeView;

@end

@implementation Cocoa_CrossCurveView

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    
    if (self) {
        
        [self.layer addSublayer: self.crossLayer];
        [self addSubview:self.infoLabel];
        
        _markView = [[UIView alloc] initWithFrame:CGRectMake(5, 5, 100, 130)];
        _markView.clipsToBounds = YES;
        _markView.backgroundColor = [UIColor clearColor];
        _markView.layer.cornerRadius = 5;
        [_markView setHidden:YES];
        [self addSubview:_markView];
        
        _shadeView = [[UIView alloc] initWithFrame:self.bounds];
        _shadeView.alpha = 0.8;
        _shadeView.backgroundColor = [UIColor colorWithRed:64.0/255.0 green:64.0/255.0 blue:79.0/255 alpha:1.0];
        [_markView addSubview:_shadeView];
        
        _dateL = [[UILabel alloc] initWithFrame:CGRectMake(5, 5, _markView.frame.size.width-10, 20)];
        _dateL.backgroundColor = [UIColor clearColor];
        _dateL.text = @"2018-00-00";
        _dateL.font = [UIFont systemFontOfSize:10];
        _dateL.textColor = [UIColor whiteColor];
        _dateL.adjustsFontSizeToFitWidth = YES;
        [_markView addSubview:_dateL];
        
        _openL = [[UILabel alloc] initWithFrame:CGRectMake(5, CGRectGetMaxY(_dateL.frame), _markView.frame.size.width-10, 20)];
        _openL.backgroundColor = [UIColor clearColor];
        _openL.text = @"开：0.00";
        _openL.font = [UIFont systemFontOfSize:10];
        _openL.textColor = [UIColor whiteColor];
        _openL.adjustsFontSizeToFitWidth = YES;
        [_markView addSubview:_openL];
        
        _closeL = [[UILabel alloc] initWithFrame:CGRectMake(5, CGRectGetMaxY(_openL.frame), _markView.frame.size.width-10, 20)];
        _closeL.backgroundColor = [UIColor clearColor];
        _closeL.text = @"收：0.00";
        _closeL.font = [UIFont systemFontOfSize:10];
        _closeL.textColor = [UIColor whiteColor];
        _closeL.adjustsFontSizeToFitWidth = YES;
        [_markView addSubview:_closeL];
        
        _highL = [[UILabel alloc] initWithFrame:CGRectMake(5, CGRectGetMaxY(_closeL.frame), _markView.frame.size.width-10, 20)];
        _highL.backgroundColor = [UIColor clearColor];
        _highL.text = @"高：0.00";
        _highL.font = [UIFont systemFontOfSize:10];
        _highL.textColor = [UIColor whiteColor];
        _highL.adjustsFontSizeToFitWidth = YES;
        [_markView addSubview:_highL];
        
        _lowL = [[UILabel alloc] initWithFrame:CGRectMake(5, CGRectGetMaxY(_highL.frame), _markView.frame.size.width-10, 20)];
        _lowL.backgroundColor = [UIColor clearColor];
        _lowL.text = @"低：0.00";
        _lowL.font = [UIFont systemFontOfSize:10];
        _lowL.textColor = [UIColor whiteColor];
        _lowL.adjustsFontSizeToFitWidth = YES;
        [_markView addSubview:_lowL];
        
        _tradingVolumeL = [[UILabel alloc] initWithFrame:CGRectMake(5, CGRectGetMaxY(_lowL.frame), _markView.frame.size.width-10, 20)];
        _tradingVolumeL.backgroundColor = [UIColor clearColor];
        _tradingVolumeL.text = @"量：0.00";
        _tradingVolumeL.font = [UIFont systemFontOfSize:10];
        _tradingVolumeL.textColor = [UIColor whiteColor];
        _tradingVolumeL.adjustsFontSizeToFitWidth = YES;
        [_markView addSubview:_tradingVolumeL];
    }
    
    return self;
}

- (UIColor *)crossLineColor
{
    if (!_crossLineColor) {
        _crossLineColor = COLOR_COORDINATELINE;
    }
    
    return _crossLineColor;
}

- (CAShapeLayer *)crossLayer
{
    if (!_crossLayer) {
        _crossLayer = [CAShapeLayer layer];
        _crossLayer.strokeColor = self.crossLineColor.CGColor;
        _crossLayer.lineDashPattern = @[@1, @2];
        _crossLayer.lineWidth = 1.0;
    }
    
    return _crossLayer;
}

- (UILabel *)infoLabel
{
    if (!_infoLabel) {
        
        _infoLabel = [[UILabel alloc] init];
        _infoLabel.font = [UIFont systemFontOfSize:10];
        _infoLabel.backgroundColor = COLOR_BACKGROUND;
        _infoLabel.textColor = [UIColor whiteColor];
        _infoLabel.textAlignment = NSTextAlignmentCenter;
        _infoLabel.adjustsFontSizeToFitWidth = YES;
    }
    
    return _infoLabel;
}

- (void)drawCrossLineWithPoint:(CGPoint)point inofStr:(NSString *)infoStr chartModel:(Cocoa_ChartModel*)chartModel
{
    UIBezierPath * path = [[UIBezierPath alloc]init];
    [path moveToPoint:CGPointMake(point.x, 0)];
    [path addLineToPoint:CGPointMake(point.x, CGRectGetHeight(self.frame))];
    [path moveToPoint:CGPointMake(0, point.y)];
    [path addLineToPoint:CGPointMake(CGRectGetWidth(self.frame), point.y)];
    self.crossLayer.path = path.CGPath;
    [_markView setHidden:NO];
    self.infoLabel.text = infoStr;
    self.dateL.text = chartModel.date;
    self.openL.text = [NSString stringWithFormat:@"开：%0.8f", chartModel.open];
    self.closeL.text = [NSString stringWithFormat:@"收：%0.8f", chartModel.close];
    self.highL.text = [NSString stringWithFormat:@"高：%0.8f", chartModel.high];
    self.lowL.text = [NSString stringWithFormat:@"低：%0.8f", chartModel.low];
    self.tradingVolumeL.text = [NSString stringWithFormat:@"量：%0.8f", chartModel.volume];
    
    if (point.x < 100) {
        
        self.infoLabel.frame = CGRectMake(CGRectGetWidth(self.frame)-40, point.y-8, 40, 16);
        
        if (self.markView.frame.origin.x == CGRectGetWidth(self.frame)-105) {
            return;
        }
        [UIView animateWithDuration:0.3 animations:^{
            self.markView.frame = CGRectMake(-100, 5, 100, 130);
            self.markView.alpha = 0.0;
        } completion:^(BOOL finished) {
            self.markView.frame = CGRectMake(CGRectGetWidth(self.frame)-105, 5, 100, 130);
            self.markView.alpha = 1.0;
        }];
        
    }else {
        
        self.infoLabel.frame = CGRectMake(0, point.y-8, 40, 16);

        if (self.markView.frame.origin.x == 5) {
            return;
        }
        
        [UIView animateWithDuration:0.3 animations:^{
            self.markView.frame = CGRectMake(CGRectGetWidth(self.frame), 5, 100, 130);
            self.markView.alpha = 0.0;
        } completion:^(BOOL finished) {
            self.markView.frame = CGRectMake(5, 5, 100, 130);
            self.markView.alpha = 1.0;
        }];
    }

}

@end
