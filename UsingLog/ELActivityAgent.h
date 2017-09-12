//
//  ELActivityAgent.h
//  ELearning
//
//  Created by 李康 on 2017/8/23.
//  Copyright © 2017年 李康. All rights reserved.//

#import <Foundation/Foundation.h>
#import "ELActivityLog.h"
#import <UIKit/UIKit.h>
@interface ELActivityAgent : NSObject
@property(atomic,strong) dispatch_source_t loadViewtimer;
@property(nonatomic,strong) NSString * currentViewControllerName;
@property(nonatomic,strong) NSString * trackUserBehaviorPath;
@property(nonatomic,strong) ELActivityLog * interruptActivityLog;

+(ELActivityAgent *)getInstance;
-(void)startAgent;
+ (void)postData:(NSString*)urlString data:(NSMutableDictionary*)content;
-(NSString *)getActivityLogFilePath;
+(NSData*)getArchivedActivities;
@end
