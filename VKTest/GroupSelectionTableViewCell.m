//
//  GroupSelectionTableViewCell.m
//  VKTest
//
//  Created by Ольферук Александр on 27.07.15.
//  Copyright (c) 2015 EnlightenedCSF. All rights reserved.
//

#import <SDWebImage/UIImageView+WebCache.h>

#import "GroupSelectionTableViewCell.h"

@interface GroupSelectionTableViewCell ()

@property (strong, nonatomic) IBOutlet UIImageView *icon;
@property (strong, nonatomic) IBOutlet UILabel *groupNameLabel;
@property (strong, nonatomic) IBOutlet UISwitch *isSelectedSwitch;

@end

@implementation GroupSelectionTableViewCell

-(void)fillWithName:(NSString *)name imageUrlString:(NSString *)url isOn:(BOOL)isOn
{
    [self.isSelectedSwitch setOn:isOn];
    [self.icon sd_setImageWithURL:[NSURL URLWithString:url]];
    self.groupNameLabel.text = name;
}

@end
