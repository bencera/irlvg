//
//  AppDelegate.m
//  opentokdemo
//
//  Created by Ben Cera on 2/19/15.
//  Copyright (c) 2015 Context Labs Inc. All rights reserved.
//

#import "AppDelegate.h"
#import "HockeySDK.h"
#import "NameViewController.h"
#import "AFNetworking.h"
#import "Mixpanel.h"
#import "FriendListViewController.h"
#import "SlidesViewController.h"

#define MIXPANEL_TOKEN @"e0ba9922519993523d6adca9280d9398"

@interface AppDelegate () <UIAlertViewDelegate,BITHockeyManagerDelegate>

@end

@implementation AppDelegate

@synthesize choiceVC;

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    // Override point for customization after application launch.
    
    [UIApplication sharedApplication].applicationIconBadgeNumber = 0;
    
    [self configureHockey];
    
    [Mixpanel sharedInstanceWithToken:MIXPANEL_TOKEN];
    
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    
    self.choiceVC = [[FriendListViewController alloc]init];
    self.window.rootViewController = self.choiceVC;
    
    [self.window makeKeyAndVisible];
    
    if (![[NSUserDefaults standardUserDefaults] objectForKey:@"token"]) {
        NameViewController *nameVC = [[NameViewController alloc] init];
        UINavigationController *navVCintro = [[UINavigationController alloc]initWithRootViewController:nameVC];
        navVCintro.navigationBarHidden = YES;
        [self.choiceVC presentViewController:navVCintro animated:NO completion:nil];
    } else {
        Mixpanel *mixpanel = [Mixpanel sharedInstance];
        [mixpanel identify:[[NSUserDefaults standardUserDefaults] valueForKey:@"token"]];
        [mixpanel.people set:@{@"$name": [[[NSUserDefaults standardUserDefaults] valueForKey:@"username"] lowercaseString]}];
        [self mixpanelTrackOpen];
    }
    
    return YES;
}


-(void)mixpanelTrackOpen{
    Mixpanel *mixpanel = [Mixpanel sharedInstance];
    [mixpanel track:@"open app"];
    [mixpanel.people increment:@"app opens" by:@1];
}


- (void)configureHockey {
    [[BITHockeyManager sharedHockeyManager] configureWithBetaIdentifier:@"0a0de10bbe379818942dcc056bc96a39" liveIdentifier:@"c69ab802c8c82d6ff9cf3884959e83a2" delegate:self];
    [[BITHockeyManager sharedHockeyManager] startManager];
    [[[BITHockeyManager sharedHockeyManager] authenticator] authenticateInstallation];
}

- (void)application:(UIApplication *)application didRegisterUserNotificationSettings:(UIUserNotificationSettings *)notificationSettings
{
    [application registerForRemoteNotifications];
}

- (void)application:(UIApplication *)application
didReceiveRemoteNotification:(NSDictionary *)userInfo
fetchCompletionHandler:(void (^)(UIBackgroundFetchResult))completionHandler {
    [self.choiceVC downloadLastRequest];
}


- (void)application:(UIApplication *)application handleActionWithIdentifier:(NSString *)identifier forRemoteNotification:(NSDictionary *)userInfo completionHandler:(void(^)())completionHandler
{
    //handle the actions
    if ([identifier isEqualToString:@"declineAction"]){
    }
    else if ([identifier isEqualToString:@"answerAction"]){
    }
}

- (void)application:(UIApplication*)application didRegisterForRemoteNotificationsWithDeviceToken:(NSData*)deviceToken
{
    NSString* newToken = [deviceToken description];
    newToken = [newToken stringByTrimmingCharactersInSet:[NSCharacterSet characterSetWithCharactersInString:@"<>"]];
    
    NSString *token = [[NSUserDefaults standardUserDefaults] valueForKey:@"token"];
    if (token) {
        [[AFHTTPRequestOperationManager manager] POST:@"https://irl-backend.herokuapp.com/quickie/register_token" parameters:@{@"push_token" : newToken, @"token" : token} success:^(AFHTTPRequestOperation *operation, id responseObject) {
            [[NSUserDefaults standardUserDefaults] setObject:newToken forKey:@"pushToken"];
        } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
            //
        }];
    }
}

- (void)application:(UIApplication*)application didFailToRegisterForRemoteNotificationsWithError:(NSError*)error
{
    NSLog(@"Failed to get token, error: %@", error);
    if (![[NSUserDefaults standardUserDefaults] boolForKey:@"noNotifications"]) {
        UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"Push Notifications" message:@"You need push notifications to be able to receive quickies from your friends! Please Allow notifications for Quickie in Settings!" delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:@"Go to Settings", @"I don't want to receive quickies", nil];
        alert.delegate = self;
        [alert show];
    }
}


-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{
    if (buttonIndex == 1) {
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:UIApplicationOpenSettingsURLString]];
    } else if (buttonIndex == 2){
        [[NSUserDefaults standardUserDefaults] setBool:YES forKey:@"noNotifications"];
    }
}

- (void)applicationWillResignActive:(UIApplication *)application {
    [[NSUserDefaults standardUserDefaults] setBool:NO forKey:@"calling"];
    [self.choiceVC notifyOnline];
}

- (void)applicationWillEnterForeground:(UIApplication *)application {
    [self.choiceVC downloadLastRequest];
    [UIApplication sharedApplication].applicationIconBadgeNumber = 0;
    Mixpanel *mixpanel = [Mixpanel sharedInstance];
    [mixpanel.people increment:@"app opens" by:@1];

}

@end
