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
#import "TJWUser.h"
#import "FayeClient.h"

@interface NewSubscribeViewController ()
<OTSessionDelegate, OTSubscriberKitDelegate, OTPublisherDelegate, CommentsViewControllerDelegate, UIScrollViewDelegate,FayeClientDelegate>

@property (nonatomic) UIScrollView *scrollView;
@property (strong, nonatomic) CommentsViewController *commentsVC;
@property (strong, nonatomic) ControlsViewController *controlsVC;
@property (strong, nonatomic) FayeClient *client;

@end

@implementation NewSubscribeViewController {
    OTSession* _session;
    OTPublisher* _publisher;
    OTSubscriber* _subscriber;
}

// *** Fill the following variables using your own Project info  ***
// ***          https://dashboard.tokbox.com/projects            ***
// Replace with your OpenTok API key
static NSString* const kApiKey = @"45159522";
// Replace with your generated session ID
static NSString* const kSessionId = @"2_MX40NTE1OTUyMn5-MTQyNDgwOTYyMDM4MX5OUTVzVkFpbmpkMkM5bVZ3M0hDaklqdnZ-fg";
// Replace with your generated token
static NSString* const kToken = @"T1==cGFydG5lcl9pZD00NTE1OTUyMiZzaWc9Yjk1ZjY5OGJlMTdkNjU5Y2JhYjI1NjU4ZGU0ZTQyNDgwNmNkYzQyYTpyb2xlPXN1YnNjcmliZXImc2Vzc2lvbl9pZD0yX01YNDBOVEUxT1RVeU1uNS1NVFF5TkRnd09UWXlNRE00TVg1T1VUVnpWa0ZwYm1wa01rTTViVlozTTBoRGFrbHFkblotZmcmY3JlYXRlX3RpbWU9MTQyNDgwOTgwMSZub25jZT0wLjE4NDEzMzU0OTM3NzIxNzUmZXhwaXJlX3RpbWU9MTQyNzQwMTU2OQ==";

// Change to NO to subscribe to streams other than your own.
static bool subscribeToSelf = NO;

#pragma mark - View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    // Step 1: As the view comes into the foreground, initialize a new instance
    // of OTSession and begin the connection process.
    _session = [[OTSession alloc] initWithApiKey:kApiKey
                                       sessionId:kSessionId
                                        delegate:self];
    [self doConnect];
    
    [self addScrollView];
    
    self.client = [[FayeClient alloc]initWithURLString:@"ws://irl-faye.herokuapp.com/faye" channel:@"/test"];
    
    [self.client connectToServer];
    

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
    _scrollView.backgroundColor = [UIColor groupTableViewBackgroundColor];
    [self.view addSubview:_scrollView];
    
    self.controlsVC = [[ControlsViewController alloc]init];
    //controlsVC.client = self.client;
    //   controlsVC.subVC = self;
    self.controlsVC.view.frame = CGRectMake(0, 0, self.view.bounds.size.width, self.view.bounds.size.height);
    self.controlsVC.view.layer.zPosition = 99;
    [_scrollView addSubview:self.controlsVC.view];
    
    CommentsViewController *commentsVC = [[CommentsViewController alloc]init];
    commentsVC.currentUser = [[TJWUser alloc] initWithName:@"Ben"];
    commentsVC.view.frame = CGRectMake(self.view.bounds.size.width, 0, self.view.bounds.size.width, self.view.bounds.size.height);
    
    self.commentsVC = commentsVC;
    commentsVC.delegate = self;
    //commentsVC.subVC = self;
    commentsVC.view.layer.zPosition = 99;
    [_scrollView addSubview:commentsVC.view];
}

- (BOOL)prefersStatusBarHidden
{
    return YES;
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
}

#pragma mark - CommentsViewControllerDelegate

- (void)commentsController:(CommentsViewController *)controller didFinishTypingText:(NSString *)text {
    // Send Comment Upward
}

- (void)backButtonPressedFromCommeentsController:(CommentsViewController *)controller {
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
   
    OTError *error = nil;
    [_session publish:_publisher error:&error];
    if (error)
    {
        [self showAlert:[error localizedDescription]];
    }
    
    [self.view addSubview:_publisher.view];
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
    //[self doPublish];
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

#pragma mark - Faye

-(void)fayeClientWillSendMessage:(NSDictionary *)messageDict withCallback:(FayeClientMessageHandler)callback{}
-(void)fayeClientWillReceiveMessage:(NSDictionary *)messageDict withCallback:(FayeClientMessageHandler)callback{}
-(void)fayeClientError:(NSError *)error{}
-(void)subscriptionFailedWithError:(NSString *)error{}
-(void)connectedToServer{}
-(void)disconnectedFromServer{}
-(void)messageReceived:(NSDictionary *)messageDict channel:(NSString *)channel{}
-(void)didSubscribeToChannel:(NSString *)channel{}
-(void)didUnsubscribeFromChannel:(NSString *)channel{}
-(void)connectionFailed{}

@end
