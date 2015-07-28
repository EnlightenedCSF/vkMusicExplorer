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
#import "VMEPlaylist.h"

@interface PlaylistCollectionViewCell ()

@property (weak, nonatomic) VMEPlaylist *playlistData;

@end

@implementation PlaylistCollectionViewCell

-(void)fillWithPlaylist:(VMEPlaylist *)playlist {
    self.playlistData = playlist;
}

#pragma mark - Table View Data Source

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == 0) {
        return 290;
    }
    return 44;
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
    return self.playlistData.songs.count;
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
        
        NSDictionary *song = self.playlistData.songs[indexPath.row];
        
        [cell fillWithTitle:[NSString stringWithFormat:@"%@ - %@", song[@"artist"], song[@"title"]] duration:song[@"duration"]];
        
        return cell;
    }
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:indexPath.section != 0];
}

@end
