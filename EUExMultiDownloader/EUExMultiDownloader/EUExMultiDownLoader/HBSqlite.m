//
//  HBSqlite.m
//  AppCanPlugin
//
//  Created by hongbao.cui on 15-1-25.
//  Copyright (c) 2015年 zywx. All rights reserved.
//

#import "HBSqlite.h"

@implementation HBSqlite
+(BOOL)creatDownLoaderTable{
//    NSString *path = [NSHomeDirectory() stringByAppendingPathComponent:@"Documents"];
    NSString *path = [NSSearchPathForDirectoriesInDomains(NSLibraryDirectory,NSUserDomainMask, YES) objectAtIndex:0];
    NSString *file = [path stringByAppendingPathComponent:kDatabaseName];
    //open database if exist, or create database
    if (sqlite3_open([file UTF8String], &database)!= SQLITE_OK) {
        sqlite3_close(database);
        return NO;
    }
    //create table
    char *erorMsg;
	NSString *createTableSQL = @"create table if not exists downLoadedFileTable(fileID text, fileName text, savePathRes text,mineType text,savePath text,url text,content_length text,strSize text,everySize text,strReceivedSize text,strReceivedRate text,totalSize text,totalFloatSize text,time text,down text,loadingStr text,progress text,imageURL text);";
    if (sqlite3_exec(database, [createTableSQL UTF8String], NULL, NULL, &erorMsg) != SQLITE_OK) {
        sqlite3_close(database);
        sqlite3_free(erorMsg);
        return NO;
    }
    return YES;
}
+(BOOL)insertFileInfo:(NSDictionary *)dict{
    BOOL result = NO;
    if ([HBSqlite creatDownLoaderTable]) {
        NSString *fileID = [dict objectForKey:@"fileID"];
        NSString *fileName = [dict objectForKey:@"fileName"];
        NSString *savePathRes = [dict objectForKey:@"savePathRes"];
        NSString *mineType = [dict objectForKey:@"mineType"];
        NSString *savePath = [dict objectForKey:@"savePath"];
        NSString *url = [dict objectForKey:@"url"];
        NSLog(@"%@", url);
        NSString *content_length = ([dict objectForKey:@"content_length"]==nil)?@"":[dict objectForKey:@"content_length"];
        NSString *strSize =([dict objectForKey:@"strSize"]==nil)?@"":[dict objectForKey:@"strSize"];
;
        NSString *everySize =([dict objectForKey:@"everySize"]==nil)?@"":[dict objectForKey:@"everySize"];
        NSString *strReceivedSize = ([dict objectForKey:@"strReceivedSize"]==nil)?@"":[dict objectForKey:@"strReceivedSize"];
        NSString *strReceivedRate = ([dict objectForKey:@"strReceivedRate"]==nil)?@"":[dict objectForKey:@"strReceivedRate"];
        NSString *totalSize = ([dict objectForKey:@"totalSize"]==nil)?@"":[dict objectForKey:@"totalSize"];
        NSString *totalFloatSize = ([dict objectForKey:@"totalFloatSize"]==nil)?@"":[dict objectForKey:@"totalFloatSize"];
        NSString *time = ([dict objectForKey:@"time"]==nil)?@"":[dict objectForKey:@"time"];
        NSString *down = ([dict objectForKey:@"down"]==nil)?@"":[dict objectForKey:@"down"];
        NSString *loadingStr = ([dict objectForKey:@"loadingStr"]==nil)?@"":[dict objectForKey:@"loadingStr"];
        NSString *progress = ([dict objectForKey:@"progress"]==nil)?@"":[dict objectForKey:@"progress"];
        NSString *imageURL = ([dict objectForKey:@"imageURL"]==nil)?@"":[dict objectForKey:@"imageURL"];
        NSString *updateSQL = [NSString stringWithFormat:@"insert into downLoadedFileTable(fileID,fileName,savePathRes,mineType,savePath,url,content_length,strSize,everySize,strReceivedSize,strReceivedRate,totalSize,totalFloatSize,time,down,loadingStr,progress,imageURL) values('%@','%@','%@','%@','%@','%@','%@','%@','%@','%@','%@','%@','%@','%@','%@','%@','%@','%@');",fileID,fileName,savePathRes,mineType,savePath,url,content_length,strSize,everySize,strReceivedSize,strReceivedRate,totalSize,totalFloatSize,time,down,loadingStr,progress,imageURL];//down有三种状态0正在下载，1已经完成，2暂停
        char *errorMsg;
        if (sqlite3_exec(database, [updateSQL UTF8String], NULL, NULL, &errorMsg) == SQLITE_OK) {
            sqlite3_free(errorMsg);
            result = YES;
        }
        else {
        }
        sqlite3_close(database);
    }
    return result;
}
+(NSMutableArray *)selectFileInfo:(NSString *)selectSQL{
    if (![HBSqlite creatDownLoaderTable]) {
        return nil;
    }
//    NSString *selectSQL = [NSString stringWithFormat:@"select * from paperTable where finish_flag = '%d' and paper_auther = '%@';",1,@"11"];
    NSMutableArray *dataArray = [NSMutableArray arrayWithCapacity:1.0];
    sqlite3_stmt *statement;
    if (sqlite3_prepare_v2(database, [selectSQL UTF8String], -1, &statement, nil) == SQLITE_OK) {
        while (sqlite3_step(statement) == SQLITE_ROW) {
            NSMutableDictionary *dict = [NSMutableDictionary dictionaryWithCapacity:1];
            const char *fileID = (char*)sqlite3_column_text(statement, 0);
            const char *fileName = (char*)sqlite3_column_text(statement, 1);
            const char *savePathRes = (char*)sqlite3_column_text(statement, 2);
            const char *mineType = (char*)sqlite3_column_text(statement, 3);
            const char *savePath = (char*)sqlite3_column_text(statement, 4);
            const char *url = (char*)sqlite3_column_text(statement, 5);
            const char *content_length = (char*)sqlite3_column_text(statement, 6);//time
            const char *strSize = (char*)sqlite3_column_text(statement, 7);//time
            const char *everySize = (char*)sqlite3_column_text(statement, 8);//time
            const char *strReceivedSize = (char*)sqlite3_column_text(statement, 9);
            const char *strReceivedRate = (char*)sqlite3_column_text(statement, 10);
            const char *totalSize = (char*)sqlite3_column_text(statement, 11);
            const char *totalFloatSize = (char*)sqlite3_column_text(statement, 12);
            const char *time = (char*)sqlite3_column_text(statement, 13);
            const char *down = (char*)sqlite3_column_text(statement, 14);
            const char *loadingStr = (char*)sqlite3_column_text(statement, 15);
            const char *progress = (char*)sqlite3_column_text(statement, 16);
            const char *imageURL = (char*)sqlite3_column_text(statement, 17);

            [dict setObject:[NSString stringWithUTF8String:fileID] forKey:@"fileID"];
            [dict setObject:[NSString stringWithUTF8String:fileName] forKey:@"fileName"];
            [dict setObject:[NSString stringWithUTF8String:savePathRes] forKey:@"savePathRes"];
            [dict setObject:[NSString stringWithUTF8String:mineType] forKey:@"mineType"];
            [dict setObject:[NSString stringWithUTF8String:savePath] forKey:@"savePath"];
            [dict setObject:[NSString stringWithUTF8String:url] forKey:@"url"];
            [dict setObject:[NSString stringWithUTF8String:content_length] forKey:@"content_length"];
            [dict setObject:[NSString stringWithUTF8String:strSize] forKey:@"strSize"];
            [dict setObject:[NSString stringWithUTF8String:everySize] forKey:@"everySize"];
            [dict setObject:[NSString stringWithUTF8String:strReceivedSize] forKey:@"strReceivedSize"];
            [dict setObject:[NSString stringWithUTF8String:strReceivedRate] forKey:@"strReceivedRate"];
            [dict setObject:[NSString stringWithUTF8String:totalSize] forKey:@"totalSize"];
            [dict setObject:[NSString stringWithUTF8String:totalFloatSize] forKey:@"totalFloatSize"];
            [dict setObject:[NSString stringWithUTF8String:time] forKey:@"time"];
            [dict setObject:[NSString stringWithUTF8String:down] forKey:@"down"];
            [dict setObject:[NSString stringWithUTF8String:loadingStr] forKey:@"loadingStr"];
            [dict setObject:[NSString stringWithUTF8String:progress] forKey:@"progress"];
            [dict setObject:[NSString stringWithUTF8String:imageURL] forKey:@"imageURL"];
            [dataArray addObject:dict];
        }
    }
    sqlite3_finalize(statement);
    sqlite3_close(database);
    return dataArray;
}
+(BOOL)deleteFileBy:(NSString*)file_ID{
    BOOL result = NO;
    if ([HBSqlite creatDownLoaderTable]) {
        NSString *updateSQL = [NSString stringWithFormat:@"delete from downLoadedFileTable where fileID='%@'",file_ID];
        char *errorMsg;
        if (sqlite3_exec(database, [updateSQL UTF8String], NULL, NULL, &errorMsg) == SQLITE_OK) {
            sqlite3_free(errorMsg);
            result = YES;
        }
        else {
        }
        sqlite3_close(database);
    }
    return result;
}
+(BOOL)updateDownLoaderInfoBy:(NSString*)SQL{
    if(![HBSqlite creatDownLoaderTable]) {
        return NO;
    }
//    NSString *updateSQL = [NSString stringWithFormat:@"update testQuestionTable set user_answer = '%@' where  paper_id='%@' and author_id ='%@';", user_answer,paper_id,author_id];
    char *errorMsg;
    if (sqlite3_exec(database, [SQL UTF8String], NULL, NULL, &errorMsg) == SQLITE_OK) {
        sqlite3_free(errorMsg);
    }
    else {
        NSLog(@"updateData fail error:%s",errorMsg);
        return NO;
    }
    sqlite3_close(database);
    return YES;
}
@end
