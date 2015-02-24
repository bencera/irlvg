//
//  TJWUser.h
//  opentokdemo
//
//  Created by Teddy Wyly on 2/24/15.
//  Copyright (c) 2015 Context Labs Inc. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface TJWUser : NSObject

@property (strong, nonatomic, readonly) NSString *name;
@property (strong, nonatomic, readonly) NSString *displayName;

- (instancetype)initWithName:(NSString *)name;


@end
