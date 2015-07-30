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
@property (weak, nonatomic) IBOutlet UILabel *timeLbl;

@end


@implementation PlaylistHeaderTableViewCell

-(void)fill:(NSString *)photoUrl andTime:(NSNumber *)time
{
    self.pic.contentMode = UIViewContentModeScaleAspectFit;
    [self.pic sd_setImageWithURL:[NSURL URLWithString:photoUrl]];
    
    NSDate *date = [NSDate dateWithTimeIntervalSince1970:[time doubleValue]];
    
    NSDateFormatter *formatter = [NSDateFormatter new];
    [formatter setTimeStyle:NSDateFormatterShortStyle];
    [formatter setDateStyle:NSDateFormatterLongStyle];
    
    self.timeLbl.text = [formatter stringFromDate:date];

}

@end
