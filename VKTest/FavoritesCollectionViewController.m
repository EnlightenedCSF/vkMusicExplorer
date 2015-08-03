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

@interface FavoritesCollectionViewController () <UICollectionViewDelegateFlowLayout, UIGestureRecognizerDelegate, FavoriteCellEditingDelegate, UITabBarControllerDelegate>

@property (strong, nonatomic) NSMutableArray *playlists;

@property (assign, nonatomic) BOOL isInEditingMode;

@end

@implementation FavoritesCollectionViewController

static NSString * const reuseIdentifier = @"favCell";

- (void)viewDidLoad {
    [super viewDidLoad];
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
    [cell fillWithPicUrl:playlist.photoUrl];
    
    // Todo: touch begin touch end instead of this
    UILongPressGestureRecognizer *longTap = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(onStartEditing:)];
    longTap.minimumPressDuration = .5;
    longTap.delaysTouchesBegan = YES;
    longTap.delegate = cell;
    [cell addGestureRecognizer:longTap];
    
    cell.delegate = self;
    
    return cell;
}

#pragma mark UICollectionViewDelegate

-(void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    [collectionView deselectItemAtIndexPath:indexPath animated:YES];
    // todo:
}

#pragma mark - Collection View Flow Delegate

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath
{
    return CGSizeMake(145, 140);
}

#pragma mark - Gestures

-(BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer
{
    return YES;
}

-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    NSLog(@"touch began");
}

-(void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
    NSLog(@"touch ended");
}
	
#pragma mark - Editing

-(void)onStartEditing:(UILongPressGestureRecognizer *)gestureRecognizer
{
    NSLog(@"%ld", (long)gestureRecognizer.state);
    if (gestureRecognizer.state != UIGestureRecognizerStateEnded) {
        return;
    }
    
    self.isInEditingMode = YES;
    [self startWiggling];
}

-(void)startWiggling
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
        
#warning Не успевает сохранить
        [[NSManagedObjectContext MR_defaultContext] MR_saveToPersistentStoreWithCompletion:^(BOOL contextDidSave, NSError *error) {
            NSLog(@"Successfully saved from favorite VC");
        }];
    }
}

@end
