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

#import "SourceGroup.h"

#import <VKSdk.h>
#import <MagicalRecord.h>
#define MR_SHORTHAND

@interface GroupSelectionViewController () <UITableViewDataSource, UITableViewDelegate, VKSdkDelegate>

@property (weak, nonatomic) IBOutlet UITableView *tableView;

@property (strong, nonatomic) NSArray *groups;

@property (strong, nonatomic) VKAccessToken *token;
@property (copy, nonatomic) NSString *userId;

@end


@implementation GroupSelectionViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.groups = [NSArray array];
    
    [VKSdk initializeWithDelegate:self andAppId:@"5009557"];
    if (![VKSdk wakeUpSession]) {
        [VKSdk authorize:@[VK_PER_GROUPS, VK_PER_WALL]];
    }
    else {
        self.token = [VKSdk getAccessToken];
        self.userId = self.token.userId;
        
        [self requestData];
    }
}

-(void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    if ([VKSdk wakeUpSession]) {
        [self requestData];
    }
}

-(void)requestData
{
    VKRequest *req = [[VKApi users] getSubscriptions:@{ @"user_id":  self.userId,
                                                        @"extended": @"1",
                                                        @"fields":   @"name,photo_50" }];
    [req executeWithResultBlock:^(VKResponse *response) {
        [self parseGroups:response.json];
        
        //NSLog(@"%@", response.json);
        
    } errorBlock:^(NSError *error) {
        NSLog(@"%@", [error description]);
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

- (IBAction)groupSelectionDoneTapped:(id)sender {
    self.groups = [self.groups filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"selected == YES"]];
    
  
//    if (![[NSUserDefaults standardUserDefaults] boolForKey:@"hasAlreadyChosenGroups"]) {
    
        for (NSDictionary *item in self.groups) {
            SourceGroup *group = [SourceGroup MR_createEntity];
            group.name = item[@"name"];
            group.domain = item[@"domain"];
            group.icon = item[@"icon"];
            
            [[NSUserDefaults standardUserDefaults] setObject:group.domain forKey:@"selectedDomain"];
            [[NSManagedObjectContext MR_defaultContext] MR_saveToPersistentStoreWithCompletion:nil];
        }
        
//        [[NSUserDefaults standardUserDefaults] setBool:YES forKey:@"hasAlreadyChosenGroups"];
//        [[NSUserDefaults standardUserDefaults] synchronize];
//    }
}

#pragma mark - VK Delegate

-(void)vkSdkShouldPresentViewController:(UIViewController *)controller
{
    [self.navigationController.topViewController presentViewController:controller animated:YES completion:nil];
}

-(void)vkSdkReceivedNewToken:(VKAccessToken *)newToken
{
    self.token = newToken;
    self.userId = newToken.userId;
}

-(void)vkSdkTokenHasExpired:(VKAccessToken *)expiredToken
{
    self.token = [VKSdk getAccessToken];
}

-(void)vkSdkUserDeniedAccess:(VKError *)authorizationError
{
    NSLog(@"%@", authorizationError.description);
}

-(void)vkSdkNeedCaptchaEnter:(VKError *)captchaError
{
    NSLog(@"%@", captchaError.description);
}

@end
