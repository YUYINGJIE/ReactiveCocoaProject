//
//  NR_YJFileUtils.h
//  App
//
//  Created by 于英杰 on 2021/5/12.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface NR_YJFileUtils : NSObject

+ (NR_YJFileUtils *)FileUtilShared;
/**caches根目录*/
-(NSString *)getCachesPath;

/**document根目录 */
- (NSString *)getDocumentPath;

/**创建文件夹*/
-(BOOL)creatfolder:(NSString*)folderPath;

/**删除文件夹*/
-(BOOL)deletefolder:(NSString*)folderPath;

/**移动文件夹*/
-(BOOL)movefolder:(NSString*)srcPath to:(NSString*)desPath;

/**文件是否存在*/
-(BOOL)fileExist:(NSString*)folderPath;

/**创建文件*/
- (BOOL)creatFile:(NSString*)filePath withData:(NSData*)data;

/**读取文件*/
-(NSData*)readFile:(NSString *)filePath;

/**删除文件*/
-(BOOL)deleteFile:(NSString *)filePath;

/**文件全路径Document*/
- (NSString*)getDocumentFilePath:(NSString*)fileName;

/**文件全路径Caches*/
- (NSString*)getCachesFilePath:(NSString*)fileName;

/**在对应文件保存数据*/
- (BOOL)writeDataToFile:(NSString*)fileName data:(NSData*)data;

/**读取数据文件*/
- (NSData*)readDataFromFile:(NSString*)fileName;

@end

/**
 沙盒：
 应用程序包、：
 Documents、：iTunes会自动备份
 Libaray（下面有Caches和Preferences目录）
 Caches：iTunes不会备份 一般存放体积比较大的文件
 Preferences:iTunes会自动备份 一般存放应用的设置信息--用户偏好设置，plist格式文档；
 系统提供[NSUserDefaults standardUserDefaults]单例类直接操作文档。
 tmp、：iTunes不会同步
 
 */


NS_ASSUME_NONNULL_END
