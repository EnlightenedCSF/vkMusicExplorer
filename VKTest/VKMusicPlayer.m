//
//  MusicPlayer.m
//  VKTest
//
//  Created by Ольферук Александр on 30.07.15.
//  Copyright (c) 2015 EnlightenedCSF. All rights reserved.
//
#import <STKAudioPlayer.h>

#import "VKMusicPlayer.h"

@interface VKMusicPlayer () <STKAudioPlayerDelegate>

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
        self.player.delegate = self;
        
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

-(BOOL)switchTrackToNext
{
    if (_index == _playlist.count-1) {
        return NO;
    }
    ++_index;
    
    if (_player.state == STKAudioPlayerStatePlaying) {
        [self playCurrentSong];
    }
    return YES;
}

-(BOOL)switchTrackToPrevious
{
    if (_index == 0) {
        return NO;
    }
    --_index;
    
    if (_player.state == STKAudioPlayerStatePlaying) {
        [self playCurrentSong];
    }
    return YES;
}

-(void)playCurrentSong
{
    Song *s = [self getCurrentTrack];
    [_player playURL:[NSURL URLWithString:s.url]];
}

# pragma mark - STK Audio Player Delegate

/// Raised when an item has started playing
-(void) audioPlayer:(STKAudioPlayer*)audioPlayer didStartPlayingQueueItemId:(NSObject*)queueItemId
{
    
}

/// Raised when an item has finished buffering (may or may not be the currently playing item)
/// This event may be raised multiple times for the same item if seek is invoked on the player
-(void) audioPlayer:(STKAudioPlayer*)audioPlayer didFinishBufferingSourceWithQueueItemId:(NSObject*)queueItemId
{
    
}

/// Raised when the state of the player has changed
-(void) audioPlayer:(STKAudioPlayer*)audioPlayer stateChanged:(STKAudioPlayerState)state previousState:(STKAudioPlayerState)previousState
{
    
}

/// Raised when an item has finished playing
-(void) audioPlayer:(STKAudioPlayer*)audioPlayer didFinishPlayingQueueItemId:(NSObject*)queueItemId withReason:(STKAudioPlayerStopReason)stopReason andProgress:(double)progress andDuration:(double)duration
{
    if (abs((int)(duration - progress)) < 1) {
        if (![self switchTrackToNext]) {
            return;
        }
        
        [self playCurrentSong];
        if ([_delegate respondsToSelector:@selector(needToSwitchToNextSong)]) {
            [_delegate needToSwitchToNextSong];
        }

    }
}

/// Raised when an unexpected and possibly unrecoverable error has occured (usually best to recreate the STKAudioPlauyer)
-(void) audioPlayer:(STKAudioPlayer*)audioPlayer unexpectedError:(STKAudioPlayerErrorCode)errorCode
{
    switch (errorCode) {
        case STKAudioPlayerErrorNone:
            NSLog(@"Error none");
            break;
        case STKAudioPlayerErrorDataSource:
            NSLog(@"Error with data source");
            break;
        case STKAudioPlayerErrorStreamParseBytesFailed:
            NSLog(@"Error parsing byte stream");
            break;
        case STKAudioPlayerErrorAudioSystemError:
            NSLog(@"Error with audio system");
            break;
        case STKAudioPlayerErrorCodecError:
            NSLog(@"Error with codec");
            break;
        case STKAudioPlayerErrorOther:
            NSLog(@"Other error");
            break;
        default:
            NSLog(@"Other error");
            break;
    }
}


@end
