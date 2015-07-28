//
//  Playlist.h
//  VKTest
//
//  Created by Ольферук Александр on 28.07.15.
//  Copyright (c) 2015 EnlightenedCSF. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface VMEPlaylist : NSObject

@property (copy, nonatomic) NSString *photoUrl;
@property (strong, nonatomic) NSMutableArray *songs;

@end
