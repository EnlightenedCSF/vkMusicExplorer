//
//  GroupSelectionTableViewCell.h
//  VKTest
//
//  Created by Ольферук Александр on 27.07.15.
//  Copyright (c) 2015 EnlightenedCSF. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface GroupSelectionTableViewCell : UITableViewCell

-(void)fillWithName:(NSString *)name imageUrlString:(NSString *)url isOn:(BOOL)isOn;

@end
