//
//  ViewController.m
//  OTMoviePlayer
//
//  Copyright (c) 2015 TokBox, Inc. All rights reserved.
//

#import "SubscribeViewController.h"
#import "OTMoviePlayer.h"
#import <MediaPlayer/MediaPlayer.h>
#import <MobileCoreServices/UTCoreTypes.h>
#import <AssetsLibrary/AssetsLibrary.h>
#import "FayeClient.h"
#import "ControlsViewController.h"
#import "CommentsViewController.h"

@interface SubscribeViewController () <OTSessionDelegate, OTPublisherDelegate, OTSubscriberKitDelegate,FayeClientDelegate>

@property (strong,nonatomic) FayeClient *client;
@property (nonatomic) UIButton *forwardB;
@property (nonatomic) UIButton *backwardB;
@property (nonatomic) UIButton *leftB;
@property (nonatomic) UIButton *rightB;
@property (nonatomic) UIButton *action1B;
@property (nonatomic) UIButton *action2B;
@property (nonatomic) UIScrollView *scrollView;
@property (nonatomic) UIView *movieSupportingView;


@end

static NSString* myApiKey = @"45159522";
static NSString* mySessionId = @"1_MX40NTE1OTUyMn5-MTQyNDQ1OTgyNTM1MX5yL2VrUENYSVlhLzZORkFRRy93MDZrdmZ-fg";
static NSString* myToken = @"T1==cGFydG5lcl9pZD00NTE1OTUyMiZzaWc9NDE1NTI2YzJiYmQ3NjU4ZjkyOWFjNTFiY2EzNWM4Y2JjOTI1YjI5MDpyb2xlPXN1YnNjcmliZXImc2Vzc2lvbl9pZD0xX01YNDBOVEUxT1RVeU1uNS1NVFF5TkRRMU9UZ3lOVE0xTVg1eUwyVnJVRU5ZU1ZsaEx6Wk9Sa0ZSUnk5M01EWnJkbVotZmcmY3JlYXRlX3RpbWU9MTQyNDQ1OTg3NCZub25jZT0wLjAxMTQyMzk3MDI5MjY5NTgxOCZleHBpcmVfdGltZT0xNDI3MDUxNzYw";

static OTMoviePlayer* moviePlayer = nil;

@implementation SubscribeViewController {
    OTSession* mySession;
    OTPublisher* myPublisher;
    OTSubscriber* mySubscriber;
}

- (void) startMovie:(NSURL*) movieUrl
{
    moviePlayer = [[OTMoviePlayer alloc] init];
    moviePlayer.loop = YES;
    [moviePlayer loadMovieAssets:movieUrl];
    
    [OTAudioDeviceManager setAudioDevice:moviePlayer.audioDevice];
    
    mySession = [[OTSession alloc] initWithApiKey:myApiKey
                                        sessionId:mySessionId
                                         delegate:self];
    [mySession connectWithToken:myToken error:nil];
}

-(void)viewWillDisappear:(BOOL)animated{
    NSLog(@"will disappear");
    
    [mySubscriber.view removeFromSuperview];
    [mySubscriber release];
    mySubscriber = nil;
    
    [mySession release];
    mySession = nil;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self ConnectToFaye];
    
    self.view.backgroundColor = [UIColor whiteColor];
    
    _movieSupportingView = [[UIView alloc] init];
    _movieSupportingView.frame = self.view.bounds;
    [self.view addSubview:_movieSupportingView];
    
    NSURL *movieUrl=[[NSBundle mainBundle]
                     URLForResource:@"OpenTok" withExtension:@"mp4"];
    
    
    [self startMovie:movieUrl];

    
    [self addScrollView];
    
}

-(void)back{
    [self.navigationController popToRootViewControllerAnimated:YES];
}

-(void)ConnectToFaye{
    self.client = [[FayeClient alloc]initWithURLString:@"ws://irl-faye.herokuapp.com/faye" channel:@"/test"];
    self.client.delegate = self;
    
    [self.client connectToServer];
}

- (void)subscribeToStream:(OTStream*)stream {
    if (nil == mySubscriber) {
        mySubscriber = [[OTSubscriber alloc] initWithStream:stream
                                                   delegate:self];
        [mySession subscribe:mySubscriber error:nil];
        
        mySubscriber.view.frame = self.view.frame;
        [_movieSupportingView addSubview:mySubscriber.view];
        
    }
}

-(void)addScrollView{
    _scrollView = [[UIScrollView alloc]init];
    _scrollView.frame = self.view.bounds;
    _scrollView.contentSize = CGSizeMake(self.view.bounds.size.width * 2, 1);
    _scrollView.bounces = NO;
    _scrollView.pagingEnabled = YES;
    _scrollView.layer.zPosition = 99;
    [self.view addSubview:_scrollView];
    
    ControlsViewController *controlsVC = [[ControlsViewController alloc]init];
    controlsVC.client = self.client;
    controlsVC.subVC = self;
    controlsVC.view.frame = CGRectMake(0, 0, self.view.bounds.size.width, self.view.bounds.size.height);
    controlsVC.view.layer.zPosition = 99;
    [_scrollView addSubview:controlsVC.view];
    
    CommentsViewController *commentsVC = [[CommentsViewController alloc]init];
    commentsVC.view.frame = CGRectMake(self.view.bounds.size.width, 0, self.view.bounds.size.width, self.view.bounds.size.height);
    commentsVC.subVC = self;
    commentsVC.view.layer.zPosition = 99;
    [_scrollView addSubview:commentsVC.view];
}

-(void)goToComments{
    [_scrollView scrollRectToVisible:CGRectMake(self.view.bounds.size.width, 0, self.view.bounds.size.width, 1) animated:YES];
}

-(void)backToGame{
    [_scrollView scrollRectToVisible:CGRectMake(0, 0, self.view.bounds.size.width, 1) animated:YES];
}

- (void)sessionDidConnect:(OTSession*)session {
    NSLog(@"session did connect");
}

- (void)sessionDidDisconnect:(OTSession*)session {
    NSLog(@"session did disconnect");
}

- (void)session:(OTSession*)session didFailWithError:(OTError*)error {
    NSLog(@"session did fail");
}

- (void)session:(OTSession*)session streamCreated:(OTStream*)stream {
    [self subscribeToStream:stream];
    
}

- (void)session:(OTSession*)session streamDestroyed:(OTStream*)stream {
    if ([mySubscriber.stream.streamId isEqualToString:stream.streamId]) {
        [mySubscriber.view removeFromSuperview];
        [mySubscriber release];
        mySubscriber = nil;
    }
}

- (void)   session:(OTSession*)session
receivedSignalType:(NSString*)type
    fromConnection:(OTConnection*)connection
        withString:(NSString*)string
{
    NSLog(@"session did receive signal");
}

- (void) session:(OTSession*) session connectionCreated:(OTConnection*) connection
{
    NSLog(@"session connection created");
}

- (void) session:(OTSession*)session connectionDestroyed:(OTConnection*) connection {
    NSLog(@"session connection destroyed");
}

- (void)publisher:(OTPublisherKit *)publisher streamCreated:(OTStream *)stream
{
    NSLog(@"stream created");
}

- (void)publisher:(OTPublisherKit *)publisher streamDestroyed:(OTStream *)stream
{
    if ([mySubscriber.stream.streamId isEqualToString:stream.streamId]) {
        [mySubscriber.view removeFromSuperview];
        [mySubscriber release];
        mySubscriber = nil;
    }
}

- (void)publisher:(OTPublisherKit*)publisher didFailWithError:(OTError*)error {
    NSLog(@"publisher error!");
}

- (void)subscriberDidConnectToStream:(OTSubscriberKit*)subscriber {
    [subscriber.stream addObserver:self
                        forKeyPath:@"videoDimensions"
                           options:NSKeyValueObservingOptionNew
                           context:NULL];
    [subscriber.stream addObserver:self
                        forKeyPath:@"hasVideo"
                           options:NSKeyValueObservingOptionNew
                           context:NULL];
    [subscriber.stream addObserver:self
                        forKeyPath:@"hasAudio"
                           options:NSKeyValueObservingOptionNew
                           context:NULL];
    
}

- (void)subscriber:(OTSubscriberKit*)subscriber
  didFailWithError:(OTError*)error
{
    
}

- (void)subscriberVideoDataReceived:(OTSubscriberKit *)subscriber {
    
}


- (void)observeValueForKeyPath:(NSString *)keyPath
                      ofObject:(id)object
                        change:(NSDictionary *)change
                       context:(void *)context
{
    NSLog(@"ViewController: observeValueForKeyPath %@ ofObject %@"
          " change %@ context %p",
          keyPath, [object description], change, context);
    if ([@"videoDimensions" isEqualToString:keyPath]) {

    } else if ([@"hasVideo" isEqualToString:keyPath]) {
        BOOL value = [[change valueForKey:@"new"] boolValue];
        [mySubscriber setSubscribeToVideo:value];
    }
    
}

- (NSUInteger)supportedInterfaceOrientations
{
    return UIInterfaceOrientationMaskAll;
}


- (BOOL)shouldAutorotate {
    return NO;
}

#pragma mark - Faye

-(void)messageReceived:(NSDictionary *)messageDict channel:(NSString *)channel{
    
    NSLog(@"%@", messageDict);
}

- (void)connectedToServer{
    NSLog(@"connected");
    
}
- (void)disconnectedFromServer{
    NSLog(@"disconnected from server");
}
- (void)connectionFailed
{
    NSLog(@"connection failed!");
}

- (void)didSubscribeToChannel:(NSString *)channel{
    NSLog(@"did sub");
    //[self.client sendMessage:@{@"test" : @"hello"} onChannel:@"/test"];
}

- (void)didUnsubscribeFromChannel:(NSString *)channel{
    NSLog(@"adfg");
}
- (void)subscriptionFailedWithError:(NSString *)error{
    NSLog(@"subscription Failed: %@", error.description);
}
- (void)fayeClientError:(NSError *)error{
    NSLog(@"%@", error.description);
}

#pragma mark - buttons

-(void)addButtons{
    _forwardB = [UIButton buttonWithType:UIButtonTypeCustom];
    _forwardB.frame = CGRectMake(80, self.view.bounds.size.height - 200, 20, 60);
    [_forwardB setBackgroundImage:[UIImage imageNamed:@"grey_frame"] forState:UIControlStateNormal];
    [_forwardB setBackgroundImage:[UIImage imageNamed:@"red_frame"] forState:UIControlStateSelected];
    [_forwardB addTarget:self action:@selector(forwardAction:) forControlEvents:UIControlEventTouchUpInside];
    _forwardB.layer.zPosition = 99;
    [self.view addSubview:_forwardB];
    
    _backwardB = [UIButton buttonWithType:UIButtonTypeCustom];
    _backwardB.frame = CGRectMake(80, self.view.bounds.size.height - 120, 20, 60);
    [_backwardB setBackgroundImage:[UIImage imageNamed:@"grey_frame"] forState:UIControlStateNormal];
    [_backwardB setBackgroundImage:[UIImage imageNamed:@"red_frame"] forState:UIControlStateSelected];
    [_backwardB addTarget:self action:@selector(backwardAction:) forControlEvents:UIControlEventTouchUpInside];
    _backwardB.layer.zPosition = 99;
    [self.view addSubview:_backwardB];
    
    _leftB = [UIButton buttonWithType:UIButtonTypeCustom];
    _leftB.frame = CGRectMake(20, self.view.bounds.size.height - 140, 60, 20);
    [_leftB setBackgroundImage:[UIImage imageNamed:@"vertical_grey"] forState:UIControlStateNormal];
    [_leftB setBackgroundImage:[UIImage imageNamed:@"vertical_red"] forState:UIControlStateSelected];
    [_leftB addTarget:self action:@selector(leftAction:) forControlEvents:UIControlEventTouchUpInside];
    _leftB.layer.zPosition = 99;
    [self.view addSubview:_leftB];
    
    _rightB = [UIButton buttonWithType:UIButtonTypeCustom];
    _rightB.frame = CGRectMake(20 + 80, self.view.bounds.size.height - 140, 60, 20);
    [_rightB setBackgroundImage:[UIImage imageNamed:@"vertical_grey"] forState:UIControlStateNormal];
    [_rightB setBackgroundImage:[UIImage imageNamed:@"vertical_red"] forState:UIControlStateSelected];
    [_rightB addTarget:self action:@selector(rightAction:) forControlEvents:UIControlEventTouchUpInside];
    _rightB.layer.zPosition = 99;
    [self.view addSubview:_rightB];
    
    _action1B = [UIButton buttonWithType:UIButtonTypeCustom];
    _action1B.frame = CGRectMake(20 + 170, self.view.bounds.size.height - 140, 40, 40);
    [_action1B setBackgroundImage:[UIImage imageNamed:@"vertical_grey"] forState:UIControlStateNormal];
    [_action1B setBackgroundImage:[UIImage imageNamed:@"vertical_red"] forState:UIControlStateSelected];
    [_action1B addTarget:self action:@selector(action1Action:) forControlEvents:UIControlEventTouchUpInside];
    _action1B.layer.zPosition = 99;
    [self.view addSubview:_action1B];
    
    _action2B = [UIButton buttonWithType:UIButtonTypeCustom];
    _action2B.frame = CGRectMake(20 + 220, self.view.bounds.size.height - 140, 40, 40);
    [_action2B setBackgroundImage:[UIImage imageNamed:@"vertical_grey"] forState:UIControlStateNormal];
    [_action2B setBackgroundImage:[UIImage imageNamed:@"vertical_red"] forState:UIControlStateSelected];
    [_action2B addTarget:self action:@selector(action2Action:) forControlEvents:UIControlEventTouchUpInside];
    _action2B.layer.zPosition = 99;
    [self.view addSubview:_action2B];
    
}


-(void)forwardAction:(UIButton*)button{
    button.selected = YES;
    _leftB.selected = NO;
    _rightB.selected = NO;
    _backwardB.selected = NO;
    _action1B.selected = NO;
    _action2B.selected = NO;
    [self.client sendMessage:@{@"action" : @"forward"} onChannel:@"/test"];
}

-(void)leftAction:(UIButton*)button{
    button.selected = YES;
    _forwardB.selected = NO;
    _rightB.selected = NO;
    _backwardB.selected = NO;
    _action1B.selected = NO;
    _action2B.selected = NO;
    [self.client sendMessage:@{@"action" : @"left"} onChannel:@"/test"];
}

-(void)rightAction:(UIButton*)button{
    button.selected = YES;
    _forwardB.selected = NO;
    _leftB.selected = NO;
    _backwardB.selected = NO;
    _action1B.selected = NO;
    _action2B.selected = NO;
    [self.client sendMessage:@{@"action" : @"right"} onChannel:@"/test"];
}

-(void)backwardAction:(UIButton*)button{
    button.selected = YES;
    _forwardB.selected = NO;
    _rightB.selected = NO;
    _leftB.selected = NO;
    _action1B.selected = NO;
    _action2B.selected = NO;
    [self.client sendMessage:@{@"action" : @"backward"} onChannel:@"/test"];
}

-(void)action1Action:(UIButton*)button{
    button.selected = YES;
    _forwardB.selected = NO;
    _rightB.selected = NO;
    _leftB.selected = NO;
    _backwardB.selected = NO;
    _action2B.selected = NO;
    [self.client sendMessage:@{@"action" : @"action1"} onChannel:@"/test"];
}

-(void)action2Action:(UIButton*)button{
    button.selected = YES;
    _forwardB.selected = NO;
    _leftB.selected = NO;
    _rightB.selected = NO;
    _backwardB.selected = NO;
    _action1B.selected = NO;
    [self.client sendMessage:@{@"action" : @"action2"} onChannel:@"/test"];
}


@end
