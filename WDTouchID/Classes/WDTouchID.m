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
    LAContext *context = [[LAContext alloc] init];
    [context canEvaluatePolicy:LAPolicyDeviceOwnerAuthenticationWithBiometrics error:nil];
    if (@available(iOS 11.0, *)) {
        if (context.biometryType == LABiometryTypeFaceID) {
            return WDBiometryTypeFaceID;
        }
        else if (context.biometryType == LABiometryTypeTouchID) {
            return WDBiometryTypeTouchID;
        }
    }
    return WDBiometryTypeNone;
}


+(BOOL)canBiometrics:(NSError * __autoreleasing *)error;
{
    LAContext *context = [[LAContext alloc] init];
    return [context canEvaluatePolicy:LAPolicyDeviceOwnerAuthenticationWithBiometrics error:error];
}

+(NSString * _Nullable)biometricsUpdateSymbol:(NSError * __autoreleasing *)error;
{
    LAContext *context = [[LAContext alloc] init];
    if ([context canEvaluatePolicy:LAPolicyDeviceOwnerAuthenticationWithBiometrics error:error]) {
        NSData * base64 = [context.evaluatedPolicyDomainState base64EncodedDataWithOptions:NSDataBase64Encoding64CharacterLineLength];
        return base64 ? [[NSString alloc] initWithData:base64 encoding:NSUTF8StringEncoding] : nil;
    }
    return nil;
}

+(void)showBiometricsAuthWithDescribe:(NSString * _Nullable)touchDesc faceIDDescribe:(NSString * _Nullable)faceDesc authFallbackTitle:(NSString * _Nullable)backTitle blockState:(biometricsStateBlock)block;
{
    WDBiometryType supperType = [self supportBiometricsType];
    
    NSString *descStr;
    switch (supperType) {
        case WDBiometryTypeTouchID:
        {
            descStr = touchDesc.length == 0 ? @"通过Home键验证已有指纹" : touchDesc;
        }
            break;
        case WDBiometryTypeFaceID:
        {
            descStr = faceDesc.length == 0 ? @"通过已有面容ID验证" : faceDesc;
        }
        default:
            break;
    }

    if (@available(iOS 8.0, *)) {
        
        LAContext *context = [[LAContext alloc] init];
        context.localizedFallbackTitle = backTitle == nil ? @"输入密码验证" : backTitle;
        
        NSError *error = nil;
        
        if ([context canEvaluatePolicy:LAPolicyDeviceOwnerAuthenticationWithBiometrics error:&error]) {
            [context evaluatePolicy:LAPolicyDeviceOwnerAuthenticationWithBiometrics localizedReason:descStr reply:^(BOOL success, NSError * _Nullable error) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    if (success) {
                        NSLog(@"生物指纹 验证成功");
                        block(WDBiometryStateSuccess,error);
                    }
                    else {
                        [self biometricsAuthError:error handler:block];
                    }
                });
            }];
        }
        else {
            dispatch_async(dispatch_get_main_queue(), ^{
                [self biometricsAuthError:error handler:block];
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

+(void)biometricsAuthError:(NSError * _Nullable)error handler:(biometricsStateBlock)block
{
    if(error) {
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
                break;
        }
        
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
        
    }
    else {
        NSLog(@"当前设备不支持生物指纹");
        block(WDBiometryStateNotSupport,nil);
    }
}

@end
