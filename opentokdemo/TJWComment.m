//
//  TJWComment.m
//  opentokdemo
//
//  Created by Teddy Wyly on 2/24/15.
//  Copyright (c) 2015 Context Labs Inc. All rights reserved.
//

#import "TJWComment.h"

@implementation TJWComment

- (instancetype)initWithMessage:(NSString *)message fromUser:(TJWUser *)user {
    self = [super init];
    if (self) {
        _message = message;
        _user = user;
    }
    return self;
}

@end
