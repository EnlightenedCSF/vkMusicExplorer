//
//  GroupContentViewController.m
//  VKTest
//
//  Created by Ольферук Александр on 27.07.15.
//  Copyright (c) 2015 EnlightenedCSF. All rights reserved.
//

#import <VKSdk.h>
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
#import "SourceGroupTableViewController.h"
#import "VKPlayerViewController.h"
#import "VKUserData.h"


@interface GroupContentViewController () <UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout, UIScrollViewDelegate, UIPopoverControllerDelegate, UITabBarControllerDelegate>

@property (weak, nonatomic) IBOutlet UICollectionView *collectionView;
@property (weak, nonatomic) IBOutlet UIButton *favBtn;
@property (weak, nonatomic) IBOutlet UILabel *timeLbl;

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
    self.tabBarController.delegate = self;
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(onVkSdkShouldPresentViewController:)
                                                 name:@"vkShouldPresentViewController"
                                               object:nil];

    
    [RACObserve(self, currentOffset) subscribeNext:^(id x) {
        NSLog(@"Current offset: %@", x);
    }];
}

-(void)viewWillAppear:(BOOL)animated
{
    [self fetchAllSources];
    
    [self downloadNextPlaylist];
    if (self.isFirstOne) {
        [self downloadNextPlaylist];
        self.isFirstOne = NO;
    }
}

-(void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
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
    self.selectedGroups = [NSMutableArray arrayWithArray:[[SourceGroup MR_findAll] mutableCopy]];
}

-(void)clearGroups
{
    [self.selectedGroups removeAllObjects];
}

-(void)reloadPosts
{
    [[NSManagedObjectContext MR_defaultContext] MR_saveToPersistentStoreWithCompletion:^(BOOL contextDidSave, NSError *error)
     {
         NSLog(@"Total playlists: %lu", (unsigned long)self.playlists.count);
         NSLog(@"%@", contextDidSave ? @"Did save all posts successfully!" : [error localizedDescription]);
         
         [self clearPlaylists];
         [self downloadNextPlaylist];
         [self downloadNextPlaylist];
     }];

}

-(void)savePlaylists
{
    [[NSManagedObjectContext MR_defaultContext] MR_saveToPersistentStoreWithCompletion:^(BOOL contextDidSave, NSError *error)
     {
         NSLog(@"Total playlists: %lu", (unsigned long)self.playlists.count);
         NSLog(@"%@", contextDidSave ? @"Did save all posts successfully!" : [error localizedDescription]);
    }];
}

-(void)clearPlaylists
{
    self.currentOffset = 0;
    self.currentPageIndex = 0;
    [self.playlists removeAllObjects];
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
            //[self setTimeLabel];
            
            //[self enableFavButtonIfNeeded];
        }
        
    } errorBlock:^(NSError *error) {
        NSLog(@"%@", [error description]);
    }];
}

-(VKRequest *)getRequestToNextPostInDomain:(NSString *)domain
{
    return [VKRequest requestWithMethod:@"wall.get" andParameters:@{ @"domain": domain ? domain : @"",
                                                                     @"count": @"1",
                                                                     @"filter": @"owner",
                                                                     @"offset": [NSString stringWithFormat:@"%i", self.currentOffset++]
                                                                     } andHttpMethod:@"GET"];
}

-(BOOL)parsePlaylist:(NSDictionary *)json andAddTo:(NSMutableArray *)target
{
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
    BOOL wasAtLeastOnePhoto = NO;
    NSString *videoFrameUrl;
    NSMutableDictionary *temp = [NSMutableDictionary dictionary];
    temp[@"songs"] = [NSMutableArray array];
    
    temp[@"date"] = item[@"date"];
    
    int i = 0;
    for (NSDictionary *attachment in attachments) {
        if ([attachment[@"type"] isEqualToString:@"photo"])
        {
            temp[@"photoUrl"] = attachment[@"photo"][@"photo_604"];
            wasAtLeastOnePhoto = YES;
        }
        else if ([attachment[@"type"] isEqualToString:@"audio"]) {
            wasAtLeastOneSong = YES;
            
            NSDictionary *item = attachment[@"audio"];

            [temp[@"songs"] addObject:@{
                                        @"artist": item[@"artist"],
                                        @"title": item[@"title"],
                                        @"duration": item[@"duration"],
                                        @"url": item[@"url"],
                                        @"index": [NSNumber numberWithInt:i++]
                                       }];
        }
        else if ([attachment[@"type"] isEqualToString:@"video"]) {
            videoFrameUrl = attachment[@"video"][@"photo_800"];
        }
    }
    
    if (!wasAtLeastOnePhoto) {
        temp[@"photoUrl"] = videoFrameUrl;
    }
    
    if (!wasAtLeastOneSong) {
        return NO;
    }
    
    if (temp[@"photoUrl"])
    {
        Playlist *mbStoredPlaylist = [Playlist MR_findFirstWithPredicate:[NSPredicate predicateWithFormat:@"(photoUrl LIKE %@) AND (isFavorite == YES)", temp[@"photoUrl"]]];
        
        if (mbStoredPlaylist)
        {
            temp[@"isFavorite"] = @(YES);
            
            [target addObject:mbStoredPlaylist]; // if it's already stored, just add it to array without creating
        }
        else {
            Playlist *newPlaylist = [Playlist MR_createEntity];
            
            newPlaylist.photoUrl = temp[@"photoUrl"];
            for (NSDictionary *item in temp[@"songs"]) {
                Song *song = [Song MR_createEntity];
                song.artist = item[@"artist"];
                song.title = item[@"title"];
                song.duration = @([item[@"duration"] intValue]);
                song.url = item[@"url"];
                song.index = @([item[@"index"] intValue]);
                
                [newPlaylist addSongsObject:song];
            }
            newPlaylist.isFavorite = @(NO);
            newPlaylist.date = @([temp[@"date"] longValue]);
            
            [target addObject:newPlaylist];
        }
        
        return YES;
    }
    
    return NO;
}

#pragma mark - Table view stuff


-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:NO];
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
    if ([popoverController.contentViewController isKindOfClass:[SourceGroupTableViewController class]])
    {
        [self reloadPosts];
    }
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

- (IBAction)togglePlayer:(UIButton *)sender
{
    VKPlayerViewController* content = [[UIStoryboard storyboardWithName:@"MainIPad" bundle:nil] instantiateViewControllerWithIdentifier:@"vkPlayerVC"];
    
    UIPopoverController* aPopover = [[UIPopoverController alloc]
                                     initWithContentViewController:content];
    aPopover.delegate = self;
    
    self.aPopoverController = aPopover;
    
    [self.aPopoverController presentPopoverFromRect:sender.frame inView:self.view permittedArrowDirections:(UIPopoverArrowDirectionAny) animated:YES];
}


- (IBAction)toggleFavoriteTapped:(UIButton *)sender
{
    Playlist *playlist = self.playlists[self.currentPageIndex];
    playlist.isFavorite = @(![playlist.isFavorite boolValue]);
    
    [sender setImage:[UIImage imageNamed: (playlist.isFavorite ? @"icon_heart" : @"icon_heart_empty")] forState:UIControlStateNormal];
}

-(void)enableFavButtonIfNeeded
{
    Playlist *playlist = self.playlists[self.currentPageIndex];
    [_favBtn setImage:[UIImage imageNamed: (playlist.isFavorite ? @"icon_heart" : @"icon_heart_empty")] forState:UIControlStateNormal];
}

#pragma mark - VK Delegate

-(void)onVkSdkShouldPresentViewController:(id)controller
{
    UIViewController *vc = (UIViewController *)controller;
    [self.navigationController.topViewController presentViewController:vc animated:YES completion:nil];
}

#pragma mark - Tab Bar Delegate

-(void)tabBarController:(UITabBarController *)tabBarController didSelectViewController:(UIViewController *)viewController
{
    if (![viewController isKindOfClass:[self class]] ) {
        [self savePlaylists];
        [self clearPlaylists];
        [self clearGroups];
        self.isFirstOne = YES;
        self.currentOffset = 0;
    }
}

@end
