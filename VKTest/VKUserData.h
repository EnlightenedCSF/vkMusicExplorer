//
//  VKUserData.h
//  VKTest
//
//  Created by Ольферук Александр on 29.07.15.
//  Copyright (c) 2015 EnlightenedCSF. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <VKSdk.h>

@interface VKUserData : NSObject

+(VKUserData *)sharedData;

@property (strong, nonatomic) VKAccessToken *token;
@property (copy, nonatomic) NSString *userId;

@end
