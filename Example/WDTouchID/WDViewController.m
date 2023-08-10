//
//  WDViewController.m
//  WDTouchID
//
//  Created by jocelen on 06/21/2021.
//  Copyright (c) 2021 jocelen. All rights reserved.
//

#import "WDViewController.h"
#import <WDTouchID/WDTouchID.h>

@interface WDViewController ()

@end

@implementation WDViewController


// MARK: -  life cycle

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self loadConfig];
    [self addSubviews];
}

// MARK: -  private methods

// 加载初始配置
-(void)loadConfig {
    self.title = @"验证生物识别";
    NSLog(@"生物识别签名标识----%@",[WDTouchID biometricsUpdateSymbol:nil]);
}

// 添加view
-(void)addSubviews {
    
    UIButton *touchIDButton = [[UIButton alloc] init];
    [touchIDButton setBackgroundImage:[UIImage imageNamed:@"touchid"] forState:UIControlStateNormal];
    [touchIDButton addTarget:self action:@selector(touchVerification) forControlEvents:UIControlEventTouchDown];
    touchIDButton.frame = CGRectMake((self.view.frame.size.width / 2) - 30, (self.view.frame.size.height / 2) - 30, 60, 60);
    [self.view addSubview:touchIDButton];
}

- (void)touchVerification {
    
    NSLog(@"生物识别类型----%ld",[WDTouchID supportBiometricsType]);
    [WDTouchID showBiometricsAuthWithDescribe:@"生物识别测试" faceIDDescribe:nil authFallbackTitle:nil blockState:^(WDBiometryState state, NSError *error) {
        
        if (state == WDBiometryStateNotSupport) {    //不支持TouchID
            
            UIAlertController * vc = [UIAlertController alertControllerWithTitle:@"当前设备不支持TouchID" message:nil preferredStyle:UIAlertControllerStyleAlert];
            [vc addAction:[UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDefault handler:nil]];
            [self presentViewController:vc animated:NO completion:nil];
        }
        else if (state == WDBiometryStateSuccess) {    //TouchID验证成功
            
            UIAlertController * vc = [UIAlertController alertControllerWithTitle:@"TouchID验证成功" message:nil preferredStyle:UIAlertControllerStyleAlert];
            [vc addAction:[UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDefault handler:nil]];
            [self presentViewController:vc animated:NO completion:nil];
        }
        else if (state == WDBiometryStateInputPassword) { //用户选择手动输入密码
            
            UIAlertController * vc = [UIAlertController alertControllerWithTitle:@"用户选择手动输入密码" message:@"请输入密码" preferredStyle:UIAlertControllerStyleAlert];
            [vc addAction:[UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDefault handler:nil]];
            [self presentViewController:vc animated:NO completion:nil];
        }
        else {
            UIAlertController * vc = [UIAlertController alertControllerWithTitle:@"其他错误" message:[NSString stringWithFormat:@"%ld",state] preferredStyle:UIAlertControllerStyleAlert];
            [vc addAction:[UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDefault handler:nil]];
            [self presentViewController:vc animated:NO completion:nil];
        }
        // ps:以上的状态处理并没有写完全!
        // 在使用中你需要根据回调的状态进行处理,需要处理什么就处理什么
        
    }];
    
}

// MARK: -  public methods



// MARK: -  getters and setters




@end
