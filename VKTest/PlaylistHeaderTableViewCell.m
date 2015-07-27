//
//  PlaylistHeaderTableViewCell.m
//  VKTest
//
//  Created by Ольферук Александр on 27.07.15.
//  Copyright (c) 2015 EnlightenedCSF. All rights reserved.
//

#import "PlaylistHeaderTableViewCell.h"

@interface PlaylistHeaderTableViewCell ()

@property (strong, nonatomic) IBOutlet UIImageView *pic;

@end


@implementation PlaylistHeaderTableViewCell

- (void)awakeFromNib {
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

-(void)fill:(NSString *)photoUrl {
    UIImage *imageToShow = [UIImage imageWithData:[NSData dataWithContentsOfURL:[NSURL URLWithString:photoUrl]]];
    
    CGRect cropRect = CGRectMake((imageToShow.size.width - self.pic.bounds.size.width)/2.0f,
                                 (imageToShow.size.height - self.pic.bounds.size.height)/2.0f,
                                 self.pic.bounds.size.width,
                                 self.pic.bounds.size.height);
    CGImageRef imageRef = CGImageCreateWithImageInRect(imageToShow.CGImage, cropRect);
    // or use the UIImage wherever you like
    [self.pic setImage:[UIImage imageWithCGImage:imageRef]];
    CGImageRelease(imageRef);
}

@end
