//
//  Cocoa_FullScreenController.m
//  PurCowExchange
//
//  Created by Yochi on 2018/8/23.
//  Copyright © 2018年 Yochi. All rights reserved.
//

#import "Cocoa_FullScreenController.h"

@interface Cocoa_FullScreenController ()

@end

@implementation Cocoa_FullScreenController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.view.backgroundColor = COLOR_BACKGROUND;
    
    _chartManager.frame = CGRectMake(0, 40, kSCREENHEIGHT, kSCREENWIDTH-40);
    [self.view addSubview:_chartManager];
    
    [_chartManager landscapeSwitch];
    
    __weak typeof(self) weakSelf = self;
    _chartManager.landscapeSwitchBlock = ^{
        __strong typeof(self) self = weakSelf;
        
        [self clickAction];
    };
}

- (void)clickAction
{
    __weak typeof(self) weakSelf = self;
    [self dismissViewControllerAnimated:NO completion:^{

        __strong typeof(self) self = weakSelf;
        self.chartManager.frame = CGRectMake(0, 60, kSCREENWIDTH, kSCREENWIDTH-60);
        
        [self.chartManager landscapeSwitch];
        [self.chartsuperView addSubview:self.chartManager];
        
    }];
}

- (BOOL)shouldAutorotate{
    return NO;
}
- (UIInterfaceOrientationMask)supportedInterfaceOrientations{
    return UIInterfaceOrientationLandscapeRight | UIInterfaceOrientationMaskLandscapeLeft;
}

- (UIInterfaceOrientation)preferredInterfaceOrientationForPresentation{
    return  UIDeviceOrientationLandscapeRight | UIInterfaceOrientationLandscapeLeft;
}

- (UIStatusBarStyle)preferredStatusBarStyle {
    return UIStatusBarStyleLightContent;
}

- (BOOL)prefersStatusBarHidden {
    return NO;
}

- (UIStatusBarAnimation)preferredStatusBarUpdateAnimation {
    return UIStatusBarAnimationNone;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
