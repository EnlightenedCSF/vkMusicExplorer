//
//  VKPlayerViewController.m
//  VKTest
//
//  Created by Ольферук Александр on 30.07.15.
//  Copyright (c) 2015 EnlightenedCSF. All rights reserved.
//

#import <LastFm.h>
#import <UIImageView+WebCache.h>

#import "VKPlayerViewController.h"
#import "PlaylistItemTableViewCell.h"

#import "VKMusicPlayer.h"
#import "VMEConsts.h"

#import "MusiXmatchService.h"
#import "Track.h"
#import "Artist.h"

#import "UIButton+FAWE.h"
#import <OBSlider.h>

#define MAX_PLAYLIST_SIZE 9

@interface VKPlayerViewController () <UITableViewDataSource, UITableViewDelegate, VKPlaylistProtocol, VKMusicPlayerProtocol>

@property (weak, nonatomic) IBOutlet UILabel *artistLabel;
@property (weak, nonatomic) IBOutlet UILabel *titleLabel;

@property (weak, nonatomic) IBOutlet OBSlider *songProgress;
@property (weak, nonatomic) IBOutlet UILabel *songProgressLabel;

@property (strong, nonatomic) NSTimer *timer;

@property (weak, nonatomic) IBOutlet UIButton *playPauseBtn;
@property (weak, nonatomic) IBOutlet UIButton *rewindBtn;
@property (weak, nonatomic) IBOutlet UIButton *forwardBtn;

@property (weak, nonatomic) IBOutlet UIButton *artistInfoBtn;
@property (weak, nonatomic) IBOutlet UIButton *lyricsBtn;

@property (weak, nonatomic) IBOutlet UITableView *tableView;

@property (strong, nonatomic) VKMusicPlayer *player;

@property (weak, nonatomic) IBOutlet UILabel *artistNameLabel;
@property (weak, nonatomic) IBOutlet UILabel *artistTagsLabel;

@property (weak, nonatomic) IBOutlet UILabel *artistPlaycountLabel;
@property (weak, nonatomic) IBOutlet UILabel *artistListenersLabel;

@property (weak, nonatomic) IBOutlet UITextView *artistSumaryTextView;

@property (weak, nonatomic) IBOutlet UIImageView *artistPortraitView;

@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *lastFmProgressIndicator;

@property (weak, nonatomic) IBOutlet UITextView *songLyrics;

@end

@implementation VKPlayerViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    _player = [VKMusicPlayer sharedPlayer];
    
    [_rewindBtn setIconAlign:(FAWEButtonIconAlignCenter)];
    [_rewindBtn setIconColor:[VMEConsts defaultBlueColor]];
    [_rewindBtn setIcon:(FAWEIconStepBackward)];
    [_rewindBtn setIconSize:32];

    [_forwardBtn setIconAlign:(FAWEButtonIconAlignCenter)];
    [_forwardBtn setIconColor:[VMEConsts defaultBlueColor]];
    [_forwardBtn setIcon:(FAWEIconStepForward)];
    [_forwardBtn setIconSize:32];
    
    [_playPauseBtn setIconAlign:(FAWEButtonIconAlignCenter)];
    [_playPauseBtn setIconColor:[VMEConsts defaultBlueColor]];
    [_playPauseBtn setIconSize:40];
    
    [_artistInfoBtn setIconAlign:(FAWEButtonIconAlignCenter)];
    [_artistInfoBtn setIconColor:[VMEConsts defaultGrayColor]];
    [_artistInfoBtn setIcon:(FAWEIconUser)];
    [_artistInfoBtn setIconSize:32];
    
    [_lyricsBtn setIconAlign:(FAWEButtonIconAlignCenter)];
    [_lyricsBtn setIconColor:[VMEConsts defaultGrayColor]];
    [_lyricsBtn setIcon:(FAWEIconFont)];
    [_lyricsBtn setIconSize:32];
    
    [_songProgress addTarget:self action:@selector(songProgressBeganChangingByUser) forControlEvents:(UIControlEventTouchDown)];
    
    [_songProgress addTarget:self action:@selector(songProgressTouchEnded) forControlEvents:(UIControlEventTouchUpInside | UIControlEventTouchUpOutside)];
}


-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    [self.tableView reloadData];
    [self refreshCurrentTrackInfo];
    
    [self loadArtistInfo];
    
    _player.delegate = self;
}

-(void)viewWillDisappear:(BOOL)animated
{
    [self disableTimer];
}

-(void)refreshCurrentTrackInfo
{
    Song *song = [_player getCurrentTrack];
    _artistLabel.text = song.artist;
    _titleLabel.text = song.title;
    
    _songProgress.value = [_player getCurrentSongProgress];
    //[self setInitalProgressText];
    
    if (self.timer) {
        [self disableTimer];
    }
    [self enableTimer];
    
    [_playPauseBtn setIcon:([_player playing] ? FAWEIconPause : FAWEIconPlay)];
}

-(void)setInitalProgressText
{
    Song *song = [_player getCurrentTrack];
    double duration = [song.duration doubleValue];
    int min = floor(duration / 60.0);
    int sec = (int)duration % 60;
    _songProgressLabel.text = [NSString stringWithFormat:(sec < 10 ? @"[ 0:00 / %d:0%d ]" : @"[ 0:00 / %d:%d ]"), min, sec];
}

-(void)updateProgress
{
    _songProgress.value = [_player getCurrentSongProgress];
    _songProgressLabel.text = [_player getCurrentSongProgressText];
}

-(void)enableTimer
{
    self.timer = [NSTimer scheduledTimerWithTimeInterval:1.0 target:self selector:@selector(updateProgress) userInfo:nil repeats:YES];
}

-(void)disableTimer
{
    [self.timer invalidate];
    self.timer = nil;
}

#pragma mark - Table view data source

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return MAX_PLAYLIST_SIZE;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    PlaylistItemTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"playlistItemCell"];
 
    if (indexPath.row < _player.playlist.count) {
        [cell fillWithSong:[_player getTrackAtIndex:indexPath.row]];
        [cell setIsPlaying:[_player isSongIsPlayingAtIndex:indexPath.row]];
        
        cell.delegate = self;
        cell.tag = indexPath.row;
    }
    else {
        [cell hideDetails];
    }
    
    return cell;
}

#pragma mark - Controls

- (IBAction)btnRewindTapped:(UIButton *)sender
{
    [_player switchTrackToPrevious];
    [self refreshCurrentTrackInfo];
    [self updateTable];
    [self loadArtistInfo];
}

- (IBAction)btnPlayPauseTapped:(UIButton *)sender
{
    [_player playPause];
    [self updateTable];
    [_playPauseBtn setIcon:([_player playing] ? FAWEIconPause : FAWEIconPlay)];
}

- (IBAction)btnForwardTapped:(id)sender
{
    [_player switchTrackToNext];
    [self refreshCurrentTrackInfo];
    [self updateTable];
    [self loadArtistInfo];
}

-(void)updateTable
{
    for (NSInteger i = 0; i < [self.tableView numberOfRowsInSection:0]; ++i) {
        PlaylistItemTableViewCell *anotherCell = (PlaylistItemTableViewCell *)[_tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:i inSection:0]];
        
        if (anotherCell.tag != _player.index) {
            [anotherCell setIsPlaying:NO];
        }
        else {
            [anotherCell setIsPlaying:[_player playing]];
        }
    }
}

#pragma mark - VKPlayer Delegate

-(void)onPlayPauseBtnTapped:(id)sender
{
    PlaylistItemTableViewCell *cell = (PlaylistItemTableViewCell *)sender;

    [_player togglePlayingAtIndex:(int)cell.tag];
    [self refreshCurrentTrackInfo];
    
    if (cell.tag != _player.index) {
        if ([self isShowingArtistInfo]) {
            [self loadArtistInfo];
        }
        else {
            [self loadLyrics];
        }
    }
    
    [self updateTable];
}

#pragma mark - LastFM & MusiXMatch Stuff

- (IBAction)showArtistInfoBtnTapped:(id)sender {
    [self hideLyrics];
    [self loadArtistInfo];
}

- (IBAction)showSongLyricsBtnTapped:(id)sender {
    [self hideArtistInfo];
    [self loadLyrics];
}

-(void)hideLyrics {
    _songLyrics.hidden = YES;
}

-(void)showLyrics {
    _songLyrics.hidden = NO;
}

-(void)hideArtistInfo
{
    _artistNameLabel.hidden = YES;
    _artistTagsLabel.hidden = YES;
    _artistSumaryTextView.hidden = YES;
    _artistPlaycountLabel.hidden = YES;
    _artistPortraitView.hidden = YES;
    _artistListenersLabel.hidden = YES;
    [_lastFmProgressIndicator startAnimating];
}

-(void)showArtistInfo
{
    _artistNameLabel.hidden = NO;
    _artistTagsLabel.hidden = NO;
    _artistSumaryTextView.hidden = NO;
    _artistPlaycountLabel.hidden = NO;
    _artistPortraitView.hidden = NO;
    _artistListenersLabel.hidden = NO;
    [_lastFmProgressIndicator stopAnimating];
}

-(void)selectButton:(UIButton *)button {
    [self.artistInfoBtn setIconColor:[VMEConsts defaultGrayColor]];
    [self.lyricsBtn setIconColor:[VMEConsts defaultGrayColor]];

    [button setIconColor:[VMEConsts defaultBlueColor]];
}

-(void)loadArtistInfo
{
    [self selectButton:self.artistInfoBtn];
    [self hideArtistInfo];
    
    Song *song = [_player getCurrentTrack];
    if (!song) {
        return;
    }
    [self tryGetInfoForArtist:song.artist];
}

-(void)tryGetInfoForArtist:(NSString *)artist
{
    __block BOOL success = NO;
    [[LastFm sharedInstance] getInfoForArtist:artist successHandler:^(NSDictionary *result)
     {
         success = YES;
         [self showArtistInfo];
         
         NSNumberFormatter *formatter = [[NSNumberFormatter alloc] init];
         formatter.numberStyle = NSNumberFormatterDecimalStyle;
         
         _artistNameLabel.text = result[@"name"];
         
         NSNumber *n = [NSNumber numberWithInt:[result[@"playcount"] intValue]];
         _artistPlaycountLabel.text = [NSString stringWithFormat:@"%@ %@", [formatter stringFromNumber:n], NSLocalizedString(@"PLAYCOUNT", nil)];
         
         n = [NSNumber numberWithInt:[result[@"listeners"] intValue]];
         _artistListenersLabel.text = [NSString stringWithFormat:@"%@ %@", [formatter stringFromNumber:n], NSLocalizedString(@"LISTENERS", nil)];
         
         NSString *tags = @"";
         BOOL isFirstTag = YES;
         for (NSString *tag in result[@"tags"])
         {
             if (isFirstTag) {
                 tags = [tags stringByAppendingString:tag];
                 isFirstTag = NO;
             }
             else {
                 tags = [tags stringByAppendingString:[NSString stringWithFormat:@",  %@", tag]];
             }
         }
         _artistTagsLabel.text = tags;
         
         _artistPortraitView.contentMode = UIViewContentModeScaleAspectFit;
         [_artistPortraitView sd_setImageWithURL:result[@"image"]];
         
         NSMutableAttributedString *attributedString = [[NSMutableAttributedString alloc] initWithData:[result[@"summary"] dataUsingEncoding:NSUnicodeStringEncoding]
                                                                                               options:@{ NSDocumentTypeDocumentAttribute: NSHTMLTextDocumentType }
                                                                                    documentAttributes:nil
                                                                                                 error:nil];
         
         _artistSumaryTextView.attributedText = attributedString;
         
     } failureHandler:^(NSError *error) {
         NSLog(@"%@", [error localizedDescription]);
         if (!success) {
             [self tryGetInfoForArtist:artist];
         }
     }];
}

-(void)loadLyrics {
    [self selectButton:self.lyricsBtn];
    [self hideLyrics];
    [_lastFmProgressIndicator startAnimating];
    
    Song *song = [_player getCurrentTrack];
    if (!song) {
        return;
    }
    
    MusiXmatchService *service = [MusiXmatchService sharedInstance];
    Track *track = [service trackSearch:song.artist track:song.title];
    
    [self showLyrics];
    [_lastFmProgressIndicator stopAnimating];
    
    NSString *lyrics = [service getLyricsOfArtist:track.artist.name track:track.name];
    _songLyrics.text = lyrics != nil ? lyrics : NSLocalizedString(@"CANT FIND LYRICS", nil);
}

#pragma mark - VKMusicPlayer Protocol

-(BOOL)isShowingArtistInfo
{
    return _songLyrics.hidden;
}

-(void)needToSwitchToNextSong
{
    if ([self isShowingArtistInfo]) {
        [self loadArtistInfo];
    }
    else {
        [self loadLyrics];
    }
    
    [self refreshCurrentTrackInfo];
    [self updateTable];
}

#pragma mark - Handling Slider Events

-(void)songProgressTouchEnded
{
    [_player seekToPositionInCurrentSong:self.songProgress.value];
    [self enableTimer];
}

-(void)songProgressBeganChangingByUser
{
    [self disableTimer];
}

@end
