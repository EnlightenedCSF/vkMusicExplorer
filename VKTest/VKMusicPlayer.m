//
//  MusicPlayer.m
//  VKTest
//
//  Created by Ольферук Александр on 30.07.15.
//  Copyright (c) 2015 EnlightenedCSF. All rights reserved.
//
#import <STKAudioPlayer.h>

#import "VKMusicPlayer.h"
#import "VMEUtils.h"

@import AVFoundation;

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
    
    [[UIApplication sharedApplication] beginReceivingRemoteControlEvents];
    
    AVAudioSession *audioSession = [AVAudioSession sharedInstance];
    NSError *setCategoryError = nil;
    [audioSession setCategory:AVAudioSessionCategoryPlayback error:&setCategoryError];

    return self;
}

-(void)dealloc
{
    [[UIApplication sharedApplication] endReceivingRemoteControlEvents];
}

-(void)getDataFromPlaylist:(Playlist *)playlist
{
    if (self.photoUrl && [self.photoUrl isEqualToString:playlist.photoUrl]) {
        return;
    }
    
    _playlist = [[[playlist.songs mutableCopy] allObjects] sortedArrayUsingComparator:^NSComparisonResult(id obj1, id obj2) {
        Song *a = (Song *)obj1;
        Song *b = (Song *)obj2;
        return a.index > b.index;
    }];
    _isReloading = YES;
    
    _photoUrl = playlist.photoUrl;
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

-(NSString *)getCurrentSongProgressText
{
    Song *song = [self getCurrentTrack];
    double duration = [song.duration doubleValue];
    int min = floor(duration / 60.0);
    int sec = (int)duration % 60;
    NSString *total = [NSString stringWithFormat:(sec < 10 ? @"%d:0%d" : @"%d:%d"), min, sec];
    
    double progress = [_player progress];
    min = floor(progress / 60.0);
    sec = (int)progress % 60;
    NSString *current = [NSString stringWithFormat:(sec < 10 ? @"%d:0%d" : @"%d:%d"), min, sec];
    
    return [NSString stringWithFormat:@"[ %@ / %@ ]", current, total];
}

-(void)startPlayingFromBeginning
{
    _index = 0;
    _isReloading = NO;
    [self playCurrentSong];
}

-(void)pause
{
    if (_player.state == STKAudioPlayerStatePlaying) {
        [_player pause];
    }
}

-(void)play
{
    if (_player.state == STKAudioPlayerStatePaused) {
        [_player resume];
    }
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
        [VMEUtils updateControlCenterWithSong:[self getCurrentTrack] elapsedTime:_player.progress];
        if (_isReloading) {
            _isReloading = NO;
        }
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
                else
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
    [VMEUtils updateControlCenterWithSong:[self getCurrentTrack] elapsedTime:_player.progress];
}

-(void)seekToPositionInCurrentSong:(float)position
{
    double time = _player.duration * position;
    [_player seekToTime:time];
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
