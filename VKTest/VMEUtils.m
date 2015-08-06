//
//  VMEUtils.m
//  VKTest
//
//  Created by Ольферук Александр on 04.08.15.
//  Copyright (c) 2015 EnlightenedCSF. All rights reserved.
//

#import "VMEUtils.h"
#import "NSString+URLEncoded.h"

#import "UIFont+FontAwesome.h"

#import <AFNetworking.h>
#import <TFHpple.h>
#import <LGHelper.h>
#import <UIImageView+WebCache.h>

@import MediaPlayer;

#define LYRICS_BASE_URL @"http://search.azlyrics.com/search.php?q="
#define XPATH_FOR_URL @"//td[@class='text-left visitedlyr']/a/@href"
#define XPATH_FOR_LYRICS @"//div[@class='col-xs-12 col-lg-8 text-center']/div[6]"

@implementation VMEUtils

+(NSString *)dateTimeStringFromDateStamp:(double)timeStamp
{
    NSDate *date = [NSDate dateWithTimeIntervalSince1970:timeStamp];
    
    NSDateFormatter *formatter = [NSDateFormatter new];
    [formatter setTimeStyle:NSDateFormatterShortStyle];
    [formatter setDateStyle:NSDateFormatterLongStyle];
    
    return [formatter stringFromDate:date];
}

+(NSString *)dateStringFromDateStamp:(double)timeStamp
{
    NSDate *date = [NSDate dateWithTimeIntervalSince1970:timeStamp];
    
    NSDateFormatter *formatter = [NSDateFormatter new];
    [formatter setTimeStyle:NSDateFormatterNoStyle];
    [formatter setDateStyle:NSDateFormatterShortStyle];
    
    return [formatter stringFromDate:date];
}

+(UIImage *)imageWithFAEnum:(FAWEIcon)symbol size:(CGSize)size {
    return [self imageWithFAEnum:symbol size:size color:[UIColor blackColor]];
}

+(UIImage *)imageWithFAEnum:(FAWEIcon)symbol size:(CGSize)size color:(UIColor *)color
{
    NSString *s = [NSString fontAwesomeIconStringForEnum:symbol];
    
    UIGraphicsBeginImageContext(size);
    
    UIFont *font = [UIFont iconicFontOfSize:size.width];
    
    CGSize stringSize = [s sizeWithAttributes:@{ NSFontAttributeName: font }];
    
    CGFloat xRatio = size.width / stringSize.width;
    CGFloat yRatio = size.height / stringSize.height;
    CGFloat ratio = MIN(xRatio, yRatio);
    
    CGFloat oldFontSize = font.pointSize;
    CGFloat newFontSize = floor(oldFontSize * ratio);
    ratio = newFontSize / oldFontSize;
    font = [font fontWithSize:newFontSize];
    
    stringSize = [s sizeWithAttributes:@{ NSFontAttributeName: font }];
    
    CGPoint textOrigin = CGPointMake((size.width - stringSize.width) / 2,
                                     (size.height - stringSize.height) / 2);
    
    [s drawAtPoint:textOrigin withAttributes:@{ NSFontAttributeName: font,
                                                NSForegroundColorAttributeName: color
                                                    }];
    
    UIImage *retImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return retImage;
}

+(void)updateControlCenterWithSong:(Song *)song elapsedTime:(double)elapsed
{
    [MPNowPlayingInfoCenter defaultCenter].nowPlayingInfo = @{
                                                              MPMediaItemPropertyTitle : song.title,
                                                              MPMediaItemPropertyArtist : song.artist,
                                                              MPNowPlayingInfoPropertyPlaybackRate : @1.0f,
                                                              MPMediaItemPropertyPlaybackDuration : song.duration,
                                                              MPNowPlayingInfoPropertyElapsedPlaybackTime : @(elapsed)
                                                            };
}

+(void)songLyricsOfArtist:(NSString *)artist title:(NSString *)title completion:(void (^)(NSString *))callback
{
    NSString *q = [[NSString stringWithFormat:@"%@ %@", artist, title] URLEncoded];
    NSString *request = [NSString stringWithFormat:@"%@%@", LYRICS_BASE_URL, q];
    
    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
    manager.responseSerializer = [AFHTTPResponseSerializer new];
    manager.requestSerializer = [AFHTTPRequestSerializer serializer];
    [manager GET:request parameters:nil success:^(NSURLSessionDataTask *task, id responseObject)
    {
        TFHpple * doc = [[TFHpple alloc] initWithHTMLData:responseObject];
        TFHppleElement *element = [[doc searchWithXPathQuery:XPATH_FOR_URL] firstObject];
        if (!element) {
            callback(LS(@"CANT FIND LYRICS"));
        }
        NSString *url = [element text];
        
        AFHTTPSessionManager *second = [AFHTTPSessionManager manager];
        second.responseSerializer = [AFHTTPResponseSerializer new];
        second.requestSerializer = [AFHTTPRequestSerializer serializer];
        [second GET:url parameters:nil success:^(NSURLSessionDataTask *task, id responseObject)
        {
            TFHpple * doc = [[TFHpple alloc] initWithHTMLData:responseObject];
            TFHppleElement *element = [[doc searchWithXPathQuery:XPATH_FOR_LYRICS] firstObject];
            if (!element) {
                callback(LS(@"CANT FIND LYRICS"));
            }
            callback([element raw]);
            
        } failure:^(NSURLSessionDataTask *task, NSError *error) {
            NSLog(@"Lyrics error: %@", [error localizedDescription]);
        }];
        
    } failure:^(NSURLSessionDataTask *task, NSError *error) {
        NSLog(@"Lyrics error: %@", [error localizedDescription]);
    }];
}

@end
