//
//  ViewController.m
//  Hello-World
//
//  Copyright (c) 2013 TokBox, Inc. All rights reserved.
//

#import "NewSubscribeViewController.h"
#import <OpenTok/OpenTok.h>
#import "ControlsViewController.h"
#import "CommentsViewController.h"
#import "InstructionModalViewController.h"
#import "TJWModalTransitionManager.h"
#import "TJWUser.h"
#import "TJWComment.h"
#import "FayeClient.h"
#import "AFNetworking.h"

@interface NewSubscribeViewController ()
<OTSessionDelegate, OTSubscriberKitDelegate, OTPublisherDelegate, CommentsViewControllerDelegate, UIScrollViewDelegate,FayeClientDelegate,ControlsViewControllerDelegate, UIViewControllerTransitioningDelegate>

@property (nonatomic) UIScrollView *scrollView;
@property (strong, nonatomic) FayeClient *client;
@property (strong, nonatomic) NSMutableArray *actionVotes;

@end

@implementation NewSubscribeViewController {
    OTSession* _session;
    OTPublisher* _publisher;
    OTSubscriber* _subscriber;
}

@synthesize commentsVC;
@synthesize controlsVC;

// *** Fill the following variables using your own Project info  ***
// ***          https://dashboard.tokbox.com/projects            ***
// Replace with your OpenTok API key
static NSString* const kApiKey = @"45159522";
// Replace with your generated session ID
static NSString* const kSessionId = @"2_MX40NTE1OTUyMn5-MTQyNDgwOTYyMDM4MX5OUTVzVkFpbmpkMkM5bVZ3M0hDaklqdnZ-fg";
// Subscriber
//static NSString* const kToken = @"T1==cGFydG5lcl9pZD00NTE1OTUyMiZzaWc9Yjk1ZjY5OGJlMTdkNjU5Y2JhYjI1NjU4ZGU0ZTQyNDgwNmNkYzQyYTpyb2xlPXN1YnNjcmliZXImc2Vzc2lvbl9pZD0yX01YNDBOVEUxT1RVeU1uNS1NVFF5TkRnd09UWXlNRE00TVg1T1VUVnpWa0ZwYm1wa01rTTViVlozTTBoRGFrbHFkblotZmcmY3JlYXRlX3RpbWU9MTQyNDgwOTgwMSZub25jZT0wLjE4NDEzMzU0OTM3NzIxNzUmZXhwaXJlX3RpbWU9MTQyNzQwMTU2OQ==";
// Publisher
static NSString* const kToken = @"T1==cGFydG5lcl9pZD00NTE1OTUyMiZzaWc9NmU5MjUzNTc1N2Y0M2EyOGQ3N2M1NWZlOTE2NWNlOWUyZTA0MTMzODpyb2xlPXB1Ymxpc2hlciZzZXNzaW9uX2lkPTJfTVg0ME5URTFPVFV5TW41LU1UUXlORGd3T1RZeU1ETTRNWDVPVVRWelZrRnBibXBrTWtNNWJWWjNNMGhEYWtscWRuWi1mZyZjcmVhdGVfdGltZT0xNDI0ODA5NjU5Jm5vbmNlPTAuMDAyMzI0ODI5MDMwODkyODE2NiZleHBpcmVfdGltZT0xNDI3NDAxNTY5";

// Change to NO to subscribe to streams other than your own.
static bool subscribeToSelf = NO;
static bool publishing = YES;

#pragma mark - View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    _actionVotes = [[NSMutableArray alloc] init];
    
    self.client = [[FayeClient alloc]initWithURLString:@"ws://irl-faye.herokuapp.com/faye" channel:@"/test"];
    self.client.delegate = self;
    [self.client connectToServer];
    
    // Step 1: As the view comes into the foreground, initialize a new instance
    // of OTSession and begin the connection process.
    _session = [[OTSession alloc] initWithApiKey:kApiKey
                                       sessionId:kSessionId
                                        delegate:self];
    [self doConnect];
    
    [self addScrollView];
    
    if (publishing) {
        [NSTimer scheduledTimerWithTimeInterval:6.0 target:self selector:@selector(voteCountAndDisplay) userInfo:nil repeats:YES];
    }

}

-(UIStatusBarStyle)preferredStatusBarStyle{
    return UIStatusBarStyleLightContent;
}

-(void)viewDidAppear:(BOOL)animated{
    [[AFHTTPRequestOperationManager manager] GET:@"https://irl-backend.herokuapp.com/is_streaming" parameters:nil success:^(AFHTTPRequestOperation *operation, id responseObject) {
        if ([responseObject[@"is_streaming"]intValue] == 0) {
            UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"Sorry" message:@"No broadcasting at the moment. We'll ping you when the suscriber turns back live!" delegate:self cancelButtonTitle:@"ok" otherButtonTitles:nil];
            [alert show];
        }
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        //
    }];
}

-(void)addScrollView{
    
    _scrollView = [[UIScrollView alloc]init];
    _scrollView.frame = self.view.bounds;
    _scrollView.contentSize = CGSizeMake(self.view.bounds.size.width * 2, 1);
    _scrollView.bounces = NO;
    _scrollView.pagingEnabled = YES;
    _scrollView.layer.zPosition = 99;
    _scrollView.delegate = self;
    _scrollView.showsHorizontalScrollIndicator = NO;
    _scrollView.showsVerticalScrollIndicator = NO;
    [self.view addSubview:_scrollView];
    
    self.controlsVC = [[ControlsViewController alloc]init];
    self.controlsVC.client = self.client;
    self.controlsVC.delegate = self;
    self.controlsVC.view.frame = CGRectMake(0, 0, self.view.bounds.size.width, self.view.bounds.size.height);
    self.controlsVC.view.layer.zPosition = 99;
    [_scrollView addSubview:self.controlsVC.view];
    
    self.commentsVC = [[CommentsViewController alloc]init];
    self.commentsVC.currentUser = [[TJWUser alloc] initWithName:[[NSUserDefaults standardUserDefaults] valueForKey:@"username"]];
    self.commentsVC.view.frame = CGRectMake(self.view.bounds.size.width, 0, self.view.bounds.size.width, self.view.bounds.size.height);
    
    self.commentsVC = commentsVC;
    self.commentsVC.delegate = self;
    //commentsVC.subVC = self;
    self.commentsVC.view.layer.zPosition = 99;
    [_scrollView addSubview:self.commentsVC.view];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:
(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    if (UIUserInterfaceIdiomPhone == [[UIDevice currentDevice]
                                      userInterfaceIdiom])
    {
        return NO;
    } else {
        return YES;
    }
}

#pragma mark - UIScrollViewDelegate

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    if (scrollView == self.scrollView) {
        [self.commentsVC resignKeyboard];

    }
}

#pragma mark - CommentsViewControllerDelegate


- (void)commentsController:(CommentsViewController *)controller didFinishTypingComment:(TJWComment *)comment {
    // PUSH COMMENT TO FAYE
    [self.client sendMessage:@{@"message" : comment.message, @"user" : comment.user.name} onChannel:@"/test"];
}

- (void)backButtonPressedFromCommentsController:(CommentsViewController *)controller {
    [self returnToGame];
}

- (void)returnToGame {
    [self.scrollView scrollRectToVisible:CGRectMake(0, 0, 1, 1) animated:YES];

}

#pragma mark - OpenTok methods

/** 
 * Asynchronously begins the session connect process. Some time later, we will
 * expect a delegate method to call us back with the results of this action.
 */
- (void)doConnect
{
    OTError *error = nil;
    
    [_session connectWithToken:kToken error:&error];
    if (error)
    {
        [self showAlert:[error localizedDescription]];
    }
}

/**
 * Sets up an instance of OTPublisher to use with this session. OTPubilsher
 * binds to the device camera and microphone, and will provide A/V streams
 * to the OpenTok session.
 */
- (void)doPublish
{
    
    _publisher =
    [[OTPublisher alloc] initWithDelegate:self
                                     name:[[UIDevice currentDevice] name]];
    _publisher.cameraPosition = AVCaptureDevicePositionBack;
   
    OTError *error = nil;
    [_session publish:_publisher error:&error];
    if (error)
    {
        [self showAlert:[error localizedDescription]];
    }
    
    [self.view addSubview:_publisher.view];
    _publisher.view.userInteractionEnabled = NO;
    [_publisher.view setFrame:self.view.bounds];
}

/**
 * Cleans up the publisher and its view. At this point, the publisher should not
 * be attached to the session any more.
 */
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
    _subscriber = [[OTSubscriber alloc] initWithStream:stream delegate:self];
    
    OTError *error = nil;
    [_session subscribe:_subscriber error:&error];
    if (error)
    {
        [self showAlert:[error localizedDescription]];
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

# pragma mark - OTSession delegate callbacks

- (void)sessionDidConnect:(OTSession*)session
{
    NSLog(@"sessionDidConnect (%@)", session.sessionId);
    
    // Step 2: We have successfully connected, now instantiate a publisher and
    // begin pushing A/V streams into OpenTok.
    if (publishing) {
        [self doPublish];
    }
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
    if (nil == _subscriber && !subscribeToSelf)
    {
        if (!publishing) {
            [self doSubscribe:stream];            
        }
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

# pragma mark - OTSubscriber delegate callbacks

- (void)subscriberDidConnectToStream:(OTSubscriberKit*)subscriber
{
    NSLog(@"subscriberDidConnectToStream (%@)",
          subscriber.stream.connection.connectionId);
    assert(_subscriber == subscriber);
    [_subscriber.view setFrame:self.view.bounds];
    _subscriber.view.userInteractionEnabled = NO;
    [self.view addSubview:_subscriber.view];
}

- (void)subscriber:(OTSubscriberKit*)subscriber
  didFailWithError:(OTError*)error
{
    NSLog(@"subscriber %@ didFailWithError %@",
          subscriber.stream.streamId,
          error);
}

# pragma mark - OTPublisher delegate callbacks

- (void)publisher:(OTPublisherKit *)publisher
    streamCreated:(OTStream *)stream
{
    
    NSLog(@"sub");
    // Step 3b: (if YES == subscribeToSelf): Our own publisher is now visible to
    // all participants in the OpenTok session. We will attempt to subscribe to
    // our own stream. Expect to see a slight delay in the subscriber video and
    // an echo of the audio coming from the device microphone.
    if (nil == _subscriber && subscribeToSelf)
    {
        [self doSubscribe:stream];
    }
}

- (void)publisher:(OTPublisherKit*)publisher
  streamDestroyed:(OTStream *)stream
{
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

- (void)showAlert:(NSString *)string
{
    // show alertview on main UI
	dispatch_async(dispatch_get_main_queue(), ^{
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"OTError"
                                                         message:string
                                                        delegate:self
                                               cancelButtonTitle:@"OK"
                                               otherButtonTitles:nil] ;
        [alert show];
    });
}


#pragma mark - action voting

- (void)voteCountAndDisplay{
    
    NSLog(@"ok");
    int forwardCount = 0;
    int leftCount = 0;
    int rightCount = 0;
    int backCount = 0;
    int action1Count = 0;
    int action2Count = 0;

    for (NSString*vote in _actionVotes) {
        if ([vote isEqualToString:@"forward"]) {
            forwardCount += 1;
        } else if ([vote isEqualToString:@"left"]){
            leftCount += 1;
        } else if ([vote isEqualToString:@"right"]){
            rightCount += 1;
        } else if ([vote isEqualToString:@"backward"]){
            backCount += 1;
        } else if ([vote isEqualToString:@"action1"]){
            action1Count += 1;
        } else if ([vote isEqualToString:@"action2"]){
            action2Count += 1;
        }
    }
    
    int max_votes = 0;
    NSString *voteName = @"";
    if (forwardCount > max_votes) {
        max_votes = forwardCount;
        voteName = [NSString stringWithFormat:@"FORWARD (%d votes)", forwardCount];
        if (forwardCount == 1) {
            voteName = @"WALK FORWARD (1 vote)";
        }
    }
    if (leftCount > max_votes){
        max_votes = leftCount;
        voteName = [NSString stringWithFormat:@"LEFT (%d votes)", leftCount];
        if (leftCount == 1) {
            voteName = @"TURN LEFT (1 vote)";
        }
    }
    if (rightCount > max_votes){
        max_votes = rightCount;
        voteName = [NSString stringWithFormat:@"RIGHT (%d votes)", rightCount];
        if (rightCount == 1) {
            voteName = @"TURN RIGHT (1 vote)";
        }
    }
    if (backCount > max_votes){
        max_votes = backCount;
        voteName = [NSString stringWithFormat:@"BACKWARD (%d votes)", backCount];
        if (backCount == 1) {
            voteName = @"TURN AROUND (1 vote)";
        }
    }
    if (action1Count > max_votes){
        max_votes = action1Count;
        voteName = [NSString stringWithFormat:@"SAY HI (%d votes)", action1Count];
        if (action1Count == 1) {
            voteName = @"SAY HI (1 vote)";
        }
    }
    if (action2Count > max_votes){
        max_votes = action2Count;
        voteName = [NSString stringWithFormat:@"THUMBS UP (%d votes)", action2Count];
        if (action2Count == 1) {
            voteName = @"THUMBS UP (1 vote)";
        }
    }
    
    [self.client sendMessage:@{@"main_action" : voteName} onChannel:@"/test"];
    
    _actionVotes = [[NSMutableArray alloc]init];
}

#pragma mark - Faye

-(void)messageReceived:(NSDictionary *)messageDict channel:(NSString *)channel{
    
    NSLog(@"%@", messageDict);
    if (messageDict[@"main_action"]) {
        [self.controlsVC pushMainAction:messageDict[@"main_action"]];
    }
    else if (messageDict[@"action"]) {
        //[self.controlsVC pushAction:messageDict];
        [_actionVotes addObject:messageDict[@"action"]];
        
    } else{
        TJWUser *user = [[TJWUser alloc]initWithName:messageDict[@"user"]];
        TJWComment *comment = [[TJWComment alloc]initWithMessage:messageDict[@"message"] fromUser:user];
        [self.commentsVC pushComment:comment];
        [self.controlsVC pushComment:[NSString stringWithFormat:@"%@: %@", messageDict[@"user"], messageDict[@"message"]]];
    }
    
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
    // [self.client sendMessage:@{@"test" : @"hello"} onChannel:@"/test"];
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

#pragma mark - ControlsControllerDelegate
-(void)backButtonPressedFromControlsController:(ControlsViewController *)controller{
    
    [self.scrollView scrollRectToVisible:CGRectMake(self.view.bounds.size.width, 0, self.view.bounds.size.width, 1) animated:YES];
}

- (void)questionButtonPressedFromControlsController:(ControlsViewController *)controller {
    InstructionModalViewController *targetViewController = [[InstructionModalViewController alloc] init];
    targetViewController.transitioningDelegate = self;
    targetViewController.modalTransitionStyle = UIModalPresentationCustom;
    targetViewController.modalPresentationStyle = UIModalPresentationOverFullScreen;
    [self presentViewController:targetViewController animated:YES completion:^{
        //
    }];
}

#pragma mark - UIViewControllerTransitioningDelegate

- (id<UIViewControllerAnimatedTransitioning>)animationControllerForPresentedController:(UIViewController *)presented presentingController:(UIViewController *)presenting sourceController:(UIViewController *)source {
    TJWModalTransitionManager *manager = [[TJWModalTransitionManager alloc] init];
    manager.presenting = YES;
    return manager;
}

- (id<UIViewControllerAnimatedTransitioning>)animationControllerForDismissedController:(UIViewController *)dismissed {
    TJWModalTransitionManager *manager = [[TJWModalTransitionManager alloc] init];
    return manager;
}

@end
