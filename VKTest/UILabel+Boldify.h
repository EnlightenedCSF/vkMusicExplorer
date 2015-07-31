//
//  UILabel+Boldify.h
//  VKTest
//
//  Created by Ольферук Александр on 31.07.15.
//  Copyright (c) 2015 EnlightenedCSF. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UILabel (Boldify)

- (void) boldSubstring: (NSString*) substring;
- (void) boldRange: (NSRange) range;

@end
