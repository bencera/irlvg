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

#define composeBoxHeight 50.f
#define sendMessagePlaceholder @"Send a message..."
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
    nameLabel.frame = CGRectMake(0, 20, self.view.bounds.size.width, 60.f);
    nameLabel.text = self.currentUser.displayName;
    nameLabel.textAlignment = NSTextAlignmentCenter;
    [self.view addSubview:nameLabel];
    
    UIButton *settingsButton = [[UIButton alloc]init];
    settingsButton.frame = CGRectMake(5, 25, 50, 50);
    [settingsButton setImage:[UIImage imageNamed:@"backB"] forState:UIControlStateNormal];
    [settingsButton addTarget:self action:@selector(backToGame) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:settingsButton];

    //tableView
    _tableView = [[UITableView alloc]initWithFrame:CGRectMake(0, NAV_BAR_HEIGHT, self.view.bounds.size.width, self.view.bounds.size.height - NAV_BAR_HEIGHT) style:UITableViewStylePlain];
    _tableView.delegate = self;
    _tableView.dataSource = self;
    _tableView.alpha = 0.7f;
    _tableView.keyboardDismissMode = UIScrollViewKeyboardDismissModeInteractive;
    [self.view addSubview:_tableView];

    
    _composerHolder = [[UIView alloc]init];
    _composerHolder.frame = CGRectMake(0, self.view.bounds.size.height - composeBoxHeight, self.view.bounds.size.width, composeBoxHeight);
    _composerHolder.backgroundColor = [UIColor whiteColor];
    [self.view addSubview:_composerHolder];
    
    CGRect tableViewFrame = CGRectMake(0,NAV_BAR_HEIGHT, self.view.bounds.size.width, _composerHolder.frame.origin.y - NAV_BAR_HEIGHT);
    _tableView.frame = tableViewFrame;
    [self scrollToLastMessageAnimated:NO];
    
    _sendButton = [UIButton buttonWithType:UIButtonTypeCustom];
    _sendButton.frame = CGRectMake(self.view.bounds.size.width - 65, 4, 60, 41);
    [_sendButton setImage:[UIImage imageNamed:@"send"] forState:UIControlStateNormal];
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
        [self performSelector:@selector(scrollUpTableView) withObject:nil afterDelay:0.15];
    }];

}

- (NSMutableArray *)comments {
    if (!_comments) {
        _comments = [[NSMutableArray alloc] init];
        TJWComment *comment = [[TJWComment alloc] initWithMessage:@"Hello Everybody, Dr. Nick" fromUser:[[TJWUser alloc] initWithName:@"Sam"]];
        TJWComment *second = [[TJWComment alloc] initWithMessage:@"Grammys sometime" fromUser:[[TJWUser alloc] initWithName:@"Jam"]];
        TJWComment *third = [[TJWComment alloc] initWithMessage:@"lalalala balingo balinga dope dah fair and even all the lines and oh maybe sometime yess or no" fromUser:[[TJWUser alloc] initWithName:@"Alice"]];
        [_comments addObjectsFromArray:@[comment, second, third]];
        [_comments addObjectsFromArray:@[comment, second, third]];
        [_comments addObjectsFromArray:@[comment, second, third]];
        [_comments addObjectsFromArray:@[comment, second, third]];
        [_comments addObjectsFromArray:@[comment, second, third]];        
    }
    return _comments;
}

- (void)pushComment:(TJWComment *)comment {
    [self.comments addObject:comment];
    [self.tableView reloadData];
    [self scrollToLastMessageAnimated:YES];
}


- (void)scrollToLastMessageAnimated:(BOOL)animated {
    NSIndexPath* ipath = [NSIndexPath indexPathForRow: [self.comments count]-1 inSection: 0];
    [self.tableView scrollToRowAtIndexPath: ipath atScrollPosition: UITableViewScrollPositionTop animated: animated];
}

-(void)showKeyboard{
    [_textView becomeFirstResponder];
    [_textView setSelectedRange:NSMakeRange(0, 0)];
    _composeButton.hidden = YES;
}

- (void)sendButtonPressed:(UIButton *)sender {
    NSString *message = self.textView.text;
    NSLog(@"%@", message);
    TJWComment *comment = [[TJWComment alloc] initWithMessage:message fromUser:self.currentUser];
    [self pushComment:comment];
    [self.delegate commentsController:self didFinishTypingText:message];
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
    return 1;
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return [self.comments count];
}


- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    CommentTableViewCell *cell = [[CommentTableViewCell alloc] init];
    cell.textLabel.attributedText = [self attributedBodyTextAtIndexPath:indexPath];
    
    // Do the layout pass on the cell, which will calculate the frames for all the views based on the constraints
    // (Note that the preferredMaxLayoutWidth is set on multi-line UILabels inside the -[layoutSubviews] method
    // in the UITableViewCell subclass
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

@end
