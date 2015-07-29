//
//  PlaylistItemTableViewCell.m
//  VKTest
//
//  Created by Ольферук Александр on 27.07.15.
//  Copyright (c) 2015 EnlightenedCSF. All rights reserved.
//

#import "PlaylistItemTableViewCell.h"

@implementation PlaylistItemTableViewCell

- (void)awakeFromNib {
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

-(void) fillWithTitle:(NSString *)title duration:(NSNumber *)duration {
    [self showDetails];
    
    self.songTitleLabel.text = title;
    
    int mins = (int)[duration integerValue] / 60;
    int secs = [duration integerValue] % 60;
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

@end
