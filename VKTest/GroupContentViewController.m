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
#import <LGHelper.h>

#import "SourceGroup.h"
#import "Playlist.h"
#import "Song.h"

#import "GroupContentViewController.h"
#import "PlaylistHeaderTableViewCell.h"
#import "PlaylistItemTableViewCell.h"
#import "PlaylistCollectionViewCell.h"
#import "SourcePublicViewController.h"
#import "VKPlayerViewController.h"
#import "VKUserData.h"
#import "VKJsonParser.h"

#import "UIButton+FAWE.h"
#import "VMEConsts.h"


@interface GroupContentViewController () <UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout, UIScrollViewDelegate, UIPopoverControllerDelegate, UITabBarControllerDelegate, VKSourcePublicSelectionDelegate>

@property (weak, nonatomic) IBOutlet UICollectionView *collectionView;
@property (weak, nonatomic) IBOutlet UIButton *favBtn;

@property (strong, nonatomic) NSMutableArray *playlists; //of Playlist

@property (assign, nonatomic) int currentOffset;
@property (assign, nonatomic) BOOL isFirstOne;

@property (assign, nonatomic) int currentPageIndex;

@property (strong, nonatomic) UIPopoverController *aPopoverController;

@property (assign, nonatomic) BOOL needsToReloadData;
@property (copy, nonatomic) NSString *oldDomain;

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
    
    [_favBtn setIconAlign:(FAWEButtonIconAlignCenter)];
    [_favBtn setIconColor:[VMEConsts defaultRedColor]];
    [_favBtn setIcon:(FAWEIconHeartEmpty)];
    [_favBtn setIconSize:32];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(onVkSdkShouldPresentViewController:)
                                                 name:@"vkShouldPresentViewController"
                                               object:nil];
}

-(void)viewWillAppear:(BOOL)animated
{
    [self fetchAllSources];
    
    [self downloadNextPlaylist];
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
         NSLog(@"%@", contextDidSave ? @"Did save all posts successfully!" : [error localizedDescription]);
         
         [self clearPlaylists];
         [self downloadNextPlaylist];
         [self downloadNextPlaylist];
     }];

}

-(void)savePlaylists
{
    // todo: save only unique posts
    NSLog(@"Total playlists are: %lu", [Playlist MR_findAll].count);
    
    [[NSManagedObjectContext MR_defaultContext] MR_saveToPersistentStoreWithCompletion:^(BOOL contextDidSave, NSError *error)
     {
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
            [self enableFavButtonIfNeeded];
            
            [self downloadSecondIfNeeded];
        }
        
    } errorBlock:^(NSError *error) {
        NSLog(@"%@", [error description]);
    }];
}

-(void)downloadSecondIfNeeded
{
    if (self.isFirstOne) {
        [self downloadNextPlaylist];
        self.isFirstOne = NO;
    }
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
    NSMutableDictionary *temp = [VKJsonParser parsePlaylist:json];
    
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
            
            if ([temp objectForKey:@"text"]) {
                newPlaylist.text = temp[@"text"];
            }
            if ([temp objectForKey:@"secondPhotoUrl"]) {
                newPlaylist.secondPhotoUrl = temp[@"secondPhotoUrl"];
            }
            
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

#pragma mark - On Closing Source Public Selection Delegates

-(void)popoverControllerDidDismissPopover:(UIPopoverController *)popoverController {
    if ([popoverController.contentViewController isKindOfClass:[SourcePublicViewController class]])
    {
        [self reloadPostsIfDomainChanged];
    }
}

-(void)onDoneBtnTapped {
    [self reloadPostsIfDomainChanged];
}

-(void)reloadPostsIfDomainChanged {
    NSString *newDomain = [[NSUserDefaults standardUserDefaults] objectForKey:@"selectedDomain"];
    if (!(_oldDomain && [_oldDomain isEqualToString:newDomain])) {
        self.currentOffset = 0;
        [self reloadPosts];
    }
}

#pragma mark - Buttons

- (IBAction)sourceSelectionTapped:(id)sender
{
    _oldDomain = [[NSUserDefaults standardUserDefaults] objectForKey:@"selectedDomain"];
    
    UIButton *btn = (UIButton *)sender;
    
    SourcePublicViewController* content = [[UIStoryboard storyboardWithName:@"MainIPad" bundle:nil] instantiateViewControllerWithIdentifier:@"sourceSelection"];
    
    if (kDeviceIsPhone) {
        content.delegate = self;
        [self presentViewController:content animated:YES completion:nil];
    }
    else {
        UIPopoverController* aPopover = [[UIPopoverController alloc]
                                     initWithContentViewController:content];
        aPopover.delegate = self;
    
        self.aPopoverController = aPopover;
        [self.aPopoverController presentPopoverFromRect:btn.frame inView:self.view permittedArrowDirections:(UIPopoverArrowDirectionAny) animated:YES];
    }
}

- (IBAction)toggleFavoriteTapped:(UIButton *)sender
{
    Playlist *playlist = self.playlists[self.currentPageIndex];
    playlist.isFavorite = @(![playlist.isFavorite boolValue]);
    
    [self enableFavButtonIfNeeded];
}

-(void)enableFavButtonIfNeeded
{
    Playlist *playlist = self.playlists[self.currentPageIndex];
    [_favBtn setIcon:([playlist.isFavorite boolValue] ? FAWEIconHeart : FAWEIconHeartEmpty )];
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
        [self clearGroups];
    }
}

#pragma mark - Rotation Support

-(void)viewDidLayoutSubviews
{
    [super viewDidLayoutSubviews];
    
    [self.view layoutIfNeeded];
    [self.view layoutSubviews];
    [self.collectionView reloadData];
}

@end
