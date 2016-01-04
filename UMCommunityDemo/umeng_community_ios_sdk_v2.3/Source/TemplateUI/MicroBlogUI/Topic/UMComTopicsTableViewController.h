//
//  UMComTopicsTableViewController.h
//  UMCommunity
//
//  Created by umeng on 15/7/15.
//  Copyright (c) 2015年 Umeng. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "UMComRequestTableViewController.h"

@class UMComPullRequest;

@interface UMComTopicsTableViewController : UMComRequestTableViewController

@property (nonatomic, copy) void (^completion)(NSArray *data, NSError *error);

@property (nonatomic, assign) BOOL isShowNextButton;


- (void)searchTopicsFromLocalWithKeyWord:(NSString *)keyWord;

- (void)searchTopicsFromServerWithKeyWord:(NSString *)keyWord;

@end
