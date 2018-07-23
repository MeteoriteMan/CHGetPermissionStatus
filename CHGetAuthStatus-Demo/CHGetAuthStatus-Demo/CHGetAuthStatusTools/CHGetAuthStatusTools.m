//
//  CHGetAuthStatusTools.m
//  CHGetAuthStatus-Demo
//
//  Created by 张晨晖 on 2018/7/16.
//  Copyright © 2018年 张晨晖. All rights reserved.
//

#import "CHGetAuthStatusTools.h"
#import <CoreLocation/CoreLocation.h>

@implementation CHGetAuthStatusTools

+ (instancetype)sharedTools {
    static dispatch_once_t onceToken;
    static CHGetAuthStatusTools *tools;
    dispatch_once(&onceToken, ^{
        tools = [[CHGetAuthStatusTools alloc] init];
    });
    return tools;
}

- (void)getPrivateTypeWithCHPrivateType:(CHPrivateType)type withBlock:(void (^)(BOOL))authStatusBlock  {
    //typedef NS_ENUM(NSUInteger, CHPrivateType){
    //    CHPrivateType_None                  = 0,
    //    CHPrivateType_LocationServices      = 1,    // 定位服务
    //    CHPrivateType_Contacts              = 2,    // 通讯录
    //    CHPrivateType_Calendars             = 3,    // 日历
    //    CHPrivateType_Reminders             = 4,    // 提醒事项
    //    CHPrivateType_Photos                = 5,    // 照片
    //    CHPrivateType_BluetoothSharing      = 6,    // 蓝牙共享
    //    CHPrivateType_Microphone            = 7,    // 麦克风
    //    CHPrivateType_SpeechRecognition     = 8,    // 语音识别 >= iOS10
    //    CHPrivateType_Camera                = 9,    // 相机
    //    CHPrivateType_Health                = 10,   // 健康 >= iOS8.0
    //    CHPrivateType_HomeKit               = 11,   // 家庭 >= iOS8.0
    //    CHPrivateType_MediaAndAppleMusic    = 12,   // 媒体与Apple Music >= iOS9.3
    //    CHPrivateType_MotionAndFitness      = 13,   // 运动与健身
    //};
    switch (type) {
        case CHPrivateType_None:
        {

        }
            break;
        case CHPrivateType_LocationServices:
        {
            //kCLAuthorizationStatusNotDetermined未确定
            //kCLAuthorizationStatusRestricted受限制
            //kCLAuthorizationStatusDenied禁止
            //kCLAuthorizationStatusAuthorizedAlways始终可以
            //kCLAuthorizationStatusAuthorizedWhenInUse当使用的时候可以
            //kCLAuthorizationStatusAuthorized没验证
            switch ([CLLocationManager authorizationStatus]) {
                case kCLAuthorizationStatusRestricted:
                case kCLAuthorizationStatusDenied:
                {
                    dispatch_async(dispatch_get_main_queue(), ^{
                        authStatusBlock(NO);
                    });
                }
                    break;
                case kCLAuthorizationStatusNotDetermined:
                {
                    CLLocationManager *locationManager = [[CLLocationManager alloc] init];
                    [locationManager requestWhenInUseAuthorization];
                }
                    break;
//                case kCLAuthorizationStatusAuthorized://已废弃
                case kCLAuthorizationStatusAuthorizedAlways:
                case kCLAuthorizationStatusAuthorizedWhenInUse:
                {
                    dispatch_async(dispatch_get_main_queue(), ^{
                        authStatusBlock(YES);
                    });
                }
                default:
                    break;
            }
        }
            break;
        default:
            break;
    }
}
//typedef NS_ENUM(NSUInteger, CHPrivateType){
//    CHPrivateType_None                  = 0,
//    CHPrivateType_LocationServices      = 1,    // 定位服务
//    CHPrivateType_Contacts              = 2,    // 通讯录
//    CHPrivateType_Calendars             = 3,    // 日历
//    CHPrivateType_Reminders             = 4,    // 提醒事项
//    CHPrivateType_Photos                = 5,    // 照片
//    CHPrivateType_BluetoothSharing      = 6,    // 蓝牙共享
//    CHPrivateType_Microphone            = 7,    // 麦克风
//    CHPrivateType_SpeechRecognition     = 8,    // 语音识别 >= iOS10
//    CHPrivateType_Camera                = 9,    // 相机
//    CHPrivateType_Health                = 10,   // 健康 >= iOS8.0
//    CHPrivateType_HomeKit               = 11,   // 家庭 >= iOS8.0
//    CHPrivateType_MediaAndAppleMusic    = 12,   // 媒体与Apple Music >= iOS9.3
//    CHPrivateType_MotionAndFitness      = 13,   // 运动与健身
//};


@end
