//
//  PlaylistHeaderTableViewCell.h
//  VKTest
//
//  Created by Ольферук Александр on 27.07.15.
//  Copyright (c) 2015 EnlightenedCSF. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface PlaylistHeaderTableViewCell : UITableViewCell

-(void)fill:(NSString *)photoUrl andTime:(NSNumber *)time;

@end
