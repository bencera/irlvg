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
#import "UIImage+animatedGIF.h"

@interface SlidesViewController () <UIScrollViewDelegate>

@end

@implementation SlidesViewController

- (void)viewDidLoad{
    [super viewDidLoad];
    
    self.view.backgroundColor = [UIColor colorWithRed:249/255.f green:139/255.f blue:61/255.f alpha:1.f];
    
    self.edgesForExtendedLayout = UIRectEdgeNone;
    
    UIScrollView *scrollView = [[UIScrollView alloc]initWithFrame:self.view.bounds];
    scrollView.contentSize = CGSizeMake(self.view.bounds.size.width*4, 1);
    scrollView.pagingEnabled = YES;
    scrollView.bounces = NO;
    scrollView.delegate = self;
    [self.view addSubview:scrollView];
    
    UIImageView *slide1 = [[UIImageView alloc]init];
    slide1.frame = CGRectMake(0, 0, self.view.bounds.size.width, self.view.bounds.size.height);
    [scrollView addSubview:slide1];
    
    UIImageView *slide2 = [[UIImageView alloc]init];
    slide2.frame = CGRectMake(self.view.bounds.size.width, 0, self.view.bounds.size.width, self.view.bounds.size.height);
    [scrollView addSubview:slide2];

    UIImageView *slide3 = [[UIImageView alloc]init];
    slide3.frame = CGRectMake(self.view.bounds.size.width*2, 0, self.view.bounds.size.width, self.view.bounds.size.height);
    [scrollView addSubview:slide3];
    
    UIImageView *gif3 = [[UIImageView alloc]init];
    [scrollView addSubview:gif3];
    
    NSLog(@"%f %f", self.view.bounds.size.width, self.view.bounds.size.height);
    
    if (self.view.bounds.size.width == 414.f && self.view.bounds.size.height == 736.f) {
        slide1.image = [UIImage imageNamed:@"1-iphone6plus"];
        slide2.image = [UIImage imageNamed:@"2-iphone6plus"];
        slide3.image = [UIImage imageNamed:@"3-iphone6plus"];
        gif3.frame = CGRectMake(self.view.bounds.size.width*2.2, self.view.bounds.size.height*0.435, self.view.bounds.size.width*0.6, self.view.bounds.size.height*0.565);
        NSURL *url = [[NSBundle mainBundle] URLForResource:@"quickie" withExtension:@"gif"];
        gif3.image = [UIImage animatedImageWithAnimatedGIFData:[NSData dataWithContentsOfURL:url]];
    } else if (self.view.bounds.size.width == 375.f && self.view.bounds.size.height == 667.f) {
        NSLog(@"here");
        slide1.image = [UIImage imageNamed:@"1-iphone6"];
        slide2.image = [UIImage imageNamed:@"2-iphone6"];
        slide3.image = [UIImage imageNamed:@"3-iphone6"];
        gif3.frame = CGRectMake(self.view.bounds.size.width*2.2, self.view.bounds.size.height*0.405, self.view.bounds.size.width*0.6, self.view.bounds.size.height*0.595);
        NSURL *url = [[NSBundle mainBundle] URLForResource:@"quickie" withExtension:@"gif"];
        gif3.image = [UIImage animatedImageWithAnimatedGIFData:[NSData dataWithContentsOfURL:url]];
    } else if (self.view.bounds.size.width == 320.f && self.view.bounds.size.height == 568.f){
        slide1.image = [UIImage imageNamed:@"1-iphone5"];
        slide2.image = [UIImage imageNamed:@"2-iphone5"];
        slide3.image = [UIImage imageNamed:@"3-iphone5"];
        gif3.frame = CGRectMake(self.view.bounds.size.width*2.15, self.view.bounds.size.height*0.35, self.view.bounds.size.width*0.7, self.view.bounds.size.height*0.65);
        NSURL *url = [[NSBundle mainBundle] URLForResource:@"quickie" withExtension:@"gif"];
        gif3.image = [UIImage animatedImageWithAnimatedGIFData:[NSData dataWithContentsOfURL:url]];
    } else {
        slide1.image = [UIImage imageNamed:@"1-iphone4"];
        slide2.image = [UIImage imageNamed:@"2-iphone4"];
        slide3.image = [UIImage imageNamed:@"3-iphone4"];
        gif3.frame = CGRectMake(self.view.bounds.size.width*2.15, self.view.bounds.size.height*0.25, self.view.bounds.size.width*0.7, self.view.bounds.size.height*0.75);
        NSURL *url = [[NSBundle mainBundle] URLForResource:@"quickie" withExtension:@"gif"];
        gif3.image = [UIImage animatedImageWithAnimatedGIFData:[NSData dataWithContentsOfURL:url]];
    }
    
    UIView *view = [[UIView alloc]initWithFrame:CGRectMake(self.view.bounds.size.width*3, 0, self.view.bounds.size.width, self.view.bounds.size.height)];
    view.backgroundColor = [UIColor colorWithRed:249/255.f green:139/255.f blue:61/255.f alpha:1.f];//[UIColor colorWithRed:0.5 green:0.4 blue:0.2 alpha:1];
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
