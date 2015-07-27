//
//  VKApiDelegate.m
//  VKTest
//
//  Created by Admin on 26.07.15.
//  Copyright (c) 2015 EnlightenedCSF. All rights reserved.
//

#import "VKApiDelegate.h"

@implementation VKApiDelegate

@synthesize token = _token;

#pragma mark - Initialization

-(id)init {
    self = [super init];
    if (self) {
        self.token = nil;
        self.userId = @"no";
    }
    return self;
}

+(VKApiDelegate *)sharedDelegate {
    static VKApiDelegate *delegate = nil;
    if (!delegate) {
        delegate = [[VKApiDelegate alloc] init];


    }
    return delegate;
}

#pragma mark - VK API Protocol

-(void)vkSdkShouldPresentViewController:(UIViewController *)controller {
    NSLog(@"Should present view controller");
}

-(void)vkSdkTokenHasExpired:(VKAccessToken *)expiredToken {
    self.token = [VKSdk getAccessToken];
}

-(void)vkSdkReceivedNewToken:(VKAccessToken *)newToken {
    self.token = newToken;
    self.userId = newToken.userId;
}

-(void)vkSdkNeedCaptchaEnter:(VKError *)captchaError {
    NSLog(@"%@", captchaError.description);
}

- (void)vkSdkUserDeniedAccess:(VKError *)authorizationError {
    NSLog(@"%@", authorizationError.description);
}

#pragma mark - Getter

-(VKAccessToken *)token {
    if (_token.isExpired) {
        _token = [VKSdk getAccessToken];
    }
    return _token;
}

@end
