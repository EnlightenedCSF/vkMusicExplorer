//
//  VMEUtils.h
//  VKTest
//
//  Created by Ольферук Александр on 04.08.15.
//  Copyright (c) 2015 EnlightenedCSF. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

#import "Playlist.h"
#import "Song.h"
#import "NSString+FontAwesome.h"

@interface VMEUtils : NSObject

+(NSString *)dateTimeStringFromDateStamp:(double)timeStamp;
+(NSString *)dateStringFromDateStamp:(double)timeStamp;

+(UIImage *)imageWithFAEnum:(FAWEIcon)symbol size:(CGSize)size;
+(UIImage *)imageWithFAEnum:(FAWEIcon)symbol size:(CGSize)size color:(UIColor *)color;

+(void)songLyricsOfArtist:(NSString *)artist title:(NSString *)title completion:(void (^)(NSString *))callback;

+(void)updateControlCenterWithSong:(Song *)song elapsedTime:(double)elapsed;

@end
