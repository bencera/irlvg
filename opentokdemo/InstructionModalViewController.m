//
//  InstructionModalViewController.m
//  opentokdemo
//
//  Created by Teddy Wyly on 2/25/15.
//  Copyright (c) 2015 Context Labs Inc. All rights reserved.
//

#import "InstructionModalViewController.h"
#import "TJWOptionView.h"
#import "UIColor+BensFavoriteColors.h"
#define OK_HEIGHT_PROPORTION 0.08f

@interface InstructionModalViewController ()

@property (strong, nonatomic) NSMutableArray *optionViews;
@property (strong, nonatomic) UILabel *cancelLabel;

@end

@implementation InstructionModalViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

- (instancetype)init {
    self = [super init];
    if (self) {
        _panelView = [[UIView alloc] initWithFrame:CGRectZero];
        _panelView.backgroundColor = [UIColor tjw_lightBlue];
        [self.view addSubview:_panelView];
        self.view.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:0.7];
        
        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapGestureRecognized:)];
        [self.view addGestureRecognizer:tap];
        
        NSArray *images = @[[UIImage imageNamed:@"trackpad"], [UIImage imageNamed:@"trackpad"] ,[UIImage imageNamed:@"trackpad"] ,[UIImage imageNamed:@"trackpad"] ,[UIImage imageNamed:@"trackpad"] ,[UIImage imageNamed:@"trackpad"]];
        NSArray *strings = @[@"say hi", @"touch your toes", @"move forward", @"move backward", @"move right", @"move left"];
        _optionViews = [NSMutableArray array];
        for (int i=0; i<[strings count]; i++) {
            TJWOptionView *view = [[TJWOptionView alloc] initWithFrame:CGRectZero image:images[i] text:strings[i]];
            view.label.textColor = [UIColor tjw_darkBlue];
            [_optionViews addObject:view];
            [_panelView addSubview:view];
        }
        
        _cancelLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        _cancelLabel.text = @"Ok";
        _cancelLabel.textColor = [UIColor tjw_lightBlue];
        _cancelLabel.backgroundColor = [UIColor tjw_darkBlue];
        _cancelLabel.textAlignment = NSTextAlignmentCenter;
        [_panelView addSubview:_cancelLabel];

    }
    return self;
}

- (void)tapGestureRecognized:(UITapGestureRecognizer *)sender {
    [self dismissViewControllerAnimated:YES completion:^{
        //
    }];
}

- (void)viewDidLayoutSubviews {
    [super viewDidLayoutSubviews];
    self.panelView.frame = CGRectInset(self.view.bounds, 40, 40);
    
    CGFloat totoalHeight = self.panelView.bounds.size.height * (1-OK_HEIGHT_PROPORTION);
    CGFloat optionHeight = totoalHeight / [self.optionViews count];
    for (int i=0; i<[self.optionViews count]; i++) {
        CGRect frame = CGRectMake(0, optionHeight*i, self.panelView.bounds.size.width, optionHeight);
        TJWOptionView *view = self.optionViews[i];
        view.frame = frame;
    }
    
    self.cancelLabel.frame = CGRectMake(0, totoalHeight, self.panelView.bounds.size.width, self.panelView.bounds.size.height * OK_HEIGHT_PROPORTION);
}

@end
