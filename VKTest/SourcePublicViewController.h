//
//  SourcePublicViewController.h
//  VKTest
//
//  Created by Ольферук Александр on 05.08.15.
//  Copyright (c) 2015 EnlightenedCSF. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol VKSourcePublicSelectionDelegate<NSObject>

-(void)onDoneBtnTapped;

@end

@interface SourcePublicViewController : UIViewController<UITableViewDataSource, UITableViewDelegate>

@property (weak, nonatomic) id<VKSourcePublicSelectionDelegate> delegate;

@end
