//
//  PlaylistItemTableViewCell.m
//  VKTest
//
//  Created by Ольферук Александр on 27.07.15.
//  Copyright (c) 2015 EnlightenedCSF. All rights reserved.
//

#import "PlaylistItemTableViewCell.h"
#import "UILabel+Boldify.h"
#import "VMEConsts.h"

#import "UIButton+FAWE.h"

@implementation PlaylistItemTableViewCell

@synthesize isPlaying = _isPlaying;

-(void)awakeFromNib {
    [_playPauseBtn setIconAlign:(FAWEButtonIconAlignCenter)];
    [_playPauseBtn setIconColor:[VMEConsts defaultBlueColor]];
    [_playPauseBtn setIconSize:32];
}

-(void)fillWithSong:(Song *)song
{
    [self showDetails];
    [self setIsPlaying:NO];
    
    NSString *s = [NSString stringWithFormat:@"%@ - %@", song.artist, song.title];
    NSRange range = [s rangeOfString:song.artist];
    NSMutableAttributedString *attributedText = [[NSMutableAttributedString alloc] initWithString:s];
    [attributedText setAttributes:@{NSFontAttributeName:[UIFont boldSystemFontOfSize:_songTitleLabel.font.pointSize]} range:range];
    
    _songTitleLabel.attributedText = attributedText;
    _songTitleLabel.pauseInterval = 3.5f;
    _songTitleLabel.scrollSpeed = 50.0f;
    _songTitleLabel.fadeLength = 10.0f;
    
    [self setDuration:[song.duration intValue]];
}

-(void)setDuration:(int)duration
{
    int mins = duration / 60;
    int secs = duration % 60;
    NSString *sec;
    if (secs < 10) {
        sec = [NSString stringWithFormat:@"0%i", secs];
    }
    else {
        sec = [NSString stringWithFormat:@"%i", secs];
    }
    self.songDurationLabel.text = [NSString stringWithFormat:@"%i:%@", mins, sec];
}

-(void)hideDetails {
    self.songTitleLabel.hidden = YES;
    self.songDurationLabel.hidden = YES;
    self.playPauseBtn.hidden = YES;
}

-(void)showDetails {
    self.songTitleLabel.hidden = NO;
    self.songDurationLabel.hidden = NO;
    self.playPauseBtn.hidden = NO;

}

-(void)setIsPlaying:(BOOL)isPlaying
{
    _isPlaying = isPlaying;
    [_playPauseBtn setIcon:(_isPlaying ? FAWEIconPause : FAWEIconPlay)];
}

- (IBAction)playPauseBtnTapped:(UIButton *)sender
{
    _isPlaying = !_isPlaying;
    [self setIsPlaying: _isPlaying];
    
    if ([_delegate respondsToSelector:@selector(onPlayPauseBtnTapped:)]) {
        [_delegate onPlayPauseBtnTapped:self];
    }
}

@end
