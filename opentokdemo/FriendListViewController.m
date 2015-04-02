//
//  FriendListViewController.m
//  opentokdemo
//
//  Created by Ben Cera on 3/18/15.
//  Copyright (c) 2015 Context Labs Inc. All rights reserved.
//

#import "FriendListViewController.h"
#import "NewSubscribeViewController.h"
#import "LeaderboardViewController.h"
#import "AFNetworking.h"
#import "AppDelegate.h"
#import <AVFoundation/AVFoundation.h>
#import "DeepCopy.h"
#import <MessageUI/MessageUI.h>

#define request_expiration 30 //30 seconds

@interface FriendListViewController() <UITableViewDataSource,UITableViewDelegate,UITextFieldDelegate,UIAlertViewDelegate,UIActionSheetDelegate, MFMailComposeViewControllerDelegate,MFMessageComposeViewControllerDelegate>

@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, strong) NSMutableArray *friendList;
@property (nonatomic, strong) UITextField *textField;
@property (nonatomic, strong) AppDelegate *delegate;
@property long missedCallRow;
@property (nonatomic, strong) NewSubscribeViewController *subVC;
@property (nonatomic, strong) UIImageView *logo;
@property int quickieDuration;
@property (nonatomic, strong) UIButton *timerB;
@property (nonatomic, strong) UIButton *leaderboardB;
@property (nonatomic, strong) UILabel *timerLabel;
@property BOOL firstLoading;
@property BOOL failedLoading;
@property int tryItOutAvailable;
@property int godMode;
@property (nonatomic) NSString *notifyUsername;

@end

@implementation FriendListViewController

-(UIStatusBarStyle)preferredStatusBarStyle{
    return UIStatusBarStyleLightContent;
}


#pragma mark - View Logic

-(void)viewDidLoad{
    [super viewDidLoad];

    self.firstLoading = YES;
    self.tryItOutAvailable = 0;
    self.godMode = 0;
    
    if ([[[[NSUserDefaults standardUserDefaults] valueForKey:@"username"]lowercaseString] isEqualToString:@"benc"]) {
        self.godMode = 1;
    }
    
    self.quickieDuration = (int)[[NSUserDefaults standardUserDefaults] integerForKey:@"quickieDuration"];
    
    if (self.quickieDuration == 0) {
        self.quickieDuration = 10;
        [[NSUserDefaults standardUserDefaults] setInteger:10 forKey:@"quickieDuration"];
    }
    
    UIView *navBar = [[UIView alloc]init];
    navBar.frame = CGRectMake(0, 0, self.view.bounds.size.width, 84.f);
    navBar.backgroundColor = [UIColor colorWithRed:249/255.f green:139/255.f blue:61/255.f alpha:1.f];
    [self.view addSubview:navBar];
    
    self.logo = [[UIImageView alloc]init];
    self.logo.frame = CGRectMake((self.view.bounds.size.width - 35)/2, 27, 35, 50);
    self.logo.image = [UIImage imageNamed:@"bolt_forcalls"];
    [self.view addSubview:self.logo];
    
    self.timerB = [[UIButton alloc]init];
    self.timerB.backgroundColor = [UIColor clearColor];
    self.timerB.frame = CGRectMake(12, 20+12.f, 36.5f, 40.f);
    [self.timerB addTarget:self action:@selector(changeTimer) forControlEvents:UIControlEventTouchUpInside];
    [self.timerB setImage:[UIImage imageNamed:@"timer"] forState:UIControlStateNormal];
    [self.view addSubview:self.timerB];

    self.leaderboardB = [[UIButton alloc]init];
    self.leaderboardB.backgroundColor = [UIColor clearColor];
    self.leaderboardB.frame = CGRectMake(self.view.bounds.size.width - 12.5f - 35.f, 20+15.5f, 35.f, 35.f);
    [self.leaderboardB addTarget:self action:@selector(leaderboard) forControlEvents:UIControlEventTouchUpInside];
    [self.leaderboardB setImage:[UIImage imageNamed:@"rank"] forState:UIControlStateNormal];
    [self.view addSubview:self.leaderboardB];
    
    self.timerLabel = [[UILabel alloc]init];
    self.timerLabel.frame = CGRectMake(11.f, 20+13.f, 36.5f, 40.f);
    self.timerLabel.text = [NSString stringWithFormat:@"%d", self.quickieDuration];
    self.timerLabel.font = [UIFont fontWithName:@"DINCond-Bold" size:20.f];
    self.timerLabel.backgroundColor = [UIColor clearColor];
    self.timerLabel.textColor = [UIColor whiteColor];
    self.timerLabel.textAlignment = NSTextAlignmentCenter;
    [self.view addSubview:self.timerLabel];
    
    self.delegate = (AppDelegate*)[[UIApplication sharedApplication] delegate];
    
    self.view.backgroundColor = [UIColor whiteColor];
    
    [[NSUserDefaults standardUserDefaults] setBool:NO forKey:@"calling"];
    
    //tableView
    _tableView = [[UITableView alloc]initWithFrame:CGRectMake(0, 84, self.view.bounds.size.width, self.view.bounds.size.height-84.f) style:UITableViewStylePlain];
    _tableView.delegate = self;
    _tableView.dataSource = self;
    _tableView.backgroundColor = [UIColor clearColor];
    _tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    [self.view addSubview:_tableView];
    
    [self downloadLastRequest];
    
    if ([[NSUserDefaults standardUserDefaults] valueForKey:@"token"]) {
        [self setupPushNotifications];
    }
    
}

-(void)viewDidAppear:(BOOL)animated{
    self.subVC = nil;
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

#pragma mark - HTTP Requests

-(void)downloadLastRequest{
    if ([[NSUserDefaults standardUserDefaults] objectForKey:@"token"]) {
        
        [self runSpinAnimationOnView:self.logo duration:1 rotations:1 repeat:10];
        
        [[AFHTTPRequestOperationManager manager] GET:@"https://irl-backend.herokuapp.com/quickie/last_request" parameters:@{@"token" : [[NSUserDefaults standardUserDefaults] valueForKey:@"token"]} success:^(AFHTTPRequestOperation *operation, id responseObject) {
            
            [self downloadFriendListWithAnimation:NO];

            NSMutableArray *last_request = responseObject;
            
            if (last_request.count > 0) {
                BOOL missedRequest = [last_request[0][@"request"] doubleValue] == 1 && ![last_request[0][@"requested_by"] isKindOfClass:[NSNull class]] && [last_request[0][@"requested_by"] isEqualToString:last_request[0][@"user_id"]];
                
                BOOL recentRequest = [last_request[0][@"request"] doubleValue] > 1 && [last_request[0][@"request"] doubleValue] > [[NSDate date]timeIntervalSince1970] - request_expiration;
                
                if ((missedRequest || recentRequest) && ![[NSUserDefaults standardUserDefaults] boolForKey:@"calling"]) {
                    BOOL calling = ![last_request[0][@"requested_by"] isEqualToString:last_request[0][@"user_id"]];
                    self.subVC = [[NewSubscribeViewController alloc]init];
                    self.subVC.user_id = last_request[0][@"user_id"];
                    self.subVC.username = last_request[0][@"username"];
                    self.subVC.calling = calling;
                    if (missedRequest) {
                        self.subVC.calling = YES;
                    }
                    self.subVC.missed_call = missedRequest;
                    self.subVC.duration = last_request[0][@"duration"];
                    self.subVC.session_id = last_request[0][@"session_id"];
                    self.subVC.session_token = last_request[0][@"session_token"];
                    [self presentViewController:self.subVC animated:NO completion:nil];
                    [[NSUserDefaults standardUserDefaults] setBool:YES forKey:@"calling"];
                }
            }
            
        } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
            //
            [self.logo.layer removeAllAnimations];
            self.failedLoading = YES;
            [self.tableView reloadData];
        }];
    }

}

-(void)downloadFriendListWithAnimation:(BOOL)animation{
    if ([[NSUserDefaults standardUserDefaults] objectForKey:@"token"]) {
        
        if (animation) {
            [self runSpinAnimationOnView:self.logo duration:1 rotations:1 repeat:10];
        }
        
        [[AFHTTPRequestOperationManager manager] GET:@"https://irl-backend.herokuapp.com/quickie/friends" parameters:@{@"token" : [[NSUserDefaults standardUserDefaults] valueForKey:@"token"]} success:^(AFHTTPRequestOperation *operation, id responseObject) {
            //
            self.firstLoading = NO;
            [self.logo.layer removeAllAnimations];
            self.friendList = [responseObject deepMutableCopy];
            [self.tableView reloadData];
            
            [self checkTryItOutAvailable];
            
        } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
            //
            [self.logo.layer removeAllAnimations];
            self.failedLoading = YES;
            [self.tableView reloadData];
        }];
    }
}

-(void)checkTryItOutAvailable{
    [[AFHTTPRequestOperationManager manager] GET:@"https://irl-backend.herokuapp.com/quickie/tryitout_available" parameters:nil success:^(AFHTTPRequestOperation *operation, id responseObject) {
        //
        if ([responseObject[@"available"] isEqualToString:@"yes"]) {
            self.tryItOutAvailable = 1;
            [self.tableView reloadData];
        } else{
            self.tryItOutAvailable = 0;
            [self.tableView reloadData];
        }
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        //
    }];
}

-(void)toggleTryitout{
    [[AFHTTPRequestOperationManager manager] POST:@"https://irl-backend.herokuapp.com/quickie/toggle_tryitout" parameters:nil success:^(AFHTTPRequestOperation *operation, id responseObject) {
        //
        if ([responseObject[@"available"] isEqualToString:@"yes"]) {
            self.tryItOutAvailable = 1;
            [self.tableView reloadData];
        } else{
            self.tryItOutAvailable = 0;
            [self.tableView reloadData];
        }
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        //
    }];
}

-(void)endRequestWithUser:(NSString *)user_id{
    [[AFHTTPRequestOperationManager manager] POST:@"https://irl-backend.herokuapp.com/quickie/end_request" parameters:@{@"token" : [[NSUserDefaults standardUserDefaults] valueForKey:@"token"], @"user_id" : user_id} success:^(AFHTTPRequestOperation *operation, id responseObject) {
        //
        [self downloadFriendListWithAnimation:YES];
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        //
    }];
}

-(void)deleteUser:(NSString*)user_id{
    [[AFHTTPRequestOperationManager manager] POST:@"https://irl-backend.herokuapp.com/quickie/delete_friend" parameters:@{@"token" : [[NSUserDefaults standardUserDefaults] valueForKey:@"token"], @"user_id" : user_id} success:^(AFHTTPRequestOperation *operation, id responseObject) {
        //
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        //
    }];
}

-(void)blockUser:(NSString*)user_id{
    [[AFHTTPRequestOperationManager manager] POST:@"https://irl-backend.herokuapp.com/quickie/block_friend" parameters:@{@"token" : [[NSUserDefaults standardUserDefaults] valueForKey:@"token"], @"user_id" : user_id} success:^(AFHTTPRequestOperation *operation, id responseObject) {
        //
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        //
    }];
}

-(void)addFriend:(NSString*)username{
    [[AFHTTPRequestOperationManager manager] POST:@"https://irl-backend.herokuapp.com/quickie/add_friend" parameters:@{@"token" : [[NSUserDefaults standardUserDefaults] valueForKey:@"token"], @"username" : username} success:^(AFHTTPRequestOperation *operation, id responseObject) {
        //
        if (responseObject[@"error"]) {
            UIAlertView *alert = [[UIAlertView alloc]initWithTitle:nil message:@"Username doesn't exist :/" delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
            alert.tag = 2;
            [alert show];
        } else{
            [self downloadFriendListWithAnimation:YES];
        }
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        //
    }];
}

-(void)turnonNotify{
    [[AFHTTPRequestOperationManager manager] POST:@"https://irl-backend.herokuapp.com/quickie/register_notify_online" parameters:@{@"token" : [[NSUserDefaults standardUserDefaults] valueForKey:@"token"], @"username" : self.notifyUsername, @"turn_on" : @"yes"} success:^(AFHTTPRequestOperation *operation, id responseObject) {
        //
        if ([responseObject[@"status"] isEqualToString:@"ok"]) {
            [[NSUserDefaults standardUserDefaults] setBool:YES forKey:[NSString stringWithFormat:@"online_notification|%@",self.notifyUsername]];
            UIAlertView *successAV = [[UIAlertView alloc]initWithTitle:@"Turned on!" message:@"You can always turn off these notifications later in ONLINE SETTINGS." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
            [successAV show];
        }
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        //
    }];
}

-(void)notifyOnline{
    [[AFHTTPRequestOperationManager manager] POST:@"https://irl-backend.herokuapp.com/quickie/notify_users_online" parameters:@{@"token" : [[NSUserDefaults standardUserDefaults] valueForKey:@"token"]} success:^(AFHTTPRequestOperation *operation, id responseObject) {
        //
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        //
    }];
}


#pragma mark - TableView functions

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    if  (self.firstLoading){
        return 1;
    } else {
        return self.friendList.count + 3 + self.tryItOutAvailable + self.godMode;
    }
}


- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 100.f;
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
    }
    
    cell.textLabel.font = [UIFont fontWithName:@"DINCond-Regular" size:40.f];
    cell.textLabel.textColor = [UIColor colorWithWhite:0.2 alpha:1.f];
    if (indexPath.row == self.friendList.count) {
        if (self.firstLoading && self.failedLoading) {
            cell.textLabel.text = @"FAILED. TAP TO RETRY.";
        } else if (self.firstLoading){
            cell.textLabel.text = @"LOADING...";
        }else {
            cell.textLabel.text = @"SEARCH >";
        }
    } else if (indexPath.row == self.friendList.count + 1){
        cell.textLabel.text = @"INVITE >";
    } else if (indexPath.row == self.friendList.count + 2){
        cell.textLabel.text = @"FEEDBACK >";
    } else if (indexPath.row == self.friendList.count + 3 && self.tryItOutAvailable) {
        cell.textLabel.text = @"TRY IT OUT >";
    } else if (indexPath.row >= self.friendList.count + 3) {
        cell.textLabel.text = @"TOGGLE TRY OUT >";
    } else {
        cell.textLabel.text = [self.friendList[indexPath.row][@"username"]uppercaseString];
        cell.textLabel.textColor = [UIColor colorWithWhite:0.2 alpha:1.f];
        cell.textLabel.font = [UIFont fontWithName:@"DINCond-Regular" size:40.f];
    }
    cell.textLabel.textAlignment = NSTextAlignmentCenter;
    cell.selectionStyle = UITableViewCellSelectionStyleGray;
    cell.accessoryType = UITableViewCellAccessoryNone;
    cell.backgroundColor = [UIColor whiteColor];
    
    return cell;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    if (indexPath.row == self.friendList.count) {
        if (self.firstLoading && self.failedLoading) {
            self.failedLoading = NO;
            [self.tableView reloadData];
            [self downloadLastRequest];
        } else if (!self.firstLoading) {
            [self addUser];
        }
    } else if (indexPath.row == self.friendList.count + 1){
        [self invite];
    } else if (indexPath.row == self.friendList.count + 2){
        [self feedback];
    } else if (indexPath.row == self.friendList.count + 3 && self.tryItOutAvailable){
        [self tryitout];
    } else if (indexPath.row >= self.friendList.count + 3){
        [self toggleTryitout];
    } else {
        self.subVC = [[NewSubscribeViewController alloc]init];
        self.subVC.user_id = self.friendList[indexPath.row][@"user_id"];
        self.subVC.username = self.friendList[indexPath.row][@"username"];
        self.subVC.calling = YES;
        self.subVC.duration = [NSString stringWithFormat:@"%d",self.quickieDuration];
        [self presentViewController:self.subVC animated:NO completion:nil];
        [[NSUserDefaults standardUserDefaults] setBool:YES forKey:@"calling"];
    }
}

-(BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath{
    return indexPath.row < self.friendList.count;
}

-(void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath{
    UIAlertView *deleteAV = [[UIAlertView alloc]initWithTitle:nil message:[NSString stringWithFormat:@"Delete or Block %@?", self.friendList[indexPath.row][@"username"]] delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:@"Delete",@"Block", nil];
    deleteAV.tag = 6;
    [deleteAV show];
    self.missedCallRow = indexPath.row;
}

-(void)tableView:(UITableView *)tableView didEndEditingRowAtIndexPath:(NSIndexPath *)indexPath{
    
}

#pragma mark - Authorizations

-(void)setupPushNotifications{
    if([[[UIDevice currentDevice] systemVersion] floatValue] >= 8)
    {
        UIUserNotificationSettings* notificationSettings = [UIUserNotificationSettings settingsForTypes:UIUserNotificationTypeAlert | UIUserNotificationTypeBadge | UIUserNotificationTypeSound categories:nil];
        [[UIApplication sharedApplication] registerUserNotificationSettings:notificationSettings];
    }
    else
    {
        [[UIApplication sharedApplication] registerForRemoteNotificationTypes:(UIRemoteNotificationTypeAlert | UIRemoteNotificationTypeSound|UIRemoteNotificationTypeBadge)];
    }
    
    [self askForCameraPermissions];
    [self askForAudioPermissions];
}

-(void)askForCameraPermissions{
    AVAuthorizationStatus authStatus = [AVCaptureDevice authorizationStatusForMediaType:AVMediaTypeVideo];
    if(authStatus == AVAuthorizationStatusAuthorized) {
        // do your logic
    } else if(authStatus == AVAuthorizationStatusDenied){
        // denied
    } else if(authStatus == AVAuthorizationStatusRestricted){
        // restricted, normally won't happen
    } else if(authStatus == AVAuthorizationStatusNotDetermined){
        // not determined?!
        [AVCaptureDevice requestAccessForMediaType:AVMediaTypeVideo completionHandler:^(BOOL granted) {
            if(granted){
                NSLog(@"Granted access to %@", @"AVMediaTypeVideo");
            } else {
                NSLog(@"Not granted access to %@", @"AVMediaTypeVideo");
            }
        }];
    } else {
        // impossible, unknown authorization status
    }
}

-(void)askForAudioPermissions{
    AVAuthorizationStatus authStatus = [AVCaptureDevice authorizationStatusForMediaType:AVMediaTypeAudio];
    if(authStatus == AVAuthorizationStatusAuthorized) {
        // do your logic
    } else if(authStatus == AVAuthorizationStatusDenied){
        // denied
    } else if(authStatus == AVAuthorizationStatusRestricted){
        // restricted, normally won't happen
    } else if(authStatus == AVAuthorizationStatusNotDetermined){
        // not determined?!
        [AVCaptureDevice requestAccessForMediaType:AVMediaTypeAudio completionHandler:^(BOOL granted) {
            if(granted){
                NSLog(@"Granted access to %@", @"AVMediaTypeAudio");
            } else {
                NSLog(@"Not granted access to %@", @"AVMediaTypeAudio");
            }
        }];
    } else {
        // impossible, unknown authorization status
    }
}


#pragma mark - Settings Operations

-(void)tryitout{
    self.subVC = [[NewSubscribeViewController alloc]init];
    self.subVC.user_id = @"17";
    self.subVC.username = @"QUICKIE TEAM";
    self.subVC.calling = YES;
    self.subVC.duration = @"5";
    self.subVC.tryitout = YES;
    [self presentViewController:self.subVC animated:NO completion:nil];
    [[NSUserDefaults standardUserDefaults] setBool:YES forKey:@"calling"];
}

- (void)addUser{
    UIAlertView *query = [[UIAlertView alloc]
             initWithTitle:@"Add Friend"
             message:nil
             delegate:self
             cancelButtonTitle:@"Cancel"
             otherButtonTitles:@"Add", nil];
    query.alertViewStyle = UIAlertViewStylePlainTextInput;
    query.delegate = self;
    self.textField = [query textFieldAtIndex:0];
    self.textField.placeholder = @"username";
    self.textField.delegate = self;
    [query show];
}

-(void)invite{
    MFMessageComposeViewController *controller = [[MFMessageComposeViewController alloc] init];
    if([MFMessageComposeViewController canSendText])
    {
        controller.body = @"Get Quickie! http://tinyurl.com/irlappbeta";
        controller.recipients = [NSArray arrayWithObjects: nil];
        controller.messageComposeDelegate = self;
        [self presentViewController:controller animated:YES completion:nil];
    }
}

- (void)messageComposeViewController:(MFMessageComposeViewController *)controller didFinishWithResult:(MessageComposeResult)result
{
    switch (result) {
        case MessageComposeResultCancelled:
            NSLog(@"Cancelled");
            break;
        case MessageComposeResultFailed:
            break;
        case MessageComposeResultSent:
            
            break;
        default:
            break;
    }
    
    [self dismissViewControllerAnimated:YES completion:nil];
}

-(void)feedback{
    
    if ([MFMailComposeViewController canSendMail]) {
        
        // Email Subject
        NSString *emailTitle = @"Feedback on Quickie";
        // Email Content
        NSString *messageBody = @"";
        // To address
        NSArray *toRecipents = [NSArray arrayWithObject:@"feedback@thefacefeed.com"];
        
        MFMailComposeViewController *mc = [[MFMailComposeViewController alloc] init];
        mc.mailComposeDelegate = self;
        [mc setSubject:emailTitle];
        [mc setMessageBody:messageBody isHTML:NO];
        [mc setToRecipients:toRecipents];
        
        // Present mail view controller on screen
        [self presentViewController:mc animated:YES completion:NULL];
    } else{
        UIAlertView *sorryVC = [[UIAlertView alloc]initWithTitle:@"Can't send email." message:@"Please check your settings." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [sorryVC show];
    }
}

- (void) mailComposeController:(MFMailComposeViewController *)controller didFinishWithResult:(MFMailComposeResult)result error:(NSError *)error
{
    
    switch (result)
    {
        case MFMailComposeResultCancelled:
            NSLog(@"Mail cancelled");
            break;
        case MFMailComposeResultSaved:
            NSLog(@"Mail saved");
            break;
        case MFMailComposeResultSent:
            NSLog(@"Mail sent");
            break;
        case MFMailComposeResultFailed:
            NSLog(@"Mail sent failure: %@", [error localizedDescription]);
            break;
        default:
            break;
    }
    
    // Close the Mail Interface
    [self dismissViewControllerAnimated:YES completion:NULL];
}


#pragma mark - AlertView Logic

-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{
    if (alertView.tag == 11) {
        if (buttonIndex == 1) {
           // NSLog(@"turn on notify");
            [self turnonNotify];
        }
    }
    else if (alertView.tag == 6) {
        if (buttonIndex == 1) {
            NSLog(@"delete");
            [self deleteUser:self.friendList[self.missedCallRow][@"user_id"]];
            [self.friendList removeObjectAtIndex:self.missedCallRow];
            [_tableView reloadData];
        } else if (buttonIndex == 2){
            NSLog(@"block");
            [self blockUser:self.friendList[self.missedCallRow][@"user_id"]];
            [self.friendList removeObjectAtIndex:self.missedCallRow];
            [_tableView reloadData];
        }
    }
    else if (alertView.tag !=2 && buttonIndex == 1) {
        [self addFriend:self.textField.text];
    }
}

#pragma mark - Call Logic

-(void)showAlertNotAvailable:(NSString *)username{

//    if (![[NSUserDefaults standardUserDefaults] boolForKey:[NSString stringWithFormat:@"online_notification|%@",username]]){
//        UIAlertView *alert = [[UIAlertView alloc]initWithTitle:nil message:[NSString stringWithFormat:@"%@ didn't pick up. Do you want to get notified when they are online?",username] delegate:nil cancelButtonTitle:@"No" otherButtonTitles:@"Notify me",nil];
//        self.notifyUsername = username;
//        alert.tag = 11;
//        alert.delegate = self;
//        [alert show];
//    } else{
//        UIAlertView *alert = [[UIAlertView alloc]initWithTitle:nil message:[NSString stringWithFormat:@"%@ didn't pick up. We'll notify you when they are online!",username] delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
//        [alert show];
//    }
    UIAlertView *alert = [[UIAlertView alloc]initWithTitle:nil message:[NSString stringWithFormat:@"%@ didn't pick up. Try again later!",username] delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
    [alert show];
}

#pragma mark - Timer Logic

-(void)changeTimer{
    NSLog(@"here");
    UIActionSheet *actionSheet = [[UIActionSheet alloc]initWithTitle:@"Quickie duration" delegate:self cancelButtonTitle:@"Cancel" destructiveButtonTitle:nil otherButtonTitles:@"5 seconds", @"10 seconds", @"20 seconds", @"30 seconds", @"60 seconds", nil];
    [actionSheet showInView:self.view];
}

-(void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex{
    NSLog(@"%ld", (long)buttonIndex);
    if (buttonIndex == 0) {
        self.quickieDuration = 5;
    } else if (buttonIndex == 1){
        self.quickieDuration = 10;
    } else if (buttonIndex == 2){
        self.quickieDuration = 20;
    } else if (buttonIndex == 3){
        self.quickieDuration = 30;
    } else if (buttonIndex == 4){
        self.quickieDuration = 60;
    }
    
    [[NSUserDefaults standardUserDefaults] setInteger:self.quickieDuration forKey:@"quickieDuration"];
    self.timerLabel.text = [NSString stringWithFormat:@"%d", self.quickieDuration];
}

-(void)leaderboard{
    LeaderboardViewController *leaderboardVC = [[LeaderboardViewController alloc]init];
    [self presentViewController:leaderboardVC animated:YES completion:nil];
}

@end
