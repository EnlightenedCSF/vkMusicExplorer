//
//  MusicPlayer.h
//  VKTest
//
//  Created by Ольферук Александр on 30.07.15.
//  Copyright (c) 2015 EnlightenedCSF. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "Song.h"
#import "Playlist.h"

@protocol VKMusicPlayerProtocol <NSObject>

-(void)needToSwitchToNextSong;

@end

@interface VKMusicPlayer : NSObject

+(VKMusicPlayer *)sharedPlayer;

@property (copy, nonatomic) NSString *photoUrl;
@property (strong, nonatomic) NSArray *playlist;
@property (assign, nonatomic) int index;

@property (weak, nonatomic) id<VKMusicPlayerProtocol> delegate;

-(void)getDataFromPlaylist:(Playlist *)playlist;

-(Song *)getCurrentTrack;
-(Song *)getTrackAtIndex:(NSInteger)index;

-(BOOL)playing;
-(BOOL)isSongIsPlayingAtIndex:(NSInteger)index;

-(void)startPlayingFromBeginning;
-(void)playPause;
-(void)togglePlayingAtIndex:(int)index;

-(float)getCurrentSongProgress;
-(NSString *)getCurrentSongProgressText;

-(BOOL)switchTrackToNext;
-(BOOL)switchTrackToPrevious;

-(void)seekToPositionInCurrentSong:(float)position;

@end
