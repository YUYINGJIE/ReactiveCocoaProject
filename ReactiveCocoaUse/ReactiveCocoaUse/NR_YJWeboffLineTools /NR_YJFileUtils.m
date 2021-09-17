//
//  NR_YJFileUtils.m
//  App
//
//  Created by 于英杰 on 2021/5/12.
//

#import "NR_YJFileUtils.h"

@implementation NR_YJFileUtils

+ (NR_YJFileUtils *)FileUtilShared{
    static NR_YJFileUtils *_shared = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _shared=[[NR_YJFileUtils alloc]init];
    });
    return _shared;
}

/**caches根目录*/
-(NSString *)getCachesPath{
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES);
    NSString *caches = [paths firstObject];
    return caches;
}

/**document根目录*/
- (NSString *)getDocumentPath{
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentPath = [paths firstObject];
    return documentPath;
}
//--------------------------------------------------------------------------- 文件夹相关操作

/**创建文件夹*/
-(BOOL)creatfolder:(NSString*)folderPath{
    if ([[NSFileManager defaultManager] fileExistsAtPath:folderPath]) {
        //判断folderPath路径文件夹是否已存在，此处folderPath为需要新建的文件夹的绝对路径
        return NO;
    }
    else{
        [[NSFileManager defaultManager] createDirectoryAtPath:folderPath withIntermediateDirectories:YES attributes:nil error:nil];//创建文件夹
        return YES;
    }
}

/**删除文件夹*/
-(BOOL)deletefolder:(NSString*)folderPath{
    if([[NSFileManager defaultManager] fileExistsAtPath:folderPath]){
        //如果存在临时文件的配置文件
        NSError *error=nil;
        return [[NSFileManager defaultManager]removeItemAtPath:folderPath error:&error];
    }
    return  NO;
}

/**移动文件夹*/
-(BOOL)movefolder:(NSString*)srcPath to:(NSString*)desPath{
    NSError *error=nil;
    if([[NSFileManager defaultManager] moveItemAtPath:srcPath toPath:desPath error:&error]!=YES){
        NSLog(@"移动文件失败");
        return NO;
    }
    else{
        NSLog(@"移动文件成功");
        return YES;
    }
}

//--------------------------------------------------------------------------- 文件相关操作
#pragma mark -文件相关

/**文件是否存在*/
-(BOOL)fileExist:(NSString*)folderPath{
    return [[NSFileManager defaultManager]fileExistsAtPath:folderPath];
}
/**创建文件*/
- (BOOL)creatFile:(NSString*)filePath withData:(NSData*)data{
    return  [[NSFileManager defaultManager] createFileAtPath:filePath contents:data attributes:nil];
}

/**读取文件*/
-(NSData*)readFile:(NSString *)filePath{
    return [NSData dataWithContentsOfFile:filePath options:0 error:NULL];
}

/**删除文件*/
-(BOOL)deleteFile:(NSString *)filePath{
    
    return [self deletefolder:filePath];
}

/**在对应文件保存数据*/
- (BOOL)writeDataToFile:(NSString*)fileName data:(NSData*)data isDocumentPath:(BOOL)isdocumentPath{
    NSString *filePath=@"";
    if (isdocumentPath) {
        filePath=[self getDocumentFilePath:fileName];
    }
    else{
        filePath=[self getCachesFilePath:fileName];
    }
    return [self creatFile:filePath withData:data];
}

/**读取数据文件*/
- (NSData*)readDataFromFile:(NSString*)fileName isDocumentPath:(BOOL)isdocumentPath{
    NSString *filePath=@"";
    if (isdocumentPath) {
        filePath=[self getDocumentFilePath:fileName];
    }
    else{
        filePath=[self getCachesFilePath:fileName];
    }
    return [self readFile:filePath];
}


@end
