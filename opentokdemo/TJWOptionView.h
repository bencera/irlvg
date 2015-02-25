//
//  TJWOptionView.h
//  opentokdemo
//
//  Created by Teddy Wyly on 2/25/15.
//  Copyright (c) 2015 Context Labs Inc. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface TJWOptionView : UIView

@property (strong, nonatomic) UIImage *image;
@property (strong, nonatomic) NSString *text;
@property (strong, nonatomic) UIImageView *imageView;
@property (strong, nonatomic) UILabel *label;

- (instancetype)initWithFrame:(CGRect)frame image:(UIImage *)image text:(NSString *)text;

@end
