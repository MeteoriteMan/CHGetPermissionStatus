//
//  CHGetAuthStatusTools.h
//  CHGetAuthStatus-Demo
//
//  Created by 张晨晖 on 2018/7/16.
//  Copyright © 2018年 张晨晖. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef NS_ENUM(NSUInteger, CHPrivateType){
    CHPrivateType_None                  = 0,
    CHPrivateType_LocationServices      = 1,    // 定位服务
    CHPrivateType_Contacts              = 2,    // 通讯录
    CHPrivateType_Calendars             = 3,    // 日历
    CHPrivateType_Reminders             = 4,    // 提醒事项
    CHPrivateType_Photos                = 5,    // 照片
    CHPrivateType_BluetoothSharing      = 6,    // 蓝牙共享
    CHPrivateType_Microphone            = 7,    // 麦克风
    CHPrivateType_SpeechRecognition     = 8,    // 语音识别 >= iOS10
    CHPrivateType_Camera                = 9,    // 相机
    CHPrivateType_Health                = 10,   // 健康 >= iOS8.0
    CHPrivateType_HomeKit               = 11,   // 家庭 >= iOS8.0
    CHPrivateType_MediaAndAppleMusic    = 12,   // 媒体与Apple Music >= iOS9.3
    CHPrivateType_MotionAndFitness      = 13,   // 运动与健身
};

@interface CHGetAuthStatusTools : NSObject

+ (instancetype)sharedTools;

- (void)getPrivateTypeWithCHPrivateType:(CHPrivateType)type withBlock:(void(^)(BOOL isAuthed))authStatusBlock;

@end
