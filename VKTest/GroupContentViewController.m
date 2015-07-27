//
//  GroupContentViewController.m
//  VKTest
//
//  Created by Ольферук Александр on 27.07.15.
//  Copyright (c) 2015 EnlightenedCSF. All rights reserved.
//

#import <VKApi.h>

#import "GroupContentViewController.h"
#import "PlaylistHeaderTableViewCell.h"
#import "PlaylistItemTableViewCell.h"

@interface GroupContentViewController () <UITableViewDataSource, UITableViewDelegate>

@property (weak, nonatomic) IBOutlet UITableView *tableViewPostContent;

@property (copy, nonatomic) NSString *photoUrl;
@property (strong, nonatomic) NSArray *currentPlaylist;

@end


@implementation GroupContentViewController

#pragma mark - Initialization

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.currentPlaylist = [NSArray array];
}

-(void)viewWillAppear:(BOOL)animated {
    
    NSString *domain = self.selectedGroups[0][@"domain"];
    
    VKRequest *req = [VKRequest requestWithMethod:@"wall.get" andParameters:@{ @"domain": domain,
                                                                               @"count": @"1",
                                                                               @"filter": @"owner",
                                                                               @"offset": @"1"
                                                                               } andHttpMethod:@"GET"];
    
    [req executeWithResultBlock:^(VKResponse *response)
    {
        [self parsePlaylist:response.json];
    } errorBlock:^(NSError *error)
    {
        NSLog(@"%@", [error description]);
    }];

}

-(void)parsePlaylist:(NSDictionary *)json {
    //NSLog(@"%@", json);
    
    NSMutableArray *res = [NSMutableArray array];
    
    NSDictionary *item = json[@"items"][0];
    NSArray *attachments = item[@"attachments"];
    for (NSDictionary *attachment in attachments) {
        if ([attachment[@"type"] isEqualToString:@"photo"]) {
            self.photoUrl = attachment[@"photo"][@"photo_604"];
        }
        else if ([attachment[@"type"] isEqualToString:@"audio"]) {
            NSDictionary *song = attachment[@"audio"];
            
            [res addObject:@{ @"artist": song[@"artist"],
                              @"title": song[@"title"],
                              @"duration": @([song[@"duration"] integerValue]),
                              @"url": song[@"url"] }];
        }
    }
    
    self.currentPlaylist = [res copy];
    [self.tableViewPostContent reloadData];
}

#pragma mark - Table view stuff

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
    return self.currentPlaylist.count;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == 0) {
        PlaylistHeaderTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"playlistHeaderCell"];
        
        [cell fill:self.photoUrl];
        
        return cell;
    }
    else {
        PlaylistItemTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"playlistItemCell"];
        
        NSDictionary *song = self.currentPlaylist[indexPath.row];
        [cell fillWithTitle:[NSString stringWithFormat:@"%@ - %@", song[@"artist"], song[@"title"]] duration:song[@"duration"]];
        
        return cell;
    }
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == 0) {
        [tableView deselectRowAtIndexPath:indexPath animated:NO];
    }
    else {
        [tableView deselectRowAtIndexPath:indexPath animated:YES];
        //do more stuff
    }
}

@end
