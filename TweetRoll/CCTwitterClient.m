//
//  CCTwitterClient.m
//  TweetRoll
//
//  Created by Cameron Cooke on 21/03/2015.
//  Copyright (c) 2015 Cameron Cooke. All rights reserved.
//

#import "CCTwitterClient.h"
#import <TwitterKit/Twitter.h>
#import "CCTweet.h"


static NSString *kBaseURL = @"https://api.twitter.com/1.1/";
static NSString *const kSearchEndPoint = @"search/tweets.json";


@interface CCTwitterClient ()
@property (nonatomic, strong) TWTRAPIClient *client;
@end


@implementation CCTwitterClient


- (TWTRAPIClient *)client
{
    /*!
     * lazily load client - this is important because
     * the client initializer will return nil if the
     * twitter login session is unavailable (i.e. user
     * has not logged in yet).
     */
    if (_client == nil) {
        _client = [[TWTRAPIClient alloc] init];
    }
    
    return _client;
}


- (void)fetchImageTweetsWithQueryString:(NSString *)queryString onSuccess:(CCTwitterClientOnCompletion)onSuccess onError:(CCTwitterClientOnError)onError
{
    NSString *endpoint = [kBaseURL stringByAppendingPathComponent:kSearchEndPoint];
    
    NSDictionary *params = @{@"q": [queryString stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding],
                             @"result_type": @"mixed",
                             @"count": @"100",
                             @"include_entities": @"true"};
    
    NSError *clientError;
    NSURLRequest *request = [self.client URLRequestWithMethod:@"GET"
                                                          URL:endpoint
                                                   parameters:params
                                                        error:&clientError];
    
    if (request) {
        
        [self.client sendTwitterRequest:request completion:^(NSURLResponse *response, NSData *data, NSError *connectionError) {
            
             if (data) {
                 // handle the response data e.g.
                NSError *jsonError;
                 NSDictionary *json = [NSJSONSerialization JSONObjectWithData:data options:0 error:&jsonError];
                 NSArray *tweets = [CCTweet tweetsWithJSONArray:json[@"statuses"]];
                 
                 // filter out tweets that don't have media
                 tweets = [tweets filteredArrayUsingPredicate:[NSPredicate predicateWithBlock:^BOOL(CCTweet * _Nonnull evaluatedObject, NSDictionary<NSString *,id> * _Nullable bindings) {
                     
                     return evaluatedObject.media.count > 0;
                     
                 }]];
                 
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
