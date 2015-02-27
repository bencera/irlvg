//
//  ControlsViewController.h
//  opentokdemo
//
//  Created by Ben Cera on 2/20/15.
//  Copyright (c) 2015 Context Labs Inc. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "FayeClient.h"

@class ControlsViewController;

@protocol ControlsViewControllerDelegate <NSObject>

- (void)backButtonPressedFromControlsController:(ControlsViewController *)controller;
- (void)questionButtonPressedFromControlsController:(ControlsViewController *)controller;

@end


@interface ControlsViewController : UIViewController

@property (strong,nonatomic) FayeClient *client;
@property (weak, nonatomic) id<ControlsViewControllerDelegate> delegate;

//@property (strong,nonatomic) SubscribeViewController *subVC;

- (void)pushAction:(NSString*)action;
- (void)pushComment:(NSString *)comment;
- (void)pushMainAction:(NSString *)action;


@end
