//
//  ViewController.m
//  VKTest
//
//  Created by Admin on 26.07.15.
//  Copyright (c) 2015 EnlightenedCSF. All rights reserved.
//

#import "GroupSelectionViewController.h"
#import "GroupSelectionTableViewCell.h"
#import "GroupContentViewController.h"
#import "VKUserData.h"

#import "SourceGroup.h"
#import "Playlist.h"

#import <VKSdk.h>
#import <MagicalRecord.h>

@interface GroupSelectionViewController () <UITableViewDataSource, UITableViewDelegate, UINavigationControllerDelegate>

@property (weak, nonatomic) IBOutlet UITableView *tableView;

@property (strong, nonatomic) NSArray *groups;

@property (strong, nonnull) VKUserData *sharedData;

@end


@implementation GroupSelectionViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.sharedData = [VKUserData sharedData];
    self.groups = [NSArray array];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(onVkSdkShouldPresentViewController:)
                                                 name:@"vkShouldPresentViewController"
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(onVkAuthorized)
                                                 name:@"vkAuthorized"
                                               object:nil];
}

-(void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    if (![VKSdk wakeUpSession]) {
        [VKSdk authorize:@[ VK_PER_GROUPS, VK_PER_WALL ]];
        
        _sharedData.token = [VKSdk getAccessToken];
        _sharedData.userId = _sharedData.token.userId;
    }
    else {
        [self requestData];
    }
}

-(void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

-(void)requestData
{
    VKRequest *preReq = [[VKApi users] get:@{ @"user_ids": _sharedData.userId,
                                              @"fields": @"id",
                                              @"name_case": @"Nom" }];
    [preReq executeWithResultBlock:^(VKResponse *response) {
        
        _sharedData.userId = response.json[0][@"id"];
        
        VKRequest *req = [[VKApi users] getSubscriptions:@{ @"user_id":  _sharedData.userId,
                                                            @"extended": @"1",
                                                            @"fields":   @"name,photo_50" }];
        [req executeWithResultBlock:^(VKResponse *response) {
            [self parseGroups:response.json];
            
        } errorBlock:^(NSError *error) {
            NSLog(@"%@", [error description]);
        }];

        
    } errorBlock:^(NSError *error) {
        NSLog(@"%@", [error localizedDescription]);
    }];
}

-(void)parseGroups:(id)json
{
    NSMutableArray *res = [NSMutableArray array];
    for (id item_ in json[@"items"]) {
        [res addObject:[NSMutableDictionary dictionaryWithDictionary:
                        @{ @"icon": item_[@"photo_50"],
                           @"name": item_[@"name"],
                           @"domain": item_[@"screen_name"],
                           @"selected": @(NO) }]];
    }
    self.groups = [res copy];
    [self.tableView reloadData];
}

#pragma mark - Table view stuff

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.groups.count;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    GroupSelectionTableViewCell *cell = [self.tableView dequeueReusableCellWithIdentifier:@"groupCell"];
    
    NSDictionary *item = self.groups[indexPath.row];

    [cell fillWithName:item[@"name"] andImageUrlString:item[@"icon"]];
    
    return cell;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:NO];
}

#pragma mark - Controls

- (IBAction)groupSelectionSwitchValueChanged:(UISwitch *)sender {
    GroupSelectionTableViewCell *cell = (GroupSelectionTableViewCell *)sender.superview.superview;
    NSIndexPath *path = [self.tableView indexPathForCell:cell];
    [self.groups[path.row] setObject:@(sender.isOn) forKey:@"selected"];
}

- (IBAction)groupSelectionDoneTapped:(id)sender
{    
    self.groups = [self.groups filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"selected == YES"]];
    
    [SourceGroup MR_truncateAll];
    [Playlist MR_truncateAll];
    [[NSManagedObjectContext MR_defaultContext] MR_saveOnlySelfAndWait];
    
    for (NSDictionary *item in self.groups) {
        SourceGroup *group = [SourceGroup MR_createEntity];
        group.name = item[@"name"];
        group.domain = item[@"domain"];
        group.icon = item[@"icon"];
            
        [[NSUserDefaults standardUserDefaults] setObject:group.domain forKey:@"selectedDomain"];
        [[NSManagedObjectContext MR_defaultContext] MR_saveToPersistentStoreWithCompletion:nil];
    }
    [[NSUserDefaults standardUserDefaults] synchronize];
}

#pragma mark - VK Delegate

-(void)onVkSdkShouldPresentViewController:(id)controller
{
    NSNotification *vc = (NSNotification *)controller;
    UINavigationController *nc = (UINavigationController *)vc.object;
    nc.delegate = self;
    nc.modalPresentationStyle = UIModalPresentationFormSheet;
    
    [self presentViewController:nc animated:YES completion:nil];
}

-(void)onVkAuthorized
{
    [[NSUserDefaults standardUserDefaults] setObject:@(YES) forKey:@"hasAlreadyAuthorized"];
    [[NSUserDefaults standardUserDefaults] synchronize];
    
    [self requestData];
}

@end
