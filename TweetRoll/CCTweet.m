//
//  CCTweet.m
//  TweetRoll
//
//  Created by Cameron Cooke on 21/03/2015.
//  Copyright (c) 2015 Cameron Cooke. All rights reserved.
//

#import "CCTweet.h"


@implementation CCTweet


+ (NSArray *)tweetsWithJSONArray:(NSArray *)array
{
    NSMutableArray *tmp = [@[] mutableCopy];
    for (NSDictionary *node in array) {
        
        CCTweet *tweet = [[CCTweet alloc] initWithJSONDictionary:node];
        [tweet mapExtendedFieldsWithJsonDictionary:node];        
        [tmp addObject:tweet];
    }
    return tmp;
}


- (void)mapExtendedFieldsWithJsonDictionary:(NSDictionary *)node
{
    NSDictionary *entities = node[@"entities"];
    if (entities == nil) {
        self.media = [@[] mutableCopy];
        return;
    }
    
    NSArray *media = entities[@"media"];
    if (media == nil) {
        self.media = [@[] mutableCopy];
        return;
    }
    
    NSMutableArray *tmp = [@[] mutableCopy];
    for (NSDictionary *mediaItem in media) {
        CCTweetMedia *media = [CCTweetMedia new];
        media.url = mediaItem[@"media_url"];        
        [tmp addObject:media];
    }
    
    self.media = tmp;
}


@end
