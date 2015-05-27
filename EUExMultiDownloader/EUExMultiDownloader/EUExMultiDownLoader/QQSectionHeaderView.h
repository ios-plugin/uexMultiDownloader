//
//  QQSectionHeaderView.h
//  TQQTableView
//
//  Created by Futao on 11-6-22.
//  Copyright 2011 ftkey.com. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol QQSectionHeaderViewDelegate;

@interface QQSectionHeaderView : UIView<UIGestureRecognizerDelegate> {
    
}

@property (nonatomic, retain) UILabel *titleLabel; //分组名称
@property (nonatomic, retain) UIButton *disclosureButton;//展开、收起标识
@property (nonatomic, assign) NSInteger section;//组索引
@property (nonatomic, assign) BOOL opened;//是否展开
@property (nonatomic, assign) id <QQSectionHeaderViewDelegate> delegate;

-(id)initWithFrame:(CGRect)frame title:(NSString*)title section:(NSInteger)sectionNumber opened:(BOOL)isOpened delegate:(id<QQSectionHeaderViewDelegate>)delegate;

//如果section之前已经建立 则更新视图即可
-(void)update_QQSectionHeaderView:(BOOL)isOpened;
-(void)toggleAction:(id)sender;
@end

//控制展开和收起动画
@protocol QQSectionHeaderViewDelegate <NSObject> 
@optional
-(void)sectionHeaderView:(QQSectionHeaderView*)sectionHeaderView sectionClosed:(NSInteger)section;
-(void)sectionHeaderView:(QQSectionHeaderView*)sectionHeaderView sectionOpened:(NSInteger)section;
-(void)sectionHeaderView:(QQSectionHeaderView*)sectionHeaderView sectionEdit:(NSInteger)section;

@end
