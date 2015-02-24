//
//  CommentsViewController.m
//  opentokdemo
//
//  Created by Ben Cera on 2/20/15.
//  Copyright (c) 2015 Context Labs Inc. All rights reserved.
//

#import "CommentsViewController.h"
#import "BABFrameObservingInputAccessoryView.h"

#define composeBoxHeight 50.f
#define cellHeight 175.f
#define sendMessagePlaceholder @"Send a message..."
#define writeFirstPlaceholder @"Write something first..."

@interface CommentsViewController () <UITableViewDataSource,UITableViewDelegate,UITextViewDelegate>

{
    CGFloat keyboardHeight;
}

@property UITableView *tableView;
@property (nonatomic) UITextView* textView;
@property (nonatomic) UIView *composerHolder;
@property (nonatomic) UIButton *cameraButton;
@property (nonatomic) UIButton *composeButton;

@end

@implementation CommentsViewController

-(void)viewDidLoad{
    [super viewDidLoad];
    

    
    UILabel *nameLabel = [[UILabel alloc]init];
    nameLabel.frame = CGRectMake(0, 20, self.view.bounds.size.width, 60.f);
    nameLabel.text = @"Comments";
    nameLabel.textAlignment = NSTextAlignmentCenter;
    [self.view addSubview:nameLabel];
    
    UIButton *settingsButton = [[UIButton alloc]init];
    settingsButton.frame = CGRectMake(5, 25, 50, 50);
    [settingsButton setImage:[UIImage imageNamed:@"backB"] forState:UIControlStateNormal];
    [settingsButton addTarget:self action:@selector(backToGame) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:settingsButton];

    //tableView
    _tableView = [[UITableView alloc]initWithFrame:CGRectMake(0, 100, self.view.bounds.size.width, self.view.bounds.size.height - 100) style:UITableViewStylePlain];
    _tableView.delegate = self;
    _tableView.dataSource = self;
    _tableView.alpha = 0.7f;
    _tableView.keyboardDismissMode = UIScrollViewKeyboardDismissModeInteractive;
    [self.view addSubview:_tableView];
    
    _composerHolder = [[UIView alloc]init];
    _composerHolder.frame = CGRectMake(0, self.view.bounds.size.height - composeBoxHeight, self.view.bounds.size.width, composeBoxHeight);
    _composerHolder.backgroundColor = [UIColor whiteColor];
    [self.view addSubview:_composerHolder];
    
    _cameraButton = [UIButton buttonWithType:UIButtonTypeCustom];
    _cameraButton.frame = CGRectMake(self.view.bounds.size.width - 65, 4, 60, 41);
    [_cameraButton setImage:[UIImage imageNamed:@"send"] forState:UIControlStateNormal];
   // [_cameraButton addTarget:self action:@selector(showCamera) forControlEvents:UIControlEventTouchUpInside];
    [_composerHolder addSubview:_cameraButton];
    
    _textView = [[UITextView alloc]init];
    _textView.frame = CGRectMake(5, 6, self.view.bounds.size.width - 100, 40);
    _textView.backgroundColor = [UIColor whiteColor];
    _textView.delegate = self;
    _textView.text = sendMessagePlaceholder;
    _textView.textColor = [UIColor lightGrayColor];
    _textView.font = [UIFont fontWithName:@"HelveticaNeue" size:17.f];
    [_textView setSelectedRange:NSMakeRange(0, 0)];
    [_composerHolder addSubview:_textView];
    
    BABFrameObservingInputAccessoryView *inputView = [[BABFrameObservingInputAccessoryView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, composeBoxHeight)];
    inputView.userInteractionEnabled = NO;
    
    _textView.inputAccessoryView = inputView;
    
    __weak typeof(self)weakSelf = self;
    
    inputView.inputAcessoryViewFrameChangedBlock = ^(CGRect frame){
        
        if (_composeButton.hidden && frame.origin.y <= self.view.bounds.size.height - composeBoxHeight) {
            
            CGRect tableViewFrame = CGRectMake(0,0, self.view.bounds.size.width, frame.origin.y);
            weakSelf.tableView.frame = tableViewFrame;
            
            CGRect composerFrame = CGRectMake(0, frame.origin.y, self.view.bounds.size.width, composeBoxHeight);
            weakSelf.composerHolder.frame = composerFrame;
        }
        
    };
    
    _composeButton = [UIButton buttonWithType:UIButtonTypeCustom];
    _composeButton.frame = CGRectMake(0, 0, self.view.bounds.size.width, composeBoxHeight);
    [_composeButton addTarget:self action:@selector(showKeyboard) forControlEvents:UIControlEventTouchDown];
    _composeButton.backgroundColor = [UIColor clearColor];
    [_composerHolder addSubview:_composeButton];
    
    [[NSNotificationCenter defaultCenter] addObserverForName:UIKeyboardWillShowNotification object:nil queue:nil usingBlock:^(NSNotification *note) {
        
        CGRect keyboardRect = [note.userInfo[UIKeyboardFrameEndUserInfoKey] CGRectValue];
        keyboardRect = [self.view convertRect:keyboardRect fromView:nil]; //this is it!
        keyboardHeight = keyboardRect.size.height;
        
        NSDictionary *keyboardAnimationDetail = [note userInfo];
        UIViewAnimationCurve animationCurve = [keyboardAnimationDetail[UIKeyboardAnimationCurveUserInfoKey] integerValue];
        CGFloat duration = [keyboardAnimationDetail[UIKeyboardAnimationDurationUserInfoKey] floatValue];
        
        [UIView animateWithDuration:duration delay:0.0 options:(animationCurve << 16) animations:^{
            
            CGRect tableViewFrame = CGRectMake(0,0, self.view.bounds.size.width, self.view.bounds.size.height - keyboardHeight);
            _tableView.frame = tableViewFrame;
            
            CGRect composerFrame = CGRectMake(0, self.view.bounds.size.height  - keyboardHeight, self.view.bounds.size.width, composeBoxHeight);
            _composerHolder.frame = composerFrame;
            
        } completion:^(BOOL finished) {
            [_textView setSelectedRange:NSMakeRange(0, 0)];
        }];
        [self performSelector:@selector(scrollUpTableView) withObject:nil afterDelay:0.15];
    }];

}

- (void)pushMessageText:(NSString *)text {
    NSLog(@"Message Pushed");
}

-(void)showKeyboard{
    [_textView becomeFirstResponder];
    [_textView setSelectedRange:NSMakeRange(0, 0)];
    _composeButton.hidden = YES;
}


-(void)scrollUpTableView{
   // [_tableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:(_messages.count - 1) inSection:0] atScrollPosition:UITableViewScrollPositionBottom animated:YES];
    
}

-(void)backToGame{
    [self.delegate backButtonPressedFromCommeentsController:self];
}

#pragma mark - TableView functions

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    int n = 1;
    return n;
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    // return _streams.count;
    return 6;
}


- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    int height;
    height = 40.f;
    return height;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    
    UITableViewCell *cell;
    
    cell = [tableView dequeueReusableCellWithIdentifier:@"commentCell"];
    
    if (!cell){
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"commentCell"];
        
        UILabel *streamDescription = [[UILabel alloc]init];
        streamDescription.frame = CGRectMake(5, 5, 240.f, 30.f);
        streamDescription.text = @"bencera: this is really dope!";
        streamDescription.numberOfLines = 2;
        // streamDescription.backgroundColor = [UIColor greenColor];
        [cell addSubview:streamDescription];
        
    }
    
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    
    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    
    return cell;
}


-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

@end
