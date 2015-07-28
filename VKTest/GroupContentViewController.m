//
//  GroupContentViewController.m
//  VKTest
//
//  Created by Ольферук Александр on 27.07.15.
//  Copyright (c) 2015 EnlightenedCSF. All rights reserved.
//

#import <VKApi.h>
#import <MagicalRecord.h>
#import <ReactiveCocoa.h>

#import "SourceGroup.h"
#import "Playlist.h"
#import "Song.h"

#import "GroupContentViewController.h"
#import "PlaylistHeaderTableViewCell.h"
#import "PlaylistItemTableViewCell.h"
#import "PlaylistCollectionViewCell.h"
#import "VMEPlaylist.h"
#import "SourceGroupTableViewController.h"

@interface GroupContentViewController () <UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout, UIScrollViewDelegate, UIPopoverControllerDelegate>

@property (weak, nonatomic) IBOutlet UICollectionView *collectionView;
@property (weak, nonatomic) IBOutlet UIButton *favBtn;

@property (strong, nonatomic) NSMutableArray *playlists; //of Playlist

@property (assign, nonatomic) int currentOffset;
@property (assign, nonatomic) BOOL isFirstOne;

@property (assign, nonatomic) int currentPageIndex;

@property (strong, nonatomic) UIPopoverController *aPopoverController;

@property (assign, nonatomic) BOOL needsToReloadData;

@end


@implementation GroupContentViewController

#pragma mark - Initialization

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.playlists = [NSMutableArray array];
    
    self.isFirstOne = YES;
    self.currentOffset = 0;
    self.currentPageIndex = 0;
    
    [RACObserve(self, currentOffset) subscribeNext:^(id x) {
        NSLog(@"Current offset: %@", x);
    }];
}

-(void)viewWillAppear:(BOOL)animated {
    
    [self fetchAllSources];
    
    [self downloadNextPlaylist];
    if (self.isFirstOne) {
        [self downloadNextPlaylist];
        self.isFirstOne = NO;
    }
}

#pragma mark - Data stuff

-(SourceGroup *)getSelectedGroup
{
    NSUserDefaults *defs = [NSUserDefaults standardUserDefaults];
    NSString *selectedDomain = [defs objectForKey:@"selectedDomain"];
    
    for (SourceGroup *item in self.selectedGroups) {
        if ([item.domain isEqualToString:selectedDomain]) {
            return item;
        }
    }
    return nil;
}

-(void)fetchAllSources
{
    self.selectedGroups = (NSArray *)[[SourceGroup MR_findAll] mutableCopy];
}

-(void)reloadPosts
{
    self.currentOffset = 0;
    self.currentPageIndex = 0;
    [self.playlists removeAllObjects];
    [self downloadNextPlaylist];
    [self downloadNextPlaylist];
}

-(void)downloadNextPlaylist
{
    SourceGroup *group = [self getSelectedGroup];
    
    [[self getRequestToNextPostInDomain:group.domain] executeWithResultBlock:^(VKResponse *response) {
        
        if (![self parsePlaylist:response.json andAddTo:self.playlists])
        {
            [self downloadNextPlaylist];
        }
        else {
            [self.collectionView reloadData];
            [self enableFavButtonIfNeeded];
        }
        
    } errorBlock:^(NSError *error) {
        NSLog(@"%@", [error description]);
    }];
}

-(VKRequest *)getRequestToNextPostInDomain:(NSString *)domain
{
    self.currentOffset++;
    
    return [VKRequest requestWithMethod:@"wall.get" andParameters:@{ @"domain": domain ? domain : @"",
                                                                     @"count": @"1",
                                                                     @"filter": @"owner",
                                                                     @"offset": [NSString stringWithFormat:@"%i", self.currentOffset - 1]
                                                                     } andHttpMethod:@"GET"];
}

-(BOOL)parsePlaylist:(NSDictionary *)json andAddTo:(NSMutableArray *)target
{
    VMEPlaylist *newPlaylist = [[VMEPlaylist alloc] init];
    
    NSDictionary *item = json[@"items"][0];
    NSArray *attachments = item[@"attachments"];
    if (!attachments) {     //it's a repost
        NSDictionary *repost = item[@"copy_history"][0];
        attachments = repost[@"attachments"];
    }
    if (!attachments) {
        return NO;
    }
    
    BOOL wasAtLeastOneSong = NO;
    for (NSDictionary *attachment in attachments) {
        if ([attachment[@"type"] isEqualToString:@"photo"]) {
            newPlaylist.photoUrl = attachment[@"photo"][@"photo_604"];
        }
        else if ([attachment[@"type"] isEqualToString:@"audio"]) {
            wasAtLeastOneSong = YES;
            
            NSDictionary *song = attachment[@"audio"];
            
            [newPlaylist.songs addObject:@{ @"artist": song[@"artist"],
                                            @"title": song[@"title"],
                                            @"duration": @([song[@"duration"] integerValue]),
                                            @"url": song[@"url"] }];
        }
    }
    
    if (!wasAtLeastOneSong) {
        return NO;
    }
    
    [target addObject:newPlaylist];
    return YES;
}

#pragma mark - Table view stuff


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

#pragma mark - Collection view stuff

-(NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return self.playlists.count;
}

-(UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    PlaylistCollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"playlistCell" forIndexPath:indexPath];
    
    if (self.playlists.count > 0) {
        [cell fillWithPlaylist:self.playlists[indexPath.row]];
        
        cell.playlist.delegate = cell;
        cell.playlist.dataSource = cell;
        
        [cell.playlist reloadData];
    }
    
    return cell;
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath
{
    CGSize size = collectionView.bounds.size;
    size.height -= collectionView.contentInset.top + collectionView.contentInset.bottom + 5;
    return size;
}

#pragma mark - Scroll View Delegate

-(void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
    if (self.needsToReloadData) {
        self.needsToReloadData = NO;
        [self.collectionView reloadData];
    }
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    CGFloat pageWidth = scrollView.frame.size.width;
    float fractionalPage = scrollView.contentOffset.x / pageWidth;
    NSInteger page = lround(fractionalPage);
    if (self.currentPageIndex != page)
    {
        if (page == self.playlists.count-1) {
            [self downloadNextPlaylist];
            self.needsToReloadData = YES;
        }
        self.currentPageIndex = (int)page;
        [self enableFavButtonIfNeeded];
    }
}

#pragma mark - Popover Delegate

-(void)popoverControllerDidDismissPopover:(UIPopoverController *)popoverController
{
    [self reloadPosts];
}

#pragma mark - Buttons

- (IBAction)sourceSelectionTapped:(id)sender
{
    SourceGroupTableViewController* content = [[UIStoryboard storyboardWithName:@"MainIPad" bundle:nil] instantiateViewControllerWithIdentifier:@"sourceSelection"];
    
    UIPopoverController* aPopover = [[UIPopoverController alloc]
                                     initWithContentViewController:content];
    aPopover.delegate = self;
    
    self.aPopoverController = aPopover;
    
    UIButton *btn = (UIButton *)sender;
    
    [self.aPopoverController presentPopoverFromRect:btn.frame inView:self.view permittedArrowDirections:(UIPopoverArrowDirectionAny) animated:YES];
}

- (IBAction)toggleFavoriteTapped:(UIButton *)sender {
    if (!sender.isSelected) {
        VMEPlaylist *sourcePlaylist = self.playlists[self.currentPageIndex];
        
        Playlist *newPlaylist = [Playlist MR_createEntity];
        newPlaylist.photoUrl = sourcePlaylist.photoUrl;
        
        for (NSDictionary *item in sourcePlaylist.songs) {
            Song *song = [Song MR_createEntity];
            song.artist = item[@"artist"];
            song.title = item[@"title"];
            song.duration = item[@"duration"];
            song.url = item[@"url"];
            
            [newPlaylist addSongsObject:song];
        }
        
        [[NSManagedObjectContext MR_defaultContext] MR_saveToPersistentStoreWithCompletion:^(BOOL contextDidSave, NSError *error) {
            if (contextDidSave) {
                [sender setSelected:YES];
                sender.imageView.image = [UIImage imageNamed:@"icon_heart"];
            }
            else
                NSLog(@"%@", [error description]);
        }];
    }
    else {
        //todo:
    }
}

-(void)enableFavButtonIfNeeded {
    [self.favBtn setSelected:NO];
    self.favBtn.imageView.image = [UIImage imageNamed:@"icon_heart_empty"];
    
    VMEPlaylist *playlist = self.playlists[self.currentPageIndex];

    Playlist *p = [Playlist MR_findFirstByAttribute:@"photoUrl" withValue:playlist.photoUrl];
    if (p && [p.photoUrl isEqualToString:playlist.photoUrl]) {
        [self.favBtn setSelected:YES];
        self.favBtn.imageView.image = [UIImage imageNamed:@"icon_heart"];
    }
}

@end
