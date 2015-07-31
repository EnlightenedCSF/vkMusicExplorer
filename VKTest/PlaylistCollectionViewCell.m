//
//  PlaylistCollectionViewCell.m
//  VKTest
//
//  Created by Ольферук Александр on 28.07.15.
//  Copyright (c) 2015 EnlightenedCSF. All rights reserved.
//

#import "PlaylistCollectionViewCell.h"
#import "PlaylistItemTableViewCell.h"
#import "PlaylistHeaderTableViewCell.h"

#import "Song.h"

#import "VKMusicPlayer.h"

#define DEFAULT_ROW_HEIGHT 44
#define MAX_PLAYLIST_SIZE 9

@interface PlaylistCollectionViewCell () <VKPlaylistProtocol>

@property (weak, nonatomic) Playlist *playlistData;

@end

@implementation PlaylistCollectionViewCell

-(void)fillWithPlaylist:(Playlist *)playlist {
    self.playlistData = playlist;
}

#pragma mark - Table View Data Source

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == 0) {
        return tableView.bounds.size.height - DEFAULT_ROW_HEIGHT * MAX_PLAYLIST_SIZE;
    }
    return DEFAULT_ROW_HEIGHT;
}

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 2;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (section == 0) {
        return 1;
    }
    return MAX_PLAYLIST_SIZE;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == 0) {
        PlaylistHeaderTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"playlistHeaderCell"];
        
        [cell fill:self.playlistData.photoUrl andTime:self.playlistData.date];
        
        return cell;
    }
    else {
        PlaylistItemTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"playlistItemCell"];
        
        if (indexPath.row < self.playlistData.songs.count)
        {
            NSPredicate *p = [NSPredicate predicateWithFormat:@"index == %i", indexPath.row];
            Song *song = [[[[self.playlistData.songs mutableCopy] allObjects] filteredArrayUsingPredicate:p] firstObject];
            
            [cell fillWithSong:song];
            cell.tag = [song.index intValue];
            
            cell.delegate = self;
        }
        else {
            [cell hideDetails];
        }
        
        return cell;
    }
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:indexPath.section != 0];
}

#pragma mark - VK Protocol Delegate

-(void)onPlayPauseBtnTapped:(id)sender
{
    PlaylistItemTableViewCell *cell = (PlaylistItemTableViewCell *)sender;

    NSArray *arr = [[self.playlistData.songs mutableCopy] allObjects];
    arr = [arr sortedArrayUsingComparator:^NSComparisonResult(id obj1, id obj2) {
        Song *a = (Song *)obj1;
        Song *b = (Song *)obj2;
        return a.index > b.index;
    }];
    
    for (NSInteger i = 0; i < [self.playlist numberOfRowsInSection:1]; ++i) {
        PlaylistItemTableViewCell *anotherCell = (PlaylistItemTableViewCell *)[_playlist cellForRowAtIndexPath:[NSIndexPath indexPathForRow:i inSection:1]];
        if (anotherCell.tag == cell.tag) {
            continue;
        }
        [anotherCell setIsPlaying:NO];
    }

    [VKMusicPlayer sharedPlayer].playlist = [NSMutableArray arrayWithArray:arr];
    
    [[VKMusicPlayer sharedPlayer] togglePlayingAtIndex:(int)cell.tag];
}

@end
