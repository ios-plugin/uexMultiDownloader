//
//  HBProgressView.h
//  AppCanPlugin
//
//  Created by hongbao.cui on 15-1-22.
//  Copyright (c) 2015年 zywx. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ASIProgressDelegate.h"
@interface HBProgressView : UIView<ASIProgressDelegate>{
}
@property(nonatomic,retain)UIProgressView *progressView;
@property(nonatomic,retain)UIImageView *loadingView;
@property(nonatomic,retain)UILabel *loadedLabel;
@property(nonatomic,retain)UILabel *loadingProgressLabel;
//@property(nonatomic,retain)NSDictionary *headerDict;
//@property(nonatomic,copy)NSString *content_length;
@property(nonatomic,copy)NSString *file_ID;
//@property(nonatomic)BOOL bFirstReceived;
//@property(nonatomic,copy)NSString *strSize;
//@property(nonatomic,copy)NSString *strReceivedSize;
//@property(nonatomic,copy)NSString *strReceivedRate;
@end
