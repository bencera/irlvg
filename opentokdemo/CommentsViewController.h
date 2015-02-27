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
@class TJWComment;
@class TJWUser;

@protocol CommentsViewControllerDelegate <NSObject>

- (void)commentsController:(CommentsViewController *)controller didFinishTypingComment:(TJWComment *)comment;
- (void)backButtonPressedFromCommentsController:(CommentsViewController *)controller;

@end

@interface CommentsViewController : UIViewController

@property (strong, nonatomic) TJWUser *currentUser;
@property (weak, nonatomic) id<CommentsViewControllerDelegate> delegate;
- (void)pushComment:(TJWComment *)comment;
- (void)resignKeyboard;
- (void)downloadComments;

@end
