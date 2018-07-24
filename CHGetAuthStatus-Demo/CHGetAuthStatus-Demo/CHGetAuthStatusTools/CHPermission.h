//
//  CHPermission.h
//  CHGetAuthStatus-Demo
//
//  Created by 张晨晖 on 2018/7/23.
//  Copyright © 2018年 张晨晖. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef NS_ENUM(NSUInteger, CHPermissionRequestType){/// 请求类型
    CHPermission_None                             = 0,
    CHPermission_BluetoothPeripheralUsage         = 1,    // 蓝牙
    CHPermission_CalendarsUsage                   = 2,    // 日历
    CHPermission_CameraUsage                      = 3,    // 相机
    CHPermission_ContactsUsage                    = 4,    // 通讯录
    CHPermission_FaceIDUsage                      = 5,    // FaceID
    CHPermission_HealthShareUsage                 = 6,    // 健康数据分享
    CHPermission_HealthUpdateUsage                = 7,    // 健康数据更新
    CHPermission_HomeKitUsage                     = 8,    // 家庭 >= iOS8.0
    CHPermission_LocationLocationAlwaysUsage      = 9,    // 定位服务始终开启
    CHPermission_LocationLocationUsage            = 10,   // 定位服务
    CHPermission_LocationLocationWhenInUseUsage   = 11,   // 需要时开启定位
    CHPermission_MediaLibraryUsage                = 12,   // 播放音乐或者视频
    CHPermission_MicrophoneUsage                  = 13,   // 麦克风
    CHPermission_MotionUsage                      = 14,   // 运动与健身
    CHPermission_MusicUsage                       = 15,   // 音乐
    CHPermission_NFCScanUsage                     = 16,   // NFC
    CHPermission_PhotoLibraryUsage                = 17,   // 照片
    CHPermission_RemindersUsage                   = 18,   // 提醒事项
    CHPermission_SiriUsage                        = 19,   // Siri
    CHPermission_SpeechRecognitionUsage           = 20,   // 语音识别 >= iOS10
    CHPermission_TVProviderUsage                  = 21,   // 电视提供商
    CHPermission_VideoSubscriberAccountUsage      = 22,   // 媒体与Apple Music >= iOS9.3
};

typedef NS_ENUM(NSUInteger, CHPermissionRequestResultType) {/// 返回结果类型
    CHPermissionRequestResultType_NotExplicit,//结果不明
    CHPermissionRequestResultType_Granted,//允许
    CHPermissionRequestResultType_Reject,//拒绝
    CHPermissionRequestResultType_ParentallyRestricted,//家长权限拒绝
};

typedef NS_ENUM(NSUInteger, CHPermissionRequestSupportType) {/// 返回结果类型
    CHPermissionRequestSupportType_Support,//支持
    CHPermissionRequestSupportType_NotSupport,//不支持
};

@interface CHPermission : NSObject

/// 全局单例访问点
+ (instancetype)sharedClass;

- (void)requestAuthWithPermissionRequestType:(CHPermissionRequestType)requestType andCompleteHandle:(void(^)(CHPermissionRequestResultType resultType,CHPermissionRequestSupportType supportType))completeHandle;

@end
