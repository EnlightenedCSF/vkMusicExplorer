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

#define DEFAULT_ROW_HEIGHT 44
#define MAX_PLAYLIST_SIZE 10

@interface PlaylistCollectionViewCell ()

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
    return MAX_PLAYLIST_SIZE; //self.playlistData.songs.count;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == 0) {
        PlaylistHeaderTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"playlistHeaderCell"];
        
        [cell fill:self.playlistData.photoUrl];
        
        return cell;
    }
    else {
        PlaylistItemTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"playlistItemCell"];
        
        if (indexPath.row < self.playlistData.songs.count) {
            NSArray *array = [self.playlistData.songs allObjects];
            Song *song = array[indexPath.row];
            
            [cell fillWithTitle:[NSString stringWithFormat:@"%@ - %@", song.artist, song.title] duration:song.duration];
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

@end
