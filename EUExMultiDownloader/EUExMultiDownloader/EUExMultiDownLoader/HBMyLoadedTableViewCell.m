//
//  HBMyLoadedTableViewCell.m
//  AppCanPlugin
//
//  Created by hongbao.cui on 15-1-24.
//  Copyright (c) 2015年 zywx. All rights reserved.
//

#import "HBMyLoadedTableViewCell.h"

@implementation HBMyLoadedTableViewCell
@synthesize accessoryBlock;
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
        UIImageView *iconImageView = [[UIImageView alloc] initWithFrame:CGRectMake(25.0, (45.0-23.5)/2, 46.5/2, 46.5/2)];
        [iconImageView setImage:[UIImage imageNamed:@"uexMultiDownloader/uexMultiDownLoader_icon.png"]];
        [self addSubview:iconImageView];
        [iconImageView release];
        
        _titleLabel  = [[UILabel alloc] initWithFrame:CGRectMake(66.5, 5.0, 200.0, 15.0)];
        [_titleLabel setText:@"hiappcan.apk"];
        [_titleLabel setFont:[UIFont systemFontOfSize:14.0]];
        [_titleLabel setBackgroundColor:[UIColor clearColor]];
        [self addSubview:_titleLabel];
        
        _fomateLabel  = [[UILabel alloc] initWithFrame:CGRectMake(66.5, 25.0, 200.0, 15.0)];
        [_fomateLabel setText:@"2015-01-24   13.07M"];
        [_fomateLabel setFont:[UIFont systemFontOfSize:12.0]];
        [_fomateLabel setTextColor:[UIColor lightGrayColor]];
        [_fomateLabel setBackgroundColor:[UIColor clearColor]];
        [self addSubview:_fomateLabel];
        
//        _menueImageView = [[UIImageView alloc] initWithFrame:CGRectMake(87.5+100+90, (76.0-31.0)/2, 31.0, 31.0)];
//        [_menueImageView setImage:[UIImage imageNamed:@"uexMultiDownloader/uexMultiDownLoader_downBtn.png"]];
//        [self addSubview:_menueImageView];
        UIButton *accessoryBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        [accessoryBtn setFrame:CGRectMake(0, 0, 31.0, 31.0)];
        [accessoryBtn setBackgroundImage:[UIImage imageNamed:@"uexMultiDownloader/uexMultiDownLoader_downBtn.png"] forState:UIControlStateNormal];
        [accessoryBtn setBackgroundImage:[UIImage imageNamed:@"uexMultiDownloader/uexMultiDownLoader_downBtn.png"] forState:UIControlStateHighlighted];
        [accessoryBtn addTarget:self action:@selector(accessoryBtnClicked:) forControlEvents:UIControlEventTouchUpInside];
        self.accessoryView = accessoryBtn;
    }
    return self;
}
-(void)dealloc{
    if (_titleLabel) {
        [_titleLabel release];
        _titleLabel = nil;
    }
    if (_fomateLabel) {
        [_fomateLabel release];
        _fomateLabel = nil;
    }
    if (_menueImageView) {
        [_menueImageView release];
        _menueImageView = nil;
    }
    if (self.accessoryBlock) {
        self.accessoryBlock = nil;
    }
    [super dealloc];
}
@end
