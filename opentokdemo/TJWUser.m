//
//  TJWUser.m
//  opentokdemo
//
//  Created by Teddy Wyly on 2/24/15.
//  Copyright (c) 2015 Context Labs Inc. All rights reserved.
//

#import "TJWUser.h"

@implementation TJWUser

- (instancetype)initWithName:(NSString *)name {
    self = [super init];
    if (self) {
        _name = name;
    }
    return self;
}

- (NSString *)displayName {
    return [NSString stringWithFormat:@"@%@", self.name];
}

@end
