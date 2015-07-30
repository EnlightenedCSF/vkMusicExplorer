//
//  MusicPlayer.m
//  VKTest
//
//  Created by Ольферук Александр on 30.07.15.
//  Copyright (c) 2015 EnlightenedCSF. All rights reserved.
//

#import <AFNetworking.h>

#import "VKMusicPlayer.h"

@interface VKMusicPlayer ()

@property (strong, nonatomic) AVAudioPlayer *player;

@end

@implementation VKMusicPlayer

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
        self.player = [AVAudioPlayer new];
        self.playlist = [NSMutableArray array];
        self.index = -1;
    }
    return self;
}

-(void)togglePlayingAtIndex:(int)index
{
    if (self.index != index) { //then play it anyway
        self.index = index;
        
        NSPredicate *p = [NSPredicate predicateWithFormat:@"index == %i", index];
        
        Song *s = [[self.playlist filteredArrayUsingPredicate:p] firstObject];
        
        if (s) {
            AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
            
            manager.requestSerializer = [AFHTTPRequestSerializer serializer];
            manager.responseSerializer = [AFHTTPResponseSerializer new];
            
            [manager GET:s.url parameters:nil success:^(AFHTTPRequestOperation *operation, id responseObject) {
                
                NSLog(@"%@", [responseObject class]);
                
                NSError *error;
                self.player = [[AVAudioPlayer alloc] initWithData:responseObject error:&error];
                [self.player prepareToPlay];
                [self.player play];
                
            } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                NSLog(@"%@", [error localizedDescription]);
            }];
        }
    }
    else {
        if (self.player.playing) {
            [self.player pause];
        }
        else {
            
        }
    }
}

@end
