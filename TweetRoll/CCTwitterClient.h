//
//  CCTwitterClient.h
//  TweetRoll
//
//  Created by Cameron Cooke on 21/03/2015.
//  Copyright (c) 2015 Cameron Cooke. All rights reserved.
//

#import <Foundation/Foundation.h>


typedef void (^CCTwitterClientOnCompletion)(NSArray *tweets);
typedef void (^CCTwitterClientOnError)(NSError *error);


@interface CCTwitterClient : NSObject

- (void)fetchImagesTweetsMatchingKeyword:(NSString *)keyword onSuccess:(CCTwitterClientOnCompletion)onSuccess onError:(CCTwitterClientOnError)onError;

@end
