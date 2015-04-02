//
//  FriendListViewController.h
//  opentokdemo
//
//  Created by Ben Cera on 3/18/15.
//  Copyright (c) 2015 Context Labs Inc. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "NewSubscribeViewController.h"

@interface FriendListViewController : UIViewController

-(void)downloadFriendListWithAnimation:(BOOL)animation;
-(void)setupPushNotifications;
-(void)downloadLastRequest;
-(void)showAlertNotAvailable:(NSString *)username;
-(void)notifyOnline;

@end
