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

- (void)requestAuthWithPermissionRequestType:(CHPermissionRequestType)requestType andCompleteHandle:(void(^)(CHPermissionRequestResultType resultType))completeHandle {
    switch (requestType) {
        case CHPermission_None:
        {
            dispatch_async(dispatch_get_main_queue(), ^{
                completeHandle(CHPermissionRequestResultType_NotExplicit);
            });
        }
            break;

        // MARK: 1.定位权限
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
                                completeHandle(CHPermissionRequestResultType_Granted);
                            });
                        } else {
                            dispatch_async(dispatch_get_main_queue(), ^{/// 只开启使用时认证,不开启一直认证.返回Reject.
                                completeHandle(CHPermissionRequestResultType_Reject);
                            });
                        }
                    } else if (requestType == CHPermission_LocationLocationUsage) {
                        dispatch_async(dispatch_get_main_queue(), ^{
                            completeHandle(CHPermissionRequestResultType_Granted);
                        });
                    } else if (requestType == CHPermission_LocationLocationWhenInUseUsage) {
                        dispatch_async(dispatch_get_main_queue(), ^{
                            completeHandle(CHPermissionRequestResultType_Granted);
                        });
                    }
                } else if (status == kCLAuthorizationStatusRestricted) {
                    dispatch_async(dispatch_get_main_queue(), ^{
                        completeHandle(CHPermissionRequestResultType_ParentallyRestricted);
                    });
                } else if (status == kCLAuthorizationStatusNotDetermined) {
                    dispatch_async(dispatch_get_main_queue(), ^{
                        completeHandle(CHPermissionRequestResultType_NotExplicit);
                    });
                } else if (status == kCLAuthorizationStatusDenied) {
                    //定位不可用
                    dispatch_async(dispatch_get_main_queue(), ^{
                        completeHandle(CHPermissionRequestResultType_Reject);
                    });
                }
            } else {
                //定位不可用
                dispatch_async(dispatch_get_main_queue(), ^{
                    completeHandle(CHPermissionRequestResultType_Reject);
                });
            }
            break;
        }

        // MARK: 7.麦克风权限
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
                                completeHandle(CHPermissionRequestResultType_Granted);
                            });
                        } else {
                            dispatch_async(dispatch_get_main_queue(), ^{
                                completeHandle(CHPermissionRequestResultType_Reject);
                            });
                        }
                    }];
                    break;
                }
                case AVAuthorizationStatusAuthorized:
                {
                    dispatch_async(dispatch_get_main_queue(), ^{
                        completeHandle(CHPermissionRequestResultType_Granted);
                    });
                    break;
                }
                case AVAuthorizationStatusRestricted:
                {
                    dispatch_async(dispatch_get_main_queue(), ^{
                        completeHandle(CHPermissionRequestResultType_ParentallyRestricted);
                    });
                }
                case AVAuthorizationStatusDenied:
                {
                    dispatch_async(dispatch_get_main_queue(), ^{
                        completeHandle(CHPermissionRequestResultType_Reject);
                    });
                }
                    break;
                default:
                    break;
            }

            break;
        }

        // MARK: 9.相机权限
        case CHPermission_CameraUsage:
        {
            AVAuthorizationStatus authStatus = [AVCaptureDevice authorizationStatusForMediaType:AVMediaTypeVideo];
            switch (authStatus) {
                case AVAuthorizationStatusNotDetermined:
                    //没有询问是否开启相机
                {
                    dispatch_async(dispatch_get_main_queue(), ^{
                        completeHandle(CHPermissionRequestResultType_NotExplicit);
                    });
                }
                    break;
                case AVAuthorizationStatusRestricted:
                    //未授权，家长限制
                {
                    dispatch_async(dispatch_get_main_queue(), ^{
                        completeHandle(CHPermissionRequestResultType_ParentallyRestricted);
                    });
                }
                    break;
                case AVAuthorizationStatusDenied:
                {
                    dispatch_async(dispatch_get_main_queue(), ^{
                        completeHandle(CHPermissionRequestResultType_Reject);
                    });
                }
                    break;
                case AVAuthorizationStatusAuthorized:
                {
                    dispatch_async(dispatch_get_main_queue(), ^{
                        completeHandle(CHPermissionRequestResultType_Granted);
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
//        CHPermission_None                  = 0,
//        CHPermission_Contacts              = 2,    // 通讯录
//        CHPermission_Calendars             = 3,    // 日历
//        CHPermission_Reminders             = 4,    // 提醒事项
//        CHPermission_Photos                = 5,    // 照片
//        CHPermission_BluetoothSharing      = 6,    // 蓝牙共享
//        CHPermission_Microphone            = 7,    // 麦克风
//        CHPermission_SpeechRecognition     = 8,    // 语音识别 >= iOS10
//        CHPermission_Health                = 10,   // 健康 >= iOS8.0
//        CHPermission_HomeKit               = 11,   // 家庭 >= iOS8.0
//        CHPermission_MediaAndAppleMusic    = 12,   // 媒体与Apple Music >= iOS9.3
//        CHPermission_MotionAndFitness      = 13,   // 运动与健身

}

@end
