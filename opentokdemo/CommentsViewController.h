//
//  CommentsViewController.h
//  opentokdemo
//
//  Created by Ben Cera on 2/20/15.
//  Copyright (c) 2015 Context Labs Inc. All rights reserved.
//

#import <UIKit/UIKit.h>
//#import "SubscribeViewController.h"
@class CommentsViewController;

@protocol CommentsViewControllerDelegate <NSObject>

- (void)commentsController:(CommentsViewController *)controller didFinishTypingText:(NSString *)text;
- (void)backButtonPressedFromCommeentsController:(CommentsViewController *)controller;

@end

@interface CommentsViewController : UIViewController

//@property (strong,nonatomic) SubscribeViewController *subVC;
@property (weak, nonatomic) id<CommentsViewControllerDelegate> delegate;
- (void)pushMessageText:(NSString *)text;


@end
