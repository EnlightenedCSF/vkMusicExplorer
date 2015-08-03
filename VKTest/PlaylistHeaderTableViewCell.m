//
//  PlaylistHeaderTableViewCell.m
//  VKTest
//
//  Created by Ольферук Александр on 27.07.15.
//  Copyright (c) 2015 EnlightenedCSF. All rights reserved.
//

#import <SDWebImage/UIImageView+WebCache.h>

#import "PlaylistHeaderTableViewCell.h"

#import "UIButton+FAWE.h"
#import "VMEConsts.h"

@interface PlaylistHeaderTableViewCell ()

@property (weak, nonatomic) IBOutlet UIView *header;

@property (strong, nonatomic) IBOutlet UIImageView *pic;
@property (weak, nonatomic) IBOutlet UIView *twoPicView;
@property (weak, nonatomic) IBOutlet UIImageView *picLeft;
@property (weak, nonatomic) IBOutlet UIImageView *picRight;

@property (assign, atomic) BOOL oneIsReady;

@property (weak, nonatomic) IBOutlet UILabel *timeLbl;

@property (weak, nonatomic) IBOutlet UIButton *showPostDataBtn;
@property (assign, nonatomic) BOOL isShowingPostText;
@property (weak, nonatomic) IBOutlet UITextView *postTextView;

@end


@implementation PlaylistHeaderTableViewCell

-(void)awakeFromNib
{
    [_showPostDataBtn setIconAlign:(FAWEButtonIconAlignCenter)];
    [_showPostDataBtn setIconColor:[VMEConsts defaultBlueColor]];
    [_showPostDataBtn setIcon:(FAWEIconEyeOpen)];
    [_showPostDataBtn setIconSize:32];
    
    _oneIsReady = NO;
}

-(void)fill:(Playlist *)playlist
{
    _isShowingPostText = NO;
    _postTextView.text = playlist.text;
    
    _pic.hidden = YES;
    _twoPicView.hidden = YES;
    
    _pic.contentMode = UIViewContentModeScaleAspectFit;
    _picLeft.contentMode = UIViewContentModeScaleAspectFit;
    _picRight.contentMode = UIViewContentModeScaleAspectFit;
    
    [self setTime:playlist];
    
    if (playlist.secondPhotoUrl == nil || [@"" isEqualToString:playlist.secondPhotoUrl]) // one photo
    {
        _pic.hidden = NO;
        
        [_pic sd_setImageWithURL:[NSURL URLWithString:playlist.photoUrl]];
    }
    else    // two
    {
        _twoPicView.hidden = NO;
        
        [_picLeft sd_setImageWithURL:[NSURL URLWithString:playlist.photoUrl]];
        [_picRight sd_setImageWithURL:[NSURL URLWithString:playlist.secondPhotoUrl]];
    }
}

-(void)setTime:(Playlist *)pl
{
    NSDate *date = [NSDate dateWithTimeIntervalSince1970:[pl.date doubleValue]];
    
    NSDateFormatter *formatter = [NSDateFormatter new];
    [formatter setTimeStyle:NSDateFormatterShortStyle];
    [formatter setDateStyle:NSDateFormatterLongStyle];
    
    self.timeLbl.text = [formatter stringFromDate:date];
}

-(void)showPost
{
    [UIView animateWithDuration:0.5 animations:^{
        _showPostDataBtn.center = CGPointMake(
                _showPostDataBtn.center.x + _postTextView.bounds.size.width - _showPostDataBtn.bounds.size.width,
                _showPostDataBtn.center.y);
        }];
    [UIView animateWithDuration:0.5 animations:^{
        _postTextView.alpha = 1;
    }];
}

-(void)hidePost
{
    [UIView animateWithDuration:0.5 animations:^{
        _showPostDataBtn.center = CGPointMake(
                _showPostDataBtn.center.x - _postTextView.bounds.size.width + _showPostDataBtn.bounds.size.width,
                _showPostDataBtn.center.y);
    }];
    [UIView animateWithDuration:0.5 animations:^{
        _postTextView.alpha = 0;
    }];
}

- (IBAction)showPostTapped:(id)sender {
    if (!_isShowingPostText) {
        [_showPostDataBtn setIcon:(FAWEIconEyeClose)];
        [self showPost];
    }
    else {
        [_showPostDataBtn setIcon:(FAWEIconEyeOpen)];
        [self hidePost];
    }
    _isShowingPostText = !_isShowingPostText;
}

@end
