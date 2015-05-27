//
//  HBProgressView.m
//  AppCanPlugin
//
//  Created by hongbao.cui on 15-1-22.
//  Copyright (c) 2015年 zywx. All rights reserved.
//

#import "HBProgressView.h"
#import "ASIHTTPRequest.h"
#import "HBMultiDownLoadManager.h"
#import "HBSqlite.h"
#import "EUtility.h"
@implementation HBProgressView
-(id)initWithFrame:(CGRect)frame{
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [UIColor clearColor];
        _progressView = [[UIProgressView alloc] initWithProgressViewStyle:UIProgressViewStyleDefault];
        [_progressView setFrame:CGRectMake(0.0, 3.5, self.frame.size.width, 2)];
        [_progressView setProgressTintColor:[EUtility ColorFromString:@"#4ca5f0"]];
        [_progressView setTrackTintColor:[EUtility ColorFromString:@"#ebebeb"]];
        [_progressView setProgress:0.0];
        [_progressView setTrackTintColor:[UIColor lightGrayColor]];
        [self addSubview:_progressView];
        
        _loadingView = [[UIImageView alloc] initWithFrame:CGRectMake(0.0, 8.5, 11.0,15.0)];
        [_loadingView setImage:[UIImage imageNamed:@"uexMultiDownloader/uexMultiDownLoader_Load.png"]];
        [self addSubview:_loadingView];
        
        _loadedLabel = [[UILabel alloc] initWithFrame:CGRectMake(21, 8.5, 120.0, 25.0)];
        [_loadedLabel setText:@"0.0kB/0.0kB"];
        [_loadedLabel setFont:[UIFont systemFontOfSize:12.0]];
        [_loadedLabel setTextColor:[EUtility ColorFromString:@"#a4a4a4"]];
        [_loadedLabel setBackgroundColor:[UIColor clearColor]];
        [self addSubview:_loadedLabel];
        
        _loadingProgressLabel = [[UILabel alloc] initWithFrame:CGRectMake(21.0+100+30, 8.5, 100.0, 25.0)];
        [_loadingProgressLabel setText:@"0.0kB/s"];
        [_loadingProgressLabel setFont:[UIFont systemFontOfSize:12.0]];
        [_loadingProgressLabel setTextColor:[EUtility ColorFromString:@"#666666"]];
        [_loadingProgressLabel setBackgroundColor:[UIColor clearColor]];
        [self addSubview:_loadingProgressLabel];
    }
    return self;
}
/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/
- (void)setProgress:(float)newProgress{
    _progressView.progress = newProgress;
}
- (void)request:(ASIHTTPRequest *)request didReceiveBytes:(long long)bytes{
    NSLog(@"-----bytes-------%lld",bytes);
    HBMultiDownLoadManager *downLoadManager =[request.userInfo objectForKey:@"multiDownLoadManager"];
    if ([downLoadManager.fileID isEqualToString:_file_ID]) {
        if (downLoadManager.bFirstReceived) {
           downLoadManager.strReceivedSize =  [NSString stringWithFormat:@"%lld",[downLoadManager.strReceivedSize longLongValue] + bytes];//累加已下载文件大小（缓存目录中的缓存文件）
            downLoadManager.strReceivedRate = [NSString stringWithFormat:@"%lld",bytes];                                                                                     //速率
        }else{
            downLoadManager.strReceivedSize = [NSString stringWithFormat:@"%lld",bytes];                                                                                     //如果是断点后的再次下载，bytes就为已下载文件大小.
            downLoadManager.bFirstReceived = true;
        }
        NSLog(@"----strReceivedSize-every-------%lld",bytes);
        //刷新UI
       unsigned long  every= [ASIHTTPRequest averageBandwidthUsedPerSecond];
        NSLog(@"----ASIHTTPRequest-every-------%lu",every);
        NSString *everySize;
        if ((every/1000)<1024) {
            everySize = [NSString stringWithFormat:@"%.2fK/s" ,every/1000.0];
        }else{
            everySize = [NSString stringWithFormat:@"%.2fM/s",every/1000000.0];
        }
        [_loadingProgressLabel setText :everySize];
        NSString *loadingStr =nil;
        if (([downLoadManager.strReceivedSize longLongValue]/1000)<1024) {
            loadingStr = [NSString stringWithFormat:@"%.2fKB/%@" ,[downLoadManager.strReceivedSize longLongValue]/ 1000.0,downLoadManager.totalSize];
        }else{
            loadingStr = [NSString stringWithFormat:@"%.2fMB/%@" ,[downLoadManager.strReceivedSize longLongValue]/ 1000000.0,downLoadManager.totalSize];
        }//累加已下载文件大小（缓存目录中的缓存文件）
        [_loadedLabel setText :loadingStr];
        downLoadManager.loadingStr = loadingStr;
        NSString *progress = [NSString stringWithFormat:@"%.2f",[downLoadManager.strReceivedSize floatValue]/[downLoadManager.totalFloatSize floatValue]];
        downLoadManager.progesss = progress;
           NSString *updateSQL = [NSString stringWithFormat:@"update downLoadedFileTable set strReceivedSize = '%@',loadingStr = '%@',content_length = '%@',progress ='%@' where  fileID='%@';",downLoadManager.strReceivedSize,loadingStr,downLoadManager.totalSize,progress, downLoadManager.fileID];
           BOOL success = [HBSqlite updateDownLoaderInfoBy:updateSQL];
            if (success) {
                NSLog(@"更新下载进度成功");
            }
    }
}
-(void)dealloc{
    if (_progressView) {
        [_progressView release];
        _progressView = nil;
    }
    if (_loadingView) {
        [_loadingView release];
        _loadingView = nil;
    }
    if (_loadingProgressLabel) {
        [_loadingProgressLabel release];
        _loadingProgressLabel = nil;
    }
    if (_loadedLabel) {
        [_loadedLabel release];
        _loadedLabel = nil;
    }
    if (self.file_ID) {
        self.file_ID = nil;
    }
    [super dealloc];
}
@end
