//
//  TJWOptionView.m
//  opentokdemo
//
//  Created by Teddy Wyly on 2/25/15.
//  Copyright (c) 2015 Context Labs Inc. All rights reserved.
//

#import "TJWOptionView.h"

#define IMAGE_PROPORTION 0.4

@interface TJWOptionView()

@end

@implementation TJWOptionView

- (instancetype)initWithFrame:(CGRect)frame image:(UIImage *)image text:(NSString *)text {
    self = [super initWithFrame:frame];
    if (self) {
        _image = image;
        _text = text;
        _imageView = [[UIImageView alloc] initWithImage:_image];
        _imageView.contentMode = UIViewContentModeScaleAspectFit;
        _label = [[UILabel alloc] initWithFrame:CGRectZero];
        _label.text = text;
        [self addSubview:_imageView];
        [self addSubview:_label];
    }
    return self;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    self.imageView.frame = CGRectMake(0, 0, self.bounds.size.width * IMAGE_PROPORTION, self.bounds.size.height);
    self.label.frame = CGRectMake(self.bounds.size.width * IMAGE_PROPORTION, 0, self.bounds.size.width * (1-IMAGE_PROPORTION), self.bounds.size.height);
}

@end
