//
//  VKApiDelegate.h
//  VKTest
//
//  Created by Admin on 26.07.15.
//  Copyright (c) 2015 EnlightenedCSF. All rights reserved.
//

#import <Foundation/Foundation.h>

#import <VKSdk.h>

@interface VKApiDelegate : NSObject<VKSdkDelegate>

+(VKApiDelegate *)sharedDelegate;

@property (strong, nonatomic) VKAccessToken *token;
@property (copy, nonatomic) NSString *userId;

@end
