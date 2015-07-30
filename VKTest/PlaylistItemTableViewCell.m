//
//  PlaylistItemTableViewCell.m
//  VKTest
//
//  Created by Ольферук Александр on 27.07.15.
//  Copyright (c) 2015 EnlightenedCSF. All rights reserved.
//

#import "PlaylistItemTableViewCell.h"

@implementation PlaylistItemTableViewCell

-(void) fillWithTitle:(NSString *)title duration:(int)duration {
    [self showDetails];
    self.isPlaying = NO;
    
    self.songTitleLabel.text = title;
    
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

- (IBAction)playPauseBtnTapped:(UIButton *)sender
{
    self.isPlaying = !self.isPlaying;
    [self.playPauseBtn setImage:[UIImage imageNamed:(self.isPlaying ? @"icon_pause" : @"icon_play")] forState:UIControlStateNormal];
    
    if ([_delegate respondsToSelector:@selector(onPlayPauseBtnTapped:)]) {
        [_delegate onPlayPauseBtnTapped:self];
    }
}

@end
