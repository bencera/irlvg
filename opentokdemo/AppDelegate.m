//
//  AppDelegate.m
//  opentokdemo
//
//  Created by Ben Cera on 2/19/15.
//  Copyright (c) 2015 Context Labs Inc. All rights reserved.
//

#import "AppDelegate.h"
#import "ChoiceViewController.h"
#import "HockeySDK.h"
//#import "SubscribeViewController.h"
#import "NewSubscribeViewController.h"
#import "ViewController.h"
#import "NameViewController.h"

@interface AppDelegate ()

@property (nonatomic) NewSubscribeViewController *choiceVC;

@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    // Override point for customization after application launch.
    
    [self configureHockey];
    
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    
    _choiceVC = [[NewSubscribeViewController alloc]init];
    self.window.rootViewController = _choiceVC;
    
    [self.window makeKeyAndVisible];
    
    if (![[NSUserDefaults standardUserDefaults] objectForKey:@"username"]) {
        NameViewController *nameVC = [[NameViewController alloc] init];
        UINavigationController *navVCintro = [[UINavigationController alloc]initWithRootViewController:nameVC];
        navVCintro.navigationBarHidden = YES;
        [_choiceVC presentViewController:navVCintro animated:NO completion:nil];
    }
    
    return YES;
}

- (void)configureHockey {
    [[BITHockeyManager sharedHockeyManager] configureWithIdentifier:@"0a0de10bbe379818942dcc056bc96a39"];
    [[BITHockeyManager sharedHockeyManager] startManager];
    [[[BITHockeyManager sharedHockeyManager] authenticator] authenticateInstallation];
}

- (void)applicationWillResignActive:(UIApplication *)application {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application {
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application {
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
    
    [_choiceVC.commentsVC downloadComments];
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

@end
