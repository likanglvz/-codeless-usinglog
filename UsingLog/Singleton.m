//
//  Singleton.m
//  codelessUsinglog
//
//  Created by 李康 on 2017/9/12.
//  Copyright © 2017年 李康. All rights reserved.
//

#import "Singleton.h"

@implementation Singleton

+(BOOL)createFolderIfNotAtPath:(NSString *)folderPath
{
    NSFileManager *fileManager=[NSFileManager defaultManager];
    BOOL isDir;
    BOOL isExist=[fileManager fileExistsAtPath:folderPath isDirectory:&isDir];
    if(isExist&&isDir)
    {
        return YES;
    }
    return [fileManager createDirectoryAtPath:folderPath withIntermediateDirectories:YES attributes:nil error:nil];
}

+(NSString *)urlEncode:(NSString *)url
{
    return (NSString*)CFBridgingRelease(CFURLCreateStringByAddingPercentEscapes(nil,(CFStringRef)url, nil, (CFStringRef)@"", kCFStringEncodingUTF8));
}
+(NSString *)urlDecode:(NSString *)url
{
    NSString *decodeUrl= (__bridge_transfer NSString *)CFURLCreateStringByReplacingPercentEscapesUsingEncoding(NULL, (CFStringRef)url, CFSTR(""), kCFStringEncodingUTF8);
    if(!decodeUrl)
    {
        CFStringEncoding gbkEncoding = (CFStringEncoding)CFStringConvertEncodingToNSStringEncoding(kCFStringEncodingGB_18030_2000);
        decodeUrl= (__bridge_transfer NSString *)CFURLCreateStringByReplacingPercentEscapesUsingEncoding(NULL, (CFStringRef)url, CFSTR(""), gbkEncoding);
    }
    if(!decodeUrl)
    {
        decodeUrl=url;
    }
    return decodeUrl;
}
+(NetworkStatus)getCurrentNetWorkStatus
{
    Reachability *reachability = [Reachability reachabilityForInternetConnection];
    return [reachability currentReachabilityStatus];
}

+(BOOL)deleteFileWithFilePath:(NSString *)filePath
{
    if(![self isFileExistWithFilePath:filePath])
    {
        return NO;
    }
    NSFileManager *fileManager=[NSFileManager defaultManager];
    return [fileManager removeItemAtPath:filePath error:nil];
}

+(BOOL)isFileExistWithFilePath:(NSString *)filePath
{
    NSFileManager *fileManager=[NSFileManager defaultManager];
    BOOL isFolder=NO;
    if([fileManager fileExistsAtPath:filePath isDirectory:&isFolder]&&!isFolder)
    {
        return YES;
    }
    return NO;
}
+(NSString *)getAppVersionString
{
    return [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleShortVersionString"];
}
@end
