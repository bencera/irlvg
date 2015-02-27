//
//  ViewController.h
//  Hello-World
//
//  Copyright (c) 2013 TokBox, Inc. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CommentsViewController.h"
#import "ControlsViewController.h"

@interface NewSubscribeViewController : UIViewController

@property (strong, nonatomic) CommentsViewController *commentsVC;
@property (strong, nonatomic) ControlsViewController *controlsVC;


@end
