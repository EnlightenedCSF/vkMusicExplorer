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
#import "VMEUtils.h"

@interface PlaylistHeaderTableViewCell ()

@property (strong, nonatomic) IBOutlet UIImageView *pic;
@property (weak, nonatomic) IBOutlet UIView *twoPicView;
@property (weak, nonatomic) IBOutlet UIImageView *picLeft;
@property (weak, nonatomic) IBOutlet UIImageView *picRight;

@property (assign, atomic) BOOL oneIsReady;

@property (weak, nonatomic) IBOutlet UILabel *timeLbl;

@property (weak, nonatomic) IBOutlet UIButton *showPostDataBtn;
@property (assign, nonatomic) BOOL isShowingPostText;
@property (weak, nonatomic) IBOutlet UITextView *postTextView;

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *showPostBtnLeft;

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
    self.timeLbl.text = [VMEUtils dateTimeStringFromDateStamp:[pl.date doubleValue]];
}

-(void)showPost
{
    self.showPostBtnLeft.constant = self.showPostBtnLeft.constant + self.postTextView.bounds.size.width - self.showPostDataBtn.bounds.size.width;
    [UIView animateWithDuration:0.5 animations:^{
        [self layoutIfNeeded];
    }];
    
    [UIView animateWithDuration:0.5 animations:^{
        _postTextView.alpha = 1;
    }];
}

-(void)hidePost
{
    self.showPostBtnLeft.constant = self.showPostBtnLeft.constant - self.postTextView.bounds.size.width + self.showPostDataBtn.bounds.size.width;
    [UIView animateWithDuration:0.5 animations:^{
        [self layoutIfNeeded];
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
