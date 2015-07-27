//
//  GroupSelectionTableViewCell.m
//  VKTest
//
//  Created by Ольферук Александр on 27.07.15.
//  Copyright (c) 2015 EnlightenedCSF. All rights reserved.
//

#import "GroupSelectionTableViewCell.h"

@interface GroupSelectionTableViewCell ()

@property (strong, nonatomic) IBOutlet UIImageView *icon;
@property (strong, nonatomic) IBOutlet UILabel *groupNameLabel;
@property (strong, nonatomic) IBOutlet UISwitch *isSelectedSwitch;

@end

@implementation GroupSelectionTableViewCell

- (void)awakeFromNib {
    [self.isSelectedSwitch setOn:NO];
}

-(void)fillWithName:(NSString *)name andImageUrlString:(NSString *)url
{
    self.icon.image = [UIImage imageWithData:[NSData dataWithContentsOfURL:[NSURL URLWithString:url]]];
    self.groupNameLabel.text = name;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
