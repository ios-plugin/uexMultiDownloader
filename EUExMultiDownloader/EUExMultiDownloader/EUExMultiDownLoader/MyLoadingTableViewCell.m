//
//  MyLoadingTableViewCell.m
//  AppCanPlugin
//
//  Created by hongbao.cui on 15-1-12.
//  Copyright (c) 2015年 zywx. All rights reserved.
//

#import "MyLoadingTableViewCell.h"
#import "ASINetworkQueue.h"
#import "ASIHTTPRequest.h"
#import "HBProgressView.h"
#import "HBMultiDownLoadManager.h"
#import "UIImageView+WebCache.h"
@implementation MyLoadingTableViewCell
@synthesize networkQueue;
- (void)awakeFromNib {
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}
-(void)accessoryBtnClicked:(id)sender{
    if (self.accessoryBlock) {
        self.accessoryBlock(self);
    }
}
-(id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        UIImageView *iconImageView = [[UIImageView alloc] initWithFrame:CGRectMake(10.0, 15.0, 46.5, 46.5)];
        [iconImageView setImage:[UIImage imageNamed:@"uexMultiDownloader/uexMultiDownLoader_icon.png"]];
        [iconImageView setTag:1000];
        [self addSubview:iconImageView];
        [iconImageView release];
        
        _titleLabel  = [[UILabel alloc] initWithFrame:CGRectMake(66.5, 14.0, 200.0, 25.0)];
        [_titleLabel setText:@"hiappcan.apk"];
        [_titleLabel setBackgroundColor:[UIColor clearColor]];
        [self addSubview:_titleLabel];
        _hbProgressView = [[HBProgressView alloc]initWithFrame:CGRectMake(66.5, 43.5, self.frame.size.width-66.5-50-20, 30)];
        [self addSubview:_hbProgressView];
        
//        _menueImageView = [[UIImageView alloc] initWithFrame:CGRectMake(87.5+100+90, (76.0-31.0)/2, 31.0, 31.0)];
//        [_menueImageView setImage:[UIImage imageNamed:@"uexMultiDownloader/uexMultiDownLoader_downBtn.png"]];
//        [self addSubview:_menueImageView];
        UIButton *accessoryBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        [accessoryBtn setFrame:CGRectMake(0, 0, 40.0, 40.0)];
        [accessoryBtn setBackgroundImage:[UIImage imageNamed:@"uexMultiDownloader/uexMultiDownLoader_downBtn.png"] forState:UIControlStateNormal];
        [accessoryBtn setBackgroundImage:[UIImage imageNamed:@"uexMultiDownloader/uexMultiDownLoader_downBtn.png"] forState:UIControlStateHighlighted];
        [accessoryBtn addTarget:self action:@selector(accessoryBtnClicked:) forControlEvents:UIControlEventTouchUpInside];
        self.accessoryView = accessoryBtn;
        self.backgroundColor = [UIColor whiteColor];
    }
    return self;
}
-(void)setModelReloadData:(NSDictionary *)dataDict{
    NSString *fileName = [dataDict objectForKey:@"fileName"];
    [_titleLabel setText:fileName];
    NSString *savePathRes = [dataDict objectForKey:@"savePathRes"];
    NSString *fileMineType = [dataDict objectForKey:@"mineType"];
    NSString *savePath = [dataDict objectForKey:@"savePath"];
    NSString *urlString = [dataDict objectForKey:@"url"];
    NSString *fileid = [dataDict objectForKey:@"fileID"];
    NSString *imageURL = [dataDict objectForKey:@"imageURL"];
    UIImageView *iconImageView = (UIImageView *)[self viewWithTag:1000];
    if ([imageURL hasPrefix:@"http://"]||[imageURL hasPrefix:@"https://"]) {
        NSURL *url = [NSURL URLWithString:imageURL];
        [iconImageView setImageWithURL:url placeholderImage:[UIImage imageNamed:@"uexMultiDownloader/uexMultiDownLoader_icon.png"]];
    }else{
        UIImage *image = [UIImage imageWithContentsOfFile:imageURL];
        [iconImageView setImage:image];
    }
    self.fileID = fileid;
    _hbProgressView.file_ID = fileid;
    for (ASIHTTPRequest *request in [networkQueue operations]) {
       HBMultiDownLoadManager *multiDownLoadManager = [request.userInfo objectForKey:@"multiDownLoadManager"];
        if ([multiDownLoadManager.fileID isEqualToString:fileid]) {
            return;
        }
    }
    urlString = [urlString stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    NSFileManager *fm= nil;
    if (fm == nil) {
        fm=[NSFileManager defaultManager];
    }
    // 先创建文件 file1 ，再用 NSFileHandle 打开它
    NSString *path1=[savePath stringByAppendingPathComponent :fileName];
    BOOL b = [fm createFileAtPath:path1 contents:nil attributes:nil];
    __block uint fSize1= 0 ; // 以 B 为单位，记录已下载的文件大小 , 需要声明为块可写
    NSURL *url1 = [NSURL URLWithString: urlString];
//    NSFileHandle *fh1=nil;
//    if (b) {
//        fh1=[ NSFileHandle fileHandleForWritingAtPath :path1];
//    }
    //////////////////////////// 任务队列 /////////////////////////////
    if (! networkQueue ) {
        ASINetworkQueue *queue = [[ASINetworkQueue alloc ] init ];
        self.networkQueue =queue;
        [queue release];
    }
    failed = NO ;
    [networkQueue reset]; // 队列清零
//    [networkQueue setDownloadProgressDelegate:progress_total]; // 设置 queue 进度条
    [networkQueue setShowAccurateProgress : YES ]; // 进度精确显示
    [networkQueue setDelegate : self ]; // 设置队列的代理对象
    [networkQueue setRequestDidStartSelector:@selector(setRequestDidStartSelector:)];
    ///////////////// request for file1 //////////////////////
   ASIHTTPRequest *request = [ASIHTTPRequest requestWithURL :url1]; // 设置文件 1 的 url
    [request setDownloadProgressDelegate:_hbProgressView ]; // 文件 1 的下载进度条
    HBMultiDownLoadManager *multiDownLoadManager = [[HBMultiDownLoadManager alloc] init];
    multiDownLoadManager.url = urlString;
    multiDownLoadManager.fileID = fileid;
    multiDownLoadManager.fileName = fileName;
    multiDownLoadManager.mineType = fileMineType;
    multiDownLoadManager.savePath = savePath;
    multiDownLoadManager.savePathRes = savePathRes;
    NSString *tempFilepath = [NSString stringWithFormat:@"%@.temp",path1];
    [request setDownloadDestinationPath:path1];
    [request setTemporaryFileDownloadPath:tempFilepath];
    [request setAllowResumeForFileDownloads:YES];
    [request setHeadersReceivedBlock:^(NSDictionary *responseHeaders) {
        NSLog(@"responseHeaders--------->%@",responseHeaders);
        HBMultiDownLoadManager *downManager = [request.userInfo objectForKey:@"multiDownLoadManager"];
        if ([fileid isEqualToString:downManager.fileID]) {
            NSString *Content_Range = [responseHeaders objectForKey:@"Content-Range"];
            NSString *Connection = [responseHeaders objectForKey:@"Connection"];
            NSString *length_content = nil;
            if ((Content_Range==nil)&&[Connection isEqualToString:@"keep-alive"]) {                        //是否是断点后重新接受的数据
                multiDownLoadManager.bFirstReceived = true;
                multiDownLoadManager.strSize = [NSString stringWithFormat:@"%lld",request.contentLength]; //文件大小
                NSNumber *Content_Length = [responseHeaders objectForKey:@"Content-Length"];
                length_content = [NSString stringWithFormat:@"%f",[Content_Length floatValue]];
            }else{
                NSArray *rangeArray = [Content_Range componentsSeparatedByString:@"/"];
                NSString *Content_Length = [rangeArray lastObject];
                length_content = [NSString stringWithFormat:@"%f",[Content_Length floatValue]];
                multiDownLoadManager.bFirstReceived = false;
            }
            multiDownLoadManager.content_length = length_content;
            NSString *totalStr = nil;
            if (([length_content longLongValue]/1000)<1024) {
                totalStr = [NSString stringWithFormat:@"%.2fKB",[length_content floatValue]/1000];
            }else{
                totalStr = [NSString stringWithFormat:@"%.2fMB",[length_content floatValue]/1000000];
            }
            self.content_length = totalStr;
            multiDownLoadManager.totalSize = totalStr;
            multiDownLoadManager.totalFloatSize = length_content;
        }
    }];
    // 设置 userInfo ，可用于识别不同的 request 对象
    [request setUserInfo :[NSDictionary dictionaryWithObject:multiDownLoadManager forKey : @"multiDownLoadManager" ]];
    [multiDownLoadManager release];
    // 使用 complete 块，在下载完时做一些事情
    [request setCompletionBlock :^( void ){
        NSLog ( @"%@ complete !" ,fileName);
        HBMultiDownLoadManager  *hbDLM = [request.userInfo objectForKey:@"multiDownLoadManager"];
//        NSUserDefaults *standors = [NSUserDefaults standardUserDefaults];
//        NSMutableArray *doneArray = [standors objectForKey:@"multiDownLoaderDone"];
//        NSMutableArray  *array = [NSMutableArray arrayWithCapacity:1.0];
//        for (NSDictionary *dict in doneArray) {
//            NSString *file_ID = [dict objectForKey:@"fileID"];
//            if ([file_ID isEqualToString:hbDLM.fileID]) {
//                
//            }else{
//                [array addObject:dict];
//            }
//        }
//        [standors setObject:array forKey:@"multiDownLoaderDone"];
        _status = 1;
        if (self.completedBlock) {
            self.completedBlock(self);
        }
        _hbProgressView.progressView.progress = 0.0;
        _hbProgressView.loadedLabel.text = @"0.0kB/0.0kB";
        [_hbProgressView.loadingProgressLabel setText:@"0.0kB/s"];
        
    }];
    // 使用 failed 块，在下载失败时做一些事情
    [request setFailedBlock :^( void ){
        NSLog ( @"%@ download failed !" ,fileName);
        NSLog(@"error------>%@",[request.error debugDescription]);
        _status = 0;
        if (self.failBlock) {
            self.failBlock(self);
        }
    }
     ];
    [ networkQueue addOperation :request];
    [networkQueue go]; // 队列任务开始
}
-(void)setRequestDidStartSelector:(ASINetworkQueue *)netQueue{
    if (self.onQueueBlock) {
        self.onQueueBlock(self);
    }
}
- (void)didReceiveResponseHeaders:(ASIHTTPRequest *)request
{
    NSLog(@"didReceiveResponseHeaders %@",[request.responseHeaders valueForKey:@"Content-Length"]);
    NSDictionary *responseHeaders = request.responseHeaders;
    HBMultiDownLoadManager *downManager = [request.userInfo objectForKey:@"multiDownLoadManager"];
    if ([self.fileID isEqualToString:downManager.fileID]) {
        if (![responseHeaders objectForKey:@"Content-Range"]) {                        //是否是断点后重新接受的数据
            downManager.bFirstReceived = true;
            downManager.strSize = [NSString stringWithFormat:@"%lld",request.contentLength]; //文件大小
            NSNumber *Content_Length = [responseHeaders objectForKey:@"Content-Length"];
            NSString *length_content = [NSString stringWithFormat:@"%f",[Content_Length floatValue]];
            downManager.content_length = length_content;
            NSString *totalStr = nil;
            if (([length_content longLongValue]/1000)<1024) {
                totalStr = [NSString stringWithFormat:@"%.2fKB",[length_content floatValue]/1000];
            }else{
                totalStr = [NSString stringWithFormat:@"%.2fMB",[length_content floatValue]/1000000];
            }
            self.content_length = totalStr;
            downManager.totalSize = totalStr;
            downManager.totalFloatSize = length_content;
        }else{
            downManager.bFirstReceived = false;
        }
    }
}
-(void)dealloc{
    if (_titleLabel) {
        [_titleLabel release];
        _titleLabel = nil;
    }
    if (_menueImageView) {
        [_menueImageView release];
        _menueImageView = nil;
    }
    if (self.completedBlock) {
        self.completedBlock = nil;
    }
    if (self.fileID) {
        self.fileID = nil;
    }
    if (networkQueue) {
        [networkQueue cancelAllOperations];
        [networkQueue release];
        networkQueue = nil;
    }
    if (_hbProgressView) {
        [_hbProgressView release];
        _hbProgressView = nil;
    }
    if (self.content_length) {
        self.content_length = nil;
    }
    if (self.failBlock) {
        self.failBlock = nil;
    }
    if (self.accessoryBlock) {
        self.accessoryBlock = nil;
    }
    [super dealloc];
}
@end
