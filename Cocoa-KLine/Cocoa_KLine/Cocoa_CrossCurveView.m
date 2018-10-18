//
//  Cocoa_CrossCurveView.m
//  Cocoa-KLine
//
//  Created by Yochi on 2018/8/4.
//  Copyright © 2018年 Yochi. All rights reserved.
//

#import "Cocoa_CrossCurveView.h"
#import "Cocoa_ChartModel.h"
#import "Cocoa_ChartProtocol.h"
@interface Cocoa_CrossCurveView ()<UITableViewDataSource, UITableViewDelegate>

@property (nonatomic, strong) UILabel *infoLabel;
@property (nonatomic, strong) UIView *markView;
@property (nonatomic, strong) UIView *shadeView;

@property (nonatomic, strong) UITableView *klineTableView;
@property (nonatomic, strong) NSArray *titleArray;
@property (nonatomic, strong) UILabel *dateL;
@property (nonatomic, strong) NSDateFormatter *formatter;
@property (nonatomic, strong) UIBezierPath *crossPath;

@end

@implementation Cocoa_CrossCurveView

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    
    if (self) {
        
        [self.layer addSublayer: self.crossLayer];
        [self addSubview:self.suspendDateL];
        [self addSubview:self.infoLabel];
        
        _markView = [[UIView alloc] initWithFrame:CGRectMake(5, 5, 120, 160)];
        _markView.clipsToBounds = YES;
        _markView.backgroundColor = [UIColor clearColor];
        _markView.layer.cornerRadius = 3;
        [_markView setHidden:YES];
        _markView.layer.borderWidth = 0.3;
        _markView.layer.borderColor = [UIColor blackColor].CGColor;
        [self addSubview:_markView];
        
        _markView.layer.shadowColor = [UIColor blackColor].CGColor;
        _markView.layer.shadowOffset = CGSizeMake(0, 3);
        _markView.layer.shadowOpacity = 0.8;
        _markView.layer.shadowRadius = 3.0;
        _markView.layer.masksToBounds=YES;
        
        _shadeView = [[UIView alloc] initWithFrame:self.bounds];
        _shadeView.alpha = 0.8;
        _shadeView.backgroundColor = COLOR_CROSSBACKGROUND;
        //[UIColor colorWithRed:64.0/255.0 green:64.0/255.0 blue:79.0/255 alpha:1.0];
        [_markView addSubview:_shadeView];
        
        _klineTableView = [[UITableView alloc] initWithFrame:CGRectMake(-10, 0, 140, 160) style:(UITableViewStylePlain)];
        _klineTableView.separatorStyle = UITableViewCellSeparatorStyleNone;
        _klineTableView.delegate = self;
        _klineTableView.dataSource = self;
        _klineTableView.backgroundColor = [UIColor clearColor];
        _klineTableView.tableHeaderView = self.dateL;
        [self.markView addSubview:_klineTableView];
        
        _titleArray = @[@"开", @"高", @"低", @"收", @"涨跌额", @"涨跌幅", @"成交量"];    
    }
    
    return self;
}
#pragma mark - tableView delegate
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return _titleArray.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 20;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *cellIdentify = @"cellIdentify";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentify];
    
    if (!cell) {
        
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:cellIdentify];
        cell.textLabel.font = [UIFont systemFontOfSize:10];
        cell.textLabel.textColor = COLOR_CROSSTEXT;
        cell.detailTextLabel.font = [UIFont systemFontOfSize:10];
        cell.detailTextLabel.textAlignment = NSTextAlignmentRight;
        cell.backgroundColor = [UIColor clearColor];
        cell.textLabel.adjustsFontSizeToFitWidth = YES;
        cell.detailTextLabel.adjustsFontSizeToFitWidth = YES;
        
    }
    
    if (indexPath.row == 4 || indexPath.row == 5) {
        if (self.chartModel.priceChangeRatio > 0) {
            
            cell.detailTextLabel.textColor=COLOR_RISECOLOR;
        }else {
            cell.detailTextLabel.textColor=COLOR_FALLCOLOR;
        }
        //cell.detailTextLabel.textColor = COLOR_WARNINTEXT;
    }else {
        cell.detailTextLabel.textColor = COLOR_TITLECOLOR;
    }
    
    cell.textLabel.text = _titleArray[indexPath.row];
    
    switch (indexPath.row) {
        case 0:
        {
            
            cell.detailTextLabel.text = [NSString stringWithFormat:@"%@",klineValue(self.chartModel.open, self.chartModel.priceaccuracy)];
        }
            break;
        case 1:
        {
            cell.detailTextLabel.text = [NSString stringWithFormat:@"%@", klineValue(self.chartModel.high, self.chartModel.priceaccuracy)];
        }
            break;
        case 2:
        {
            cell.detailTextLabel.text = [NSString stringWithFormat:@"%@",klineValue(self.chartModel.low, self.chartModel.priceaccuracy)];
        }
            break;
        case 3:
        {
            cell.detailTextLabel.text = [NSString stringWithFormat:@"%@",klineValue(self.chartModel.close, self.chartModel.priceaccuracy)];
        }
            break;
        case 4:
        {
            cell.detailTextLabel.text = [NSString stringWithFormat:@"%@", klineValue(self.chartModel.close - self.chartModel.open,self.chartModel.priceaccuracy)];
        }
            break;
        case 5:
        {
            cell.detailTextLabel.text = [NSString stringWithFormat:@"%0.2f%%", self.chartModel.priceChangeRatio*100];
        }
            break;
        case 6:
        {
            cell.detailTextLabel.text = [NSString stringWithFormat:@"%@",klineValue(self.chartModel.volume, self.chartModel.volumaccuracy)];
        }
            break;
            
        default:
            break;
    }
    
    return cell;
}

#pragma mark - layz

- (UIColor *)crossLineColor
{
    if (!_crossLineColor) {
        _crossLineColor = [UIColor whiteColor];
    }
    
    return _crossLineColor;
}

- (CAShapeLayer *)crossLayer
{
    if (!_crossLayer) {
        _crossLayer = [CAShapeLayer layer];
        _crossLayer.strokeColor = self.crossLineColor.CGColor;
        //_crossLayer.lineDashPattern = @[@1, @2];
        _crossLayer.lineWidth = 0.7;
    }
    
    return _crossLayer;
}

- (UILabel *)infoLabel
{
    if (!_infoLabel) {
        
        _infoLabel = [[UILabel alloc] init];
        _infoLabel.font = [UIFont systemFontOfSize:10];
        _infoLabel.backgroundColor = [UIColor blackColor];
        _infoLabel.textColor = COLOR_COORDINATETEXT;
        _infoLabel.textAlignment = NSTextAlignmentCenter;
        _infoLabel.adjustsFontSizeToFitWidth = YES;
        _infoLabel.frame = CGRectMake(CGRectGetWidth(self.frame)-50, 0, 50, 16);
    }
    
    return _infoLabel;
}

- (UILabel *)dateL
{
    if (!_dateL) {
        
        _dateL = [[UILabel alloc] init];
        _dateL.font = [UIFont systemFontOfSize:10];
        _dateL.textColor = COLOR_CROSSTEXT;
        _dateL.textAlignment = NSTextAlignmentCenter;
        _dateL.adjustsFontSizeToFitWidth = YES;
        _dateL.frame = CGRectMake(0, 0, CGRectGetWidth(self.frame), 20);
    }
    
    return _dateL;
}

- (UILabel *)suspendDateL
{
    if (!_suspendDateL) {
        
        _suspendDateL = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 60, 16)];
        _suspendDateL.font = [UIFont systemFontOfSize:10];
        _suspendDateL.backgroundColor = [UIColor blackColor];
        _suspendDateL.textAlignment = NSTextAlignmentCenter;
        _suspendDateL.textColor = COLOR_COORDINATETEXT;
        _suspendDateL.adjustsFontSizeToFitWidth = YES;
        
    }
    return _suspendDateL;
}

- (NSDateFormatter *)formatter
{
    if (!_formatter) {
        
        _formatter = [[NSDateFormatter alloc] init];
    }
    
    return _formatter;
}

- (UIBezierPath *)crossPath
{
    if (!_crossPath) {
        
        _crossPath = [UIBezierPath bezierPath];
    }
    
    return _crossPath;
}

#pragma mark - public method

- (void)drawCrossLineWithPoint:(CGPoint)point inofStr:(NSString *)infoStr chartModel:(Cocoa_ChartModel*)chartModel
{
    self.chartModel = chartModel;
    
    [self.crossPath removeAllPoints];

    // 正常操作 50% 不偷懒做法，直接写label，20%
    [self refreshCrossData];
    
    // 性能损耗比较大 A8 cpu 86%
    //[self.klineTableView reloadData];
    
    UIBezierPath * path = self.crossPath;
    [path moveToPoint:CGPointMake(point.x, 0)];
    [path addLineToPoint:CGPointMake(point.x, CGRectGetHeight(self.frame))];
    [path moveToPoint:CGPointMake(0, point.y)];
    [path addLineToPoint:CGPointMake(CGRectGetWidth(self.frame), point.y)];
    self.crossLayer.path = path.CGPath;
    [_markView setHidden:NO];
    self.infoLabel.text = infoStr;
    self.suspendDateL.text = chartModel.date;
    self.dateL.text = [self handelklineDate:chartModel.timestampStr];
    
    CGSize strSize = [self sizeWithFont:self.infoLabel.font infoStr:infoStr];
    
    if (point.x <= self.markView.frame.origin.x + self.markView.frame.size.width && self.markView.frame.origin.x == 5) {
        [self crossCurveLayout:NO point:point];
    }
    
    if (point.x >= self.markView.frame.origin.x && self.markView.frame.origin.x > 5) {
        [self crossCurveLayout:YES point:point];
    }
    
    if (self.markView.frame.origin.x <=5) {
        
        self.infoLabel.frame = CGRectMake(CGRectGetWidth(self.frame)-strSize.width-4.5, point.y-8, strSize.width+5, 16);
    }else {
        
        self.infoLabel.frame = CGRectMake(0, point.y-8, strSize.width + 5, 16);
    }
    
}

- (void)crossCurveLayout:(BOOL)isLeft point:(CGPoint)point
{
    if (!isLeft) {
        
        
        
        if (self.markView.frame.origin.x == CGRectGetWidth(self.frame)-125) {
            return;
        }
        
        self.markView.frame = CGRectMake(CGRectGetWidth(self.frame)-125, 5, 120, 160);
        
    }else {
        
        
        
        if (self.markView.frame.origin.x == 5) {
            return;
        }

        self.markView.frame = CGRectMake(5, 5, 120, 160);
    }
}

- (CGSize)sizeWithFont:(UIFont *)font infoStr:(NSString *)infoStr
{
    NSDictionary *attrs = @{NSFontAttributeName : font};
    return [infoStr boundingRectWithSize:CGSizeMake(50, 16) options:NSStringDrawingUsesLineFragmentOrigin attributes:attrs context:nil].size;
}

- (NSString *)handelklineDate:(NSString *)timestamp
{
    NSDate *date   = [NSDate dateWithTimeIntervalSince1970:timestamp.doubleValue/1000];
    
    [self.formatter setDateFormat:@"yyyy/MM/dd HH:mm"];
    
    return [self.formatter stringFromDate:date];
}

- (void)refreshCrossData
{
    UITableViewCell *cell = [self.klineTableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0]];
    cell.detailTextLabel.text = [NSString stringWithFormat:@"%@",klineValue(self.chartModel.open, self.chartModel.priceaccuracy)];
    
    UITableViewCell *cell1 = [self.klineTableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:1 inSection:0]];
    cell1.detailTextLabel.text = [NSString stringWithFormat:@"%@", klineValue(self.chartModel.high, self.chartModel.priceaccuracy)];
    
    UITableViewCell *cell2 = [self.klineTableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:2 inSection:0]];
    cell2.detailTextLabel.text = [NSString stringWithFormat:@"%@", klineValue(self.chartModel.low, self.chartModel.priceaccuracy)];
    
    UITableViewCell *cell3 = [self.klineTableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:3 inSection:0]];
    cell3.detailTextLabel.text = [NSString stringWithFormat:@"%@", klineValue(self.chartModel.close, self.chartModel.priceaccuracy)];
    
    UITableViewCell *cell4 = [self.klineTableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:4 inSection:0]];
    cell4.detailTextLabel.text = [NSString stringWithFormat:@"%@", klineValue(self.chartModel.close - self.chartModel.open,self.chartModel.priceaccuracy)];
    
    UITableViewCell *cell5 = [self.klineTableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:5 inSection:0]];
    cell5.detailTextLabel.text = [NSString stringWithFormat:@"%0.2f%%", self.chartModel.priceChangeRatio*100];
    
    UITableViewCell *cell6 = [self.klineTableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:6 inSection:0]];
    cell6.detailTextLabel.text = [NSString stringWithFormat:@"%@",klineValue(self.chartModel.volume, self.chartModel.volumaccuracy)];
    
    if (self.chartModel.priceChangeRatio > 0) {
        
        cell4.detailTextLabel.textColor=COLOR_RISECOLOR;
        cell5.detailTextLabel.textColor=COLOR_RISECOLOR;
    }else {
        cell4.detailTextLabel.textColor=COLOR_FALLCOLOR;
        cell5.detailTextLabel.textColor=COLOR_FALLCOLOR;
    }
}

@end
