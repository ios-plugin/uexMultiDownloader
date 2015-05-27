//
//  EUExMultiDownloader.h
//  AppCanPlugin
//
//  Created by hongbao.cui on 15-1-11.
//  Copyright (c) 2015年 zywx. All rights reserved.
//

#import "EUExBase.h"

@interface EUExMultiDownloader : EUExBase<UITableViewDataSource,UITableViewDelegate>{
    
}
@property(nonatomic,retain)UITableView *hbTableView;
@property(nonatomic,retain)NSMutableArray *dataList;
@end
