//
//  MusicPlayer.m
//  VKTest
//
//  Created by Ольферук Александр on 30.07.15.
//  Copyright (c) 2015 EnlightenedCSF. All rights reserved.
//
#import <STKAudioPlayer.h>

#import "VKMusicPlayer.h"

@interface VKMusicPlayer ()

@property (strong, nonatomic) STKAudioPlayer *player;
@property (assign, nonatomic) BOOL isReloading;

@end

@implementation VKMusicPlayer

@synthesize playlist = _playlist;

+(VKMusicPlayer *)sharedPlayer
{
    static dispatch_once_t once;
    static id sharedInstance;
    dispatch_once(&once, ^{
        sharedInstance = [[self alloc] init];
    });
    return sharedInstance;
}

-(id)init {
    if (self = [super init]) {
        self.player = [STKAudioPlayer new];
        self.playlist = [NSMutableArray array];
        self.index = -1;
        self.isReloading = NO;
    }
    return self;
}

-(void)setPlaylist:(NSMutableArray *)playlist
{
    _playlist = playlist;
    _isReloading = YES;
}

#pragma mark - 

-(BOOL)playing
{
    return _player.state != STKAudioPlayerStatePaused;
}

-(BOOL)isSongIsPlayingAtIndex:(NSInteger)index
{
    return (int)index == _index;
}

-(Song *)getCurrentTrack
{
    if (_index < 0 || _index >= _playlist.count) {
        return nil;
    }
    return _playlist[_index];
}

-(Song *)getTrackAtIndex:(NSInteger)index
{
    if (index < 0 || index >= _playlist.count) {
        return nil;
    }
    return _playlist[index];

}

-(float)getCurrentSongProgress
{
    Song *song = [self getCurrentTrack];
    double total = [song.duration doubleValue];
    return (float)(_player.progress / total);    
}

-(void)playPause
{
    switch (_player.state) {
        case STKAudioPlayerStatePlaying:
        {
            [_player pause];
            break;
        }
        case STKAudioPlayerStatePaused:
        {
            [_player resume];
            break;
        }
        default:
            break;
    }
}

-(void)togglePlayingAtIndex:(int)index
{
    if (_index != index) // play it anyway
    {
        _index = index;
        Song *s = _playlist[_index];
        [_player playURL: [NSURL URLWithString:s.url]];
    }
    else {
        switch (_player.state) {
            case STKAudioPlayerStatePlaying: {
                [_player pause];
                break;
            }
            case STKAudioPlayerStatePaused: {
                if (_isReloading) {
                    [self playCurrentSong];
                    _isReloading = NO;
                }
                
                [_player resume];
                break;
            }
            default:
                break;
        }
    }
}

-(void)switchTrackToNext
{
    if (_index == _playlist.count-1) {
        return;
    }
    ++_index;
    
    if (_player.state == STKAudioPlayerStatePlaying) {
        [self playCurrentSong];
    }
}

-(void)switchTrackToPrevious
{
    if (_index == 0) {
        return;
    }
    --_index;
    
    if (_player.state == STKAudioPlayerStatePlaying) {
        [self playCurrentSong];
    }
}

-(void)playCurrentSong
{
    Song *s = [self getCurrentTrack];
    [_player playURL:[NSURL URLWithString:s.url]];
}

@end
