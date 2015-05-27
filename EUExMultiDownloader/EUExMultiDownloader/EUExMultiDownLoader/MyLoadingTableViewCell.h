//
//  MyLoadingTableViewCell.h
//  AppCanPlugin
//
//  Created by hongbao.cui on 15-1-12.
//  Copyright (c) 2015年 zywx. All rights reserved.
//

#import <UIKit/UIKit.h>
@class ASINetworkQueue;
@class MyLoadingTableViewCell;
@class HBProgressView;
typedef void (^MyLoadingTableCompletionBlock)(MyLoadingTableViewCell *completedCell);
typedef void (^MyLoadingTableFailBlock)(MyLoadingTableViewCell *queueCell);
typedef void (^MyLoadingTableOnQueueBlock)(MyLoadingTableViewCell *queueCell);
typedef void (^MyLoadingAccessoryBlock)(MyLoadingTableViewCell *accessoryCell);
@interface MyLoadingTableViewCell : UITableViewCell{
    BOOL failed;
}
@property(nonatomic,retain)UILabel *titleLabel;
@property(nonatomic,retain)UIImageView *menueImageView;
@property(nonatomic,retain)HBProgressView *hbProgressView;
@property(nonatomic,retain)ASINetworkQueue * networkQueue;
@property(nonatomic,copy)MyLoadingTableCompletionBlock completedBlock;
@property(nonatomic,copy)MyLoadingTableFailBlock failBlock;
@property(nonatomic,copy)MyLoadingTableOnQueueBlock onQueueBlock;
@property(nonatomic,copy)MyLoadingAccessoryBlock accessoryBlock;
@property(nonatomic,copy)NSString * fileID;
@property(nonatomic,copy)NSString *content_length;
@property(nonatomic)NSInteger status;
-(void)setModelReloadData:(NSDictionary *)dataDict;
@end
