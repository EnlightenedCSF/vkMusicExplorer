//
//  MusicPlayer.h
//  VKTest
//
//  Created by Ольферук Александр on 30.07.15.
//  Copyright (c) 2015 EnlightenedCSF. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "Song.h"

@interface VKMusicPlayer : NSObject

+(VKMusicPlayer *)sharedPlayer;

@property (strong, nonatomic) NSMutableArray *playlist;
@property (assign, nonatomic) int index;

-(Song *)getCurrentTrack;
-(Song *)getTrackAtIndex:(NSInteger)index;


-(BOOL)playing;
-(BOOL)isSongIsPlayingAtIndex:(NSInteger)index;

-(void)playPause;
-(void)togglePlayingAtIndex:(int)index;

-(float)getCurrentSongProgress;

-(void)switchTrackToNext;
-(void)switchTrackToPrevious;

@end
