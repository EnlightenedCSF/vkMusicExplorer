//
//  FavoriteCollectionViewCell.m
//  VKTest
//
//  Created by Ольферук Александр on 29.07.15.
//  Copyright (c) 2015 EnlightenedCSF. All rights reserved.
//

#import <SDWebImage/UIImageView+WebCache.h>
#import <QuartzCore/QuartzCore.h>

#import "FavoriteCollectionViewCell.h"
#import "UIButton+FAWE.h"

#import "VMEConsts.h"
#import "VMEUtils.h"

#define RADIANS(degrees) ((degrees * M_PI) / 180.0)
#define LOW_BUDGET_INFINITY 99999

@interface FavoriteCollectionViewCell ()

@property (weak, nonatomic) IBOutlet UIButton *deleteBtn;
@property (weak, nonatomic) IBOutlet UILabel *timeLbl;
@property (weak, nonatomic) IBOutlet UIImageView *isPlayingImageView;

@end

@implementation FavoriteCollectionViewCell

-(void)awakeFromNib
{
    [_deleteBtn setIconAlign:(FAWEButtonIconAlignCenter)];
    [_deleteBtn setIconColor:[VMEConsts defaultRedColor]];
    [_deleteBtn setIconSize:32];
    [_deleteBtn setIcon:FAWEIconMinusSign];
    
    UIImage *img = [VMEUtils imageWithFAEnum:FAWEIconPlayCircle size:CGSizeMake(50, 50) color:[VMEConsts defaultBlueColor]];
    [_isPlayingImageView setImage:img];
}

-(void)fillWithPlaylist:(Playlist *)playlist
{
    self.cover.contentMode = UIViewContentModeScaleAspectFit;
    [self.cover sd_setImageWithURL:[NSURL URLWithString:playlist.photoUrl]];
    
    self.timeLbl.text = [VMEUtils dateStringFromDateStamp:[playlist.date doubleValue]];
    
    self.deleteBtn.hidden = YES;
    [self stopAnimating];
}

-(void)toggleEditing
{
    self.deleteBtn.hidden = !self.deleteBtn.hidden;
    if (!self.deleteBtn.hidden) {
        [self animate];
    }
    else {
        [self stopAnimating];
    }
}


- (IBAction)deleteBtnTapped:(UIButton *)sender {
    if ([self.delegate respondsToSelector:@selector(onDeleteCell:)])
    {
        [self.delegate onDeleteCell:self];
    }
}

-(void)animate {
    CGAffineTransform leftWobble = CGAffineTransformRotate(CGAffineTransformIdentity, RADIANS(-5.0));
    CGAffineTransform rightWobble = CGAffineTransformRotate(CGAffineTransformIdentity, RADIANS(5.0));
    
    self.cover.transform = leftWobble;
    [UIView beginAnimations:@"wobble" context:(__bridge void *)(self.cover)];
    [UIView setAnimationRepeatAutoreverses:YES];
    [UIView setAnimationRepeatCount:LOW_BUDGET_INFINITY];
    [UIView setAnimationDuration:0.25];
    [UIView setAnimationDelegate:self];
    [UIView setAnimationDidStopSelector:@selector(wobbleEnded:finished:context:)];
    self.cover.transform = rightWobble; // end here & auto-reverse
    
    [UIView commitAnimations];
}

-(void)stopAnimating {
    [self.cover.layer removeAllAnimations];
    self.cover.transform = CGAffineTransformIdentity;
}

- (void) wobbleEnded:(NSString *)animationID finished:(NSNumber *)finished context:(void *)context
{
    if ([finished boolValue]) {
        UIImageView* image = (__bridge UIImageView *)context;
        image.transform = CGAffineTransformIdentity;
    }
}

-(void)setIsPlaying:(BOOL)isPlaying
{
    self.isPlayingImageView.hidden = !isPlaying;
}

@end
