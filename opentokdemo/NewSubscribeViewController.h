//
//  ViewController.h
//  Hello-World
//
//  Copyright (c) 2013 TokBox, Inc. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface NewSubscribeViewController : UIViewController

@property (strong, nonatomic) NSString *user_id;
@property (strong, nonatomic) NSString *username;
@property BOOL calling;
@property (strong, nonatomic) NSString *session_id;
@property (strong, nonatomic) NSString *session_token;
@property (strong, nonatomic) NSString *duration;
@property BOOL tryitout;
@property BOOL missed_call;

-(void)startCall;
-(void)stopCall;
-(void)NotifiyStopCall;

@end