//
//  ELActivityLog.m
//  ELearning
//
//  Created by 李康 on 2017/8/22.
//  Copyright © 2017年 李康. All rights reserved.//

#import "ELActivityLog.h"

@implementation ELActivityLog

-(id)initWithCoder:(NSCoder *)aDecoder
{
    if (self =[super init])
    {
        self.pageName = [aDecoder decodeObjectForKey:@"pageName"];
        self.startTime = [aDecoder decodeDoubleForKey:@"startTime"];
        self.endTime = [aDecoder decodeDoubleForKey:@"endTime"];
        self.netType = [aDecoder decodeIntForKey:@"netType"];
        self.appType = [aDecoder decodeObjectForKey:@"appType"];
        self.appVersion = [aDecoder decodeObjectForKey:@"appVersion"];
    }
    return self;
}

-(void)encodeWithCoder:(NSCoder *)aCoder
{
    [aCoder encodeObject:self.pageName forKey:@"pageName"];
    [aCoder encodeDouble:self.startTime forKey:@"startTime"];
    [aCoder encodeDouble:self.endTime forKey:@"endTime"];
    [aCoder encodeInt:self.netType forKey:@"netType"];
    [aCoder encodeObject:self.appType forKey:@"appType"];
    [aCoder encodeObject:self.appVersion forKey:@"appVersion"];
}
@end
