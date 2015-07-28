//
//  PlaylistHeaderTableViewCell.m
//  VKTest
//
//  Created by Ольферук Александр on 27.07.15.
//  Copyright (c) 2015 EnlightenedCSF. All rights reserved.
//

#import <SDWebImage/UIImageView+WebCache.h>

#import "PlaylistHeaderTableViewCell.h"

@interface PlaylistHeaderTableViewCell ()

@property (strong, nonatomic) IBOutlet UIImageView *pic;

@end


@implementation PlaylistHeaderTableViewCell

-(void)fill:(NSString *)photoUrl{
    self.pic.contentMode = UIViewContentModeScaleAspectFit;
    [self.pic sd_setImageWithURL:[NSURL URLWithString:photoUrl]];
}

@end
