//
//  ELActivityLog.h
//  ELearning
//
//  Created by 李康 on 2017/8/22.
//  Copyright © 2017年 李康. All rights reserved.//

#import <Foundation/Foundation.h>

@interface ELActivityLog : NSObject<NSCoding>

@property (nonatomic,strong) NSString *pageName;
@property (nonatomic,assign) long startTime;
@property (nonatomic,assign) long endTime;
@property (nonatomic,assign) int netType;
@property (nonatomic,strong) NSString *appType;
@property (nonatomic,strong) NSString *appVersion;

@end
