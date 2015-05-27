//
//  HBMultiDownLoadManager.m
//  AppCanPlugin
//
//  Created by hongbao.cui on 15-1-24.
//  Copyright (c) 2015年 zywx. All rights reserved.
//

#import "HBMultiDownLoadManager.h"
#import "ASINetworkQueue.h"
#import "ASIHTTPRequest.h"
@implementation HBMultiDownLoadManager
@synthesize networkQueue;
-(void)dealloc{
    if (self.fileName) {
        self.fileName = nil;
    }
    if (self.savePathRes) {
        self.savePathRes = nil;
    }
    if (self.mineType) {
        self.mineType = nil;
    }
    if (self.savePath) {
        self.savePath = nil;
    }
    if (self.strReceivedRate) {
        self.strReceivedRate = nil;
    }
    if (self.url) {
        self.url = nil;
    }
    if (self.fileID) {
        self.fileID = nil;
    }
    if (self.content_length) {
        self.content_length = nil;
    }
    if (self.everySize) {
        self.everySize = nil;
    }
    if (self.strSize) {
        self.strSize = nil;
    }
    if (self.strReceivedSize) {
        self.strReceivedSize = nil;
    }
    if (self.strReceivedRate) {
        self.strReceivedRate = nil;
    }
    if (self.totalSize) {
        self.totalSize = nil;
    }
    if (self.totalFloatSize) {
        self.totalFloatSize = nil;
    }
    if (self.loadingStr) {
        self.loadingStr = nil;
    }
    if (self.progesss) {
        self.progesss = nil;
    }
    if (self.networkQueue) {
        self.networkQueue = nil;
    }
    [super dealloc];
}
@end
