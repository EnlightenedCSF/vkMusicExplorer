//
//  VMEUtils.m
//  VKTest
//
//  Created by Ольферук Александр on 04.08.15.
//  Copyright (c) 2015 EnlightenedCSF. All rights reserved.
//

#import "VMEUtils.h"
#import "Song.h"

#import "UIFont+FontAwesome.h"

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
    
    //CGSize stringSize = [s sizeWithFont:font];
    CGSize stringSize = [s sizeWithAttributes:@{ NSFontAttributeName: font }];
    
    CGFloat xRatio = size.width / stringSize.width;
    CGFloat yRatio = size.height / stringSize.height;
    CGFloat ratio = MIN(xRatio, yRatio);
    
    CGFloat oldFontSize = font.pointSize;
    CGFloat newFontSize = floor(oldFontSize * ratio);
    ratio = newFontSize / oldFontSize;
    font = [font fontWithSize:newFontSize];
    
    //stringSize = [s sizeWithFont:font];
    stringSize = [s sizeWithAttributes:@{ NSFontAttributeName: font }];
    
    CGPoint textOrigin = CGPointMake((size.width - stringSize.width) / 2,
                                     (size.height - stringSize.height) / 2);
    
    //[s drawAtPoint:textOrigin withFont:font];
    [s drawAtPoint:textOrigin withAttributes:@{ NSFontAttributeName: font,
                                                NSForegroundColorAttributeName: color
                                                    }];
    
    UIImage *retImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return retImage;
}

@end
