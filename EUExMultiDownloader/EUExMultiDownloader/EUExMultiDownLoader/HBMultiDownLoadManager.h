//
//  HBMultiDownLoadManager.h
//  AppCanPlugin
//
//  Created by hongbao.cui on 15-1-24.
//  Copyright (c) 2015年 zywx. All rights reserved.
//

#import <Foundation/Foundation.h>
@class ASINetworkQueue;
@interface HBMultiDownLoadManager : NSObject
@property(nonatomic,strong)ASINetworkQueue *networkQueue;
@property(nonatomic,copy)NSString *fileName;
@property(nonatomic,copy)NSString *savePathRes;
@property(nonatomic,copy)NSString *mineType;
@property(nonatomic,copy)NSString *savePath;
@property(nonatomic,copy)NSString *url;
@property(nonatomic,copy)NSString *fileID;
@property(nonatomic)BOOL bFirstReceived;
@property(nonatomic,copy)NSString *content_length;
@property(nonatomic,copy)NSString *strSize;
@property(nonatomic,copy)NSString *everySize;
@property(nonatomic,copy)NSString *strReceivedSize;
@property(nonatomic,copy)NSString *strReceivedRate;
@property(nonatomic,copy)NSString *totalSize;
@property(nonatomic,copy)NSString *totalFloatSize;
@property(nonatomic,copy)NSString *loadingStr;
@property(nonatomic,copy)NSString *progesss;
@end
