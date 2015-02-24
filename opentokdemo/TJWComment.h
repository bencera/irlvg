//
//  TJWComment.h
//  opentokdemo
//
//  Created by Teddy Wyly on 2/24/15.
//  Copyright (c) 2015 Context Labs Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
@class TJWUser;

@interface TJWComment : NSObject

@property (strong, nonatomic, readonly) TJWUser *user;
@property (strong, nonatomic, readonly) NSString *message;

- (instancetype)initWithMessage:(NSString *)message fromUser:(TJWUser *)user;

@end
