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

#define MAX_PLAYLIST_SIZE 9

@interface VKPlayerViewController () <UITableViewDataSource, UITableViewDelegate, VKPlaylistProtocol, VKMusicPlayerProtocol>

@property (weak, nonatomic) IBOutlet UILabel *artistLabel;
@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
@property (weak, nonatomic) IBOutlet UIProgressView *progressView;
@property (strong, nonatomic) NSTimer *timer;

@property (weak, nonatomic) IBOutlet UIButton *playPauseBtn;
@property (weak, nonatomic) IBOutlet UIButton *rewindBtn;
@property (weak, nonatomic) IBOutlet UIButton *forwardBtn;

@property (weak, nonatomic) IBOutlet UITableView *tableView;

@property (strong, nonatomic) VKMusicPlayer *player;

@property (weak, nonatomic) IBOutlet UILabel *artistNameLabel;
@property (weak, nonatomic) IBOutlet UILabel *artistTagsLabel;
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
    [self.timer invalidate];
    self.timer = nil;
}

-(void)refreshCurrentTrackInfo
{
    Song *song = [_player getCurrentTrack];
    _artistLabel.text = song.artist;
    _titleLabel.text = song.title;
    
    [_progressView setProgress:[_player getCurrentSongProgress]];
    
    if (self.timer) {
        [self.timer invalidate];
        self.timer = nil;
    }
    self.timer = [NSTimer scheduledTimerWithTimeInterval:1.0 target:self selector:@selector(updateProgressBar) userInfo:nil repeats:YES];
        
    [_playPauseBtn setIcon:([_player playing] ? FAWEIconPause : FAWEIconPlay)];
}

-(void)updateProgressBar
{
    [_progressView setProgress:[_player getCurrentSongProgress]];
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

#pragma mark - Table view delegate

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    
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
    [self loadArtistInfo];
    
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
    _artistListenersLabel.hidden = YES;
    _artistPortraitView.hidden = YES;
    [_lastFmProgressIndicator startAnimating];
}

-(void)showArtistInfo
{
    _artistNameLabel.hidden = NO;
    _artistTagsLabel.hidden = NO;
    _artistSumaryTextView.hidden = NO;
    _artistListenersLabel.hidden = NO;
    _artistPortraitView.hidden = NO;
    [_lastFmProgressIndicator stopAnimating];
}

-(void)loadArtistInfo
{
    [self hideArtistInfo];
    
    LastFm *lastFm = [LastFm sharedInstance];
    Song *song = [_player getCurrentTrack];
    if (!song) {
        return;
    }
    
    [lastFm getInfoForArtist:song.artist successHandler:^(NSDictionary *result)
    {
        [self showArtistInfo];
        
        _artistNameLabel.text = result[@"name"];
        _artistListenersLabel.text = [NSString stringWithFormat:@"%@ %@", result[@"playcount"], NSLocalizedString(@"PLAYCOUNT", nil)];
        
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
    }];
}

-(void)loadLyrics {
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

@end
