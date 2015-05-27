//
//  HBMyLoadedTableViewCell.h
//  AppCanPlugin
//
//  Created by hongbao.cui on 15-1-24.
//  Copyright (c) 2015年 zywx. All rights reserved.
//

#import <UIKit/UIKit.h>
@class HBMyLoadedTableViewCell;
typedef void (^HBMyLoadedAccessoryBlock)(HBMyLoadedTableViewCell *accessoryCell);
@interface HBMyLoadedTableViewCell : UITableViewCell
@property(nonatomic,retain)UILabel *titleLabel;
@property(nonatomic,retain)UILabel *fomateLabel;
@property(nonatomic,retain)UIImageView *menueImageView;
@property(nonatomic,copy)HBMyLoadedAccessoryBlock accessoryBlock;
@end
