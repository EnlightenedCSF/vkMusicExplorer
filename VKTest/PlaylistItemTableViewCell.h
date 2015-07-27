//
//  PlaylistItemTableViewCell.h
//  VKTest
//
//  Created by Ольферук Александр on 27.07.15.
//  Copyright (c) 2015 EnlightenedCSF. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface PlaylistItemTableViewCell : UITableViewCell

-(void)fillWithTitle:(NSString *)title duration:(NSNumber *)duration;

@end
