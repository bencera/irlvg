//
//  ViewController.m
//  Hello-World
//
//  Copyright (c) 2013 TokBox, Inc. All rights reserved.
//

#import "NewSubscribeViewController.h"
#import <OpenTok/OpenTok.h>
#import "AFNetworking.h"
#import <QuartzCore/QuartzCore.h>
#import "Mixpanel.h"
#import "AppDelegate.h"
#import "MyAudioDevice.h"

@interface NewSubscribeViewController () <OTSessionDelegate, OTSubscriberKitDelegate, OTPublisherDelegate>

@property (nonatomic) CAShapeLayer *circle;
@property (nonatomic) UILabel *label;
@property (nonatomic) NSTimer *callingTimer;
@property int calling_time;
@property BOOL backCamera;
@property BOOL connectionHasBeenConnected;
@property (nonatomic) UILabel* quickieTimer;
@property (nonatomic) UIImageView *waitingIcon;
@property (nonatomic) NSTimer *quickierNSTimer;
@property (nonatomic) NSTimer *updateCountNSTimer;
@property BOOL videoReceived;
@property BOOL otherReceivedVideo;
@property (nonatomic) OTSession* session;
@property (nonatomic) OTPublisher* publisher;
@property (nonatomic) OTSubscriber* subscriber;
@property (nonatomic) UILabel *quickieAsk;
@property (nonatomic) CAShapeLayer *acceptCircle;
@property (nonatomic) UIButton *acceptButton;
@property (nonatomic) UIButton *skipButton;
@property (nonatomic) UILabel *name;
@property BOOL arbitrary_caller;

@end

@implementation NewSubscribeViewController {

    MyAudioDevice* _myAudioDevice;
}

@synthesize user_id;
@synthesize username;
@synthesize calling;
@synthesize session_id;
@synthesize session_token;
@synthesize duration;
@synthesize missed_call;
@synthesize tryitout;


static NSString* const kApiKey = @"45159522";

#pragma mark - View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    
    NSLog(@"%@", [self.username lowercaseString]);
    NSLog(@"%@", [[[NSUserDefaults standardUserDefaults] valueForKey:@"username"] lowercaseString]);
    
    NSString *username1 = [[[NSUserDefaults standardUserDefaults] valueForKey:@"username"]lowercaseString];
    NSString *username2 = [self.username lowercaseString];
    
    if (self.tryitout && ![username1 isEqualToString:@"benc"]) {
        username2 = @"benc";
    }
    
    if ([username1 compare:username2] == NSOrderedAscending) {
        self.arbitrary_caller = YES;
        NSLog(@"caller!");
    } else{
        self.arbitrary_caller = NO;
        NSLog(@"not caller!");
    }
    
    
    self.view.backgroundColor = [UIColor colorWithRed:249/255.f green:139/255.f blue:61/255.f alpha:1.f];
    
    self.waitingIcon = [[UIImageView alloc]init];
    self.waitingIcon.frame = CGRectMake((self.view.bounds.size.width - 50)/2, 80 + (self.view.bounds.size.height - 80 - 200 - 75)/2, 50, 75);
    self.waitingIcon.image = [UIImage imageNamed:@"bolt_forcalls"];
    [self.view addSubview:self.waitingIcon];
    
    if (missed_call) {
        [self loadConfirmCallObjects];
    } else if (calling) {
        [self loadSessionIdAndTokenAndCallFriend];
    } else{
        [self loadQuickieCallObjects];
    }
}

-(UIStatusBarStyle)preferredStatusBarStyle{
    return UIStatusBarStyleLightContent;
}


-(void)viewDidAppear:(BOOL)animated{
    if (!missed_call) {
        [self runSpinAnimationOnView:self.waitingIcon duration:1 rotations:1 repeat:99];
    }
}

-(void)loadConfirmCallObjects{
    self.quickieAsk = [[UILabel alloc]init];
    self.quickieAsk.frame = CGRectMake(0, 40, self.view.bounds.size.width, 140);
    self.quickieAsk.text = [NSString stringWithFormat:@"MISSED\n%@s QUICKIE\nW/ %@", duration, [self.username uppercaseString]];
    self.quickieAsk.font = [UIFont fontWithName:@"DINCond-Bold" size:40.f];
    self.quickieAsk.numberOfLines = 3;
    self.quickieAsk.textColor = [UIColor whiteColor];
    self.quickieAsk.backgroundColor = [UIColor clearColor];
    self.quickieAsk.layer.zPosition = 103;
    self.quickieAsk.textAlignment = NSTextAlignmentCenter;
    [self.view addSubview:self.quickieAsk];
    
    int radius = 75;
    self.acceptCircle = [CAShapeLayer layer];
    self.acceptCircle.path = [UIBezierPath bezierPathWithRoundedRect:CGRectMake(0, 0, 2.0*radius, 2.0*radius)
                                                  cornerRadius:radius].CGPath;
    self.acceptCircle.position = CGPointMake((self.view.bounds.size.width - 150)/2, self.view.bounds.size.height - 200);
    self.acceptCircle.fillColor = [UIColor colorWithRed:255/255.f green:255/255.f blue:0 alpha:1.f].CGColor;
    self.acceptCircle.strokeColor = [UIColor clearColor].CGColor;
    self.acceptCircle.lineWidth = 5;
    self.acceptCircle.zPosition = 100;
    [self.view.layer addSublayer:self.acceptCircle];
    
    self.acceptButton = [[UIButton alloc]init];
    self.acceptButton.frame = CGRectMake((self.view.bounds.size.width - 150)/2, self.view.bounds.size.height - 200, 150, 150);
    [self.acceptButton setTitle:@"CALL BACK" forState:UIControlStateNormal];
    [self.acceptButton setTitleColor:[UIColor colorWithRed:249/255.f green:139/255.f blue:61/255.f alpha:1.f] forState:UIControlStateNormal];
    self.acceptButton.titleLabel.font = [UIFont fontWithName:@"DINCond-Bold" size:35.f];
    self.acceptButton.layer.zPosition = 101;
    self.acceptButton.backgroundColor = [UIColor clearColor];
    [self.acceptButton addTarget:self action:@selector(callBack) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:self.acceptButton];
    

    self.skipButton = [UIButton buttonWithType:UIButtonTypeCustom];
    self.skipButton.frame = CGRectMake(0, self.view.bounds.size.height - 50, self.view.bounds.size.width, 50);
    self.skipButton.backgroundColor = [UIColor clearColor];
    [self.skipButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [self.skipButton setTitle:@"  ignore >" forState:UIControlStateNormal];
    self.skipButton.titleLabel.font = [UIFont fontWithName:@"DINCond-Bold" size:18.f];
    [self.skipButton addTarget:self action:@selector(ignoreMissedCall) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:self.skipButton];

}

-(void)loadQuickieCallObjects{
    _myAudioDevice = [[MyAudioDevice alloc] init];
    [OTAudioDeviceManager setAudioDevice:_myAudioDevice];
    
    _session = [[OTSession alloc] initWithApiKey:kApiKey
                                       sessionId:session_id
                                        delegate:self];
    
    [self doConnect];
    
    self.name = [[UILabel alloc]init];
    self.name.frame = CGRectMake(0, 20, self.view.bounds.size.width, 60.f);
    if (calling) {
        self.name.text = [NSString stringWithFormat:@"CALLING %@...",[self.username uppercaseString]];
    } else{
        self.name.text = @"CONNECTING...";
    }
    self.name.font = [UIFont fontWithName:@"DINCond-Regular" size:40.f];
    self.name.textColor = [UIColor whiteColor];
    self.name.backgroundColor = [UIColor clearColor];
    self.name.layer.zPosition = 103;
    self.name.textAlignment = NSTextAlignmentCenter;
    [self.view addSubview:self.name];
    
    int radius = 75;
    self.circle = [CAShapeLayer layer];
    self.circle.path = [UIBezierPath bezierPathWithRoundedRect:CGRectMake(0, 0, 2.0*radius, 2.0*radius)
                                                  cornerRadius:radius].CGPath;
    self.circle.position = CGPointMake((self.view.bounds.size.width - 150)/2, self.view.bounds.size.height - 200);
    self.circle.fillColor = [UIColor clearColor].CGColor;
    self.circle.strokeColor = [UIColor colorWithRed:249/255.f green:139/255.f blue:61/255.f alpha:1.f].CGColor;
    self.circle.lineWidth = 5;
    self.circle.zPosition = 100;
    self.circle.hidden = YES;
    [self.view.layer addSublayer:self.circle];
    
    self.quickieTimer = [[UILabel alloc]init];
    self.quickieTimer.frame = CGRectMake((self.view.bounds.size.width - 150)/2, self.view.bounds.size.height - 200, 150, 150);
    self.quickieTimer.text = duration;
    self.quickieTimer.layer.zPosition = 101;
    self.quickieTimer.textColor = [UIColor whiteColor];
    self.quickieTimer.textAlignment = NSTextAlignmentCenter;
    self.quickieTimer.backgroundColor = [UIColor clearColor];
    self.quickieTimer.font = [UIFont fontWithName:@"DINCond-Regular" size:40.f];
    [self.view addSubview:self.quickieTimer];
    
    UIButton *closeButton = [UIButton buttonWithType:UIButtonTypeCustom];
    closeButton.frame = CGRectMake(10, self.view.bounds.size.height - 60, 50.f, 50.f);
    [closeButton setImage:[UIImage imageNamed:@"close"] forState:UIControlStateNormal];
    closeButton.layer.zPosition = 100;
    [closeButton addTarget:self action:@selector(NotifiyStopCall) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:closeButton];
    
    UIButton *cameraButton = [UIButton buttonWithType:UIButtonTypeCustom];
    cameraButton.frame = CGRectMake(self.view.bounds.size.width - 60.f, self.view.bounds.size.height - 60.f, 50.f, 50.f);
    [cameraButton setImage:[UIImage imageNamed:@"rotatecamera"] forState:UIControlStateNormal];
    cameraButton.layer.zPosition = 100;
    [cameraButton addTarget:self action:@selector(SwitchCamera) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:cameraButton];
    
    [self mixpanelTrackCall];
}

-(void)callBack{
    self.acceptButton.userInteractionEnabled = NO;
    self.quickieAsk.hidden = YES;
    self.acceptCircle.hidden = YES;
    self.acceptButton.hidden = YES;
    self.skipButton.hidden = YES;
    [self runSpinAnimationOnView:self.waitingIcon duration:1 rotations:1 repeat:99];
    [self loadSessionIdAndTokenAndCallFriend];
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

-(void)mixpanelTrackCall{
    Mixpanel *mixpanel = [Mixpanel sharedInstance];
    [mixpanel track:@"quickie"];
}


-(void)mixpanelTrackCallEnded{
    Mixpanel *mixpanel = [Mixpanel sharedInstance];
    [mixpanel track:@"call ended before end"];
}

#pragma mark - HTTP Requests

-(void)loadSessionIdAndTokenAndCallFriend{
    [[AFHTTPRequestOperationManager manager] POST:@"https://irl-backend.herokuapp.com/quickie/call_friend" parameters:@{@"user_id" : user_id, @"duration" : self.duration,  @"token" : [[NSUserDefaults standardUserDefaults] valueForKey:@"token"], @"tryitout" : [NSString stringWithFormat:@"%@",[NSNumber numberWithBool:self.tryitout]]} success:^(AFHTTPRequestOperation *operation, id responseObject) {
        //
        session_id = responseObject[@"session_id"];
        session_token = responseObject[@"session_token"];
        [self loadQuickieCallObjects];
        self.callingTimer = [NSTimer scheduledTimerWithTimeInterval:20.f target:self selector:@selector(missedCall) userInfo:nil repeats:NO];
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        //
    }];
}

-(void)SendMissedCallToUser:(NSString *)user_idd{
    [[AFHTTPRequestOperationManager manager] POST:@"https://irl-backend.herokuapp.com/quickie/missed_call" parameters:@{@"token" : [[NSUserDefaults standardUserDefaults] valueForKey:@"token"], @"user_id" : user_idd} success:^(AFHTTPRequestOperation *operation, id responseObject) {
        //
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        //
    }];
}

-(void)endRequestWithUser:(NSString *)user_idd{
    [[AFHTTPRequestOperationManager manager] POST:@"https://irl-backend.herokuapp.com/quickie/end_request" parameters:@{@"token" : [[NSUserDefaults standardUserDefaults] valueForKey:@"token"], @"user_id" : user_idd} success:^(AFHTTPRequestOperation *operation, id responseObject) {
        //
        [[(AppDelegate*)[[UIApplication sharedApplication] delegate] choiceVC] downloadLastRequest];
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        //
    }];
}

-(void)SwitchCamera{
    if (self.backCamera) {
        _publisher.cameraPosition = AVCaptureDevicePositionFront;
        self.backCamera = NO;
    } else{
        _publisher.cameraPosition = AVCaptureDevicePositionBack;
        self.backCamera = YES;
    }
}

-(void)updateQuickieTimer{
    self.calling_time -= 1;
    self.quickieTimer.text = [NSString stringWithFormat:@"%d", self.calling_time];
}

#pragma Call Logic

-(void)ignoreMissedCall{
    [self endRequestWithUser:self.user_id];
    [[NSUserDefaults standardUserDefaults] setBool:NO forKey:@"calling"];
    [self dismissViewControllerAnimated:NO completion:nil];
}

-(void)missedCall{
    [self stopCall];
    [[(AppDelegate*)[[UIApplication sharedApplication] delegate] choiceVC] showAlertNotAvailable:username];
}

-(void)startCall{
    
    if (self.circle.hidden) {
        [self.circle removeAllAnimations];
        [self.quickierNSTimer invalidate];
        self.quickierNSTimer = nil;
        
        [self.updateCountNSTimer invalidate];
        self.updateCountNSTimer = nil;
        
        self.circle.hidden = NO;
        
        self.quickieTimer.text = duration;
        
        CABasicAnimation *drawAnimation = [CABasicAnimation animationWithKeyPath:@"strokeEnd"];
        drawAnimation.duration            = [duration intValue];
        drawAnimation. repeatCount         = 1.0;
        drawAnimation.fromValue = [NSNumber numberWithFloat:0.0f];
        drawAnimation.toValue   = [NSNumber numberWithFloat:1.0f];
        drawAnimation.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionLinear];
        [self.circle addAnimation:drawAnimation forKey:@"drawCircleAnimation"];
        
        self.quickierNSTimer = [NSTimer scheduledTimerWithTimeInterval:[duration intValue] target:self selector:@selector(stopCall) userInfo:nil repeats:NO];
        
        self.calling_time = [duration intValue];
        
        self.updateCountNSTimer = [NSTimer scheduledTimerWithTimeInterval:1.f target:self selector:@selector(updateQuickieTimer) userInfo:nil repeats:YES];
    }
}

-(void)NotifiyStopCall{
    [self mixpanelTrackCallEnded];
    OTError* error = nil;
    [_session signalWithType:@"" string:@"stop_call" connection:nil error:&error];
    if (error) {
        NSLog(@"signal error %@", error);
    } else {
        [self stopCall];
    }
}

-(void)stopCall{
    
    [self.callingTimer invalidate];
    self.callingTimer = nil;
    
    if (self.videoReceived || self.tryitout) {
        [self endRequestWithUser:self.user_id];
    } else {
        [self SendMissedCallToUser:self.user_id];
    }
    
    [[NSUserDefaults standardUserDefaults] setBool:NO forKey:@"calling"];
    
    [self dismissViewControllerAnimated:NO completion:^{
        [_session unpublish:_publisher error:nil];
        [_session unsubscribe:_subscriber error:nil];
        [_session disconnect:nil];
        [self deallocateObjects];
    }];
}

-(void)deallocateObjects{
    NSLog(@"dealloc");
    _session.delegate = nil;
    _subscriber.delegate = nil;
    _publisher.delegate = nil;
    _session = nil;
    _publisher = nil;
    _subscriber = nil;
    [OTAudioDeviceManager setAudioDevice:nil];
    _myAudioDevice = nil;
    AVAudioSession *mySession = [AVAudioSession sharedInstance];
    [mySession setCategory:AVAudioSessionCategorySoloAmbient error:nil];
}


#pragma mark - OpenTok methods

/** 
 * Asynchronously begins the session connect process. Some time later, we will
 * expect a delegate method to call us back with the results of this action.
 */
- (void)doConnect
{
    NSLog(@"do connect");
    OTError *error = nil;
    
    [_session connectWithToken:session_token error:&error];
    if (error)
    {
        //[self showAlert:[error localizedDescription]];
    }
}

/**
 * Sets up an instance of OTPublisher to use with this session. OTPubilsher
 * binds to the device camera and microphone, and will provide A/V streams
 * to the OpenTok session.
 */
- (void)doPublish
{
    
    NSLog(@"do publish");
    _publisher =
    [[OTPublisher alloc] initWithDelegate:self
                                     name:[[UIDevice currentDevice] name]];
   
    OTError *error = nil;
    [_session publish:_publisher error:&error];
    if (error)
    {
        //[self showAlert:[error localizedDescription]];
    }
    
    [self.view addSubview:_publisher.view];
    _publisher.view.userInteractionEnabled = NO;
    _publisher.view.layer.zPosition = 99;
    _publisher.view.layer.cornerRadius = 75;
    _publisher.view.layer.masksToBounds = YES;
    [_publisher.view setFrame:CGRectMake((self.view.bounds.size.width - 150)/2, self.view.bounds.size.height - 200, 150, 150)];
}


- (void)cleanupPublisher {
    [_publisher.view removeFromSuperview];
    _publisher = nil;
    // this is a good place to notify the end-user that publishing has stopped.
}

/**
 * Instantiates a subscriber for the given stream and asynchronously begins the
 * process to begin receiving A/V content for this stream. Unlike doPublish, 
 * this method does not add the subscriber to the view hierarchy. Instead, we 
 * add the subscriber only after it has connected and begins receiving data.
 */

- (void)doSubscribe:(OTStream*)stream
{
    NSLog(@"do subscribe");
    _subscriber = [[OTSubscriber alloc] initWithStream:stream delegate:self];
    
    OTError *error = nil;
    [_session subscribe:_subscriber error:&error];
    if (error)
    {
       // [self showAlert:[error localizedDescription]];
    }
}

/**
 * Cleans the subscriber from the view hierarchy, if any.
 * NB: You do *not* have to call unsubscribe in your controller in response to
 * a streamDestroyed event. Any subscribers (or the publisher) for a stream will
 * be automatically removed from the session during cleanup of the stream.
 */
- (void)cleanupSubscriber
{
    [_subscriber.view removeFromSuperview];
    _subscriber = nil;
}

- (void)sessionDidConnect:(OTSession*)session
{
    NSLog(@"sessionDidConnect (%@)", session.sessionId);
    

    
    // Step 2: We have successfully connected, now instantiate a publisher and
    // begin pushing A/V streams into OpenTok.
    [self doPublish];
    
}

- (void)sessionDidDisconnect:(OTSession*)session
{
    NSString* alertMessage =
    [NSString stringWithFormat:@"Session disconnected: (%@)",
     session.sessionId];
    NSLog(@"sessionDidDisconnect (%@)", alertMessage);
}


- (void)session:(OTSession*)mySession
  streamCreated:(OTStream *)stream
{
    NSLog(@"session streamCreated (%@)", stream.streamId);

    // Step 3a: (if NO == subscribeToSelf): Begin subscribing to a stream we
    // have seen on the OpenTok session.
    if (nil == _subscriber) {
        [self doSubscribe:stream];
    }
}

- (void)session:(OTSession*)session
streamDestroyed:(OTStream *)stream
{
    NSLog(@"session streamDestroyed (%@)", stream.streamId);
    
    if ([_subscriber.stream.streamId isEqualToString:stream.streamId])
    {
        [self cleanupSubscriber];
    }
}

- (void)  session:(OTSession *)session
connectionCreated:(OTConnection *)connection
{
    NSLog(@"session connectionCreated (%@)", connection.connectionId);
    self.connectionHasBeenConnected = YES;
    self.name.text = @"CONNECTING...";
    [self.callingTimer invalidate];
    self.callingTimer = nil;
}

- (void)    session:(OTSession *)session
connectionDestroyed:(OTConnection *)connection
{
    NSLog(@"session connectionDestroyed (%@)", connection.connectionId);
    if ([_subscriber.stream.connection.connectionId
         isEqualToString:connection.connectionId])
    {
        [self cleanupSubscriber];
    }
}

- (void) session:(OTSession*)session
didFailWithError:(OTError*)error
{
    NSLog(@"didFailWithError: (%@)", error);
}

-(void)session:(OTSession *)session receivedSignalType:(NSString *)type fromConnection:(OTConnection *)connection withString:(NSString *)string{
    if ([string isEqualToString:@"received_video"]) {
        self.otherReceivedVideo = YES;
    } else if ([string isEqualToString:@"start_call"]) {
        [self startCall];
    } else if ([string isEqualToString:@"stop_call"]){
        [self stopCall];
    }
}

- (void)subscriberVideoDataReceived:(OTSubscriber *)subscriber{
    NSLog(@"RECEIVED");
    
    if (!self.videoReceived & !self.arbitrary_caller) {
        self.name.text = [self.username uppercaseString];
        self.videoReceived = YES;
        OTError* error = nil;
        [_session signalWithType:@"" string:@"received_video" connection:nil error:&error];
        if (error) {
            NSLog(@"signal error %@", error);
        }
    } else if (self.arbitrary_caller && !self.videoReceived && self.otherReceivedVideo){
        self.name.text = [self.username uppercaseString];
        self.videoReceived = YES;
        OTError* error = nil;
        [_session signalWithType:@"" string:@"start_call" connection:nil error:&error];
        if (error) {
            NSLog(@"signal error %@", error);
        }
    }
}


- (void)subscriberDidConnectToStream:(OTSubscriberKit*)subscriber
{
    if (_subscriber.view.userInteractionEnabled) {
        NSLog(@"subscriberDidConnectToStream (%@)",
              subscriber.stream.connection.connectionId);
        assert(_subscriber == subscriber);
        [_subscriber.view setFrame:self.view.bounds];
        _subscriber.view.userInteractionEnabled = NO;
        _subscriber.subscribeToAudio = YES;
        [self.view addSubview:_subscriber.view];
    }
}

- (void)subscriber:(OTSubscriberKit*)subscriber
  didFailWithError:(OTError*)error
{
    NSLog(@"subscriber %@ didFailWithError %@",
          subscriber.stream.streamId,
          error);
}

- (void)publisher:(OTPublisherKit *)publisher
    streamCreated:(OTStream *)stream
{

}

- (void)publisher:(OTPublisherKit*)publisher
  streamDestroyed:(OTStream *)stream
{
    NSLog(@"stream destroyed");
    if ([_subscriber.stream.streamId isEqualToString:stream.streamId])
    {
        [self cleanupSubscriber];
    }

    [self cleanupPublisher];
}

- (void)publisher:(OTPublisherKit*)publisher
 didFailWithError:(OTError*) error
{
    NSLog(@"publisher didFailWithError %@", error);
    [self cleanupPublisher];
}

@end
