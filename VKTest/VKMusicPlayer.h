//
//  MusicPlayer.h
//  VKTest
//
//  Created by Ольферук Александр on 30.07.15.
//  Copyright (c) 2015 EnlightenedCSF. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "Song.h"

@protocol VKMusicPlayerProtocol <NSObject>

-(void)needToSwitchToNextSong;

@end

@interface VKMusicPlayer : NSObject

+(VKMusicPlayer *)sharedPlayer;

@property (strong, nonatomic) NSMutableArray *playlist;
@property (assign, nonatomic) int index;

@property (weak, nonatomic) id<VKMusicPlayerProtocol> delegate;

-(Song *)getCurrentTrack;
-(Song *)getTrackAtIndex:(NSInteger)index;


-(BOOL)playing;
-(BOOL)isSongIsPlayingAtIndex:(NSInteger)index;

-(void)playPause;
-(void)togglePlayingAtIndex:(int)index;

-(float)getCurrentSongProgress;

-(BOOL)switchTrackToNext;
-(BOOL)switchTrackToPrevious;

@end
