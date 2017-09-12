//
//  UIViewController+Usinglog.m
//  ELearning
//
//  Created by 李康 on 2017/8/16.
//  Copyright © 2017年 李康. All rights reserved.//

#import "UIViewController+Usinglog.h"
#import "ELActivityLog.h"
#import "ELActivityAgent.h"
#import "ELActivityDao.h"
#import "Singleton.h"
@implementation UIViewController (Usinglog)

+(void)load{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        Method oldViewWillAppear = class_getInstanceMethod(self, @selector(viewWillAppear:));
        Method newViewWillAppear = class_getInstanceMethod(self, @selector(qsViewWillAppear));
        method_exchangeImplementations(oldViewWillAppear, newViewWillAppear);
        
        Method oldViewWillDisappear = class_getInstanceMethod(self, @selector(viewWillDisappear:));
        Method newViewWillDisappear = class_getInstanceMethod(self, @selector(qsNewViewWillDisappear));
        method_exchangeImplementations(oldViewWillDisappear, newViewWillDisappear);
    });
}

-(void)qsViewWillAppear{
    [self qsViewWillAppear];
    double pageStartDate = [[NSDate date] timeIntervalSince1970]*1000;
    [[NSUserDefaults standardUserDefaults] setDouble:pageStartDate
                                              forKey:NSStringFromClass([self class])];
    [[NSUserDefaults standardUserDefaults] synchronize];
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^{
        if (![NSStringFromClass([self class]) isEqualToString:@"UINavigationController"]
            &&![NSStringFromClass([self class]) isEqualToString:@"UIInputWindowController"]
            &&![NSStringFromClass([self class]) isEqualToString:@"UICompatibilityInputViewController"])
        {
            [ELActivityAgent getInstance].currentViewControllerName = NSStringFromClass([self class]);
            ELActivityLog *activityLog = [[ELActivityLog alloc] init];
            NSDictionary * propertyNamesAndValuesDic = [self allPropertyNamesAndValues];
            activityLog.pageName = NSStringFromClass([self class]);
            double pageStartDate =[[NSUserDefaults standardUserDefaults] doubleForKey:NSStringFromClass([self class])];
            if (pageStartDate) {
                activityLog.startTime = pageStartDate;
            }
            activityLog.appType = @"2";
            activityLog.appVersion = [Singleton getAppVersionString];
            [ELActivityAgent getInstance].interruptActivityLog = activityLog;
        }
    });
}

-(void)qsNewViewWillDisappear{
    [self qsNewViewWillDisappear];
    if ([ELActivityAgent getInstance].interruptActivityLog
        &&![NSStringFromClass([self class]) isEqualToString:@"UINavigationController"]
        &&![NSStringFromClass([self class]) isEqualToString:@"UIInputWindowController"]
        &&![NSStringFromClass([self class]) isEqualToString:@"UICompatibilityInputViewController"]) {
         dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^{
            [ELActivityAgent getInstance].interruptActivityLog.endTime = [[NSDate date] timeIntervalSince1970]*1000;
             [ELActivityAgent getInstance].interruptActivityLog.netType = 1;
             [ELActivityAgent getInstance].interruptActivityLog.pageName = NSStringFromClass([self class]);
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
             [ELActivityAgent getInstance].interruptActivityLog = nil;
        });
    }
}

- (NSDictionary *)allPropertyNamesAndValues {
    NSMutableDictionary *resultDict = [NSMutableDictionary dictionary];
    unsigned int outCount;
    objc_property_t *properties = class_copyPropertyList([self class], &outCount);
    for (int i = 0; i < outCount; i++)
    {
        objc_property_t property = properties[i];
        const char *name = property_getName(property);
        NSString *propertyName = [NSString stringWithUTF8String:name];
        id propertyValue = [self valueForKey:propertyName];
        if (propertyValue && propertyValue != nil) {
            [resultDict setObject:propertyValue forKey:propertyName];
        }
    }
    free(properties);
    return resultDict;
}
@end
