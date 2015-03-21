//
//  CCTweet.h
//  TweetRoll
//
//  Created by Cameron Cooke on 21/03/2015.
//  Copyright (c) 2015 Cameron Cooke. All rights reserved.
//

#import <TwitterKit/TwitterKit.h>
#import "CCTweetMedia.h"

@interface CCTweet : TWTRTweet
@property (strong, nonatomic) NSArray *media;
@end
