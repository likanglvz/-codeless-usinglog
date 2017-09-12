//
//  ELActivityDao.m
//  ELearning
//
//  Created by 李康 on 2017/8/24.
//  Copyright © 2017年 李康. All rights reserved.//

#import "ELActivityDao.h"
#import "ELActivityLog.h"
#import "ELActivityAgent.h"

@implementation ELActivityDao

+ (ELActivityDao *)getinstance
{
    static ELActivityDao *instance = nil;
    if (instance == nil) {
        instance.lock = [[NSRecursiveLock alloc]init];
    }
    return instance;
}

+ (NSMutableArray *)getArchiveActivityLog
{
    [[ELActivityDao getinstance].lock lock];
    NSData *historyData = [ELActivityDao getArchivedLogFromFile];
    [[ELActivityDao getinstance].lock unlock];
    NSMutableArray * historyArray = nil;
    if (historyData!=nil)
    {
        historyArray = [NSKeyedUnarchiver unarchiveObjectWithData:historyData];
        NSLog(@"Have activity data num = %lu",(unsigned long)[historyArray count]);
    }
    return historyArray;
}

+ (void)postActivityArray:(NSMutableArray*)activityArray
{
    NSMutableArray *finalAcvitityArray = [[NSMutableArray alloc] init];
    if ([activityArray count]>0)
    {
        NSMutableDictionary *requestDictionary = nil;
        for(ELActivityLog *activityLog in activityArray)
        {
            requestDictionary = [[NSMutableDictionary alloc] init];
            if(activityLog.pageName)
            {
                [requestDictionary setObject:activityLog.pageName forKey:@"pageName"];
            }
            if(activityLog.startTime)
            {
                [requestDictionary setObject:[NSNumber numberWithLong:activityLog.startTime] forKey:@"startTime"];
            }
            if(activityLog.endTime)
            {
                [requestDictionary setObject:[NSNumber numberWithLong:activityLog.endTime] forKey:@"endTime"];
            }
            if(activityLog.netType)
            {
                [requestDictionary setObject:[NSNumber numberWithInt:activityLog.netType] forKey:@"netType"];
            }
            if(activityLog.appType)
            {
                [requestDictionary setObject:activityLog.appType forKey:@"appType"];
            }
            if(activityLog.appVersion)
            {
                [requestDictionary setObject:activityLog.appVersion forKey:@"appVersion"];
            }
            [finalAcvitityArray addObject:requestDictionary];
        }
    }
     NSMutableDictionary *finalDic = [[NSMutableDictionary alloc] init];
    [finalDic setObject:finalAcvitityArray forKey:@"behaviorItems"];
    [finalDic setObject:@1 forKey:@"clientType"];
    //修改您的nginx地址
    [ELActivityAgent postData:@"nginx地址" data:finalDic];
   }

+ (NSData*) getArchivedLogFromFile{
    NSData *logData = nil;
    logData = [NSKeyedUnarchiver unarchiveObjectWithFile:[ELActivityAgent getInstance].trackUserBehaviorPath];
    return logData;
}

@end
