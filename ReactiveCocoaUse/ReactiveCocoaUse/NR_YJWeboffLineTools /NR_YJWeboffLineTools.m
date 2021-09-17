//
//  NR_YJWeboffLineTools.m
//  App
//
//  Created by 于英杰 on 2021/5/12.
//

#import "NR_YJWeboffLineTools.h"
#import "NR_YJFileUtils.h"
#import "SSZipArchive.h"

@interface NR_YJWeboffLineTools()<SSZipArchiveDelegate>

@end

@implementation NR_YJWeboffLineTools

+ (NR_YJWeboffLineTools *)WeboffLineToolsshared{
    static NR_YJWeboffLineTools *_shared = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _shared=[[NR_YJWeboffLineTools alloc]init];
    });
    return _shared;
}

-(void)saveFiel{
    
 /** 模拟服务器给的传参*/
    
    NSString* htmlversion = @"1.5.3"; //版本
    NSString* htmlPatchurl = @"";//下载链接
    NSString* fileName = @"calendar.zip";//文件名
    NSString* releasefileName = @"calendar111";//解压后的文件名
    NSString* type = @"2";// 1轮播图 2模块
    NSString* ID = @"1";// id标识 哪个模块

    NSString *VersionfilePatch= [self getCachesFilePath:@"NR_YJhtmlVersion.plist"];//版本plist路径

    NSDictionary *param = @{
        @"htmlversion":htmlversion,
        @"htmlPatchurl":htmlPatchurl,
        @"fileName":fileName,
        @"releasefileName":releasefileName,
        @"type":type,
        @"VersionfilePatch":VersionfilePatch,
        @"ID":ID,

    };
    
  //-------------------------------------------------------------------------
    
    
    //h5创建单独的文件夹进行文件管理
    [self creatfolder:@"NR_YJhtml"];
    [self creatfolder:@"NR_YJhtmlrelease"];
    
    NSFileManager *fileManager = [NSFileManager defaultManager];
    BOOL Exists = [fileManager fileExistsAtPath:VersionfilePatch];
    if (!Exists) {
        NSString *zipPath = [[[NSBundle mainBundle]resourcePath]stringByAppendingPathComponent:@"NR_YJhtmlVersion.plist"];
        NSError *error;
        BOOL success = [fileManager copyItemAtPath:zipPath toPath:VersionfilePatch error:&error];
        if(!success){
            NSAssert1(0, @"错误写入文件:'%@'.", [error localizedDescription]);
            return;
        }
    }
    
//根据版本号判断，是否下载。第一次先保存一个空的版本号为空，直接走网络下载，然后保存当前下载完之后的版本号，再次运行app的时候，判断保存的版本号，跟接口给的版本号是否一致，一致的话，就不用下载，不一致，就下载新的。如下判断：
    NSMutableArray *usersDics =[[NSMutableArray alloc]initWithContentsOfFile:VersionfilePatch];
    NSDictionary*selectdict=@{};
    for (NSDictionary*dict in usersDics) {
        if ([[dict objectForKey:@"ID"]isEqual:[param objectForKey:@"ID"]]) {
            selectdict =dict;
        }
    }
    NSString* version = [selectdict objectForKey:@"version"]; //版本
    if (!version) {
        //下载解压缩
        [self rquestZipArchive:param];
       }
       else{
           if ([version isEqualToString:htmlversion]) {
               NSLog(@"不下载不解压");
               [self loadFiel:@"111"];
           }
           else{
               //下载解压缩
               [self rquestZipArchive:param];
           }
       }
}
//下载解压缩
-(void)rquestZipArchive:(NSDictionary *)param{
    
    // 模拟下载文件
    dispatch_async(dispatch_get_main_queue(), ^{
        [self downloadFiel:param];
    });
 
}

-(void)downloadFiel:(NSDictionary*)param{
    
    @try {
        
        NSString* fileName = [param objectForKey:@"fileName"];
        NSString *htmlPatch= [self getCachesFilePath:fileName];

        NSFileManager *fileManager = [NSFileManager defaultManager];
        NSString *zipPath = [[[NSBundle mainBundle]resourcePath]stringByAppendingPathComponent:@"calendar.zip"];
        NSError *error;
      
        [self deleteFilePath:fileName];

        //把copy替换为 服务器下载 即可
        BOOL success = [fileManager copyItemAtPath:zipPath toPath:htmlPatch error:&error];
        if(!success){
            NSAssert1(0, @"错误写入文件:'%@'.", [error localizedDescription]);
        }
        else{
            [self releaseZipFilesWithUnzipFile:param];
        }
    } @catch (NSException *exception) {
        
    } @finally {
        
    }
    
}

#pragma mark 解压
- (void)releaseZipFilesWithUnzipFile:(NSDictionary *)param{
//    NSLog(@"%@,%@",zipPath,unzipPath);
    NSError *error;

    NSString* fileName = [param objectForKey:@"fileName"];
    NSString* releasefileName = [param objectForKey:@"releasefileName"];

    NSString *htmlPatch= [self getCachesFilePath:fileName];
    NSString *Patch= [self getDocumentFilePath:releasefileName];
    if ([SSZipArchive unzipFileAtPath:htmlPatch toDestination:Patch overwrite:YES password:nil error:&error delegate:self]) {
        NSLog(@"success");
        NSString* fileName = [param objectForKey:@"fileName"];
        [self deleteFilePath:fileName];
        
        //保存新html的版本号
        NSString* path = [param objectForKey:@"VersionfilePatch"];
        NSString* htmlversion = [param objectForKey:@"htmlversion"];
        NSString* type = [param objectForKey:@"type"];
        NSString* ID = [param objectForKey:@"ID"];
        
        NSMutableDictionary *dict =@{}.mutableCopy;
        [dict setObject:ID forKey:@"ID"];
        [dict setObject:type forKey:@"type"];
        [dict setObject:Patch forKey:@"htmlPatch"];
        [dict setObject:htmlversion forKey:@"version"];
        
        NSMutableArray *usersDics =[[NSMutableArray alloc]initWithContentsOfFile:path];
        if (usersDics.count==0) {
            [usersDics addObject:dict];
        }
        else{
            NSMutableArray *array = [NSMutableArray array];
            for (NSMutableDictionary*dict in usersDics) {
                [array addObject:[dict objectForKey:@"ID"]];
            }
            if ([array containsObject:ID]) {
              NSInteger index = [array indexOfObject:ID];
             [usersDics replaceObjectAtIndex:index withObject:dict];
            }
            else{
                [usersDics addObject:dict];
            }
        }
        NSLog(@"--%@",usersDics);
        [usersDics writeToFile:path atomically:YES];
        [self loadFiel:ID];
    }
    else{
        NSLog(@"%@",error);
    }
}

//加载
-(void)loadFiel:(NSString*)ID{
    
    NSString *VersionfilePatch= [self getCachesFilePath:@"NR_YJhtmlVersion.plist"];//版本plist路径

    NSMutableArray *usersDics =[[NSMutableArray alloc]initWithContentsOfFile:VersionfilePatch];
    NSDictionary*selectdict=@{};
    for (NSDictionary*dict in usersDics) {
        if ([[dict objectForKey:@"ID"]isEqual:ID]) {
            selectdict =dict;
        }
    }
    NSLog(@"-------%@",selectdict);
}

-(BOOL)creatfolder:(NSString*)folderName{
    
    NSString *filePatch = [[[NR_YJFileUtils FileUtilShared]getCachesPath]stringByAppendingPathComponent:folderName];
    BOOL creat= [[NR_YJFileUtils FileUtilShared]creatfolder:filePatch];
    return creat;
    
}

//下载路径 fileName 文件名
- (NSString*)getCachesFilePath:(NSString*)fileName{
    
    NSString *dirPath = [[[[NR_YJFileUtils FileUtilShared] getCachesPath]stringByAppendingPathComponent:@"NR_YJhtml"]stringByAppendingPathComponent:fileName];
    return dirPath;
    
}

//解压路径 fileName 文件名
- (NSString*)getDocumentFilePath:(NSString*)fileName{
    
    NSString *dirPath = [[[[NR_YJFileUtils FileUtilShared] getCachesPath]stringByAppendingPathComponent:@"NR_YJhtmlrelease"]stringByAppendingPathComponent:fileName];
    return dirPath;
    
}

- (void)deleteFilePath:(NSString*)fileName{
    
    NSString *htmlPatch= [self getCachesFilePath:fileName];
    BOOL delete= [[NR_YJFileUtils FileUtilShared]deleteFile:htmlPatch];
    if (delete) {
        NSLog(@"delete-----success");
    }
    else{
        NSLog(@"delete-----error");
    }
    
}

- (void)deletefoldPath:(NSString*)fileName{
    
    NSString *htmlPatch= [self getDocumentFilePath:fileName];
    BOOL delete= [[NR_YJFileUtils FileUtilShared]deletefolder:htmlPatch];
    if (delete) {
        NSLog(@"delete-----success");
    }
    else{
        NSLog(@"delete-----error");
    }
    
}

@end
