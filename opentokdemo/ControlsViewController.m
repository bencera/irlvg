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
@property (nonatomic) UIView *controllerBG;
@property (nonatomic) CGFloat border;

@end

@implementation ControlsViewController

@synthesize client;

-(void)viewDidLoad{
    [super viewDidLoad];
    
//    UILabel *nameLabel = [[UILabel alloc]init];
//    nameLabel.frame = CGRectMake(0, 20, self.view.bounds.size.width, 50.f);
//    nameLabel.text = @"IRL";
//    nameLabel.textAlignment = NSTextAlignmentCenter;
//    [self.view addSubview:nameLabel];
    
    
    CGFloat deviceWidth = self.view.bounds.size.width;
    _border = 20.f;
    if (deviceWidth > 320.f) {
        _border = 35.f;
    }
    
    _controllerBG = [[UIView alloc]init];
    _controllerBG.frame = CGRectMake(0, self.view.bounds.size.height - 200.f, self.view.bounds.size.width, self.view.bounds.size.height);
    _controllerBG.backgroundColor = [UIColor colorWithRed:232/255.f green:240.f/255.f blue:246/255.f alpha:0.9f];
    [self.view addSubview:_controllerBG];
    
    UIImageView *trackpad = [[UIImageView alloc]init];
    trackpad.frame = CGRectMake(_border, 35.f, 130.f, 130.f);
    trackpad.image = [UIImage imageNamed:@"trackpad"];
    [_controllerBG addSubview:trackpad];
    
    UIImageView *buttons = [[UIImageView alloc]init];
    buttons.frame = CGRectMake(self.view.bounds.size.width - 110.f - _border, 40.f, 110.f, 120.f);
    buttons.image = [UIImage imageNamed:@"twobuttons_unpressed"];
    [_controllerBG addSubview:buttons];
    
    [self addButtons];
    
    UIButton *questionButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [questionButton setImage:[UIImage imageNamed:@"question"] forState:UIControlStateNormal];
    [questionButton addTarget:self action:@selector(questionButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
    questionButton.frame = CGRectMake(buttons.frame.origin.x + buttons.frame.size.width - 10, buttons.frame.origin.y + buttons.frame.size.height-10, 30, 30);
    [self.controllerBG addSubview:questionButton];
    
//    UIButton *settingsButton = [[UIButton alloc]init];
//    settingsButton.frame = CGRectMake(5, 25, 50, 50);
//    [settingsButton setImage:[UIImage imageNamed:@"buttonpressed"] forState:UIControlStateNormal];
//    //[settingsButton addTarget:self action:@selector(back) forControlEvents:UIControlEventTouchUpInside];
//    [self.view addSubview:settingsButton];
    
    UIButton *commentsButton = [[UIButton alloc]init];
    commentsButton.frame = CGRectMake(self.view.bounds.size.width - 5 - 50, 25, 50, 50);
    [commentsButton setImage:[UIImage imageNamed:@"buttonpressed"] forState:UIControlStateNormal];
    [commentsButton addTarget:self action:@selector(goToComments) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:commentsButton];
}

- (void)questionButtonPressed:(UIButton *)sender {
    [self.delegate questionButtonPressedFromControlsController:self];
}

-(void)back{
   // [self.subVC back];
}

-(void)goToComments{
    [self.delegate backButtonPressedFromControlsController:self];
}

-(void)addButtons{
    _forwardB = [UIButton buttonWithType:UIButtonTypeCustom];
    _forwardB.frame = CGRectMake(_border + 54, 50, 22, 40);
    [_forwardB setBackgroundImage:nil forState:UIControlStateNormal];
    [_forwardB setBackgroundImage:[UIImage imageNamed:@"down-updown"] forState:UIControlStateSelected];
    [_forwardB addTarget:self action:@selector(forwardAction) forControlEvents:UIControlEventTouchUpInside];
    _forwardB.layer.zPosition = 99;
    [_controllerBG addSubview:_forwardB];
    
    _backwardB = [UIButton buttonWithType:UIButtonTypeCustom];
    _backwardB.frame = CGRectMake(_border + 54, 110, 22, 40);
    [_backwardB setBackgroundImage:nil forState:UIControlStateNormal];
    [_backwardB setBackgroundImage:[UIImage imageNamed:@"down-updown"] forState:UIControlStateSelected];
    [_backwardB addTarget:self action:@selector(backwardAction) forControlEvents:UIControlEventTouchUpInside];
    _backwardB.layer.zPosition = 99;
    [_controllerBG addSubview:_backwardB];
    
    _leftB = [UIButton buttonWithType:UIButtonTypeCustom];
    _leftB.frame = CGRectMake(_border + 15, 89, 40, 22);
    [_leftB setBackgroundImage:nil forState:UIControlStateNormal];
    [_leftB setBackgroundImage:[UIImage imageNamed:@"down-leftright"] forState:UIControlStateSelected];
    [_leftB addTarget:self action:@selector(leftAction) forControlEvents:UIControlEventTouchUpInside];
    _leftB.layer.zPosition = 99;
    [_controllerBG addSubview:_leftB];
    
    _rightB = [UIButton buttonWithType:UIButtonTypeCustom];
    _rightB.frame = CGRectMake(_border + 75, 89, 40, 22);
    [_rightB setBackgroundImage:nil forState:UIControlStateNormal];
    [_rightB setBackgroundImage:[UIImage imageNamed:@"down-leftright"] forState:UIControlStateSelected];
    [_rightB addTarget:self action:@selector(rightAction) forControlEvents:UIControlEventTouchUpInside];
    _rightB.layer.zPosition = 99;
    [_controllerBG addSubview:_rightB];
    
    _action1B = [UIButton buttonWithType:UIButtonTypeCustom];
    _action1B.frame = CGRectMake(self.view.bounds.size.width - 100 - _border, 100.f, 50, 50);
    [_action1B setBackgroundImage:nil forState:UIControlStateNormal];
    [_action1B setBackgroundImage:[UIImage imageNamed:@"buttonpressed"] forState:UIControlStateSelected];
    [_action1B addTarget:self action:@selector(action1Action) forControlEvents:UIControlEventTouchUpInside];
    _action1B.layer.zPosition = 99;
    [_controllerBG addSubview:_action1B];
    
    _action2B = [UIButton buttonWithType:UIButtonTypeCustom];
    _action2B.frame = CGRectMake(self.view.bounds.size.width - 60 - _border, 50, 50, 50);
    [_action2B setBackgroundImage:nil forState:UIControlStateNormal];
    [_action2B setBackgroundImage:[UIImage imageNamed:@"buttonpressed"] forState:UIControlStateSelected];
    [_action2B addTarget:self action:@selector(action2Action) forControlEvents:UIControlEventTouchUpInside];
    _action2B.layer.zPosition = 99;
    [_controllerBG addSubview:_action2B];
    
}

-(void)unselectAllButtonsExcept:(UIButton*)button{
    _forwardB.selected = NO;
    _leftB.selected = NO;
    _rightB.selected = NO;
    _backwardB.selected = NO;
    _action1B.selected = NO;
    _action2B.selected = NO;
    button.selected = YES;
}

-(void)forwardAction{
    [self unselectAllButtonsExcept:_forwardB];
    [self.client sendMessage:@{@"action" : @"forward"} onChannel:@"/test"];
}

-(void)leftAction{
    [self unselectAllButtonsExcept:_leftB];
    [self.client sendMessage:@{@"action" : @"left"} onChannel:@"/test"];
}

-(void)rightAction{
    [self unselectAllButtonsExcept:_rightB];
    [self.client sendMessage:@{@"action" : @"right"} onChannel:@"/test"];
}

-(void)backwardAction{
    [self unselectAllButtonsExcept:_backwardB];
    [self.client sendMessage:@{@"action" : @"backward"} onChannel:@"/test"];
}

-(void)action1Action{
    [self unselectAllButtonsExcept:_action1B];
    [self.client sendMessage:@{@"action" : @"action1"} onChannel:@"/test"];
}

-(void)action2Action{
    [self unselectAllButtonsExcept:_action2B];
    [self.client sendMessage:@{@"action" : @"action2"} onChannel:@"/test"];
}


- (void)pushAction:(NSDictionary*)action{
    if ([action[@"action"] isEqualToString:@"forward"]) {
        [self unselectAllButtonsExcept:_forwardB];
    } else if ([action[@"action"] isEqualToString:@"backward"]){
        [self unselectAllButtonsExcept:_backwardB];
    } else if ([action[@"action"] isEqualToString:@"left"]){
        [self unselectAllButtonsExcept:_leftB];
    } else if ([action[@"action"] isEqualToString:@"right"]){
        [self unselectAllButtonsExcept:_rightB];
    } else if ([action[@"action"] isEqualToString:@"action1"]){
        [self unselectAllButtonsExcept:_action1B];
    } else if ([action[@"action"] isEqualToString:@"action2"]){
        [self unselectAllButtonsExcept:_action2B];
    }
}

@end
