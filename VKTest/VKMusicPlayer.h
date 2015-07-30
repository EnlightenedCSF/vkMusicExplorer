//
//  MusicPlayer.h
//  VKTest
//
//  Created by Ольферук Александр on 30.07.15.
//  Copyright (c) 2015 EnlightenedCSF. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AVFoundation/AVFoundation.h>

#import "Song.h"

@interface VKMusicPlayer : NSObject

+(VKMusicPlayer *)sharedPlayer;

@property (strong, nonatomic) NSMutableArray *playlist;
@property (assign, nonatomic) int index;

-(void)togglePlayingAtIndex:(int)index;

//-(void)song:(Song *)song isNowPlaying:(BOOL)isPlaying;

@end
