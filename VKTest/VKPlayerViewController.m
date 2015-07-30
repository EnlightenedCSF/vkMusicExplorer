//
//  VKPlayerViewController.m
//  VKTest
//
//  Created by Ольферук Александр on 30.07.15.
//  Copyright (c) 2015 EnlightenedCSF. All rights reserved.
//

#import "VKPlayerViewController.h"
#import "PlaylistItemTableViewCell.h"

#import "VKMusicPlayer.h"

#define DEFAULT_ROW_HEIGHT 44
#define TABLE_WIDTH 400

@interface VKPlayerViewController () <UITableViewDataSource, UITableViewDelegate>

@property (weak, nonatomic) IBOutlet UILabel *artistLabel;
@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
@property (weak, nonatomic) IBOutlet UIProgressView *progressView;

@property (weak, nonatomic) IBOutlet UITableView *tableView;

@property (strong, nonatomic) VKMusicPlayer *player;

@end

@implementation VKPlayerViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    CGFloat height = self.preferredContentSize.height;
    self.preferredContentSize = CGSizeMake(TABLE_WIDTH, height);
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    _player = [VKMusicPlayer sharedPlayer];
}

#pragma mark - Table view data source

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return _player.playlist.count;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    PlaylistItemTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"playlistItemCell"];
    
    
    
    return cell;
}

#pragma mark - Table view delegate

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    
}

#pragma mark - Controls

- (IBAction)btnRewindTapped:(UIButton *)sender
{
    
}

- (IBAction)btnPlayPauseTapped:(UIButton *)sender
{
    
}

- (IBAction)btnForwardTapped:(id)sender
{
    
}

@end
