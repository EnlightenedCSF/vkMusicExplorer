//
//  VKJsonParser.m
//  VKTest
//
//  Created by Ольферук Александр on 06.08.15.
//  Copyright (c) 2015 EnlightenedCSF. All rights reserved.
//

#import "VKJsonParser.h"

@implementation VKJsonParser

+(NSMutableArray *)parsePublics:(id)json
{
    NSMutableArray *res = [NSMutableArray array];
    for (id item_ in json[@"items"]) {
        if ([item_ objectForKey:@"screen_name"]) {
            
            [res addObject:[NSMutableDictionary dictionaryWithDictionary:
                            @{ @"icon": item_[@"photo_50"],
                               @"name": ([item_ objectForKey:@"name"] ?
                                         item_[@"name"] :
                                         [NSString stringWithFormat:@"%@ %@", item_[@"first_name"], item_[@"second_name"]]
                                         ),
                               @"domain": item_[@"screen_name"],
                               @"selected": @(NO) }]];
        }
    }
    return res;
}

+(NSMutableDictionary *)parsePlaylist:(id)json
{
    NSMutableDictionary *temp = [NSMutableDictionary dictionary];

    NSDictionary *item = json[@"items"][0];
    
    if ([item objectForKey:@"text"]) {
        temp[@"text"] = item[@"text"];
    }
    
    NSArray *attachments = item[@"attachments"];
    if (!attachments) {     //it's a repost
        NSDictionary *repost = item[@"copy_history"][0];
        attachments = repost[@"attachments"];
    }
    if (!attachments) {
        return nil;
    }
    
    BOOL wasAtLeastOneSong = NO;
    BOOL wasAtLeastOnePhoto = NO;
    BOOL isSecondPhoto = NO;
    
    NSString *videoFrameUrl;
    temp[@"songs"] = [NSMutableArray array];
    temp[@"date"] = item[@"date"];
    
    int i = 0;
    for (NSDictionary *attachment in attachments) {
        if ([attachment[@"type"] isEqualToString:@"photo"])
        {
            wasAtLeastOnePhoto = YES;
            
            if (isSecondPhoto) {
                temp[@"secondPhotoUrl"] = attachment[@"photo"][@"photo_604"];
            }
            else {
                temp[@"photoUrl"] = attachment[@"photo"][@"photo_604"];
                isSecondPhoto = YES;
            }
        }
        else if ([attachment[@"type"] isEqualToString:@"audio"]) {
            wasAtLeastOneSong = YES;
            
            NSDictionary *item = attachment[@"audio"];
            
            [temp[@"songs"] addObject:@{
                                        @"artist": item[@"artist"],
                                        @"title": item[@"title"],
                                        @"duration": item[@"duration"],
                                        @"url": item[@"url"],
                                        @"index": [NSNumber numberWithInt:i++]
                                        }];
        }
        else if ([attachment[@"type"] isEqualToString:@"video"]) {
            videoFrameUrl = attachment[@"video"][@"photo_800"];
        }
    }

    if (!wasAtLeastOneSong) {
        return nil;
    }
    
    if (!wasAtLeastOnePhoto) {
        if (videoFrameUrl == nil) {
            return nil;
        }
        
        temp[@"photoUrl"] = videoFrameUrl;
    }
    
    return temp;
}

@end
