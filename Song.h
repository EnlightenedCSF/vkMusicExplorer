//
//  Song.h
//  
//
//  Created by Ольферук Александр on 30.07.15.
//
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class Playlist;

@interface Song : NSManagedObject

@property (nonatomic, retain) NSString * artist;
@property (nonatomic, retain) NSNumber * duration;
@property (nonatomic, retain) NSString * title;
@property (nonatomic, retain) NSString * url;
@property (nonatomic, retain) NSNumber * index;
@property (nonatomic, retain) Playlist *playlist;

@end
