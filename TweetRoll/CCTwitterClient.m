//
//  CCTwitterClient.m
//  TweetRoll
//
//  Created by Cameron Cooke on 21/03/2015.
//  Copyright (c) 2015 Cameron Cooke. All rights reserved.
//

#import "CCTwitterClient.h"
#import <TwitterKit/TwitterKit.h>
#import "CCTweet.h"


static NSString *CCBaseURL = @"https://api.twitter.com/1.1/";
static NSString *const CCSearchEndPoint = @"search/tweets.json";


@implementation CCTwitterClient


- (void)fetchImagesTweetsMatchingKeyword:(NSString *)keyword onSuccess:(CCTwitterClientOnCompletion)onSuccess onError:(CCTwitterClientOnError)onError
{
    NSString *endpoint = [CCBaseURL stringByAppendingString:CCSearchEndPoint];
    
    NSDictionary *params = @{@"q": keyword,
                             @"result_type": @"recent",
                             @"count": @"20",
                             @"include_entities": @"true"};
    
    NSError *clientError;
    NSURLRequest *request = [[[Twitter sharedInstance] APIClient] URLRequestWithMethod:@"GET"
                                                                                   URL:endpoint
                                                                            parameters:params
                                                                                 error:&clientError];
    
    if (request) {
        
        [[[Twitter sharedInstance] APIClient] sendTwitterRequest:request completion:^(NSURLResponse *response, NSData *data, NSError *connectionError) {
            
             if (data) {
                 // handle the response data e.g.
                NSError *jsonError;
                 NSDictionary *json = [NSJSONSerialization JSONObjectWithData:data options:0 error:&jsonError];
                 NSArray *tweets = [CCTweet tweetsWithJSONArray:json[@"statuses"]];
                 
                 onSuccess(tweets);
             }
             else {
                 NSLog(@"Error: %@", connectionError);
                 
                 if (onError) {
                     onError(connectionError);
                 }
             }
         }];
    }
    else {
        NSLog(@"Error: %@", clientError);
    }
}


@end
