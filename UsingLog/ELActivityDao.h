//
//  ELActivityDao.h
//  ELearning
//
//  Created by 李康 on 2017/8/24.
//  Copyright © 2017年 李康. All rights reserved.//

#import <Foundation/Foundation.h>

@interface ELActivityDao : NSObject
@property(nonatomic)NSRecursiveLock *lock;

+ (ELActivityDao *)getinstance;
+ (NSMutableArray *)getArchiveActivityLog;
+ (void)postActivityArray:(NSMutableArray*)activityArray;
+ (NSData*)getArchivedLogFromFile:(NSString*)fileName;

@end
