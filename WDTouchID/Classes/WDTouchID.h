//
//  WDTouchID.h
//  WDTouchID
//
//  Created by jocelen on 2021/6/21.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

/**
 *  生物指纹状态
 */
typedef NS_ENUM(NSUInteger, WDBiometryState){
    /// 当前设备不支持生物验证
    WDBiometryStateNotSupport = 0,
    /// TouchID 验证成功
    WDBiometryStateSuccess = 1,
    /// TouchID 验证失败
    WDBiometryStateFail = 2,
    /// TouchID 被用户手动取消
    WDBiometryStateUserCancel = 3,
    /// 用户不使用生物验证,选择手动输入密码
    WDBiometryStateInputPassword = 4,
    /// 生物验证 被系统取消 (如遇到来电,锁屏,按了Home键等)
    WDBiometryStateSystemCancel = 5,
    /// 生物验证 无法启动,因为用户没有设置密码
    WDBiometryStatePasswordNotSet = 6,
    /// 生物验证 无法启动,因为用户没有设置生物验证
    WDBiometryStateTouchIDNotSet = 7,
    /// 生物验证 无效
    WDBiometryStateTouchIDNotAvailable = 8,
    /// 生物验证 被锁定(连续多次验证TouchID失败,系统需要用户手动输入密码)
    WDBiometryStateTouchIDLockout = 9,
    /// 当前软件被挂起并取消了授权 (如App进入了后台等)
    WDBiometryStateAppCancel = 10,
    /// 当前软件被挂起并取消了授权 (LAContext对象无效)
    WDBiometryStateInvalidContext = 11,
    /// 系统版本不支持TouchID (必须高于iOS 8.0才能使用)
    WDBiometryStateVersionNotSupport = 12
};



/**
 *  生物识别特征
 */
typedef NS_ENUM(NSUInteger, WDBiometryType){
    WDBiometryTypeNone = 0,
    WDBiometryTypeTouchID = 1,
    WDBiometryTypeFaceID = 2,
};

@interface WDTouchID : NSObject

typedef void (^biometricsStateBlock)(WDBiometryState state,NSError * _Nullable error);


/**
 *  判断是否支持Face ID / Touch ID
 *
 *  @return 支持类型
 */
+(WDBiometryType)supportBiometricsType;



/**
 *  启动TouchID进行验证
 *
 *  @param touchDesc TouchID显示的描述
 *  @param faceDesc FaceID显示的描述
 *  @param backTitle 失败后的描述
 *  @param block 回调状态的block
 *
 */
+(void)showTouchIDWithDescribe:(NSString * _Nullable)touchDesc faceIDDescribe:(NSString * _Nullable)faceDesc authFallbackTitle:(NSString * _Nullable)backTitle blockState:(biometricsStateBlock)block;

@end

NS_ASSUME_NONNULL_END
