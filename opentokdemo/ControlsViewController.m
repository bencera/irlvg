//
//  ControlsViewController.m
//  opentokdemo
//
//  Created by Ben Cera on 2/20/15.
//  Copyright (c) 2015 Context Labs Inc. All rights reserved.
//

#import "ControlsViewController.h"

@interface ControlsViewController ()

@property (nonatomic) UIButton *forwardB;
@property (nonatomic) UIButton *backwardB;
@property (nonatomic) UIButton *leftB;
@property (nonatomic) UIButton *rightB;
@property (nonatomic) UIButton *action1B;
@property (nonatomic) UIButton *action2B;

@end

@implementation ControlsViewController

@synthesize subVC;

@synthesize client;

-(void)viewDidLoad{
    [super viewDidLoad];
    
    UILabel *nameLabel = [[UILabel alloc]init];
    nameLabel.frame = CGRectMake(0, 20, self.view.bounds.size.width, 50.f);
    nameLabel.text = @"IRL";
    nameLabel.textAlignment = NSTextAlignmentCenter;
    [self.view addSubview:nameLabel];
    
    [self addButtons];

    UIButton *settingsButton = [[UIButton alloc]init];
    settingsButton.frame = CGRectMake(5, 25, 50, 50);
    [settingsButton setImage:[UIImage imageNamed:@"list"] forState:UIControlStateNormal];
    [settingsButton addTarget:self action:@selector(back) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:settingsButton];
    
    UIButton *commentsButton = [[UIButton alloc]init];
    commentsButton.frame = CGRectMake(self.view.bounds.size.width - 5 - 50, 25, 50, 50);
    [commentsButton setImage:[UIImage imageNamed:@"commentB"] forState:UIControlStateNormal];
    [commentsButton addTarget:self action:@selector(goToComments) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:commentsButton];
}

-(void)back{
    [self.subVC back];
}

-(void)goToComments{
    [self.subVC goToComments];
}

-(void)addButtons{
    _forwardB = [UIButton buttonWithType:UIButtonTypeCustom];
    _forwardB.frame = CGRectMake(65, self.view.bounds.size.height - 145, 40, 40);
    [_forwardB setBackgroundImage:[UIImage imageNamed:@"forward"] forState:UIControlStateNormal];
    [_forwardB setBackgroundImage:[UIImage imageNamed:@"red_frame"] forState:UIControlStateSelected];
    [_forwardB addTarget:self action:@selector(forwardAction:) forControlEvents:UIControlEventTouchUpInside];
    _forwardB.layer.zPosition = 99;
    [self.view addSubview:_forwardB];
    
    _backwardB = [UIButton buttonWithType:UIButtonTypeCustom];
    _backwardB.frame = CGRectMake(65, self.view.bounds.size.height - 65, 40, 40);
    [_backwardB setBackgroundImage:[UIImage imageNamed:@"back"] forState:UIControlStateNormal];
    [_backwardB setBackgroundImage:[UIImage imageNamed:@"red_frame"] forState:UIControlStateSelected];
    [_backwardB addTarget:self action:@selector(backwardAction:) forControlEvents:UIControlEventTouchUpInside];
    _backwardB.layer.zPosition = 99;
    [self.view addSubview:_backwardB];
    
    _leftB = [UIButton buttonWithType:UIButtonTypeCustom];
    _leftB.frame = CGRectMake(25, self.view.bounds.size.height - 105, 40, 40);
    [_leftB setBackgroundImage:[UIImage imageNamed:@"left"] forState:UIControlStateNormal];
    [_leftB setBackgroundImage:[UIImage imageNamed:@"vertical_red"] forState:UIControlStateSelected];
    [_leftB addTarget:self action:@selector(leftAction:) forControlEvents:UIControlEventTouchUpInside];
    _leftB.layer.zPosition = 99;
    [self.view addSubview:_leftB];
    
    _rightB = [UIButton buttonWithType:UIButtonTypeCustom];
    _rightB.frame = CGRectMake(105, self.view.bounds.size.height - 105, 40, 40);
    [_rightB setBackgroundImage:[UIImage imageNamed:@"right"] forState:UIControlStateNormal];
    [_rightB setBackgroundImage:[UIImage imageNamed:@"vertical_red"] forState:UIControlStateSelected];
    [_rightB addTarget:self action:@selector(rightAction:) forControlEvents:UIControlEventTouchUpInside];
    _rightB.layer.zPosition = 99;
    [self.view addSubview:_rightB];
    
    UIButton *centerB = [UIButton buttonWithType:UIButtonTypeCustom];
    centerB.frame = CGRectMake(65, self.view.bounds.size.height - 105, 40, 40);
    [centerB setBackgroundImage:[UIImage imageNamed:@"middle"] forState:UIControlStateNormal];
    centerB.layer.zPosition = 99;
    [self.view addSubview:centerB];
    
    _action1B = [UIButton buttonWithType:UIButtonTypeCustom];
    _action1B.frame = CGRectMake(self.view.bounds.size.width - 150, self.view.bounds.size.height - 110, 50, 50);
    [_action1B setBackgroundImage:[UIImage imageNamed:@"button"] forState:UIControlStateNormal];
    [_action1B setBackgroundImage:[UIImage imageNamed:@"vertical_red"] forState:UIControlStateSelected];
    [_action1B addTarget:self action:@selector(action1Action:) forControlEvents:UIControlEventTouchUpInside];
    _action1B.layer.zPosition = 99;
    [self.view addSubview:_action1B];
    
    _action2B = [UIButton buttonWithType:UIButtonTypeCustom];
    _action2B.frame = CGRectMake(self.view.bounds.size.width - 75, self.view.bounds.size.height - 110, 50, 50);
    [_action2B setBackgroundImage:[UIImage imageNamed:@"button"] forState:UIControlStateNormal];
    [_action2B setBackgroundImage:[UIImage imageNamed:@"vertical_red"] forState:UIControlStateSelected];
    [_action2B addTarget:self action:@selector(action2Action:) forControlEvents:UIControlEventTouchUpInside];
    _action2B.layer.zPosition = 99;
    [self.view addSubview:_action2B];
    
}


-(void)forwardAction:(UIButton*)button{
    button.selected = YES;
    _leftB.selected = NO;
    _rightB.selected = NO;
    _backwardB.selected = NO;
    _action1B.selected = NO;
    _action2B.selected = NO;
    [self.client sendMessage:@{@"action" : @"forward"} onChannel:@"/test"];
}

-(void)leftAction:(UIButton*)button{
    button.selected = YES;
    _forwardB.selected = NO;
    _rightB.selected = NO;
    _backwardB.selected = NO;
    _action1B.selected = NO;
    _action2B.selected = NO;
    [self.client sendMessage:@{@"action" : @"left"} onChannel:@"/test"];
}

-(void)rightAction:(UIButton*)button{
    button.selected = YES;
    _forwardB.selected = NO;
    _leftB.selected = NO;
    _backwardB.selected = NO;
    _action1B.selected = NO;
    _action2B.selected = NO;
    [self.client sendMessage:@{@"action" : @"right"} onChannel:@"/test"];
}

-(void)backwardAction:(UIButton*)button{
    button.selected = YES;
    _forwardB.selected = NO;
    _rightB.selected = NO;
    _leftB.selected = NO;
    _action1B.selected = NO;
    _action2B.selected = NO;
    [self.client sendMessage:@{@"action" : @"backward"} onChannel:@"/test"];
}

-(void)action1Action:(UIButton*)button{
    button.selected = YES;
    _forwardB.selected = NO;
    _rightB.selected = NO;
    _leftB.selected = NO;
    _backwardB.selected = NO;
    _action2B.selected = NO;
    [self.client sendMessage:@{@"action" : @"action1"} onChannel:@"/test"];
}

-(void)action2Action:(UIButton*)button{
    button.selected = YES;
    _forwardB.selected = NO;
    _leftB.selected = NO;
    _rightB.selected = NO;
    _backwardB.selected = NO;
    _action1B.selected = NO;
    [self.client sendMessage:@{@"action" : @"action2"} onChannel:@"/test"];
}



@end
