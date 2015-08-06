//
//  NSString+URLEncoded.m
//  VKTest
//
//  Created by Ольферук Александр on 05.08.15.
//  Copyright (c) 2015 EnlightenedCSF. All rights reserved.
//

#import "NSString+URLEncoded.h"

@implementation NSString (URLEncoded)

- (NSString *)URLEncoded
{
    return (NSString *) CFBridgingRelease(CFURLCreateStringByAddingPercentEscapes(kCFAllocatorDefault, (CFStringRef)self, NULL, CFSTR(":/?#[]@!$&’()*+,;="), kCFStringEncodingUTF8));
}

@end
