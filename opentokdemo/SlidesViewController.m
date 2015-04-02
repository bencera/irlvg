//
//  SlidesViewController.m
//  opentokdemo
//
//  Created by Ben Cera on 2/25/15.
//  Copyright (c) 2015 Context Labs Inc. All rights reserved.
//

#import "SlidesViewController.h"
#import "AppDelegate.h"
#import "NameViewController.h"

@interface SlidesViewController () <UIScrollViewDelegate>

@end

@implementation SlidesViewController

- (void)viewDidLoad{
    [super viewDidLoad];
    
    self.edgesForExtendedLayout = UIRectEdgeNone;
    
    UIScrollView *scrollView = [[UIScrollView alloc]initWithFrame:self.view.bounds];
    scrollView.contentSize = CGSizeMake(self.view.bounds.size.width*4, 1);
    scrollView.pagingEnabled = YES;
    scrollView.bounces = NO;
    scrollView.delegate = self;
    [self.view addSubview:scrollView];
    
    UIImageView *slide1 = [[UIImageView alloc]initWithImage:[UIImage imageNamed:@"HELP1"]];
    slide1.frame = CGRectMake(0, 0, self.view.bounds.size.width, self.view.bounds.size.height);
    [scrollView addSubview:slide1];
    
    UIImageView *slide2 = [[UIImageView alloc]initWithImage:[UIImage imageNamed:@"HELP2"]];
    slide2.frame = CGRectMake(self.view.bounds.size.width, 0, self.view.bounds.size.width, self.view.bounds.size.height);
    [scrollView addSubview:slide2];

    UIImageView *slide3 = [[UIImageView alloc]initWithImage:[UIImage imageNamed:@"HELP3"]];
    slide3.frame = CGRectMake(self.view.bounds.size.width*2, 0, self.view.bounds.size.width, self.view.bounds.size.height);
    [scrollView addSubview:slide3];
    
    UIView *view = [[UIView alloc]initWithFrame:CGRectMake(self.view.bounds.size.width*3, 0, self.view.bounds.size.width, self.view.bounds.size.height)];
    view.backgroundColor = [UIColor colorWithRed:0.5 green:0.4 blue:0.2 alpha:1];
    [scrollView addSubview:view];
    
}

-(void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView{
    if (scrollView.contentOffset.x == self.view.bounds.size.width*3){
        [[(AppDelegate*)[[UIApplication sharedApplication]delegate] choiceVC] downloadFriendListWithAnimation:YES];
        [[(AppDelegate*)[[UIApplication sharedApplication]delegate] choiceVC] setupPushNotifications];
        [self dismissViewControllerAnimated:YES completion:nil];
    }
}

@end
