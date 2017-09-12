//
//  Singleton.h
//  codelessUsinglog
//
//  Created by 李康 on 2017/9/12.
//  Copyright © 2017年 李康. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Reachability.h"
@interface Singleton : NSObject
+(BOOL)createFolderIfNotAtPath:(NSString *)folderPath;
+(NSString *)urlEncode:(NSString *)url;
+(BOOL)deleteFileWithFilePath:(NSString *)filePath;
+(NetworkStatus)getCurrentNetWorkStatus;
+(NSString *)getAppVersionString;
@end
