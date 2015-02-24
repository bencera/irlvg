//
//  ControlsViewController.h
//  opentokdemo
//
//  Created by Ben Cera on 2/20/15.
//  Copyright (c) 2015 Context Labs Inc. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "FayeClient.h"
#import "SubscribeViewController.h"

@interface ControlsViewController : UIViewController

@property (strong,nonatomic) FayeClient *client;

@property (strong,nonatomic) SubscribeViewController *subVC;

@end
