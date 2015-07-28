//
//  Playlist.m
//  VKTest
//
//  Created by Ольферук Александр on 28.07.15.
//  Copyright (c) 2015 EnlightenedCSF. All rights reserved.
//

#import "VMEPlaylist.h"

@implementation VMEPlaylist

-(id)init {
    if (self = [super init]) {
        self.songs = [NSMutableArray array];
    }
    return self;
}

@end
