//
//  NameViewController.m
//  opentokdemo
//
//  Created by Ben Cera on 2/25/15.
//  Copyright (c) 2015 Context Labs Inc. All rights reserved.
//

#import "NameViewController.h"
#import "SlidesViewController.h"

@interface NameViewController () <UITextFieldDelegate>

@property (nonatomic) UITextField *nameField;

@end

@implementation NameViewController

-(void)viewDidLoad{
    [super viewDidLoad];
    
    self.automaticallyAdjustsScrollViewInsets = NO;
    
    self.view.backgroundColor = [UIColor whiteColor];
    
    _nameField = [[UITextField alloc]init];
    _nameField.frame = CGRectMake(20.f, 100.f, self.view.bounds.size.width - 40.f, 30.f);
    _nameField.placeholder = @"Pick a username";
    _nameField.textAlignment = NSTextAlignmentCenter;
   // _nameField.backgroundColor = [UIColor grayColor];
    [self.view addSubview:_nameField];
    
    UIButton *okButton = [UIButton buttonWithType:UIButtonTypeCustom];
    okButton.frame = CGRectMake(40, 140, (self.view.bounds.size.width - 80), 60);
    okButton.backgroundColor = [UIColor colorWithRed:255/255.f green:204/255.f blue:0 alpha:1.f];
    [okButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [okButton setTitle:@"ENTER >" forState:UIControlStateNormal];
    [okButton addTarget:self action:@selector(enter) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:okButton];
    
    [_nameField becomeFirstResponder];
    
}
//-(BOOL)textFieldShouldReturn:(UITextField *)textField{
//    [self enter];
//    
//    return YES;
//}

-(void)enter{
    [[NSUserDefaults standardUserDefaults] setValue:_nameField.text forKey:@"username"];
    
    SlidesViewController *slidesVC = [[SlidesViewController alloc]init];
    [self.navigationController pushViewController:slidesVC animated:YES];
    //[self dismissViewControllerAnimated:YES completion:nil];
}

@end
