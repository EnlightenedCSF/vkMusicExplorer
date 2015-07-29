//
//  VKUserData.m
//  VKTest
//
//  Created by Ольферук Александр on 29.07.15.
//  Copyright (c) 2015 EnlightenedCSF. All rights reserved.
//

#import "VKUserData.h"

@implementation VKUserData

+(VKUserData *)sharedData
{
    static dispatch_once_t once;
    static id sharedInstance;
    dispatch_once(&once, ^{
        sharedInstance = [[self alloc] init];
    });
    return sharedInstance;
}

-(id)init
{
    if (self = [super init]) {
        _userId = @"";
    }
    return self;
}

@end
