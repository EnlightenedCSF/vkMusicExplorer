//
//  Playlist.h
//  
//
//  Created by Ольферук Александр on 28.07.15.
//
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class Song, SourceGroup;

@interface Playlist : NSManagedObject

@property (nonatomic, retain) NSString * photoUrl;
@property (nonatomic, retain) NSSet *songs;
@property (nonatomic, retain) SourceGroup *source;
@end

@interface Playlist (CoreDataGeneratedAccessors)

- (void)addSongsObject:(Song *)value;
- (void)removeSongsObject:(Song *)value;
- (void)addSongs:(NSSet *)values;
- (void)removeSongs:(NSSet *)values;

@end
