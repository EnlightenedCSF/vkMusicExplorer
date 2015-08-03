//
//  VKTabBarViewController.m
//  VKTest
//
//  Created by Ольферук Александр on 03.08.15.
//  Copyright (c) 2015 EnlightenedCSF. All rights reserved.
//

#import "VKTabBarViewController.h"

#import "UIFont+FontAwesome.h"
#import "NSString+FontAwesome.h"

@interface VKTabBarViewController ()

@end

@implementation VKTabBarViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    UITabBarItem *explore = self.tabBar.items[0];
    explore.selectedImage = [self imageWithString:[NSString fontAwesomeIconStringForEnum:FAWEIconSearch] size:CGSizeMake(26, 26)];
    explore.image = [self imageWithString:[NSString fontAwesomeIconStringForEnum:FAWEIconSearch] size:CGSizeMake(24, 24)];
    
    UITabBarItem *favs = self.tabBar.items[1];
    favs.selectedImage = [self imageWithString:[NSString fontAwesomeIconStringForEnum:FAWEIconStar] size:CGSizeMake(26, 26)];
    favs.image = [self imageWithString:[NSString fontAwesomeIconStringForEnum:FAWEIconStar] size:CGSizeMake(24, 24)];

    UITabBarItem *player = self.tabBar.items[2];
    player.selectedImage = [self imageWithString:[NSString fontAwesomeIconStringForEnum:FAWEIconPlayCircle] size:CGSizeMake(26, 26)];
    player.image = [self imageWithString:[NSString fontAwesomeIconStringForEnum:FAWEIconPlayCircle] size:CGSizeMake(24, 24)];
}

-(UIImage *)imageWithString:(NSString *)string size:(CGSize)size
{
    UIGraphicsBeginImageContext(size);
    
    UIFont *font = [UIFont iconicFontOfSize:size.width];
    
    CGSize stringSize = [string sizeWithFont:font];
    
    CGFloat xRatio = size.width / stringSize.width;
    CGFloat yRatio = size.height / stringSize.height;
    CGFloat ratio = MIN(xRatio, yRatio);
    
    CGFloat oldFontSize = font.pointSize;
    CGFloat newFontSize = floor(oldFontSize * ratio);
    ratio = newFontSize / oldFontSize;
    font = [font fontWithSize:newFontSize];
    
    stringSize = [string sizeWithFont:font];
    
    CGPoint textOrigin = CGPointMake((size.width - stringSize.width) / 2,
                                     (size.height - stringSize.height) / 2);
    
    [string drawAtPoint:textOrigin withFont:font];
    
    UIImage *retImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return retImage;
}


@end
