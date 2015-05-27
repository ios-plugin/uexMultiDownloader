//
//  QQSectionHeaderView.m
//  TQQTableView
//
//  Created by Futao on 11-6-22.
//  Copyright 2011 ftkey.com. All rights reserved.
//

#import "QQSectionHeaderView.h"
#import <QuartzCore/QuartzCore.h>
#import "EUtility.h"
@implementation QQSectionHeaderView
@synthesize titleLabel, disclosureButton, delegate, section, opened;

-(id)initWithFrame:(CGRect)frame title:(NSString*)title section:(NSInteger)sectionNumber opened:(BOOL)isOpened delegate:(id)aDelegate{
    if (self = [super initWithFrame:frame]) {
		self.backgroundColor = [UIColor clearColor];
		self.userInteractionEnabled = YES;
        [self setAutoresizesSubviews:YES];
        [self setAutoresizingMask:UIViewAutoresizingFlexibleLeftMargin|UIViewAutoresizingFlexibleRightMargin|UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleHeight|UIViewAutoresizingFlexibleBottomMargin|UIViewAutoresizingFlexibleTopMargin];
		section = sectionNumber;
		delegate = aDelegate;
		opened = isOpened;
        
		//背景
		float x, y, width, height;
		x=0; y=0; width=frame.size.width; height=frame.size.height;
//        width = 480;
		UIView* bgView=[[UIView alloc] initWithFrame:CGRectMake(x, y, width, height)];
		[bgView setBackgroundColor:[UIColor clearColor]];
		//背景图片
        UIImageView* bgImgView=[[UIImageView alloc] initWithFrame:CGRectMake(0, 0, width, height)];
//		[bgImgView setImage:[[UIImage imageNamed:@"uexMultiDownloader/FolderBgImage.png"] resizableImageWithCapInsets:UIEdgeInsetsMake(5, 10, 10, 5)]];
        [bgImgView setBackgroundColor:[EUtility ColorFromString:@"#f4f4f4"]];
		[bgView addSubview:bgImgView];
		[bgImgView release];
        
//        UIImageView *bookImageView = [[UIImageView alloc] initWithFrame:CGRectMake(10, (height-30)/2, 30, 30)];
//        [bookImageView setImage:[UIImage imageNamed:@"icon06.png"]];
//        [bgImgView addSubview:bookImageView];
//        [bookImageView release];
        
        //名称
		x=31; width=width;
		UILabel* aLabel = [[UILabel alloc] initWithFrame:CGRectMake(x, y, width, height)];
		self.titleLabel=aLabel;
		[aLabel release];
		[self.titleLabel setBaselineAdjustment:UIBaselineAdjustmentAlignCenters];
		[self.titleLabel setTextAlignment:UITextAlignmentLeft];
		self.titleLabel.backgroundColor = [UIColor clearColor];
		self.titleLabel.font = [UIFont systemFontOfSize:20.0];
        self.titleLabel.textColor = [EUtility ColorFromString:@"#9b9b9b"];
        self.titleLabel.text = title;
        [bgView addSubview:self.titleLabel];
        
		//展开和收起的标识
        width=15; height=17; x=frame.size.width-25;
        y=(frame.size.height-height)/2;
        UIButton* tempBtn= [[UIButton alloc] initWithFrame:CGRectMake(x, y, width, height)];
        self.disclosureButton=tempBtn;
		[tempBtn release];
		[self.disclosureButton setBackgroundColor:[UIColor clearColor]];
		[self.disclosureButton setImage:[UIImage imageNamed:@"uexMultiDownloader/uexMultiDownLoader_up.png"] forState:UIControlStateNormal];
		[self.disclosureButton setImage:[UIImage imageNamed:@"uexMultiDownloader/uexMultiDownLoader_down.png"]forState:UIControlStateSelected];
		[self.disclosureButton setUserInteractionEnabled:NO];
		[self.disclosureButton setSelected:opened];
        [bgView addSubview:self.disclosureButton];
        
		[self addSubview:bgView];
		[bgView release];
		        
		//添加点击事件
//        UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(toggleAction:)];
//		[tapGesture setDelegate:self];
//		[self addGestureRecognizer:tapGesture];
//        [tapGesture release];
	}
	return self;
}

-(void)update_QQSectionHeaderView:(BOOL)isOpened{
    opened=isOpened;
    if (self.disclosureButton) {
        [self.disclosureButton setSelected:opened];
    }
}

//点击事件
-(void)toggleAction:(id)sender {
	
	disclosureButton.selected = !disclosureButton.selected;
	if (disclosureButton.selected) {
		if ([delegate respondsToSelector:@selector(sectionHeaderView:sectionOpened:)]) {
			[delegate sectionHeaderView:self sectionOpened:section];
		}
	} else{
		if ([delegate respondsToSelector:@selector(sectionHeaderView:sectionClosed:)]) {
			[delegate sectionHeaderView:self sectionClosed:section];
		}
	}
}

- (void)dealloc {
    if (self.titleLabel) {
        self.titleLabel=nil;
    }
    if (disclosureButton) {
        self.disclosureButton=nil;
    }
    [super dealloc];
}

@end
