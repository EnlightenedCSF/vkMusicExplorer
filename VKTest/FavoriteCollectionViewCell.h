//
//  FavoriteCollectionViewCell.h
//  VKTest
//
//  Created by Ольферук Александр on 29.07.15.
//  Copyright (c) 2015 EnlightenedCSF. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol FavoriteCellEditingDelegate <NSObject>

-(void)onDeleteCell:(id)sender;

@end

@interface FavoriteCollectionViewCell : UICollectionViewCell <UIGestureRecognizerDelegate>

@property (weak, nonatomic) id<FavoriteCellEditingDelegate> delegate;

@property (weak, nonatomic) IBOutlet UIImageView *cover;

-(void)fillWithPicUrl:(NSString *)picUrl;
-(void)toggleEditing;

@end
