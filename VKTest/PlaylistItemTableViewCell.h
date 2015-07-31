//
//  PlaylistItemTableViewCell.h
//  VKTest
//
//  Created by Ольферук Александр on 27.07.15.
//  Copyright (c) 2015 EnlightenedCSF. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "Song.h"

@protocol VKPlaylistProtocol <NSObject>

-(void)onPlayPauseBtnTapped:(id)sender;

@end

@interface PlaylistItemTableViewCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UIButton *playPauseBtn;
@property (weak, nonatomic) IBOutlet UILabel *songTitleLabel;
@property (weak, nonatomic) IBOutlet UILabel *songDurationLabel;

@property (weak, nonatomic) id<VKPlaylistProtocol> delegate;

@property (assign, nonatomic) BOOL isPlaying;

-(void)fillWithTitle:(NSString *)title duration:(int)duration;
-(void)fillWithSong:(Song *)song;

-(void)hideDetails;

@end
