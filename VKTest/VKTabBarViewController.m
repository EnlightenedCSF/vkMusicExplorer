//
//  VKTabBarViewController.m
//  VKTest
//
//  Created by Ольферук Александр on 03.08.15.
//  Copyright (c) 2015 EnlightenedCSF. All rights reserved.
//

#import "VKTabBarViewController.h"

#import "UIFont+FontAwesome.h"
#import "NSString+FontAwesome.h"

#import "VMEUtils.h"

@interface VKTabBarViewController ()

@end

@implementation VKTabBarViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    UITabBarItem *explore = self.tabBar.items[0];
    explore.selectedImage = [VMEUtils imageWithFAEnum:FAWEIconSearch size:CGSizeMake(26, 26)];
    explore.image =         [VMEUtils imageWithFAEnum:FAWEIconSearch size:CGSizeMake(24, 24)];

    UITabBarItem *favs = self.tabBar.items[1];
    favs.selectedImage = [VMEUtils imageWithFAEnum:FAWEIconStar size:CGSizeMake(26, 26)];
    favs.image =         [VMEUtils imageWithFAEnum:FAWEIconStar size:CGSizeMake(24, 24)];
    
    UITabBarItem *player = self.tabBar.items[2];
    player.selectedImage =  [VMEUtils imageWithFAEnum:FAWEIconPlayCircle size:CGSizeMake(26, 26)];
    player.image =          [VMEUtils imageWithFAEnum:FAWEIconPlayCircle size:CGSizeMake(24, 24)];
}

@end
