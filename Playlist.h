//
//  Playlist.h
//  
//
//  Created by Ольферук Александр on 03.08.15.
//
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class Song, SourceGroup;

@interface Playlist : NSManagedObject

@property (nonatomic, retain) NSNumber * date;
@property (nonatomic, retain) NSNumber * isFavorite;
@property (nonatomic, retain) NSString * photoUrl;
@property (nonatomic, retain) NSString * secondPhotoUrl;
@property (nonatomic, retain) NSString * text;
@property (nonatomic, retain) NSSet *songs;
@property (nonatomic, retain) SourceGroup *source;
@end

@interface Playlist (CoreDataGeneratedAccessors)

- (void)addSongsObject:(Song *)value;
- (void)removeSongsObject:(Song *)value;
- (void)addSongs:(NSSet *)values;
- (void)removeSongs:(NSSet *)values;

@end
