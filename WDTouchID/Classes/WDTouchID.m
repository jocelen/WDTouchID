//
//  WDTouchID.m
//  WDTouchID
//
//  Created by jocelen on 2021/6/21.
//

#import "WDTouchID.h"
#import <LocalAuthentication/LocalAuthentication.h>

@implementation WDTouchID

+ (instancetype)sharedInstance;
{
    static WDTouchID *instance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [[WDTouchID alloc] init];
    });
    return instance;
}

+(WDBiometryType)supportBiometricsType;
{
    WDBiometryType type = WDBiometryTypeNone;
    
    LAContext *context = [[LAContext alloc]init];
    NSError *error = nil;
    if ([context canEvaluatePolicy:LAPolicyDeviceOwnerAuthenticationWithBiometrics error:&error]) {
        if (error) {
            if (@available(iOS 11.0, *)) {
                switch (context.biometryType) {
                    case LABiometryTypeFaceID:
                        type = WDBiometryTypeFaceID;
                        break;
                    case LABiometryTypeTouchID:
                        type = WDBiometryTypeTouchID;
                        break;
                    default:
                        break;
                }
            }
            else {
                type = WDBiometryTypeTouchID;
            }
        }
    }

    return type;
}


+(void)showTouchIDWithDescribe:(NSString * _Nullable)desc blockState:(biometricsStateBlock)block;
{
    
    if (@available(iOS 8.0, *)) {
        WDBiometryType type = [self supportBiometricsType];
        
        if (type != WDBiometryTypeNone) {
            LAContext *context = [[LAContext alloc] init];
            context.localizedFallbackTitle = desc.length ? desc : (type == WDBiometryTypeTouchID ? @"通过Home键验证已有指纹" : @"面容ID");
            [context evaluatePolicy:LAPolicyDeviceOwnerAuthenticationWithBiometrics localizedReason:context.localizedFallbackTitle reply:^(BOOL success, NSError * _Nullable error) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    
                    if (success) {
                        NSLog(@"生物指纹 验证成功");
                        block(WDBiometryStateSuccess,error);
                    }
                    else if(error) {
                        
                        switch (error.code) {
                            case LAErrorAuthenticationFailed:{
                                NSLog(@"生物指纹 验证失败");
                                block(WDBiometryStateFail,error);
                                break;
                            }
                            case LAErrorUserCancel:{
                                NSLog(@"生物指纹 被用户手动取消");
                                block(WDBiometryStateUserCancel,error);
                            }
                                break;
                            case LAErrorUserFallback:{
                                NSLog(@"用户不使用生物指纹,选择手动输入密码");
                                block(WDBiometryStateInputPassword,error);
                            }
                                break;
                            case LAErrorSystemCancel:{
                                NSLog(@"生物指纹 被系统取消 (如遇到来电,锁屏,按了Home键等)");
                                block(WDBiometryStateSystemCancel,error);
                            }
                                break;
                            case LAErrorPasscodeNotSet:{
                                NSLog(@"生物指纹 无法启动,因为用户没有设置密码");
                                block(WDBiometryStatePasswordNotSet,error);
                            }
                                break;
                            case LAErrorAppCancel:{
                                NSLog(@"当前软件被挂起并取消了授权 (如App进入了后台等)");
                                block(WDBiometryStateAppCancel,error);
                            }
                                break;
                            case LAErrorInvalidContext:{
                                NSLog(@"当前软件被挂起并取消了授权 (LAContext对象无效)");
                                block(WDBiometryStateInvalidContext,error);
                            }
                                break;
                            default:
                                
                                if (@available(iOS 11.0, *))
                                {
                                    if (error.code == LAErrorBiometryNotEnrolled) {
                                        NSLog(@"生物指纹 无法启动,因为用户没有设置");
                                        block(WDBiometryStateTouchIDNotSet,error);
                                    }
                                    else if (error.code == LAErrorBiometryNotAvailable) {
                                        NSLog(@"生物指纹 无效");
                                        block(WDBiometryStateTouchIDNotAvailable,error);
                                    }
                                    else if (error.code == LAErrorBiometryLockout) {
                                        NSLog(@"生物指纹 被锁定(连续多次验证TouchID失败,系统需要用户手动输入密码)");
                                        block(WDBiometryStateTouchIDLockout,error);
                                    }
                                }
                                else {
                                    if (error.code == LAErrorTouchIDNotEnrolled) {
                                        NSLog(@"生物指纹 无法启动,因为用户没有设置");
                                        block(WDBiometryStateTouchIDNotSet,error);
                                    }
                                    else if (error.code == LAErrorTouchIDNotAvailable) {
                                        NSLog(@"生物指纹 无效");
                                        block(WDBiometryStateTouchIDNotAvailable,error);
                                    }
                                    else if (error.code == LAErrorTouchIDLockout) {
                                        NSLog(@"生物指纹 被锁定(连续多次验证失败,系统需要用户手动输入密码)");
                                        block(WDBiometryStateTouchIDLockout,error);
                                    }
                                }
                                break;
                        }
                    }
                    
                });
                
            }];
            
        }
        else {
            dispatch_async(dispatch_get_main_queue(), ^{
                NSLog(@"当前设备不支持生物指纹");
                block(WDBiometryStateNotSupport,nil);
            });
            
        }
    }
    else {
        dispatch_async(dispatch_get_main_queue(), ^{
            NSLog(@"系统版本不支持生物指纹 (必须高于iOS 8.0才能使用)");
            block(WDBiometryStateVersionNotSupport,nil);
        });
    }
}


@end
