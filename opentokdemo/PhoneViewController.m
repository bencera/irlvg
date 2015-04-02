//
//  PhoneViewController.m
//  opentokdemo
//
//  Created by Ben Cera on 3/25/15.
//  Copyright (c) 2015 Context Labs Inc. All rights reserved.
//

#import "PhoneViewController.h"
#import "AFNetworking.h"
#import "SlidesViewController.h"
#import "NSString+Hashes.h"
#import <AddressBook/AddressBook.h>
#import <AddressBookUI/AddressBookUI.h>
#import "AppDelegate.h"

#define ACCEPTABLE_CHARECTERS @"0123456789"

@interface PhoneViewController () <UITextFieldDelegate, UITableViewDataSource, UITableViewDelegate>

@property (nonatomic) UITextField *nameField;
@property (nonatomic) UIButton *okButton;
@property (nonatomic) UIButton *skipButton;
@property (nonatomic) UITableView *tableView;
@property (nonatomic) NSMutableArray *friendList;
@property (nonatomic) UIImageView *logo;

@end

@implementation PhoneViewController

@synthesize firstFlow;

-(void)viewDidLoad{
    [super viewDidLoad];
        
    self.view.backgroundColor = [UIColor whiteColor];
        
    [self loadPhoneInputControls];
    
}

- (void) runSpinAnimationOnView:(UIView*)view duration:(CGFloat)duration rotations:(CGFloat)rotations repeat:(float)repeat;
{
    CABasicAnimation* rotationAnimation;
    rotationAnimation = [CABasicAnimation animationWithKeyPath:@"transform.rotation.z"];
    rotationAnimation.toValue = [NSNumber numberWithFloat: M_PI * 2.0 /* full rotation*/ * rotations];
    rotationAnimation.duration = duration;
    rotationAnimation.cumulative = YES;
    rotationAnimation.repeatCount = repeat;
    [view.layer addAnimation:rotationAnimation forKey:@"rotationAnimation"];
}

- (void)loadTableViewForFriends{
    UIView *navBar = [[UIView alloc]init];
    navBar.frame = CGRectMake(0, 0, self.view.bounds.size.width, 84.f);
    navBar.backgroundColor = [UIColor colorWithRed:249/255.f green:139/255.f blue:61/255.f alpha:1.f];
    [self.view addSubview:navBar];
    
    self.logo = [[UIImageView alloc]init];
    self.logo.frame = CGRectMake((self.view.bounds.size.width - 35)/2, 27, 35, 50);
    self.logo.image = [UIImage imageNamed:@"bolt_forcalls"];
    [self.view addSubview:self.logo];
    
    //tableView
    _tableView = [[UITableView alloc]initWithFrame:CGRectMake(0, 84, self.view.bounds.size.width, self.view.bounds.size.height-84.f) style:UITableViewStylePlain];
    _tableView.delegate = self;
    _tableView.dataSource = self;
    _tableView.backgroundColor = [UIColor clearColor];
    _tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    [self.view addSubview:_tableView];
    
    [self askAddressBookAccess];
    
}

-(void)loadPhoneInputControls{
    _nameField = [[UITextField alloc]init];
    _nameField.frame = CGRectMake(20.f, 100.f, self.view.bounds.size.width - 40.f, 30.f);
    _nameField.placeholder = @"Phone number";
    _nameField.font = [UIFont fontWithName:@"DINCond-Regular" size:24.f];
    _nameField.textAlignment = NSTextAlignmentCenter;
    _nameField.delegate = self;
    _nameField.keyboardType = UIKeyboardTypeDecimalPad;
    [self.view addSubview:_nameField];
    
    self.okButton = [UIButton buttonWithType:UIButtonTypeCustom];
    self.okButton.frame = CGRectMake(40, 140, (self.view.bounds.size.width - 80), 60);
    self.okButton.backgroundColor = [UIColor colorWithRed:255/255.f green:204/255.f blue:0 alpha:1.f];
    [self.okButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [self.okButton setTitle:@"FIND FRIENDS >" forState:UIControlStateNormal];
    self.okButton.titleLabel.font = [UIFont fontWithName:@"DINCond-Bold" size:26.f];
    [self.okButton addTarget:self action:@selector(enter) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:self.okButton];
    
    self.skipButton = [UIButton buttonWithType:UIButtonTypeCustom];
    self.skipButton.frame = CGRectMake(40, 200, (self.view.bounds.size.width - 80), 60);
    self.skipButton.backgroundColor = [UIColor clearColor];
    [self.skipButton setTitleColor:[UIColor colorWithRed:255/255.f green:204/255.f blue:0 alpha:1.f] forState:UIControlStateNormal];
    [self.skipButton setTitle:@"skip >" forState:UIControlStateNormal];
    self.skipButton.titleLabel.font = [UIFont fontWithName:@"DINCond-Bold" size:18.f];
    [self.skipButton addTarget:self action:@selector(askAddressBookAccess) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:self.skipButton];
    
    
    [_nameField becomeFirstResponder];
}

-(void)enter{
    if (_nameField.text.length > 0) {
   
    self.okButton.userInteractionEnabled = NO;
    [self.okButton setTitle:@"LOADING..." forState:UIControlStateNormal];
    self.skipButton.userInteractionEnabled = NO;
    self.skipButton.hidden = YES;
    
    [[AFHTTPRequestOperationManager manager] POST:@"http://irl-backend.herokuapp.com/quickie/input_phone"
                                       parameters:@{@"phone" : [_nameField.text sha1], @"token" : [[NSUserDefaults standardUserDefaults] valueForKey:@"token"]}
                                          success:^(AFHTTPRequestOperation *operation, id responseObject) {
                                              
                                              //ask access to contacts
                                              [self askAddressBookAccess];
                                              
                                              
                                          } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                                              
                                              NSLog(@"%@", error.description);
                                              self.okButton.userInteractionEnabled = YES;
                                              [self.okButton setTitle:@"ENTER >" forState:UIControlStateNormal];
                                              self.skipButton.hidden = NO;
                                              //
                                          }];
    }
}


-(void)getAddressBook{
    
    ABAddressBookRef addressBook = ABAddressBookCreate(); // create address book reference object
    NSArray *abContactArray = (__bridge NSArray *)ABAddressBookCopyArrayOfAllPeople(addressBook); // get address book contact array
    
    NSInteger totalContacts =[abContactArray count];
    
    NSMutableArray *phoneNumberArray = [[NSMutableArray alloc]init];
    
    for(NSUInteger loop= 0 ; loop < totalContacts; loop++)
    {
        ABRecordRef record = (__bridge ABRecordRef)[abContactArray objectAtIndex:loop]; // get address book record
        
        if(ABRecordGetRecordType(record) ==  kABPersonType) // this check execute if it is person group
        {
            
            NSString* phone = nil;
            ABMultiValueRef phoneNumbers = ABRecordCopyValue(record,
                                                             kABPersonPhoneProperty);
            if (ABMultiValueGetCount(phoneNumbers) > 0) {
                phone = (__bridge_transfer NSString*)
                ABMultiValueCopyValueAtIndex(phoneNumbers, 0);
            } else {
                phone = @"[None]";
            }
            CFRelease(phoneNumbers);
            
            NSString *newString = [[phone componentsSeparatedByCharactersInSet:
                                    [[NSCharacterSet decimalDigitCharacterSet] invertedSet]]
                                   componentsJoinedByString:@""];
            
            if (newString.length >= 9) {
                newString = [newString substringFromIndex: [newString length] - 9];
            }
            
            [phoneNumberArray addObject:[newString sha1]];
        }
    }
    
    [self sendPhoneNumbers:phoneNumberArray];
}


-(void)sendPhoneNumbers:(NSMutableArray*)phonenumbers{
    [[AFHTTPRequestOperationManager manager] POST:@"https://irl-backend.herokuapp.com/quickie/find_friends" parameters:@{@"phone_numbers" : phonenumbers,@"token" : [[NSUserDefaults standardUserDefaults] valueForKey:@"token"]} success:^(AFHTTPRequestOperation *operation, id responseObject) {
        //

        SlidesViewController *slidesVC = [[SlidesViewController alloc]init];
        [self.navigationController pushViewController:slidesVC animated:YES];


    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        //
        SlidesViewController *slidesVC = [[SlidesViewController alloc]init];
        [self.navigationController pushViewController:slidesVC animated:YES];
    }];
}

-(void)askAddressBookAccess{
    [_nameField resignFirstResponder];
    self.okButton.userInteractionEnabled = NO;
    self.skipButton.userInteractionEnabled = NO;
    [self.okButton setTitle:@"LOADING" forState:UIControlStateNormal];
    
    ABAddressBookRequestAccessWithCompletion(ABAddressBookCreateWithOptions(NULL, nil), ^(bool granted, CFErrorRef error) {
        dispatch_async(dispatch_get_main_queue(), ^{
        if (!granted){
            SlidesViewController *slidesVC = [[SlidesViewController alloc]init];
            [self.navigationController pushViewController:slidesVC animated:YES];
        } else{
            //5
            NSLog(@"Just authorized");
            [self getAddressBook];
        }
        });
    });
}

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string  {
    
    NSCharacterSet *cs = [[NSCharacterSet characterSetWithCharactersInString:ACCEPTABLE_CHARECTERS] invertedSet];
    
    NSString *filtered = [[string componentsSeparatedByCharactersInSet:cs] componentsJoinedByString:@""];
    
    return [string isEqualToString:filtered];
}

#pragma mark - TableView functions

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return self.friendList.count;
}


- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    CGFloat height = 100.f;
    
    return height;
    
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    
    UITableViewCell *cell;
    
    cell = [tableView dequeueReusableCellWithIdentifier:@"friendCell"];
    
    if (!cell){
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"friendCell"];
        UIView *seperator = [[UIView alloc]init];
        seperator.frame = CGRectMake(0, 99.f, self.view.bounds.size.width, 1.f);
        seperator.backgroundColor = [UIColor colorWithWhite:0.9f alpha:1.f];
        [cell addSubview:seperator];
        
        UIActivityIndicatorView *actInd = [[UIActivityIndicatorView alloc]initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
        actInd.center = CGPointMake(self.view.bounds.size.width / 2, 50.f);
        actInd.tag = 2;
        actInd.hidesWhenStopped = YES;
        [cell addSubview:actInd];
    }
    
    cell.textLabel.font = [UIFont fontWithName:@"DINCond-Regular" size:40.f];
    cell.textLabel.textColor = [UIColor colorWithWhite:0.2 alpha:1.f];
    cell.textLabel.text = [self.friendList[indexPath.row][@"username"] uppercaseString];
    
    cell.textLabel.textAlignment = NSTextAlignmentCenter;
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    cell.accessoryType = UITableViewCellAccessoryNone;

    cell.backgroundColor = [UIColor whiteColor];
    
    return cell;
}


@end
