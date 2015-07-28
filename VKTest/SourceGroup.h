//
//  SourceGroup.h
//  
//
//  Created by Ольферук Александр on 28.07.15.
//
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class Playlist;

@interface SourceGroup : NSManagedObject

@property (nonatomic, retain) NSString * domain;
@property (nonatomic, retain) NSString * icon;
@property (nonatomic, retain) NSString * name;
@property (nonatomic, retain) NSSet *playlists;
@end

@interface SourceGroup (CoreDataGeneratedAccessors)

- (void)addPlaylistsObject:(Playlist *)value;
- (void)removePlaylistsObject:(Playlist *)value;
- (void)addPlaylists:(NSSet *)values;
- (void)removePlaylists:(NSSet *)values;

@end
