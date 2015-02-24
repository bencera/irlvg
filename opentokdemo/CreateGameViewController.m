//
//  CreateGameViewController.m
//  opentokdemo
//
//  Created by Ben Cera on 2/20/15.
//  Copyright (c) 2015 Context Labs Inc. All rights reserved.
//

#import "CreateGameViewController.h"
#import "ViewController.h"

@interface CreateGameViewController () <UITableViewDelegate, UITableViewDataSource, UITextFieldDelegate>

@property (nonatomic) UITableView *tableView;
@property BOOL n_controls;
@property (nonatomic) UITextField *gameTitle;
@property (nonatomic) UIButton *createGameB;

@end

@implementation CreateGameViewController

-(void)viewDidLoad{
    [super viewDidLoad];
    
    UIView * navBar = [[UIView alloc]init];
    navBar.frame = CGRectMake(0, 0, self.view.bounds.size.width, 64.f);
    navBar.backgroundColor = [UIColor blackColor];
    [self.view addSubview:navBar];
    
    UILabel *navTitle = [[UILabel alloc]init];
    navTitle.frame = CGRectMake(0, 20, self.view.bounds.size.width, 44.f);
    navTitle.text = @"CREATE GAME";
    navTitle.font = [UIFont fontWithName:@"Helvetica-Bold" size:18.f];
    navTitle.textColor = [UIColor whiteColor];
    navTitle.textAlignment = NSTextAlignmentCenter;
    navTitle.backgroundColor = [UIColor clearColor];
    [self.view addSubview:navTitle];
    
    UIButton *closeButton = [UIButton buttonWithType:UIButtonTypeCustom];
    closeButton.frame = CGRectMake(5,25, 36, 36);
    [closeButton setTitle:@"x" forState:UIControlStateNormal];
    [closeButton addTarget:self action:@selector(close) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:closeButton];
    
    //tableView
    _tableView = [[UITableView alloc]initWithFrame:CGRectMake(0, 64, self.view.bounds.size.width, self.view.bounds.size.height) style:UITableViewStyleGrouped];
    _tableView.delegate = self;
    _tableView.dataSource = self;
    [self.view addSubview:_tableView];
    
    _createGameB = [[UIButton alloc]init];
    _createGameB.frame = CGRectMake(0, self.view.bounds.size.height - 60.f, self.view.bounds.size.width, 60.f);
    [_createGameB setTitle:@"START >" forState:UIControlStateNormal];
    _createGameB.backgroundColor = [UIColor colorWithWhite:0.6 alpha:1];
    [_createGameB addTarget:self action:@selector(startGame) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:_createGameB];
    
    _n_controls = 1;
}

-(void)startGame{
    ViewController *viewC = [[ViewController alloc]init];
    [self.navigationController pushViewController:viewC animated:YES];
}

-(void)scrollViewDidScroll:(UIScrollView *)scrollView{
    [_gameTitle resignFirstResponder];
    if (_gameTitle.text.length > 0) {
        _createGameB.backgroundColor = [UIColor colorWithRed:10/255.f green:230/255.f blue:8/255.f alpha:1.f];
    }
}

-(BOOL)textFieldShouldReturn:(UITextField *)textField{
    [_gameTitle resignFirstResponder];
    if (_gameTitle.text.length > 0) {
        _createGameB.backgroundColor = [UIColor colorWithRed:10/255.f green:230/255.f blue:8/255.f alpha:1.f];
    }
    return YES;
}


-(void)close{
    [self dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - TableView functions

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    int n = 2;
    return n;
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    // return _streams.count;
    if (section == 0) {
        return 1;
    } else{
        return 3;
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    int height;
    if (indexPath.section == 0) {
        height = 40.f;
    } else{
        height = 100.f;
    }
    
    return height;
}

-(NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section{
    if (section == 0) {
        return @"TITLE";
    } else if (section == 1) {
        return @"CONTROLS";
    } else{
        return nil;
    }
    
}

-(UIStatusBarStyle)preferredStatusBarStyle{
    return UIStatusBarStyleLightContent;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    
    UITableViewCell *cell;
    
    if (indexPath.section == 0) {
        
        cell = [tableView dequeueReusableCellWithIdentifier:@"titleCell"];
        
        if (!cell){
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"titleCell"];
            if (_gameTitle == NULL) {
                _gameTitle = [[UITextField alloc]init];
                _gameTitle.delegate = self;
                [cell addSubview:_gameTitle];
            }
            _gameTitle.frame = CGRectMake(10, 0, self.view.bounds.size.width, 40.f);
            _gameTitle.placeholder = @"Description of your game...";
        }
        
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        
        return cell;
    } else if (indexPath.section == 1){
        cell = [tableView dequeueReusableCellWithIdentifier:@"controlCell"];
        
        if (!cell){
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"controlCell"];
            
            UIImageView *streamImage = [[UIImageView alloc]init];
            streamImage.frame = CGRectMake(5, 5, 90, 90);
            streamImage.image = [UIImage imageNamed:@"controller"];
            streamImage.tag = 1;
            [cell addSubview:streamImage];
            
            UILabel *streamName = [[UILabel alloc]init];
            streamName.frame = CGRectMake(105, 25, 240.f, 50.f);
            streamName.text = @"controller";
            streamName.tag = 2;
            [cell addSubview:streamName];
        }
        
        UIImageView *streamImage = (UIImageView*)[cell viewWithTag:1];
        UILabel *streamName = (UILabel *)[cell viewWithTag:2];
        
        if (indexPath.row == 0) {
            streamImage.image = [UIImage imageNamed:@"controller"];
            streamImage.frame = CGRectMake(5, 5, 90, 90);
            streamName.text = @"directional controller";
        } else{
            streamImage.image = [UIImage imageNamed:@"button"];
            streamImage.frame = CGRectMake(25, 25, 50, 50);
            streamName.text = @"action button";
        }
        
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        
        return cell;
    } else{
        cell = [tableView dequeueReusableCellWithIdentifier:@"blaCell"];

        return cell;
    }
}


-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
 //   SubscribeViewController *streamVC = [[SubscribeViewController alloc]init];
 //   [self.navigationController pushViewController:streamVC animated:YES];
    
}



@end