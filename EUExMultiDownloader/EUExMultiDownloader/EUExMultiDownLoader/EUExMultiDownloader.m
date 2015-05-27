//
//  EUExMultiDownloader.m
//  AppCanPlugin
//
//  Created by hongbao.cui on 15-1-11.
//  Copyright (c) 2015年 zywx. All rights reserved.
//

#import "EUExMultiDownloader.h"
#import "JSON.h"
#import "EUtility.h"
#import "MyLoadingTableViewCell.h"
#import "QQSectionHeaderView.h"
#import "ASINetworkQueue.h"
#import "ASIHTTPRequest.h"
#import "HBProgressView.h"
#import "HBMyLoadedTableViewCell.h"
#import "HBMultiDownLoadManager.h"
#import "HBSqlite.h"
@interface EUExMultiDownloader()<QQSectionHeaderViewDelegate,UIActionSheetDelegate>{
//    NSInteger addRow;
//    BOOL isPause;
    BOOL fileCount;
    HBMyLoadedTableViewCell *downDoneCell;
    MyLoadingTableViewCell *loadingCell;
}
@property(nonatomic,retain)    NSMutableArray *indexPathsArray;
@property(nonatomic,retain) NSMutableArray *arrayList;
@end
@implementation EUExMultiDownloader
@synthesize hbTableView;
@synthesize dataList;
-(id)initWithBrwView:(EBrowserView *)eInBrwView{
    self = [super initWithBrwView:eInBrwView];
    if (self) {
        
    }
    return self;
}
-(void)clean{
    [self releaseMyDealloc];
    [super clean];
}
-(void)releaseMyDealloc{
    if (self.hbTableView) {
        [self.hbTableView removeFromSuperview];
        self.hbTableView = nil;
    }
    if (self.dataList) {
        [self.dataList removeAllObjects];
        self.dataList = nil;
    }
    if (_indexPathsArray) {
//        [_indexPathsArray removeAllObjects];
        [_indexPathsArray release];
        _indexPathsArray = nil;
    }
    if (_arrayList) {
        [_arrayList removeAllObjects];
        [_arrayList release];
        _arrayList = nil;
    }
    NSString *selectSQL_loading = [NSString stringWithFormat:@"select * from downLoadedFileTable where down ='%@';",@"0"];//正在下载的
    NSMutableArray *listArray_loading = [HBSqlite selectFileInfo:selectSQL_loading];
    for (NSInteger j=0; j<[listArray_loading count]; j++) {
        NSIndexPath *indexPath = [NSIndexPath indexPathForRow:j inSection:0];
        MyLoadingTableViewCell *cell = (MyLoadingTableViewCell *)[hbTableView cellForRowAtIndexPath:indexPath];
        [cell.networkQueue cancelAllOperations];
    }

}
-(void)dealloc{
    [self releaseMyDealloc];
    [super dealloc];
}
-(void)openManagerView:(NSMutableArray *)array{
    if ([array count] ==0) {
        NSLog(@"paragms is error!!");
        return;
    }
    NSDictionary *dict = [[array objectAtIndex:0] JSONValue];
    CGFloat x = [[dict objectForKey:@"x"] floatValue];
    CGFloat y = [[dict objectForKey:@"y"] floatValue];
    CGFloat width = [[dict objectForKey:@"w"] floatValue];
    CGFloat height = [[dict objectForKey:@"h"] floatValue];
    if (!self.hbTableView) {
        UITableView *tempTableView = [[UITableView alloc] initWithFrame:CGRectMake(x, y, width, height) style:UITableViewStylePlain];
        self.hbTableView = tempTableView;
        [tempTableView release];
        [hbTableView setDelegate:self];
        [hbTableView setDataSource:self];
    }else{
        return;
    }
    if (!self.dataList) {
        self.dataList = [NSMutableArray arrayWithCapacity:1];
    }
    NSString *selectSQL_Pause = [NSString stringWithFormat:@"select * from downLoadedFileTable where down ='%@';",@"2"];
    NSMutableArray *listArray_Pause = [HBSqlite selectFileInfo:selectSQL_Pause];
    [self.dataList addObject:[NSMutableDictionary dictionaryWithObjectsAndKeys:@"正在下载",@"sectionTitle",listArray_Pause,@"list",nil]];
    
    NSString *selectSQL_down = [NSString stringWithFormat:@"select * from downLoadedFileTable where down ='%@';",@"1"];
    NSMutableArray *listArray_down = [HBSqlite selectFileInfo:selectSQL_down];
    [self.dataList addObject:[NSMutableDictionary dictionaryWithObjectsAndKeys:@"已下载",@"sectionTitle",listArray_down,@"list",nil]];
    
    for (NSInteger j=0; j<[self.dataList count]; j++) {
        NSMutableArray *indexPathsArray = [NSMutableArray arrayWithCapacity:1];
        NSMutableDictionary *dictPath = [self.dataList objectAtIndex:j];
            NSArray *arrayDown_localArray = [dictPath objectForKey:@"list"];
            for (NSInteger i=0; i<[arrayDown_localArray count]; i++) {
                NSIndexPath *indexPa = [NSIndexPath indexPathForRow:i inSection:j];
                [indexPathsArray addObject:indexPa];
            }
        NSMutableDictionary *pathsDict = [NSMutableDictionary dictionaryWithCapacity:1];
        [pathsDict setObject:indexPathsArray forKey:@"indexPaths"];
        [dictPath addEntriesFromDictionary:pathsDict];
    }
    [EUtility brwView:self.meBrwView addSubview:hbTableView];
}
-(void)closeManagerView:(NSMutableArray *)array{
    [self releaseMyDealloc];
}
-(void)enqueue:(NSMutableArray *)array{
    if ([array count] ==0) {
        NSLog(@"paragms is error!!");
        return;
    }
    NSDictionary *dict = [[array objectAtIndex:0] JSONValue];
    NSString *urlStr = [dict objectForKey:@"url"];
    NSString *savePathRes = [dict objectForKey:@"savePath"];
    NSString *savePath = [EUtility getAbsPath:self.meBrwView path:savePathRes];
    NSString *fileName = [dict objectForKey:@"name"];
    NSString *fileMineType = [dict objectForKey:@"mineType"];
    NSString *fileNameMineType = [NSString stringWithFormat:@"%@.%@",fileName,fileMineType];
    NSString *fileloading_Icon = [dict objectForKey:@"imageURL"];
    NSString *fileloading_IconPath = [[EUtility getAbsPath:self.meBrwView path:fileloading_Icon] stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    NSString *path = [savePath stringByAppendingPathComponent:fileNameMineType];
//    NSFileManager *fileManager = [NSFileManager defaultManager];
//   BOOL sucess =  [fileManager fileExistsAtPath:path];
//    if (sucess) {
//        fileCount = 0;
//        fileNameMineType = [NSString stringWithFormat:@"%@(%d).%@",fileName,fileCount+1,fileMineType];
//        fileCount++;
//    }
    NSString *fileid = [dict objectForKey:@"id"];

    NSMutableDictionary *listDict = (NSMutableDictionary *)[self.dataList objectAtIndex:0];
    if (!_arrayList) {
        _arrayList = [[NSMutableArray alloc] initWithCapacity:1.0];
    }
    NSString *timeStr = [self stringFromDate:[NSDate date]];
    NSLog(@"timeStr-------%@",timeStr);
    NSDictionary *inforDict = [NSDictionary dictionaryWithObjectsAndKeys:urlStr,@"url",savePathRes,@"savePathRes",savePath,@"savePath",fileNameMineType,@"fileName",fileMineType,@"mineType",fileloading_IconPath,@"imageURL",fileid,@"fileID",@"0",@"down",timeStr,@"time",nil];
    BOOL success = [HBSqlite insertFileInfo:inforDict];//down 0是正在下载，1是下载完成，2是暂停下载
    if (success) {
        NSLog(@"下载数据插入数据库成功");
    }
//    NSString *selectSQL = [NSString stringWithFormat:@"select * from downLoadedFileTable where down ='%@' and fileID='%@';",@"0",cell.fileID];
//    BOOL selectSuccess = [HBSqlite selectFileInfo:<#(NSString *)#>];
    //NSIndexPath
    NSMutableDictionary *dictPath = [self.dataList objectAtIndex:0];
    NSMutableDictionary *pathsDict = [NSMutableDictionary dictionaryWithCapacity:1];
    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:[_arrayList count]+1 inSection:0];
    NSMutableArray *indexPathArray = [dictPath objectForKey:@"indexPaths"];
    if (indexPathArray) {
        [indexPathArray addObject:indexPath];
        [pathsDict setObject:indexPathArray forKey:@"indexPaths"];
        [pathsDict setObject:[NSNumber numberWithBool:YES] forKey:@"opened"];
        [dictPath addEntriesFromDictionary:pathsDict];
    }
    [_arrayList addObject:inforDict];
    [listDict setObject:_arrayList forKey:@"list"];
//    if(addRow == 0){
        [self.hbTableView reloadData];
//    }else{
//        [self.hbTableView insertRowsAtIndexPaths:[NSArray arrayWithObjects:indexPath, nil] withRowAnimation:UITableViewRowAnimationMiddle];
//    }
//    if (!_indexPathsArray) {
//        _indexPathsArray = [NSMutableArray arrayWithCapacity:1];
//    }
//    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:0 inSection:1];
//    [_indexPathsArray addObject:indexPath];
//    NSMutableDictionary *dictPath = [self.dataList objectAtIndex:0];
//    NSMutableDictionary *pathsDict = [NSMutableDictionary dictionaryWithCapacity:1];
//    [pathsDict setObject:_indexPathsArray forKey:@"indexPaths"];
//    [dictPath addEntriesFromDictionary:pathsDict];
    
//    [self.hbTableView insertRowsAtIndexPaths:indexPathsArray withRowAnimation:UITableViewRowAnimationMiddle];
//    [self.hbTableView reloadData];
//    addRow++;
}
-(void)queryById:(NSMutableArray *)array{
    if ([array count] ==0) {
        NSLog(@"paragms is error!!");
        return;
    }
    NSDictionary *dict = [[array objectAtIndex:0] JSONValue];
    NSString *fileID = [dict objectForKey:@"id"];
    NSString *selectSQL = [NSString stringWithFormat:@"select * from downLoadedFileTable where fileID ='%@';",fileID];
    NSMutableArray *listArray_Pause = [HBSqlite selectFileInfo:selectSQL];
    NSDictionary *dict_Info =[listArray_Pause objectAtIndex:0];
    NSString *json = [NSString stringWithFormat:@"uexMultiDownloader.onQuery('%@')",[dict_Info JSONRepresentation]];
    [EUtility brwView:self.meBrwView evaluateScript:json];
}
#pragma -
#pragma tableView
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    if (self.dataList!=nil&&[self.dataList count]>0) {
        return [self.dataList count];
    }else{
        return 1;
    }
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    if (self.dataList!=nil&&[self.dataList count]>0) {
        NSDictionary *dict = [self.dataList objectAtIndex:section];
        NSArray *indexArray = [dict objectForKey:@"indexPaths"];
        if (indexArray!=nil&&[indexArray count]>0) {
            return [indexArray count];
        }else{
            return 1;
        }
    }else{
        return 0;
    }
}
-(NSString *)stringFromDate:(NSDate *)date{
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    //zzz表示时区，zzz可以删除，这样返回的日期字符将不包含时区信息。
    [dateFormatter setDateFormat:@"yyyy-MM-dd HH:mm"];
    NSString *destDateString = [dateFormatter stringFromDate:date];
    [dateFormatter release];
    return destDateString;
}
-(MyLoadingTableViewCell *)tableView:(UITableView *)tableView myLoadingForRowAtIndexPath:(NSIndexPath *)indexPath{
    static NSString *CellIdentifier = @"MyLoadingTableViewCell";
    MyLoadingTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[[MyLoadingTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier] autorelease] ;
    }
    NSDictionary *dict = [self.dataList objectAtIndex:0];
    NSArray *indexArray = [dict objectForKey:@"list"];
    if ([indexArray count]>0) {
        NSDictionary *loadingDict = [indexArray objectAtIndex:indexPath.row];
        NSString *isDone = [loadingDict objectForKey:@"down"];
        if (isDone==nil||[isDone isEqualToString:@"0"]) {
            [cell setModelReloadData:loadingDict];
        }else if([isDone isEqualToString:@"2"]){
            cell.hbProgressView.loadedLabel.text = [loadingDict objectForKey:@"loadingStr"];
            cell.hbProgressView.loadingProgressLabel.text = @"0.0kB/s";
            [cell.hbProgressView.loadingView setImage:[UIImage imageNamed:@"uexMultiDownloader/uexMultiDownLoader_pause.png"]];
            cell.hbProgressView.progressView.progress = [[loadingDict objectForKey:@"progress"] floatValue];
        }
        cell.accessoryBlock = ^(MyLoadingTableViewCell *cell){
            loadingCell = cell;
            NSString *startStr = @"暂停下载";
            if ([isDone isEqualToString:@"2"]) {
                startStr = @"开始任务";
            }
            UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:nil delegate:self cancelButtonTitle:@"取消" destructiveButtonTitle:@"删除任务" otherButtonTitles:startStr, nil];
            UIWindow *keyWindow = [[UIApplication sharedApplication] keyWindow];
            actionSheet.tag = 101;
            [actionSheet showInView:keyWindow];
        };
    }
    cell.completedBlock = ^(MyLoadingTableViewCell *cell){
        NSLog(@"----completedBlock--MyLoadingTableViewCell--%@",cell);
        NSDictionary *dict = [self.dataList objectAtIndex:0];
        NSMutableArray *listArray = [dict objectForKey:@"list"];
        NSMutableArray *indexPathsArray = [dict objectForKey:@"indexPaths"];
        NSIndexPath *downDoneIndexPath = [tableView indexPathForCell:cell];
        if ([listArray count]>0&&([listArray count]>downDoneIndexPath.row)) {
            [listArray removeObjectAtIndex:downDoneIndexPath.row];
        }
        if ([indexPathsArray count]>0&&([indexPathsArray count]>downDoneIndexPath.row)) {
            [indexPathsArray removeObjectAtIndex:downDoneIndexPath.row];
        }
        if ([_arrayList count]>0&&([_arrayList count]>downDoneIndexPath.row)) {
            [_arrayList removeObjectAtIndex:downDoneIndexPath.row];
        }
        NSString *updateSQL = [NSString stringWithFormat:@"update downLoadedFileTable set down = '%@' where  fileID='%@';",@"1", cell.fileID];
        BOOL success = [HBSqlite updateDownLoaderInfoBy:updateSQL];
        if (success) {
            NSLog(@"更新下载状态为下载成功 down=1");
        }
        NSString *selectSQL = [NSString stringWithFormat:@"select * from downLoadedFileTable where down ='%@';",@"1"];
        
        NSMutableArray *listArray1 = [HBSqlite selectFileInfo:selectSQL];
        //已下载过的
        NSMutableDictionary *dict1 = [self.dataList objectAtIndex:1];
//        NSMutableArray *listArray1 = [dict1 objectForKey:@"list"];
//        [listArray1 addObject:done_Dict];
        [dict1 setObject:listArray1 forKey:@"list"];
        
        NSMutableArray *indexArray1 = [NSMutableArray arrayWithCapacity:1.0];
        for (NSInteger i=0; i<[listArray1 count]; i++) {
            NSIndexPath *path = [NSIndexPath indexPathForRow:i inSection:1];
            [indexArray1 addObject:path];
        }
        [dict1 setObject:indexArray1 forKey:@"indexPaths"];
        
//        NSArray *arrayIndexPath = [NSArray arrayWithObjects:indexPath, nil];
//        [self.hbTableView deleteRowsAtIndexPaths:arrayIndexPath withRowAnimation:UITableViewRowAnimationMiddle];
        [self.hbTableView reloadData];
//        [cell.loadedLabel setText:@"0.0kB/0.0kB"];
//        [cell.loadingProgressLabel setText:@"0.0kB/s"];
//        cell.progressView.progress = 0.0;
        NSString *jsonStr = [NSString stringWithFormat:@"{\"id\":\"%@\",\"status\",\"%d\"}",cell.fileID,cell.status];
        NSString *json = [NSString stringWithFormat:@"uexMultiDownloader.onComplete('%@')",jsonStr];
        [EUtility brwView:self.meBrwView evaluateScript:json];
        
    };
    cell.failBlock = ^(MyLoadingTableViewCell *cell){
        NSString *jsonStr = [NSString stringWithFormat:@"{\"id\":\"%@\",\"status\",\"%d\"}",cell.fileID,cell.status];
        NSString *json = [NSString stringWithFormat:@"uexMultiDownloader.onComplete('%@')",jsonStr];
        [EUtility brwView:self.meBrwView evaluateScript:json];
    };
    cell.onQueueBlock = ^(MyLoadingTableViewCell *cell){
        NSString *jsonStr = [NSString stringWithFormat:@"{\"id\":\"%@\"}",cell.fileID];
        NSString *json = [NSString stringWithFormat:@"uexMultiDownloader.onEnqueue('%@')",jsonStr];
        [EUtility brwView:self.meBrwView evaluateScript:json];
    };
    [tableView setSeparatorStyle:UITableViewCellSeparatorStyleSingleLine];
    return cell;
}
-(void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex{
    if (actionSheet.tag == 100) {
        if (buttonIndex==0) {
            NSDictionary *dict = [self.dataList objectAtIndex:1];
            NSMutableArray *listArray = [dict objectForKey:@"list"];
            NSMutableArray *indexPathsArray = [dict objectForKey:@"indexPaths"];

            NSIndexPath *IndexPath = [hbTableView indexPathForCell:downDoneCell];
            NSInteger row = [IndexPath row];
            NSDictionary *listDict = [listArray objectAtIndex:row];
            NSString *fileID= [listDict objectForKey:@"fileID"];
            NSString *fileName= [listDict objectForKey:@"fileName"];
            NSString *savePath= [listDict objectForKey:@"savePath"];
            BOOL delete = [HBSqlite deleteFileBy:fileID];
            if (delete) {
                NSFileManager *fileManager = [NSFileManager defaultManager];
                NSError *error = nil;
                NSString *path = [NSString stringWithFormat:@"%@%@",savePath,fileName];
                [fileManager removeItemAtPath:path error:&error];
                [listArray removeObjectAtIndex:row];
                [indexPathsArray removeObjectAtIndex:row];
                [hbTableView reloadData];
            }
        }
    }else if (actionSheet.tag == 101){
        switch (buttonIndex) {
            case 0:
            {
                NSDictionary *dict = [self.dataList objectAtIndex:0];
                NSMutableArray *listArray = [dict objectForKey:@"list"];
                NSMutableArray *indexPathsArray = [dict objectForKey:@"indexPaths"];
                
                NSIndexPath *IndexPath = [hbTableView indexPathForCell:downDoneCell];
                NSInteger row = [IndexPath row];
                NSDictionary *listDict = [listArray objectAtIndex:row];
                NSString *fileID= [listDict objectForKey:@"fileID"];
                NSString *fileName= [listDict objectForKey:@"fileName"];
                NSString *savePath= [listDict objectForKey:@"savePath"];
                BOOL delete = [HBSqlite deleteFileBy:fileID];
                if (delete) {
                    NSFileManager *fileManager = [NSFileManager defaultManager];
                    NSError *error = nil;
                    NSString *path = [NSString stringWithFormat:@"%@%@.temp",savePath,fileName];
                    [fileManager removeItemAtPath:path error:&error];
                    [listArray removeObjectAtIndex:row];
                    [indexPathsArray removeObjectAtIndex:row];
                    [hbTableView reloadData];
                }
                
            }
                break;
            case 1:
            {
                NSIndexPath *IndexPath = [hbTableView indexPathForCell:loadingCell];
                [self PauseRequest:IndexPath];
            }
                break;
            default:
                break;
        }
    }
}
-(void)showActionSheet{
    UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:nil delegate:self cancelButtonTitle:@"取消" destructiveButtonTitle:@"删除任务" otherButtonTitles:nil, nil];
    UIWindow *keyWindow = [[UIApplication sharedApplication] keyWindow];
    actionSheet.tag = 100;
    [actionSheet showInView:keyWindow];
}
-(HBMyLoadedTableViewCell *)tableView:(UITableView *)tableView downLoadedForRowAtIndexPath:(NSIndexPath *)indexPath{
    static NSString *CellIdentifier = @"myCell";
    HBMyLoadedTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[[HBMyLoadedTableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle  reuseIdentifier:CellIdentifier] autorelease] ;
    }
    NSDictionary *dict = [self.dataList objectAtIndex:indexPath.section];
    NSArray *listArray = [dict objectForKey:@"list"];
    NSDictionary *infoDict = [listArray objectAtIndex:indexPath.row];
    NSString *fileName = [infoDict objectForKey:@"fileName"];
    NSString *time = [infoDict objectForKey:@"time"];
    NSString *content_length = [infoDict objectForKey:@"content_length"];
    NSString *all_formate = [NSString stringWithFormat:@"%@  %@",time,content_length];
    cell.titleLabel.text = fileName;
    cell.fomateLabel.text = all_formate;
    cell.accessoryBlock = ^(HBMyLoadedTableViewCell *accessroyCell){
        downDoneCell = accessroyCell;
        [self showActionSheet];
    };
//    cell.imageView.image =[UIImage imageNamed:@"uexMultiDownloader/uexMultiDownLoader_icon.png"];
//    cell.textLabel.text = fileName;
//    cell.textLabel.font = [UIFont systemFontOfSize:14.0];
//    cell.detailTextLabel.text =all_formate;
//    cell.detailTextLabel.font = [UIFont systemFontOfSize:12.0];
    [tableView setSeparatorStyle:UITableViewCellSeparatorStyleSingleLine];
    return cell;
}
-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    if (self.dataList!=nil&&[self.dataList count]>0) {
        NSDictionary *dict = [self.dataList objectAtIndex:indexPath.section];
        NSArray *indexArray = [dict objectForKey:@"indexPaths"];
        if (indexArray!=nil&&[indexArray count]>0) {
            switch (indexPath.section) {
                case 0:
                    return [self tableView:tableView myLoadingForRowAtIndexPath:indexPath];
                    break;
                case 1:
                    return [self tableView:tableView downLoadedForRowAtIndexPath:indexPath];
                    break;
                default:
                    break;
            }
        }else{
            static NSString *CellIdentifier = @"Cell";
            UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
            if (cell == nil) {
                cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier] autorelease] ;
            }
            cell.textLabel.text = @"暂无数据";
            cell.textLabel.textAlignment = NSTextAlignmentCenter;
            [cell setSelectionStyle:UITableViewCellSelectionStyleNone];
            [tableView setSeparatorStyle:UITableViewCellSeparatorStyleNone];
            return cell;
        }
    }
    return nil;
}
-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    if (indexPath.section==0) {
        return 76.5;
    }
    return 45.0;
}
-(void)PauseRequest:(NSIndexPath *)indexPath{
    NSMutableDictionary *dict = [self.dataList objectAtIndex:0];
    MyLoadingTableViewCell  *myCell = (MyLoadingTableViewCell *)[hbTableView cellForRowAtIndexPath:indexPath];
    NSMutableArray *indexArray = (NSMutableArray *)[dict objectForKey:@"list"];
    NSMutableDictionary *dataDict = [[indexArray objectAtIndex:indexPath.row] mutableCopy];
    NSString *isPause = [dataDict objectForKey:@"down"];
    NSString *file_id = [dataDict objectForKey:@"fileID"];
    if ([isPause isEqualToString:@"0"]) {
        for (ASIHTTPRequest *request in myCell.networkQueue.operations) {
            HBMultiDownLoadManager *multiDownLoadManager = [request.userInfo objectForKey:@"multiDownLoadManager"];
            if ([multiDownLoadManager.fileID isEqualToString:file_id]) {
                if (multiDownLoadManager.loadingStr) {
                    [dataDict setObject:multiDownLoadManager.loadingStr forKey:@"loadingStr"];
                }
                NSString *progress = [NSString stringWithFormat:@"%@",multiDownLoadManager.progesss];
                [dataDict setObject:progress forKey:@"progress"];
                myCell.hbProgressView.progressView.progress = [progress floatValue];
                myCell.hbProgressView.loadingProgressLabel.text = @"任务暂停";
                [myCell.hbProgressView.loadingView setImage:[UIImage imageNamed:@"uexMultiDownloader/uexMultiDownLoader_pause.png"]];
                NSString *updateSQL = [NSString stringWithFormat:@"update downLoadedFileTable set down = '%@',loadingStr='%@',progress='%@' where  fileID='%@';",@"2",multiDownLoadManager.loadingStr,progress,multiDownLoadManager.fileID];
                BOOL success = [HBSqlite updateDownLoaderInfoBy:updateSQL];
                if (success) {
                    NSLog(@"更新下载状态为暂停状态 down=2");
                }
                [request clearDelegatesAndCancel];
            }
        }
        [dataDict setObject:@"2" forKey:@"down"];
    }else if([isPause isEqualToString:@"2"]){
        myCell.hbProgressView.loadingProgressLabel.text = @"0.0kB/s";
        [myCell.hbProgressView.loadingView setImage:[UIImage imageNamed:@"uexMultiDownloader/uexMultiDownLoader_Load.png"]];
        [myCell setModelReloadData:dataDict];//开始
        [dataDict setObject:@"0" forKey:@"down"];
    }
    [indexArray replaceObjectAtIndex:indexPath.row withObject:dataDict];
    [dataDict release];
}
-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    if (self.dataList!=nil&&[self.dataList count]>0) {
        NSDictionary *dict = [self.dataList objectAtIndex:indexPath.section];
        NSArray *indexArray = [dict objectForKey:@"indexPaths"];
        if (indexArray!=nil&&[indexArray count]>0) {
            if (0==indexPath.section) {//正在下载的
                [tableView deselectRowAtIndexPath:indexPath animated:YES];
                [self PauseRequest:indexPath];
            }else{//已下载的
                [tableView deselectRowAtIndexPath:indexPath animated:YES];
//                [self showActionSheet];
            }
            
        }else{//暂无数据
            [tableView deselectRowAtIndexPath:indexPath animated:YES];

        }
    }else{
        
    }
}
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath{
    if (self.dataList!=nil&&[self.dataList count]>0) {
        NSDictionary *dict = [self.dataList objectAtIndex:indexPath.section];
        NSArray *indexArray = [dict objectForKey:@"indexPaths"];
        if (indexArray!=nil&&[indexArray count]>0) {
            if (0==indexPath.section) {//正在下载的
                
            }else{//已下载的
                
            }
            
        }else{//暂无数据
            return NO;
        }
    }else{
        
    }
    return YES;
}
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath{
    if (self.dataList!=nil&&[self.dataList count]>0) {
        NSDictionary *dict = [self.dataList objectAtIndex:indexPath.section];
        NSArray *indexArray = [dict objectForKey:@"indexPaths"];
        if (indexArray!=nil&&[indexArray count]>0) {
            if (0==indexPath.section) {//正在下载的
                MyLoadingTableViewCell  *myCell = (MyLoadingTableViewCell *)[hbTableView cellForRowAtIndexPath:indexPath];
                NSMutableArray *indexArray = (NSMutableArray *)[dict objectForKey:@"list"];
                NSMutableDictionary *dataDict = [[indexArray objectAtIndex:indexPath.row] mutableCopy];
                NSString *isPause = [dataDict objectForKey:@"down"];
                NSString *file_id = [dataDict objectForKey:@"fileID"];
                if ([isPause isEqualToString:@"0"]) {
                    for (ASIHTTPRequest *request in myCell.networkQueue.operations) {
                        HBMultiDownLoadManager *multiDownLoadManager = [request.userInfo objectForKey:@"multiDownLoadManager"];
                        if ([multiDownLoadManager.fileID isEqualToString:file_id]) {
                            [request clearDelegatesAndCancel];
                        }
                    }
                }
                NSDictionary *dict = [self.dataList objectAtIndex:0];
                NSMutableArray *listArray = [dict objectForKey:@"list"];
                NSMutableArray *indexPathsArray = [dict objectForKey:@"indexPaths"];
                NSInteger row = [indexPath row];
                NSDictionary *listDict = [listArray objectAtIndex:row];
                NSString *fileName= [listDict objectForKey:@"fileName"];
                NSString *savePath= [listDict objectForKey:@"savePath"];
                BOOL delete = [HBSqlite deleteFileBy:file_id];
                if (delete) {
                    NSFileManager *fileManager = [NSFileManager defaultManager];
                    NSError *error = nil;
                    NSString *path = [NSString stringWithFormat:@"%@%@",savePath,fileName];
                    [fileManager removeItemAtPath:path error:&error];
                    [listArray removeObjectAtIndex:row];
                    [indexPathsArray removeObjectAtIndex:row];
                    [hbTableView reloadData];
                }
                
            }else{//已下载的
                NSDictionary *dict = [self.dataList objectAtIndex:1];
                NSMutableArray *listArray = [dict objectForKey:@"list"];
                NSMutableArray *indexPathsArray = [dict objectForKey:@"indexPaths"];
                NSInteger row = [indexPath row];
                NSDictionary *listDict = [listArray objectAtIndex:row];
                NSString *fileID= [listDict objectForKey:@"fileID"];
                NSString *fileName= [listDict objectForKey:@"fileName"];
                NSString *savePath= [listDict objectForKey:@"savePath"];
                BOOL delete = [HBSqlite deleteFileBy:fileID];
                if (delete) {
                    NSFileManager *fileManager = [NSFileManager defaultManager];
                    NSError *error = nil;
                    NSString *path = [NSString stringWithFormat:@"%@%@",savePath,fileName];
                    [fileManager removeItemAtPath:path error:&error];
                    [listArray removeObjectAtIndex:row];
                    [indexPathsArray removeObjectAtIndex:row];
                    [hbTableView reloadData];
                }
            }
            
        }else{//暂无数据

        }
    }else{
        
    }
}
#pragma mark - Table view data source
-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    return 30.0;
}
- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section{
    if (self.dataList!=nil && [self.dataList count]>0) {
        
        NSMutableDictionary *dict = [self.dataList objectAtIndex:section];
        NSString* headString=[dict objectForKey:@"sectionTitle"];
        QQSectionHeaderView *sectionHeadView = [[QQSectionHeaderView alloc] initWithFrame:CGRectMake(0.0, 0.0, tableView.bounds.size.width, 30)
                                                                                    title:headString
                                                                                  section:section
                                                                                   opened:[[dict objectForKey:@"opened"] boolValue]
                                                                                 delegate:self] ;
        [sectionHeadView update_QQSectionHeaderView:YES];
        return [sectionHeadView autorelease];
    }else if ([self.dataList count]==0){
        UILabel *titleLabel = [[[UILabel alloc] initWithFrame:CGRectMake(0, 0, tableView.frame.size.width, 45)] autorelease];
        [titleLabel setText:@"暂无数据"];
        [titleLabel setBackgroundColor:[UIColor clearColor]];
        [titleLabel setTextAlignment:UITextAlignmentCenter];
        [tableView setSeparatorStyle:UITableViewCellSeparatorStyleNone];
        return titleLabel;
    }
    return nil;
}
// Override to support conditional editing of the table view.
// - (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
// {
// // Return NO if you do not want the specified item to be editable.
//     return YES;
// }
//

/*
 // Override to support editing the table view.
 - (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
 {
 if (editingStyle == UITableViewCellEditingStyleDelete) {
 // Delete the row from the data source
 [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
 }
 else if (editingStyle == UITableViewCellEditingStyleInsert) {
 // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
 }
 }
 */

/*
 // Override to support rearranging the table view.
 - (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath
 {
 }
 */

/*
 // Override to support conditional rearranging of the table view.
 - (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath
 {
 // Return NO if you do not want the item to be re-orderable.
 return YES;
 }
 */
#pragma mark - QQSectionHeaderViewDelegate
-(void)sectionHeaderView:(QQSectionHeaderView*)sectionHeaderView sectionClosed:(NSInteger)section
{
    if (self.dataList!=nil && [self.dataList count]>0) {
        NSMutableDictionary *dict = [self.dataList objectAtIndex:section];
        if ([[dict objectForKey:@"opened"] boolValue]) {
            [dict setObject:[NSNumber numberWithBool:NO] forKey:@"opened"];
        }else {
            [dict setObject:[NSNumber numberWithBool:YES] forKey:@"opened"];
        }
        NSArray *arrayIndexPath =[NSArray arrayWithArray:[dict objectForKey:@"indexPaths"]];
        [dict removeObjectForKey:@"indexPaths"];//删除数组
        // 收缩+动画 (如果不需要动画直接reloaddata)
        NSInteger countOfRowsToDelete = [self.hbTableView numberOfRowsInSection:section];
        if (countOfRowsToDelete > 0) {
            [self.hbTableView deleteRowsAtIndexPaths:arrayIndexPath withRowAnimation:UITableViewRowAnimationMiddle];
        }
    }
}

-(void)sectionHeaderView:(QQSectionHeaderView*)sectionHeaderView sectionOpened:(NSInteger)section
{
    
    NSMutableArray *indexPathsArray = [NSMutableArray arrayWithCapacity:1];
    NSMutableDictionary *dict = (NSMutableDictionary *)[self.dataList objectAtIndex:section];
    NSArray *arrayList = [dict objectForKey:@"list"];
    for (int i=0; i<[arrayList count]; i++) {
        NSIndexPath *indexPath = [NSIndexPath indexPathForRow:i inSection:section];
        [indexPathsArray addObject:indexPath];
    }
    NSMutableDictionary *pathsDict = [NSMutableDictionary dictionaryWithCapacity:1];
    [pathsDict setObject:indexPathsArray forKey:@"indexPaths"];
    [dict addEntriesFromDictionary:pathsDict];
    
    if (self.dataList!=nil && [self.dataList count]>0) {
        NSMutableDictionary *dict = [self.dataList objectAtIndex:section];
        if ([[dict objectForKey:@"opened"] boolValue]) {
            [dict setObject:[NSNumber numberWithBool:NO] forKey:@"opened"];
        }else {
            [dict setObject:[NSNumber numberWithBool:YES] forKey:@"opened"];
        }
        // 展开+动画 (如果不需要动画直接reloaddata)
        if(![[dict objectForKey:@"indexPaths"] isKindOfClass:[NSNull class]]){
            [self.hbTableView insertRowsAtIndexPaths:[dict objectForKey:@"indexPaths"] withRowAnimation:UITableViewRowAnimationMiddle];
        }
    }
}


@end
