//
//  PlaylistCollectionViewCell.h
//  VKTest
//
//  Created by Ольферук Александр on 28.07.15.
//  Copyright (c) 2015 EnlightenedCSF. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "VMEPlaylist.h"

@interface PlaylistCollectionViewCell : UICollectionViewCell <UITableViewDataSource, UITableViewDelegate>

@property (weak, nonatomic) IBOutlet UITableView *playlist;

-(void)fillWithPlaylist:(VMEPlaylist *)playlist;

@end
