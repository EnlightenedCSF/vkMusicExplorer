//
//  VKJsonParser.h
//  VKTest
//
//  Created by Ольферук Александр on 06.08.15.
//  Copyright (c) 2015 EnlightenedCSF. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface VKJsonParser : NSObject

+(NSMutableArray *)parsePublics:(id)json;

+(NSMutableDictionary *)parsePlaylist:(id)json;

@end
