//
//  ViewController.m
//  TweetRoll
//
//  Created by Cameron Cooke on 21/03/2015.
//  Copyright (c) 2015 Cameron Cooke. All rights reserved.
//

#import "ViewController.h"
#import "CCTwitterClient.h"
#import "CCTweet.h"
#import <TwitterKit/TwitterKit.h>
#import <AsyncDisplayKit/AsyncDisplayKit.h>


static NSString *const CCTweetCellIdentifier = @"MyCell";


@interface ViewController () <UICollectionViewDataSource, UICollectionViewDelegate>
@property (weak, nonatomic) IBOutlet UICollectionView *collectionView;
@property (strong, nonatomic) TWTRLogInButton *logInButton;
@property (strong, nonatomic) CCTwitterClient *twitterClient;
@property (strong, nonatomic) NSArray *tweets;
@end


@implementation ViewController


- (id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if (self) {
        _twitterClient = [CCTwitterClient new];
    }
    return self;
}


- (void)viewDidLoad
{
    [super viewDidLoad];
    
    TWTRLogInButton *logInButton = [TWTRLogInButton buttonWithLogInCompletion:^(TWTRSession *session, NSError *error) {
        NSLog(@"Got Twitter Session: %@", session);
       
        [UIView animateWithDuration:0.3f animations:^{
            self.logInButton.alpha = 0;
        } completion:^(BOOL finished) {
            [self.logInButton removeFromSuperview];
        }];
        
        [self getTweets];
    }];
    logInButton.center = self.view.center;
    [self.view addSubview:logInButton];
    self.logInButton = logInButton;
}


- (void)getTweets
{
    [self.twitterClient fetchImagesTweetsMatchingKeyword:@"Car" onSuccess:^(NSArray *tweets) {
        self.tweets = tweets;
        [self.collectionView reloadData];
    } onError:nil];
}


# pragma mark -
# pragma mark UICollectionView

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return self.tweets.count;
}


- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    UICollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:CCTweetCellIdentifier forIndexPath:indexPath];
    
    ASNetworkImageNode *imageNode;
    if ((imageNode = cell.contentView.subviews.firstObject) == nil) {
        [imageNode removeFromSupernode];
    }
    
    imageNode = [[ASNetworkImageNode alloc] init];
    imageNode.frame = cell.contentView.bounds;
    [cell.contentView insertSubview:imageNode.view atIndex:0];
    
    // load URL if applicable
    CCTweet *tweet = self.tweets[indexPath.item];
    CCTweetMedia *media  = tweet.media.firstObject;
    if (media != nil) {
        NSURL *url = [NSURL URLWithString:media.url];
        [imageNode setURL:url resetToDefault:YES];
    }
    
    return cell;
}

@end
