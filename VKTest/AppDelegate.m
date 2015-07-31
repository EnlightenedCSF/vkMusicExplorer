//
//  AppDelegate.m
//  VKTest
//
//  Created by Admin on 26.07.15.
//  Copyright (c) 2015 EnlightenedCSF. All rights reserved.
//

#import "AppDelegate.h"
#import "VKUserData.h"
#import "GroupSelectionViewController.h"
#import "GroupContentViewController.h"

#import "Playlist.h"

#import <MagicalRecord.h>
#import <VKSdk.h>
#import <LastFm.h>

@interface AppDelegate () <VKSdkDelegate>

@property (strong, nonatomic) VKUserData *sharedData;

@end

@implementation AppDelegate

-(BOOL)application:(UIApplication *)application openURL:(NSURL *)url sourceApplication:(NSString *)sourceApplication annotation:(id)annotation
{
    [VKSdk processOpenURL:url fromApplication:sourceApplication];
    return YES;
}


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    [MagicalRecord setupCoreDataStackWithStoreNamed:@"VKTest"];
    
    LastFm *lastFm = [LastFm sharedInstance];
    lastFm.apiKey    = @"3432d18ae7dc1fc6decf4a6411d419ac";
    lastFm.apiSecret = @"6a599f2293668cec9bbfa08e75eb50ea";
    [lastFm getSessionForUser:@"Enlightened12" password:@"989592qq" successHandler:^(NSDictionary *result) {
        lastFm.session = result[@"key"];
        lastFm.username = result[@"name"];
    } failureHandler:^(NSError *error) {
        NSLog(@"%@", [error localizedDescription]);
    }];
    
    _sharedData = [VKUserData sharedData];
    
    if (![[NSUserDefaults standardUserDefaults] objectForKey:@"hasAlreadyAuthorized"]) { // very first time
        [[NSUserDefaults standardUserDefaults] setObject:@(NO) forKey:@"hasAlreadyAuthorized"];
    }
    
    id vc;
    if (![[[NSUserDefaults standardUserDefaults] objectForKey:@"hasAlreadyAuthorized"] boolValue]) {
        vc = (GroupSelectionViewController *)[[UIStoryboard storyboardWithName:@"MainIPad" bundle:nil] instantiateViewControllerWithIdentifier:@"sourceChoosingVC"];
    }
    else {
        vc = (GroupContentViewController *)[[UIStoryboard storyboardWithName:@"MainIPad" bundle:nil] instantiateViewControllerWithIdentifier:@"contentVCTab"];
    }
    
    [Playlist MR_truncateAll];
    [[NSManagedObjectContext MR_defaultContext] MR_saveToPersistentStoreAndWait];
    
    [VKSdk initializeWithDelegate:self andAppId:@"5009557"];
        
    self.window.rootViewController = vc;
    
    return YES;
}

- (void)applicationWillResignActive:(UIApplication *)application {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application {
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application {
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    // Saves changes in the application's managed object context before the application terminates.
}

#pragma mark - VK Delegate

-(void)vkSdkShouldPresentViewController:(UIViewController *)controller
{
    [[NSNotificationCenter defaultCenter]
        postNotificationName:@"vkShouldPresentViewController"
        object:controller];
}

-(void)vkSdkReceivedNewToken:(VKAccessToken *)newToken
{
    _sharedData.token = newToken;
    _sharedData.userId = _sharedData.token.userId;
    
    VKRequest *preReq = [[VKApi users] get:@{ @"user_ids": _sharedData.userId,
                                              @"fields": @"id",
                                              @"name_case": @"Nom" }];
    
    [preReq executeWithResultBlock:^(VKResponse *response) {
        _sharedData.userId = response.json[0][@"id"];
    } errorBlock:^(NSError *error) {
        NSLog(@"%@", [error localizedDescription]);
    }];
    
    [[NSNotificationCenter defaultCenter] postNotificationName:@"vkAuthorized" object:nil];
}

-(void)vkSdkTokenHasExpired:(VKAccessToken *)expiredToken
{
    _sharedData.token = [VKSdk getAccessToken];
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
