//
//  NameViewController.m
//  opentokdemo
//
//  Created by Ben Cera on 2/25/15.
//  Copyright (c) 2015 Context Labs Inc. All rights reserved.
//

#import "NameViewController.h"
#import "SlidesViewController.h"
#import "AFNetworking.h"
#import "PhoneViewController.h"
#import "Mixpanel.h"

#define ACCEPTABLE_CHARECTERS @"ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789_"

@interface NameViewController () <UITextFieldDelegate>

@property (nonatomic) UITextField *nameField;
@property (nonatomic) UIButton *okButton;
@property (nonatomic) UIWebView *webView;

@end

@implementation NameViewController

-(void)viewDidLoad{
    [super viewDidLoad];
    
    self.automaticallyAdjustsScrollViewInsets = NO;
    
    self.view.backgroundColor = [UIColor whiteColor];
    
    _nameField = [[UITextField alloc]init];
    _nameField.frame = CGRectMake(20.f, 100.f, self.view.bounds.size.width - 40.f, 30.f);
    _nameField.placeholder = @"Pick a username";
    _nameField.delegate = self;
    _nameField.font = [UIFont fontWithName:@"DINCond-Regular" size:24.f];
    _nameField.textAlignment = NSTextAlignmentCenter;
    [self.view addSubview:_nameField];
    
    self.okButton = [UIButton buttonWithType:UIButtonTypeCustom];
    self.okButton.frame = CGRectMake(40, 140, (self.view.bounds.size.width - 80), 60);
    self.okButton.backgroundColor = [UIColor colorWithRed:249/255.f green:139/255.f blue:61/255.f alpha:1.f];
    [self.okButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [self.okButton setTitle:@"ENTER >" forState:UIControlStateNormal];
    self.okButton.titleLabel.font = [UIFont fontWithName:@"DINCond-Bold" size:26.f];
    [self.okButton addTarget:self action:@selector(enter) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:self.okButton];
    
    [_nameField becomeFirstResponder];
    
    UILabel *termsLabel = [[UILabel alloc]init];
    termsLabel.frame = CGRectMake(40, self.view.bounds.size.height - 300.f, (self.view.bounds.size.width - 80), 60);
    NSString *textOutStations = @"By signing up you're agreeing to Terms of Use and Privacy Policy.";
    termsLabel.font = [UIFont fontWithName:@"DINCond-Regular" size:12.f];
    [self.view addSubview:termsLabel];
    termsLabel.textAlignment = NSTextAlignmentCenter;
    NSDictionary *underlineAttribute = @{NSUnderlineStyleAttributeName: @(NSUnderlineStyleSingle)};
    termsLabel.attributedText = [[NSAttributedString alloc] initWithString:textOutStations
                                                             attributes:underlineAttribute];
    
    UIButton *buttonTerms = [[UIButton alloc]init];
    buttonTerms.frame = termsLabel.frame;
    buttonTerms.backgroundColor = [UIColor clearColor];
    [buttonTerms addTarget:self action:@selector(openSafari) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:buttonTerms];
    
}

-(void)openSafari{
    NSURL *url = [NSURL URLWithString:@"http://5secondquickie.me/"];
    
    if (![[UIApplication sharedApplication] openURL:url]) {
        NSLog(@"%@%@",@"Failed to open url:",[url description]);
    }
}

-(void)enter{

    if ([_nameField.text length] > 0) {
        
        self.okButton.userInteractionEnabled = NO;
        [self.okButton setTitle:@"LOADING..." forState:UIControlStateNormal];
        
    [[NSUserDefaults standardUserDefaults] setValue:[_nameField.text lowercaseString] forKey:@"username"];
    
    [[AFHTTPRequestOperationManager manager] POST:@"http://irl-backend.herokuapp.com/quickie/create_account"
                                        parameters:@{@"username" : _nameField.text}
                                        success:^(AFHTTPRequestOperation *operation, id responseObject) {
                                            
                                            if (responseObject[@"error"]) {
                                                self.okButton.userInteractionEnabled = YES;
                                                [self.okButton setTitle:@"ENTER >" forState:UIControlStateNormal];
                                                UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"Username taken" message:@"This username already exists! Pick another one please :)" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
                                                [alert show];
                                            } else{
                                                [[NSUserDefaults standardUserDefaults] setValue:responseObject[@"token"] forKey:@"token"];
                                                
                                                Mixpanel *mixpanel = [Mixpanel sharedInstance];
                                                [mixpanel identify:[[NSUserDefaults standardUserDefaults] valueForKey:@"token"]];
                                                [mixpanel.people set:@{@"$name": [_nameField.text lowercaseString]}];
                                                [mixpanel.people set:@{@"token": responseObject[@"token"]}];
                                                [mixpanel.people increment:@"app opens" by:@1];
                                                [mixpanel track:@"open app"];
                                                
                                                PhoneViewController *phoneVC = [[PhoneViewController alloc]init];
                                                phoneVC.firstFlow = YES;
                                                [self.navigationController pushViewController:phoneVC animated:YES];
                                            }
                                            
                                            
                    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                        
                        NSLog(@"%@", error.description);
                        self.okButton.userInteractionEnabled = YES;
                        [self.okButton setTitle:@"ENTER >" forState:UIControlStateNormal];
        //
                    }];
    }

}

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string  {
    
    NSCharacterSet *cs = [[NSCharacterSet characterSetWithCharactersInString:ACCEPTABLE_CHARECTERS] invertedSet];
    
    NSString *filtered = [[string componentsSeparatedByCharactersInSet:cs] componentsJoinedByString:@""];
    
    return [string isEqualToString:filtered];
}




@end
