//
//  LeaderboardViewController.m
//  opentokdemo
//
//  Created by Ben Cera on 3/31/15.
//  Copyright (c) 2015 Context Labs Inc. All rights reserved.
//

#import "LeaderboardViewController.h"
#import "AFNetworking.h"
#import "AppDelegate.h"
#import "FriendListViewController.h"
#import "Mixpanel.h"

@interface LeaderboardViewController () <UITableViewDataSource,UITableViewDelegate,UIAlertViewDelegate>

@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic) UIImageView *logo;
@property (nonatomic) UIButton *closeB;
@property (nonatomic) UIButton *infoB;
@property (nonatomic) NSMutableArray *peopleList;
@property (nonatomic, strong) UILabel *navTitle;
@property (nonatomic) NSString *friend_added;

@end

@implementation LeaderboardViewController

- (void)viewDidLoad{
    [self mixpanelTrackLeaderboard];
    
    UIView *navBar = [[UIView alloc]init];
    navBar.frame = CGRectMake(0, 0, self.view.bounds.size.width, 84.f);
    navBar.backgroundColor = [UIColor colorWithRed:249/255.f green:139/255.f blue:61/255.f alpha:1.f];
    [self.view addSubview:navBar];
    
    self.logo = [[UIImageView alloc]init];
    self.logo.frame = CGRectMake((self.view.bounds.size.width - 35)/2, 27, 35, 50);
    self.logo.image = [UIImage imageNamed:@"bolt_forcalls"];
    [self.view addSubview:self.logo];
    
    self.navTitle = [[UILabel alloc]init];
    self.navTitle.frame = CGRectMake(0, 10, self.view.bounds.size.width, 80);
    self.navTitle.text = @"LEADERBOARD";
    self.navTitle.font = [UIFont fontWithName:@"DINCond-Regular" size:40.f];
    self.navTitle.textColor = [UIColor whiteColor];
    self.navTitle.hidden = YES;
    self.navTitle.textAlignment = NSTextAlignmentCenter;
    [self.view addSubview:self.navTitle];
    
    self.closeB = [UIButton buttonWithType:UIButtonTypeCustom];
    self.closeB.frame = CGRectMake(15, 20 + 22, 20, 20);
    [self.closeB setImage:[UIImage imageNamed:@"close_thin"] forState:UIControlStateNormal];
    [self.closeB addTarget:self action:@selector(closeAction) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:self.closeB];

    self.infoB = [UIButton buttonWithType:UIButtonTypeCustom];
    self.infoB.frame = CGRectMake(self.view.bounds.size.width - 30 - 15, 20 + 17, 30, 30);
    [self.infoB setImage:[UIImage imageNamed:@"help"] forState:UIControlStateNormal];
    [self.infoB addTarget:self action:@selector(infoAction) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:self.infoB];
    
    //tableView
    _tableView = [[UITableView alloc]initWithFrame:CGRectMake(0, 84, self.view.bounds.size.width, self.view.bounds.size.height-84.f) style:UITableViewStylePlain];
    _tableView.delegate = self;
    _tableView.dataSource = self;
    _tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    [self.view addSubview:_tableView];
    
    [self downloadLeaderboard];
}

- (void)viewDidAppear:(BOOL)animated{
    [self runSpinAnimationOnView:self.logo duration:1 rotations:1 repeat:99];
}

- (void) runSpinAnimationOnView:(UIView*)view duration:(CGFloat)duration1 rotations:(CGFloat)rotations repeat:(float)repeat;
{
    CABasicAnimation* rotationAnimation;
    rotationAnimation = [CABasicAnimation animationWithKeyPath:@"transform.rotation.z"];
    rotationAnimation.toValue = [NSNumber numberWithFloat: M_PI * 2.0 /* full rotation*/ * rotations];
    rotationAnimation.duration = duration1;
    rotationAnimation.cumulative = YES;
    rotationAnimation.repeatCount = repeat;
    [view.layer addAnimation:rotationAnimation forKey:@"rotationAnimation"];
}

- (void)infoAction{
    UIAlertView *infoAlert = [[UIAlertView alloc]initWithTitle:nil message:@"Score = Quickie requests received (in seconds). Friends and friends of friends only!" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
    [infoAlert show];
}

- (void)closeAction{
    [self dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - TableView functions

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return self.peopleList.count;
}


- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 80.f;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    
    UITableViewCell *cell;
    
    cell = [tableView dequeueReusableCellWithIdentifier:@"friendCell"];
    
    if (!cell){
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:@"friendCell"];
        UIView *seperator = [[UIView alloc]init];
        seperator.frame = CGRectMake(0, 79.f, self.view.bounds.size.width, 1.f);
        seperator.backgroundColor = [UIColor colorWithWhite:0.9f alpha:1.f];
        [cell addSubview:seperator];
        
        UILabel *score = [[UILabel alloc]init];
        score.frame = CGRectMake(self.view.bounds.size.width - 80, 10, 60, 60);
        score.text = @"1254";
        score.font = [UIFont fontWithName:@"DINCond-Regular" size:30.f];
        score.tag = 2;
        score.textAlignment = NSTextAlignmentRight;
        [cell addSubview:score];

    }
    
    cell.textLabel.font = [UIFont fontWithName:@"DINCond-Regular" size:30.f];
    cell.textLabel.textColor = [UIColor colorWithWhite:0.2 alpha:1.f];
    cell.textLabel.text = [self.peopleList[indexPath.row][@"username"] uppercaseString];
    
    if ([self.peopleList[indexPath.row][@"friends_with"] isEqualToString:@"0"]) {
        cell.detailTextLabel.text = @"";
    } else {
        cell.detailTextLabel.text = [NSString stringWithFormat:@"Friends with %@", [self.peopleList[indexPath.row][@"friends_with"]uppercaseString]];
    }
    cell.detailTextLabel.font =  [UIFont fontWithName:@"DINCond-Regular" size:16.f];
    cell.detailTextLabel.textColor = [UIColor colorWithWhite:0.4 alpha:1.f];
    
    UILabel *score = (UILabel*)[cell viewWithTag:2];
    score.text = self.peopleList[indexPath.row][@"score"];
    
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    cell.accessoryType = UITableViewCellAccessoryNone;
    cell.backgroundColor = [UIColor whiteColor];
    
    return cell;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    if (![self.peopleList[indexPath.row][@"friends_with"] isEqualToString:@"0"]) {
        self.friend_added = self.peopleList[indexPath.row][@"user_id"];
        UIAlertView *addV = [[UIAlertView alloc]initWithTitle:nil  message:[NSString stringWithFormat:@"Add %@ as a friend?",self.peopleList[indexPath.row][@"username"]] delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:@"Add", nil];
        addV.tag = 2;
        [addV show];
    } else{
        UIAlertView *addV = [[UIAlertView alloc]initWithTitle:nil  message:[NSString stringWithFormat:@"You are already friends with %@.",self.peopleList[indexPath.row][@"username"]] delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [addV show];
    }
}

-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{
    if (buttonIndex == 1 && alertView.tag == 2) {
        [self addFriend:self.friend_added];
        [self mixpanelTrackAddFriend];
    }
}

-(void)addFriend:(NSString*)user_id{
    [[AFHTTPRequestOperationManager manager] POST:@"https://irl-backend.herokuapp.com/quickie/add_friend" parameters:@{@"token" : [[NSUserDefaults standardUserDefaults] valueForKey:@"token"], @"user_id" : user_id} success:^(AFHTTPRequestOperation *operation, id responseObject) {
        //
        FriendListViewController *friendVC =  (FriendListViewController*)[(AppDelegate*)[[UIApplication sharedApplication] delegate] choiceVC];
        [friendVC downloadFriendListWithAnimation:NO];
        UIAlertView *success = [[UIAlertView alloc]initWithTitle:@"Added!" message:nil delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [success show];
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        //
    }];
}


#pragma mark - HTTP Requests

-(void)downloadLeaderboard{
    [[AFHTTPRequestOperationManager manager] GET:@"https://irl-backend.herokuapp.com/quickie/leaderboard" parameters:@{@"token" : [[NSUserDefaults standardUserDefaults] valueForKey:@"token"]} success:^(AFHTTPRequestOperation *operation, id responseObject) {
        //
        [self.logo.layer removeAllAnimations];
        self.logo.hidden = YES;
        self.navTitle.hidden = NO;
        self.peopleList = responseObject;
        [self.tableView reloadData];
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        //
    }];
}

#pragma mark - Mixpanel

-(void)mixpanelTrackLeaderboard{
    Mixpanel *mixpanel = [Mixpanel sharedInstance];
    [mixpanel track:@"leaderboard"];
}

-(void)mixpanelTrackAddFriend{
    Mixpanel *mixpanel = [Mixpanel sharedInstance];
    [mixpanel track:@"added friend from leaderboard"];
}

@end
