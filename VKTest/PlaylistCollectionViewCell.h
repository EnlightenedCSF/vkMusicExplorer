//
//  PlaylistCollectionViewCell.h
//  VKTest
//
//  Created by Ольферук Александр on 28.07.15.
//  Copyright (c) 2015 EnlightenedCSF. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "Playlist.h"

@interface PlaylistCollectionViewCell : UICollectionViewCell <UITableViewDataSource, UITableViewDelegate>

@property (weak, nonatomic) IBOutlet UITableView *playlist;

-(void)fillWithPlaylist:(Playlist *)playlist;

@end
