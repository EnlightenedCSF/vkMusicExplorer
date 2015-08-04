//
//  MusiXmatchService.h
//  MusiXmatch
//
//  Created by Roman Shterenzon on 9/27/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

// Set this!
#define APIKEY @"d4f724b93c55d168a323ea810ed119c9"
#define APIBASE @"http://api.musixmatch.com/ws/1.1/"
#define APIFORMAT @"json"

#define USER_AGENT @"MusiXmatchObjC/1.0"

// Method names
#define TRACK_GET @"track.get"
#define TRACK_SEARCH @"track.search"
#define LYRICS_GET @"lyrics.get"
#define LYRICS_GET_TRACK @"track.lyrics.get"
#define LYRICS_GET_MATCHER @"matcher.lyrics.get"

@class Track;

@interface MusiXmatchService : NSObject {

}

// Get a singleton instance
+ (MusiXmatchService*)sharedInstance;

// Query all fields, return limited number of results
- (NSArray*)trackSearch:(NSString *)query numResults:(NSUInteger)numResults;
// Return only one track
- (Track*)trackSearch:(NSString*)artist track:(NSString*)track;
- (NSString*)getLyrics:(NSUInteger)lyricsId;
- (Track*)getTrack:(NSUInteger)trackId;

-(NSString *)getLyricsOfArtist:(NSString *)artist track:(NSString *)track;

@end
