//
//  ELActivityAgent.m
//  ELearning
//
//  Created by 李康 on 2017/8/23.
//  Copyright © 2017年 李康. All rights reserved.//

#import "ELActivityAgent.h"
#import "ELActivityDao.h"
#import "Singleton.h"
#define ThresholdTime 300

static ELActivityAgent *instance = nil;

@implementation ELActivityAgent

+(ELActivityAgent *)getInstance
{
    static dispatch_once_t once;
    dispatch_once(&once, ^{
        instance = [[self alloc]init];
    });
    return instance;
}

-(void)startAgent
{
    [ELActivityAgent getInstance].trackUserBehaviorPath = [self getActivityLogFilePath];
    [ELActivityDao postActivityArray:[ELActivityDao getArchiveActivityLog]];
    NSNotificationCenter *notifCenter = [NSNotificationCenter defaultCenter];
    [notifCenter addObserver:self
                    selector:@selector(resignActive:)
                        name:UIApplicationWillResignActiveNotification
                      object:nil];
    [notifCenter addObserver:self
                    selector:@selector(becomeActive:)
                        name:UIApplicationDidBecomeActiveNotification
                      object:nil];
    [notifCenter addObserver:self
                    selector:@selector(willTerminate:)
                        name:UIApplicationWillTerminateNotification
                      object:nil];
}

- (void)resignActive:(NSNotification *)notification
{
    dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
    [ELActivityAgent getInstance].loadViewtimer = dispatch_source_create(DISPATCH_SOURCE_TYPE_TIMER, 0, 0,queue);
    __block int timeout = ThresholdTime;
    dispatch_source_set_timer([ELActivityAgent getInstance].loadViewtimer,dispatch_walltime(NULL, 0),1.0*NSEC_PER_SEC, 0);
    dispatch_source_set_event_handler([ELActivityAgent getInstance].loadViewtimer, ^{
        if(timeout<=0){
            dispatch_source_cancel([ELActivityAgent getInstance].loadViewtimer);
            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
                [ELActivityAgent getInstance].loadViewtimer = nil;
                [ELActivityAgent getInstance].interruptActivityLog.endTime = [[NSDate date] timeIntervalSince1970]*1000;
                [ELActivityAgent getInstance].interruptActivityLog.netType =(int) [Singleton getCurrentNetWorkStatus];
                NSData *activityLogData = [ELActivityAgent getArchivedActivities];
                NSMutableArray * activityLogArray = [[NSMutableArray alloc] init ];
                if (activityLogData!=nil)
                {
                    activityLogArray = [NSKeyedUnarchiver unarchiveObjectWithData:activityLogData];
                }
                else {
                    activityLogArray = [[NSMutableArray alloc] init ];
                }
                [activityLogArray addObject:[ELActivityAgent getInstance].interruptActivityLog];
                NSData *newActivityData = [NSKeyedArchiver archivedDataWithRootObject:activityLogArray];
                [NSKeyedArchiver archiveRootObject:newActivityData toFile:[[ELActivityAgent getInstance] getActivityLogFilePath]];
            });
        }else
        {
            timeout--;
        }
    });
    dispatch_resume([ELActivityAgent getInstance].loadViewtimer);
}

- (void)becomeActive:(NSNotification *)notification
{
    if ([ELActivityAgent getInstance].loadViewtimer)
    {
        dispatch_source_cancel([ELActivityAgent getInstance].loadViewtimer);
    }else
    {
        if ([ELActivityAgent getInstance].currentViewControllerName)
        {
            double pageStartDate = [[NSDate date] timeIntervalSince1970]*1000;
            
            [[NSUserDefaults standardUserDefaults] setDouble:pageStartDate
                                                      forKey:NSStringFromClass([self class])];
            [[NSUserDefaults standardUserDefaults] synchronize];
        }
    }
}
- (void)willTerminate:(NSNotification *)notification
{
    if ([ELActivityAgent getInstance].interruptActivityLog)
    {
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            [ELActivityAgent getInstance].loadViewtimer = nil;
            [ELActivityAgent getInstance].interruptActivityLog.endTime = [[NSDate date] timeIntervalSince1970]*1000;
            [ELActivityAgent getInstance].interruptActivityLog.netType = (int)[Singleton getCurrentNetWorkStatus];
            NSData *activityLogData = [ELActivityAgent getArchivedActivities];
            NSMutableArray * activityLogArray = [[NSMutableArray alloc] init ];
            if (activityLogData!=nil)
            {
                activityLogArray = [NSKeyedUnarchiver unarchiveObjectWithData:activityLogData];
            }
            else {
                activityLogArray = [[NSMutableArray alloc] init ];
            }
            [activityLogArray addObject:[ELActivityAgent getInstance].interruptActivityLog];
            NSData *newActivityData = [NSKeyedArchiver archivedDataWithRootObject:activityLogArray];
            [NSKeyedArchiver archiveRootObject:newActivityData toFile:[[ELActivityAgent getInstance] getActivityLogFilePath]];
        });
    }
}
-(NSString *)getActivityLogFilePath{
    NSArray *array = NSSearchPathForDirectoriesInDomains(NSApplicationSupportDirectory, NSUserDomainMask, YES);
    NSString *directory = [array objectAtIndex:0];
    [Singleton createFolderIfNotAtPath:directory];
    NSString *resultPath = [directory stringByAppendingPathComponent:@"TrackUserBehavior"];
    return resultPath;
}

+ (void)postData:(NSString*)urlString data:(NSMutableDictionary*)content
{
    NSURL *postUrl = [NSURL URLWithString:[Singleton urlEncode:urlString]];
    NSError *parseError = nil;
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:content options:NSJSONWritingPrettyPrinted error:&parseError];
    NSString *requestJson = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
    NSMutableURLRequest * request = [[NSMutableURLRequest alloc] initWithURL:postUrl];
    [request setValue:@"application/json;charset=utf-8" forHTTPHeaderField:@"Content-type"];
    [request setHTTPMethod: @"POST"];
    NSData *requestData = [requestJson dataUsingEncoding:NSUTF8StringEncoding];
    [request setHTTPBody:requestData];
    NSOperationQueue *queue = [[NSOperationQueue alloc] init];
    [NSURLConnection sendAsynchronousRequest:request queue:queue completionHandler:^(NSURLResponse *response, NSData *data, NSError *error)
     {
         NSHTTPURLResponse *httpResponse = (NSHTTPURLResponse*)response;
         if ([response respondsToSelector:@selector(statusCode)]) {
             if ([httpResponse statusCode] == 200) {
                 [Singleton deleteFileWithFilePath:[ELActivityAgent getInstance].trackUserBehaviorPath];
             }
         }
     }];
}
+(NSData*)getArchivedActivities{
    [[ELActivityDao getinstance].lock lock];
    NSData *result = nil;
    NSString *resultPath = [[ELActivityAgent getInstance] getActivityLogFilePath];
    NSData *oldData = [NSKeyedUnarchiver unarchiveObjectWithFile:resultPath];
    NSArray *oldArr = [NSKeyedUnarchiver unarchiveObjectWithData:oldData];
    [[ELActivityDao getinstance].lock unlock];
    
    NSMutableArray *newArr = [[NSMutableArray alloc]init];
    for (ELActivityLog * activityLog in oldArr) {
        [newArr addObject:activityLog];
        NSData* newData = [NSKeyedArchiver archivedDataWithRootObject:newArr];
        result = newData;
    }
    return result;
}

@end
