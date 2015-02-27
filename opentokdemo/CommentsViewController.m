//
//  CommentsViewController.m
//  opentokdemo
//
//  Created by Ben Cera on 2/20/15.
//  Copyright (c) 2015 Context Labs Inc. All rights reserved.
//

#import "CommentsViewController.h"
#import "BABFrameObservingInputAccessoryView.h"
#import "CommentTableViewCell.h"
#import "TJWComment.h"
#import "TJWUser.h"
#import "AFNetworking.h"

#define composeBoxHeight 50.f
#define sendMessagePlaceholder @"Comment..."
#define writeFirstPlaceholder @"Write something first..."
#define NAV_BAR_HEIGHT 100.f

@interface CommentsViewController () <UITableViewDataSource,UITableViewDelegate,UITextViewDelegate>

{
    CGFloat keyboardHeight;
}

@property UITableView *tableView;
@property (nonatomic) UITextView* textView;
@property (nonatomic) UIView *composerHolder;
@property (nonatomic) UIButton *sendButton;
@property (nonatomic) UIButton *composeButton;
@property (strong, nonatomic) NSMutableArray *comments;

@end

@implementation CommentsViewController

-(void)viewDidLoad{
    [super viewDidLoad];
    
    UILabel *nameLabel = [[UILabel alloc]init];
    nameLabel.frame = CGRectMake(0, 20, self.view.bounds.size.width, 70.f);
    nameLabel.text = @"COMMENTS";
    nameLabel.font = [UIFont fontWithName:@"HelveticaNeue-Bold" size:30.f];
    nameLabel.textColor = [UIColor colorWithRed:255/255.f green:204/255.f blue:0 alpha:1.f];
    nameLabel.textAlignment = NSTextAlignmentCenter;
    self.view.backgroundColor = [[UIColor whiteColor] colorWithAlphaComponent:0.7];
    [self.view addSubview:nameLabel];
    
    UIButton *settingsButton = [[UIButton alloc]init];
    settingsButton.frame = CGRectMake(10, 30, 50, 50);
    [settingsButton setImage:[UIImage imageNamed:@"back"] forState:UIControlStateNormal];
    [settingsButton addTarget:self action:@selector(backToGame) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:settingsButton];

    //tableView
    _tableView = [[UITableView alloc]initWithFrame:CGRectMake(0, NAV_BAR_HEIGHT, self.view.bounds.size.width, self.view.bounds.size.height - NAV_BAR_HEIGHT - composeBoxHeight) style:UITableViewStylePlain];
    _tableView.delegate = self;
    _tableView.dataSource = self;
    _tableView.backgroundColor = [UIColor clearColor];
    _tableView.keyboardDismissMode = UIScrollViewKeyboardDismissModeInteractive;
    [self.view addSubview:_tableView];

    
    _composerHolder = [[UIView alloc]init];
    _composerHolder.frame = CGRectMake(0, self.view.bounds.size.height - composeBoxHeight, self.view.bounds.size.width, composeBoxHeight);
    _composerHolder.backgroundColor = [UIColor whiteColor];
    [self.view addSubview:_composerHolder];
    
    [self scrollToLastMessageAnimated:NO];
    
    _sendButton = [UIButton buttonWithType:UIButtonTypeCustom];
    _sendButton.frame = CGRectMake(self.view.bounds.size.width - 65, 4, 60, 41);
    [_sendButton setImage:[UIImage imageNamed:@"send2"] forState:UIControlStateNormal];
    [_sendButton addTarget:self action:@selector(sendButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
    [_composerHolder addSubview:_sendButton];
    
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
            
            CGRect tableViewFrame = CGRectMake(0,NAV_BAR_HEIGHT, self.view.bounds.size.width, frame.origin.y - NAV_BAR_HEIGHT);
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
        UIViewAnimationCurve animationCurve = [[keyboardAnimationDetail objectForKey:UIKeyboardAnimationCurveUserInfoKey] integerValue];
     
        CGFloat duration = [keyboardAnimationDetail[UIKeyboardAnimationDurationUserInfoKey] floatValue];
        
        
        [UIView animateWithDuration:duration delay:0.0 options:(animationCurve << 16) animations:^{
            
            CGRect tableViewFrame = CGRectMake(0,NAV_BAR_HEIGHT, self.view.bounds.size.width, self.view.bounds.size.height - keyboardHeight - NAV_BAR_HEIGHT);
            _tableView.frame = tableViewFrame;
            
            CGRect composerFrame = CGRectMake(0, self.view.bounds.size.height  - keyboardHeight, self.view.bounds.size.width, composeBoxHeight);
            _composerHolder.frame = composerFrame;
            
            [self scrollToLastMessageAnimated:NO];
            
        } completion:^(BOOL finished) {
            [_textView setSelectedRange:NSMakeRange(0, 0)];
        }];
        //[self performSelector:@selector(scrollUpTableView) withObject:nil afterDelay:0.15];
    }];
    
    [[NSNotificationCenter defaultCenter] addObserverForName:UIKeyboardWillHideNotification object:nil queue:nil usingBlock:^(NSNotification *note) {
        
        CGRect keyboardRect = [note.userInfo[UIKeyboardFrameEndUserInfoKey] CGRectValue];
        keyboardRect = [self.view convertRect:keyboardRect fromView:nil]; //this is it!
        keyboardHeight = keyboardRect.size.height;
        
        NSDictionary *keyboardAnimationDetail = [note userInfo];
        UIViewAnimationCurve animationCurve = [[keyboardAnimationDetail objectForKey:UIKeyboardAnimationCurveUserInfoKey] integerValue];
        
        CGFloat duration = [keyboardAnimationDetail[UIKeyboardAnimationDurationUserInfoKey] floatValue];
        
        
        [UIView animateWithDuration:duration delay:0.0 options:(animationCurve << 16) animations:^{
            
            CGRect tableViewFrame = CGRectMake(0,NAV_BAR_HEIGHT, self.view.bounds.size.width, self.view.bounds.size.height - NAV_BAR_HEIGHT - composeBoxHeight);
            _tableView.frame = tableViewFrame;
            
            CGRect composerFrame = CGRectMake(0, self.view.bounds.size.height - composeBoxHeight, self.view.bounds.size.width, composeBoxHeight);
            _composerHolder.frame = composerFrame;
            
            [self scrollToLastMessageAnimated:NO];
            
        } completion:^(BOOL finished) {
            [_textView setSelectedRange:NSMakeRange(0, 0)];
        }];
        //[self performSelector:@selector(scrollUpTableView) withObject:nil afterDelay:0.15];
    }];


    [self downloadComments];
}

- (NSMutableArray *)comments {
    if (!_comments) {
        _comments = [[NSMutableArray alloc] init];
    }
    return _comments;
}

- (void)pushComment:(TJWComment *)comment {
    [self.comments addObject:comment];
    [self.tableView reloadData];
    [self scrollToLastMessageAnimated:YES];
    [self sendCommentToServerWithUser:comment.user.name andMessage:comment.message];
}


- (void)scrollToLastMessageAnimated:(BOOL)animated {
    if ([self.comments count]) {
        NSIndexPath* ipath = [NSIndexPath indexPathForRow: [self.comments count]-1 inSection: 0];
        [self.tableView scrollToRowAtIndexPath: ipath atScrollPosition: UITableViewScrollPositionTop animated: animated];
    }
}

-(void)showKeyboard{
    [_textView becomeFirstResponder];
    [_textView setSelectedRange:NSMakeRange(0, 0)];
    _composeButton.hidden = YES;
}

- (void)sendButtonPressed:(UIButton *)sender {
    NSString *message = self.textView.text;
    
    if (![message isEqualToString:sendMessagePlaceholder] && [message length]) {
        TJWComment *comment = [[TJWComment alloc] initWithMessage:message fromUser:self.currentUser];
        [self.delegate commentsController:self didFinishTypingComment:comment];
        self.textView.text = @"";
    }

}

-(void)backToGame{
    [self.textView resignFirstResponder];
    [self.delegate backButtonPressedFromCommentsController:self];
}

#pragma mark - TableView functions

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return [self.comments count];
}


- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    CommentTableViewCell *cell = [[CommentTableViewCell alloc] init];
    cell.textLabel.attributedText = [self attributedBodyTextAtIndexPath:indexPath];

    [cell setNeedsLayout];
    [cell layoutIfNeeded];
    
    // Get the actual height required for the cell
    CGFloat height = [cell.contentView systemLayoutSizeFittingSize:UILayoutFittingCompressedSize].height;
    
    // Add an extra point to the height to account for the cell separator, which is added between the bottom
    // of the cell's contentView and the bottom of the table view cell.
    height += 1;
    
    return height;

}

- (NSAttributedString *)attributedBodyTextAtIndexPath:(NSIndexPath *)path {
    TJWComment *comment = self.comments[path.row];
    NSMutableAttributedString *name = [[NSMutableAttributedString alloc] initWithString:[NSString stringWithFormat:@"%@ ", comment.user.displayName] attributes:@{NSForegroundColorAttributeName : [self colorForIndex:path.row]}];
    NSAttributedString *message = [[NSAttributedString alloc] initWithString:comment.message attributes:@{NSForegroundColorAttributeName : [UIColor blackColor]}];
    [name appendAttributedString:message];
    return name;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    
    CommentTableViewCell *cell;
    
    cell = [tableView dequeueReusableCellWithIdentifier:@"commentCell"];
    
    if (!cell){
        cell = [[CommentTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"commentCell"];
    }
    cell.backgroundColor = [UIColor clearColor];
    cell.textLabel.attributedText = [self attributedBodyTextAtIndexPath:indexPath];
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    cell.accessoryType = UITableViewCellAccessoryNone;
    
    return cell;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

- (NSArray *)commentColors {
    return @[[UIColor yellowColor], [UIColor redColor], [UIColor blueColor], [UIColor greenColor], [UIColor purpleColor], [UIColor orangeColor]];
}

- (UIColor *)colorForIndex:(NSInteger)index {
    NSInteger colorIndex = index % [[self commentColors] count];
    return [self commentColors][colorIndex];
}

- (void)resignKeyboard {
    [self.textView resignFirstResponder];
}

#pragma mark - UITextViewDelegate

- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text {
    
    NSString *newText = [self.textView.text stringByReplacingCharactersInRange:range withString:text];
    if ([newText length] == 0) {
        self.textView.text = sendMessagePlaceholder;
        self.textView.textColor  = [UIColor lightGrayColor];
        return NO;
    } else {
        if ([self.textView.text isEqualToString:sendMessagePlaceholder]) {
            self.textView.text = text;
            self.textView.textColor  = [UIColor blackColor];
            return NO;
        } else {
            return YES;
        }
    }
    
}

#pragma mark - Comments server

-(void)downloadComments{
    [[AFHTTPRequestOperationManager manager] GET:@"https://irl-backend.herokuapp.com/comments" parameters:nil success:^(AFHTTPRequestOperation *operation, id responseObject) {
        _comments = [[NSMutableArray alloc] init];
        for (NSDictionary *comment in responseObject) {
            TJWComment *commentObject = [[TJWComment alloc] initWithMessage:comment[@"message"] fromUser:[[TJWUser alloc] initWithName:comment[@"user"]]];
            [_comments addObject:commentObject];
        }
        [_tableView reloadData];
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        //
    }];
}

-(void)sendCommentToServerWithUser:(NSString*)username andMessage:(NSString*)message{
    [[AFHTTPRequestOperationManager manager] POST:@"https://irl-backend.herokuapp.com/comment" parameters:@{@"username" : username, @"message" : message} success:^(AFHTTPRequestOperation *operation, id responseObject) {

    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        //
    }];
}

@end
