//
//  CHPermission.m
//  CHGetAuthStatus-Demo
//
//  Created by 张晨晖 on 2018/7/23.
//  Copyright © 2018年 张晨晖. All rights reserved.
//

#import "CHPermission.h"
#import <CoreBluetooth/CoreBluetooth.h>
#import <AVFoundation/AVFoundation.h>
#import <CoreLocation/CLLocationManager.h>
#import <LocalAuthentication/LocalAuthentication.h>//生物验证

@interface CHPermission ()

@end

@implementation CHPermission

+ (instancetype)sharedClass {
    static dispatch_once_t once_Token;
    static CHPermission *permission;
    dispatch_once(&once_Token, ^{
        permission = [[CHPermission alloc] init];
    });
    return permission;
}

- (void)requestAuthWithPermissionRequestType:(CHPermissionRequestType)requestType andCompleteHandle:(void(^)(CHPermissionRequestResultType resultType,CHPermissionRequestSupportType supportType))completeHandle {
    switch (requestType) {
        case CHPermission_None:
        {
            dispatch_async(dispatch_get_main_queue(), ^{
                completeHandle(CHPermissionRequestResultType_NotExplicit ,CHPermissionRequestSupportType_NotSupport);
            });
        }
            break;

            
            // MARK: 3.相机权限
        case CHPermission_CameraUsage:
        {
            AVAuthorizationStatus authStatus = [AVCaptureDevice authorizationStatusForMediaType:AVMediaTypeVideo];
            switch (authStatus) {
                case AVAuthorizationStatusNotDetermined:
                    //没有询问是否开启相机
                {
                    dispatch_async(dispatch_get_main_queue(), ^{
                        completeHandle(CHPermissionRequestResultType_NotExplicit ,CHPermissionRequestSupportType_Support);
                    });
                }
                    break;
                case AVAuthorizationStatusRestricted:
                    //未授权，家长限制
                {
                    dispatch_async(dispatch_get_main_queue(), ^{
                        completeHandle(CHPermissionRequestResultType_ParentallyRestricted ,CHPermissionRequestSupportType_Support);
                    });
                }
                    break;
                case AVAuthorizationStatusDenied:
                {
                    dispatch_async(dispatch_get_main_queue(), ^{
                        completeHandle(CHPermissionRequestResultType_Reject ,CHPermissionRequestSupportType_Support);
                    });
                }
                    break;
                case AVAuthorizationStatusAuthorized:
                {
                    dispatch_async(dispatch_get_main_queue(), ^{
                        completeHandle(CHPermissionRequestResultType_Granted ,CHPermissionRequestSupportType_Support);
                    });
                }
                    break;
                default:
                    break;
            }
        }
            break;

        // MARK: Face_ID
        case CHPermission_FaceIDUsage:
        {
            LAContext *context = [[LAContext alloc] init];
            if ([context canEvaluatePolicy:LAPolicyDeviceOwnerAuthenticationWithBiometrics error:nil]) {
                if (@available(iOS 11.0, *)) {
                    if (context.biometryType == LABiometryTypeTouchID) {
                        NSString *reason;
                        if ([[[NSBundle mainBundle] infoDictionary] objectForKey:@"NSFaceIDUsageDescription"]) {
                            reason = [[[NSBundle mainBundle] infoDictionary] objectForKey:@"NSFaceIDUsageDescription"];
                        } else {
                            reason = @"";
                        }
                        [context evaluatePolicy:LAPolicyDeviceOwnerAuthenticationWithBiometrics localizedReason:reason reply:^(BOOL success, NSError * _Nullable error) {
                            if (success) {
                                completeHandle(CHPermissionRequestResultType_Granted ,CHPermissionRequestSupportType_Support);
                            } else {
                                // MARK :这个可以多次调用
                                completeHandle(CHPermissionRequestResultType_NotExplicit ,CHPermissionRequestSupportType_Support);
                            }
                        }];
                    } else {///指纹识别,密码识别等
                        completeHandle(CHPermissionRequestResultType_Reject ,CHPermissionRequestSupportType_NotSupport);
                    }
                } else {
                    // Fallback on earlier versions
                    completeHandle(CHPermissionRequestResultType_Reject ,CHPermissionRequestSupportType_NotSupport);
                }
            } else {
                completeHandle(CHPermissionRequestResultType_Reject ,CHPermissionRequestSupportType_NotSupport);
            }
        }
            break;

        // MARK: 8.9.10.定位权限
        case CHPermission_LocationLocationAlwaysUsage:
        case CHPermission_LocationLocationUsage:
        case CHPermission_LocationLocationWhenInUseUsage:
        {
            CLAuthorizationStatus status = [CLLocationManager authorizationStatus];
            if ([CLLocationManager locationServicesEnabled]) {
                if (status == kCLAuthorizationStatusAuthorizedWhenInUse || status == kCLAuthorizationStatusAuthorizedAlways) {
                    if (requestType == CHPermission_LocationLocationAlwaysUsage) {
                        if (status == kCLAuthorizationStatusAuthorizedAlways) {
                            dispatch_async(dispatch_get_main_queue(), ^{
                                completeHandle(CHPermissionRequestResultType_Granted ,CHPermissionRequestSupportType_Support);
                            });
                        } else {
                            dispatch_async(dispatch_get_main_queue(), ^{/// 只开启使用时认证,不开启一直认证.返回Reject.
                                completeHandle(CHPermissionRequestResultType_Reject ,CHPermissionRequestSupportType_Support);
                            });
                        }
                    } else if (requestType == CHPermission_LocationLocationUsage) {
                        dispatch_async(dispatch_get_main_queue(), ^{
                            completeHandle(CHPermissionRequestResultType_Granted ,CHPermissionRequestSupportType_Support);
                        });
                    } else if (requestType == CHPermission_LocationLocationWhenInUseUsage) {
                        dispatch_async(dispatch_get_main_queue(), ^{
                            completeHandle(CHPermissionRequestResultType_Granted ,CHPermissionRequestSupportType_Support);
                        });
                    }
                } else if (status == kCLAuthorizationStatusRestricted) {
                    dispatch_async(dispatch_get_main_queue(), ^{
                        completeHandle(CHPermissionRequestResultType_ParentallyRestricted ,CHPermissionRequestSupportType_Support);
                    });
                } else if (status == kCLAuthorizationStatusNotDetermined) {
                    dispatch_async(dispatch_get_main_queue(), ^{
                        completeHandle(CHPermissionRequestResultType_NotExplicit ,CHPermissionRequestSupportType_Support);
                    });
                } else if (status == kCLAuthorizationStatusDenied) {
                    //定位不可用
                    dispatch_async(dispatch_get_main_queue(), ^{
                        completeHandle(CHPermissionRequestResultType_Reject ,CHPermissionRequestSupportType_Support);
                    });
                }
            } else {
                //定位不可用
                dispatch_async(dispatch_get_main_queue(), ^{
                    completeHandle(CHPermissionRequestResultType_Reject ,CHPermissionRequestSupportType_Support);
                });
            }
            break;
        }

        // MARK: 13.麦克风权限
        case CHPermission_MicrophoneUsage:
        {
            AVAuthorizationStatus videoAuthStatus = [AVCaptureDevice authorizationStatusForMediaType:AVMediaTypeVideo];
            switch (videoAuthStatus) {
                case AVAuthorizationStatusNotDetermined:
                {
                    //第一次提示用户授权
                    [AVCaptureDevice requestAccessForMediaType:AVMediaTypeVideo completionHandler:^(BOOL granted) {
                        if (granted) {
                            dispatch_async(dispatch_get_main_queue(), ^{
                                completeHandle(CHPermissionRequestResultType_Granted ,CHPermissionRequestSupportType_Support);
                            });
                        } else {
                            dispatch_async(dispatch_get_main_queue(), ^{
                                completeHandle(CHPermissionRequestResultType_Reject ,CHPermissionRequestSupportType_Support);
                            });
                        }
                    }];
                    break;
                }
                case AVAuthorizationStatusAuthorized:
                {
                    dispatch_async(dispatch_get_main_queue(), ^{
                        completeHandle(CHPermissionRequestResultType_Granted ,CHPermissionRequestSupportType_Support);
                    });
                    break;
                }
                case AVAuthorizationStatusRestricted:
                {
                    dispatch_async(dispatch_get_main_queue(), ^{
                        completeHandle(CHPermissionRequestResultType_ParentallyRestricted ,CHPermissionRequestSupportType_Support);
                    });
                }
                case AVAuthorizationStatusDenied:
                {
                    dispatch_async(dispatch_get_main_queue(), ^{
                        completeHandle(CHPermissionRequestResultType_Reject ,CHPermissionRequestSupportType_Support);
                    });
                }
                    break;
                default:
                    break;
            }

            break;
        }

        // MARK: 17.相册权限
        case CHPermission_PhotoLibraryUsage:
        {
            NSString *mediaType = AVMediaTypeVideo;//读取媒体类型
            AVAuthorizationStatus authStatus = [AVCaptureDevice authorizationStatusForMediaType:mediaType];//读取设备授权状态
            switch (authStatus) {
                case AVAuthorizationStatusNotDetermined:
                {
                    dispatch_async(dispatch_get_main_queue(), ^{
                        completeHandle(CHPermissionRequestResultType_NotExplicit ,CHPermissionRequestSupportType_Support);
                    });
                }
                    break;
                case AVAuthorizationStatusAuthorized:
                {
                    dispatch_async(dispatch_get_main_queue(), ^{
                        completeHandle(CHPermissionRequestResultType_Granted ,CHPermissionRequestSupportType_Support);
                    });
                }
                    break;
                case AVAuthorizationStatusRestricted:
                {
                    dispatch_async(dispatch_get_main_queue(), ^{
                        completeHandle(CHPermissionRequestResultType_ParentallyRestricted ,CHPermissionRequestSupportType_Support);
                    });
                }
                    break;
                case AVAuthorizationStatusDenied:
                {
                    dispatch_async(dispatch_get_main_queue(), ^{
                        completeHandle(CHPermissionRequestResultType_Reject ,CHPermissionRequestSupportType_Support);
                    });
                }
                    break;
                default:
                    break;
            }
        }
            break;
        default:
            break;
    }
}

@end
