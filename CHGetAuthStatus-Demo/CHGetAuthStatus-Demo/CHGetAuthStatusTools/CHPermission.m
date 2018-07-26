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

@interface CHPermission () <CLLocationManagerDelegate>

@property (nonatomic ,assign) CHPermissionRequestType requestType;

@property (nonatomic ,strong) CLLocationManager *locationManager;

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

- (void)requestAuthWithPermissionRequestType:(CHPermissionRequestType)requestType andCompleteHandle:(void(^)(CHPermissionRequestSupportType supportType))completeHandle {
    self.requestType = requestType;
    switch (requestType) {
        case CHPermission_None:
        {
            dispatch_async(dispatch_get_main_queue(), ^{
                completeHandle(CHPermissionRequestSupportType_NotSupport);
                if (self.permissionRequestResultBlock) {
                    self.permissionRequestResultBlock(CHPermissionRequestResultType_NotExplicit);
                }
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
                    [AVCaptureDevice requestAccessForMediaType:AVMediaTypeVideo completionHandler:^(BOOL granted) {
                        if (granted == YES) {
                            dispatch_async(dispatch_get_main_queue(), ^{
                                completeHandle(CHPermissionRequestSupportType_Support);
                                if (self.permissionRequestResultBlock) {
                                    self.permissionRequestResultBlock(CHPermissionRequestResultType_Granted);
                                }
                            });
                        } else {
                           dispatch_async(dispatch_get_main_queue(), ^{
                               completeHandle(CHPermissionRequestSupportType_Support);
                               if (self.permissionRequestResultBlock) {
                                   self.permissionRequestResultBlock(CHPermissionRequestResultType_Reject);
                               }
                           });
                        }
                    }];
                }
                    break;
                case AVAuthorizationStatusRestricted:
                    //未授权，家长限制
                {
                    dispatch_async(dispatch_get_main_queue(), ^{
                        completeHandle(CHPermissionRequestSupportType_Support);
                        if (self.permissionRequestResultBlock) {
                            self.permissionRequestResultBlock(CHPermissionRequestResultType_ParentallyRestricted);
                        }
                    });
                }
                    break;
                case AVAuthorizationStatusDenied:
                {
                    dispatch_async(dispatch_get_main_queue(), ^{
                        completeHandle(CHPermissionRequestSupportType_Support);
                        if (self.permissionRequestResultBlock) {
                            self.permissionRequestResultBlock(CHPermissionRequestResultType_Reject);
                        }
                    });
                }
                    break;
                case AVAuthorizationStatusAuthorized:
                {
                    dispatch_async(dispatch_get_main_queue(), ^{
                        completeHandle(CHPermissionRequestSupportType_Support);
                        if (self.permissionRequestResultBlock) {
                            self.permissionRequestResultBlock(CHPermissionRequestResultType_Granted);
                        }
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
                                completeHandle(CHPermissionRequestSupportType_Support);
                                if (self.permissionRequestResultBlock) {
                                    self.permissionRequestResultBlock(CHPermissionRequestResultType_Granted);
                                }
                            } else {
                                // MARK :这个可以多次调用
                                completeHandle(CHPermissionRequestSupportType_Support);
                                if (self.permissionRequestResultBlock) {
                                    self.permissionRequestResultBlock(CHPermissionRequestResultType_NotExplicit);
                                }
                            }
                        }];
                    } else {///指纹识别,密码识别等
                        completeHandle(CHPermissionRequestSupportType_NotSupport);
                        if (self.permissionRequestResultBlock) {
                            self.permissionRequestResultBlock(CHPermissionRequestResultType_Reject);
                        }
                    }
                } else {
                    // Fallback on earlier versions
                    completeHandle(CHPermissionRequestSupportType_NotSupport);
                    if (self.permissionRequestResultBlock) {
                        self.permissionRequestResultBlock(CHPermissionRequestResultType_Reject);
                    }
                }
            } else {
                completeHandle(CHPermissionRequestSupportType_NotSupport);
                if (self.permissionRequestResultBlock) {
                    self.permissionRequestResultBlock(CHPermissionRequestResultType_Reject);
                }
            }
        }
            break;

        // MARK: 8.9.10.定位权限
        case CHPermission_LocationLocationAlwaysUsage:
        case CHPermission_LocationLocationUsage:
        case CHPermission_LocationLocationWhenInUseUsage:
        {
            if ([CLLocationManager locationServicesEnabled]) {
                CLAuthorizationStatus status = [CLLocationManager authorizationStatus];
                switch (status) {
                    case kCLAuthorizationStatusAuthorizedAlways:
                    {
                        dispatch_async(dispatch_get_main_queue(), ^{
                            completeHandle(CHPermissionRequestSupportType_Support);
                        });
                        if (self.permissionRequestResultBlock) {
                            self.permissionRequestResultBlock(CHPermissionRequestResultType_Granted);
                        }
                    }
                        break;
                    case kCLAuthorizationStatusAuthorizedWhenInUse:
                    {
                        switch (self.requestType) {
                            case CHPermission_LocationLocationAlwaysUsage:
                            {
                                dispatch_async(dispatch_get_main_queue(), ^{
                                    completeHandle(CHPermissionRequestSupportType_Support);
                                });
                                /// 请求定位授权

                            }
                                break;
                            case CHPermission_LocationLocationUsage:
                            case CHPermission_LocationLocationWhenInUseUsage:
                            {
                                dispatch_async(dispatch_get_main_queue(), ^{
                                    completeHandle(CHPermissionRequestSupportType_Support);
                                });
                                if (self.permissionRequestResultBlock) {
                                    self.permissionRequestResultBlock(CHPermissionRequestResultType_Granted);
                                }
                            }
                            default:
                                break;
                        }
                    }
                        break;
                    case kCLAuthorizationStatusRestricted:
                    {
                        dispatch_async(dispatch_get_main_queue(), ^{
                            completeHandle(CHPermissionRequestSupportType_Support);
                        });
                        if (self.permissionRequestResultBlock) {
                            self.permissionRequestResultBlock(CHPermissionRequestResultType_ParentallyRestricted);
                        }
                    }
                        break;
                    case kCLAuthorizationStatusDenied:
                    {
                        dispatch_async(dispatch_get_main_queue(), ^{
                            completeHandle(CHPermissionRequestSupportType_Support);
                        });
                        if (self.permissionRequestResultBlock) {
                            self.permissionRequestResultBlock(CHPermissionRequestResultType_Reject);
                        }
                    }
                    case kCLAuthorizationStatusNotDetermined:
                    {
                        dispatch_async(dispatch_get_main_queue(), ^{
                            completeHandle(CHPermissionRequestSupportType_Support);
                        });
                        if (self.permissionRequestResultBlock) {
                            self.permissionRequestResultBlock(CHPermissionRequestResultType_NotExplicit);
                        }
                    }
                        break;
                    default:
                        break;
                }
            } else {
                //定位不可用
                dispatch_async(dispatch_get_main_queue(), ^{
                    completeHandle(CHPermissionRequestSupportType_Support);
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
                                completeHandle(CHPermissionRequestSupportType_Support);
                                if (self.permissionRequestResultBlock) {
                                    self.permissionRequestResultBlock(CHPermissionRequestResultType_Granted);
                                }
                            });
                        } else {
                            dispatch_async(dispatch_get_main_queue(), ^{
                                completeHandle(CHPermissionRequestSupportType_Support);
                                if (self.permissionRequestResultBlock) {
                                    self.permissionRequestResultBlock(CHPermissionRequestResultType_Reject);
                                }
                            });
                        }
                    }];
                    break;
                }
                case AVAuthorizationStatusAuthorized:
                {
                    dispatch_async(dispatch_get_main_queue(), ^{
                        completeHandle(CHPermissionRequestSupportType_Support);
                        if (self.permissionRequestResultBlock) {
                            self.permissionRequestResultBlock(CHPermissionRequestResultType_Granted);
                        }
                    });
                    break;
                }
                case AVAuthorizationStatusRestricted:
                {
                    dispatch_async(dispatch_get_main_queue(), ^{
                        completeHandle(CHPermissionRequestSupportType_Support);
                        if (self.permissionRequestResultBlock) {
                            self.permissionRequestResultBlock(CHPermissionRequestResultType_ParentallyRestricted);
                        }
                    });
                }
                case AVAuthorizationStatusDenied:
                {
                    dispatch_async(dispatch_get_main_queue(), ^{
                        completeHandle(CHPermissionRequestSupportType_Support);
                        if (self.permissionRequestResultBlock) {
                            self.permissionRequestResultBlock(CHPermissionRequestResultType_Reject);
                        }
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
                        completeHandle(CHPermissionRequestSupportType_Support);
                        if (self.permissionRequestResultBlock) {
                            self.permissionRequestResultBlock(CHPermissionRequestResultType_NotExplicit);
                        }
                    });
                }
                    break;
                case AVAuthorizationStatusAuthorized:
                {
                    dispatch_async(dispatch_get_main_queue(), ^{
                        completeHandle(CHPermissionRequestSupportType_Support);
                        if (self.permissionRequestResultBlock) {
                            self.permissionRequestResultBlock(CHPermissionRequestResultType_Granted);
                        }
                    });
                }
                    break;
                case AVAuthorizationStatusRestricted:
                {
                    dispatch_async(dispatch_get_main_queue(), ^{
                        completeHandle(CHPermissionRequestSupportType_Support);
                        if (self.permissionRequestResultBlock) {
                            self.permissionRequestResultBlock(CHPermissionRequestResultType_ParentallyRestricted);
                        }
                    });
                }
                    break;
                case AVAuthorizationStatusDenied:
                {
                    dispatch_async(dispatch_get_main_queue(), ^{
                        completeHandle(CHPermissionRequestSupportType_Support);
                        if (self.permissionRequestResultBlock) {
                            self.permissionRequestResultBlock(CHPermissionRequestResultType_Reject);
                        }
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

- (void)locationManager:(CLLocationManager *)manager didChangeAuthorizationStatus:(CLAuthorizationStatus)status {
    switch (status) {
        case kCLAuthorizationStatusAuthorizedAlways:
        {
            if (self.permissionRequestResultBlock) {
                self.permissionRequestResultBlock(CHPermissionRequestResultType_Granted);
            }
        }
            break;
        case kCLAuthorizationStatusAuthorizedWhenInUse:
        {
            switch (self.requestType) {
                case CHPermission_LocationLocationAlwaysUsage:
                {
                    if (self.permissionRequestResultBlock) {
                        self.permissionRequestResultBlock(CHPermissionRequestResultType_NotExplicit);
                    }
                }
                    break;
                case CHPermission_LocationLocationUsage:
                case CHPermission_LocationLocationWhenInUseUsage:
                {
                    if (self.permissionRequestResultBlock) {
                        self.permissionRequestResultBlock(CHPermissionRequestResultType_Granted);
                    }
                }
                    break;
                default:
                    break;
            }
        }
            break;
        case kCLAuthorizationStatusDenied:
        {
            if (self.permissionRequestResultBlock) {
                self.permissionRequestResultBlock(CHPermissionRequestResultType_Reject);
            }
        }
            break;
        case kCLAuthorizationStatusNotDetermined:
        {
            if (self.permissionRequestResultBlock) {
                self.permissionRequestResultBlock(CHPermissionRequestResultType_NotExplicit);
            }
        }
            break;
        case kCLAuthorizationStatusRestricted:
        {
            if (self.permissionRequestResultBlock) {
                self.permissionRequestResultBlock(CHPermissionRequestResultType_Reject);
            }
        }
            break;
        break;
        default:
            break;
    }
}

@end
