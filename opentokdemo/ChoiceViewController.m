//
//  ChoiceViewController.m
//  opentokdemo
//
//  Created by Ben Cera on 2/19/15.
//  Copyright (c) 2015 Context Labs Inc. All rights reserved.
//

#import "ChoiceViewController.h"
#import "ViewController.h"
#import "SubscribeViewController.h"
#import "CreateGameViewController.h"


@interface ChoiceViewController () <UITableViewDataSource, UITableViewDelegate>

@property (nonatomic) UITableView *tableView;

@end

@implementation ChoiceViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.view.backgroundColor = [UIColor whiteColor];
    
    UIView *navBar = [[UIView alloc]init];
    navBar.frame = CGRectMake(0, 0, self.view.bounds.size.width, 64.f);
    navBar.backgroundColor = [UIColor blackColor];
    [self.view addSubview:navBar];
    
    UIImageView *icon = [[UIImageView alloc]init];
    icon.frame = CGRectMake((self.view.bounds.size.width - 44)/2, 20, 44, 44);
    icon.image = [UIImage imageNamed:@"icon"];
    [self.view addSubview:icon];
    
    //tableView
    _tableView = [[UITableView alloc]initWithFrame:CGRectMake(0, 64, self.view.bounds.size.width, self.view.bounds.size.height) style:UITableViewStylePlain];
    _tableView.delegate = self;
    _tableView.dataSource = self;
    _tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    [self.view addSubview:_tableView];
    
    UIButton *stream = [UIButton buttonWithType:UIButtonTypeCustom];
    stream.frame = CGRectMake((self.view.bounds.size.width - 72)/2, self.view.bounds.size.height - 92, 72, 72);
    stream.backgroundColor = [UIColor clearColor];
    [stream setImage:[UIImage imageNamed:@"create"] forState:UIControlStateNormal];
    [stream addTarget:self action:@selector(startStreaming) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:stream];
}

-(UIStatusBarStyle)preferredStatusBarStyle{
    return UIStatusBarStyleLightContent;
}

-(void)startStreaming{
    CreateGameViewController *subscribeVC = [[CreateGameViewController alloc]init];
    UINavigationController *navVC = [[UINavigationController alloc]initWithRootViewController:subscribeVC];
    navVC.navigationBarHidden = YES;
    [self presentViewController:navVC animated:YES completion:nil];
}

#pragma mark - TableView functions

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    int n = 1;
    return n;
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
   // return _streams.count;
    return 1;
}


- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    int height;
    height = 102.f;
    return height;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    
    UITableViewCell *cell;
    
    cell = [tableView dequeueReusableCellWithIdentifier:@"streamCell"];
    
    if (!cell){
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"streamCell"];
        
        UIImageView *streamImage = [[UIImageView alloc]init];
        streamImage.frame = CGRectMake(0, 0, 100, 100);
        streamImage.image = [UIImage imageNamed:@"IMG_1166.JPG"];
        [cell addSubview:streamImage];
        
        UILabel *streamName = [[UILabel alloc]init];
        streamName.frame = CGRectMake(105, 5, 240.f, 30.f);
        streamName.text = @"bencera";
       // streamName.backgroundColor = [UIColor blueColor];
        [cell addSubview:streamName];
        
        UILabel *streamDescription = [[UILabel alloc]init];
        streamDescription.frame = CGRectMake(105, 35, 240.f, 60.f);
        streamDescription.text = @"NYC livin'";
        streamDescription.numberOfLines = 2;
       // streamDescription.backgroundColor = [UIColor greenColor];
        [cell addSubview:streamDescription];
        
        UIView *separator = [[UIView alloc]init];
        separator.frame = CGRectMake(0, 100, self.view.bounds.size.width, 2.f);
        separator.backgroundColor = [UIColor blackColor];
        [cell addSubview:separator];

    }
    
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    
    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    
    return cell;
}


-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    SubscribeViewController *streamVC = [[SubscribeViewController alloc]init];
    [self.navigationController pushViewController:streamVC animated:YES];
    
}

@end
