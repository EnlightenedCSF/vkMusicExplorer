//
//  FavoritesCollectionViewController.m
//  VKTest
//
//  Created by Ольферук Александр on 29.07.15.
//  Copyright (c) 2015 EnlightenedCSF. All rights reserved.
//

#import <MagicalRecord.h>
#import <QuartzCore/QuartzCore.h>

#import "FavoritesCollectionViewController.h"
#import "Playlist.h"
#import "Song.h"

#import "FavoriteCollectionViewCell.h"

#import "VKMusicPlayer.h"
#import "VMEUtils.h"

@interface FavoritesCollectionViewController () <UICollectionViewDelegateFlowLayout, UIGestureRecognizerDelegate, FavoriteCellEditingDelegate, UITabBarControllerDelegate>

@property (strong, nonatomic) NSMutableArray *playlists;

@property (assign, nonatomic) BOOL isInEditingMode;

@property (strong, nonatomic) VKMusicPlayer *player;

@end

@implementation FavoritesCollectionViewController

static NSString * const reuseIdentifier = @"favCell";

- (void)viewDidLoad {
    [super viewDidLoad];
    
    _player = [VKMusicPlayer sharedPlayer];
}

-(void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    self.isInEditingMode = NO;
    [self fetchFavs];
    [self.collectionView reloadData];
}

-(void)fetchFavs
{
    self.playlists = [NSMutableArray arrayWithArray:[Playlist MR_findByAttribute:@"isFavorite" withValue:@(YES)]];
}

#pragma mark - UICollectionViewDataSource

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    return 1;
}


- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return self.playlists.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    
    FavoriteCollectionViewCell *cell = (FavoriteCollectionViewCell *)[collectionView dequeueReusableCellWithReuseIdentifier:reuseIdentifier forIndexPath:indexPath];
    
    Playlist *playlist = self.playlists[indexPath.row];
    [cell fillWithPlaylist:playlist];
    
    // Todo: touch begin touch end instead of this
    UILongPressGestureRecognizer *longTap = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(onStartEditing:)];
    longTap.minimumPressDuration = .5;
    longTap.delaysTouchesBegan = YES;
    longTap.delegate = cell;
    [cell addGestureRecognizer:longTap];
    
    cell.delegate = self;
    
    if (self.isInEditingMode) {
        [cell toggleEditing];
    }
    
    return cell;
}

#pragma mark UICollectionViewDelegate

-(void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    [collectionView deselectItemAtIndexPath:indexPath animated:YES];
    
    if (_isInEditingMode) {
        return;
    }
    
    NSLog(@"Selected");
    [self setOthersNotPlaying];
    
    FavoriteCollectionViewCell *cell = (FavoriteCollectionViewCell *)[collectionView cellForItemAtIndexPath:indexPath];
    [cell setIsPlaying:YES];
    
    [_player getDataFromPlaylist:_playlists[indexPath.row]];
    [_player startPlayingFromBeginning];
}

-(void)setOthersNotPlaying
{
    for (NSInteger i = 0; i < [self.collectionView numberOfItemsInSection:0]; ++i) {
        FavoriteCollectionViewCell *cell = (FavoriteCollectionViewCell *)[self.collectionView cellForItemAtIndexPath:[NSIndexPath indexPathForRow:i inSection:0]];
        [cell setIsPlaying:NO];
    }
}

#pragma mark - Collection View Flow Delegate

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath
{
    return CGSizeMake(145, 140);
}

#pragma mark - Editing

-(void)onStartEditing:(UILongPressGestureRecognizer *)gestureRecognizer
{
    if (gestureRecognizer.state != UIGestureRecognizerStateEnded) {
        return;
    }
    
    self.isInEditingMode = !self.isInEditingMode;
    [self toggleWiggling];
}

-(void)toggleWiggling
{
    for (NSInteger i = 0; i < self.playlists.count; ++i)
    {
        NSIndexPath *ip = [NSIndexPath indexPathForRow:i inSection:0];
        FavoriteCollectionViewCell *cell = (FavoriteCollectionViewCell *)[self.collectionView cellForItemAtIndexPath:ip];
        
        [cell toggleEditing];
    }
}


-(void)onDeleteCell:(id)sender {
    FavoriteCollectionViewCell *cell = (FavoriteCollectionViewCell *)sender;
    NSIndexPath *path = [self.collectionView indexPathForCell:cell];
    
    Playlist *p = self.playlists[path.row];
    [p MR_deleteEntity];
    [self.playlists removeObjectAtIndex:path.row];
    
    [self.collectionView deleteItemsAtIndexPaths:@[ path ]];
    
    [self.collectionView reloadData];
    
    if (self.playlists.count == 0) {
        [self stopEditing];
    }
}

-(void)stopEditing
{
    self.editing = NO;
    
    for (NSInteger i = 0; i < self.playlists.count; ++i)
    {
        NSIndexPath *ip = [NSIndexPath indexPathForRow:i inSection:0];
        FavoriteCollectionViewCell *cell = (FavoriteCollectionViewCell *)[self.collectionView cellForItemAtIndexPath:ip];
        
        [cell toggleEditing];
    }
}

#pragma mark - Tab Bar Delegate

-(void)tabBarController:(UITabBarController *)tabBarController didSelectViewController:(UIViewController *)viewController
{
    if (![viewController isKindOfClass:[self class]] ) {
        if (self.editing) {
            [self stopEditing];
        }
        
        [[NSManagedObjectContext MR_defaultContext] MR_saveToPersistentStoreWithCompletion:^(BOOL contextDidSave, NSError *error) {
            NSLog(@"Successfully saved from favorite VC");
        }];
    }
}

@end
