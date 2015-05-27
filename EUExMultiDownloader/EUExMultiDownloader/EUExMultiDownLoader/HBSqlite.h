//
//  HBSqlite.h
//  AppCanPlugin
//
//  Created by hongbao.cui on 15-1-25.
//  Copyright (c) 2015年 zywx. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <sqlite3.h>

#define kDatabaseName @"HBdatabase.sqlite3"

sqlite3 *database;
@interface HBSqlite : NSObject
+(BOOL)creatDownLoaderTable;
+(BOOL)insertFileInfo:(NSDictionary *)dict;
+(NSMutableArray *)selectFileInfo:(NSString *)selectSQL;
+(BOOL)deleteFileBy:(NSString*)file_ID;
+(BOOL)updateDownLoaderInfoBy:(NSString*)SQL;
@end
