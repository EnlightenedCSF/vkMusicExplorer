//
//  SourcePublicViewController.m
//  VKTest
//
//  Created by Ольферук Александр on 05.08.15.
//  Copyright (c) 2015 EnlightenedCSF. All rights reserved.
//

#import "SourcePublicViewController.h"

#import <MagicalRecord.h>
#import <SDWebImage/UIImageView+WebCache.h>

#import "SourceGroup.h"

#define DEFAULT_ROW_HEIGHT 44
#define TABLE_WIDTH 300
#define MAX_ROWS 10

@interface SourcePublicViewController ()

@property (strong, nonatomic) NSArray *groups;
@property (copy, nonatomic) NSString *selectedDomain;

@property (weak, nonatomic) IBOutlet UITableView *tableView;

@end

@implementation SourcePublicViewController

-(void)viewDidLoad
{
    [super viewDidLoad];
    
    self.groups = [[SourceGroup MR_findAll] mutableCopy];
    
    self.selectedDomain = [[NSUserDefaults standardUserDefaults] objectForKey:@"selectedDomain"];
    
    CGFloat height = self.groups.count > MAX_ROWS ?
    MAX_ROWS * DEFAULT_ROW_HEIGHT :
    self.groups.count * DEFAULT_ROW_HEIGHT;
    
    self.preferredContentSize = CGSizeMake(TABLE_WIDTH, height);
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self.tableView reloadData];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.groups.count;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"sourceGroup" forIndexPath:indexPath];
    
    SourceGroup *group = self.groups[indexPath.row];
    
    cell.textLabel.text = group.name;
    [cell.imageView sd_setImageWithURL:[NSURL URLWithString:group.icon] completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL)
    {
        [cell setNeedsLayout];
    }];
    
    cell.accessoryType = [group.domain isEqualToString:self.selectedDomain] ? UITableViewCellAccessoryCheckmark : UITableViewCellAccessoryNone;
    
    return cell;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    for (NSInteger i = 0; i < self.groups.count; i++) {
        UITableViewCell *cell = [tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:i inSection:0]];
        cell.accessoryType = UITableViewCellAccessoryNone;
    }
    
    [tableView deselectRowAtIndexPath:indexPath animated:NO];
    
    UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
    cell.accessoryType = UITableViewCellAccessoryCheckmark;
    
    SourceGroup *group = self.groups[indexPath.row];
    self.selectedDomain = group.domain;
    
    [[NSUserDefaults standardUserDefaults] setObject:self.selectedDomain forKey:@"selectedDomain"];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

- (IBAction)onDoneBtnTapped:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
    if ([self.delegate respondsToSelector:@selector(onDoneBtnTapped)]) {
        [self.delegate onDoneBtnTapped];
    }
}

@end
