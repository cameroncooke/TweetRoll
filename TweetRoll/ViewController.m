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
#import "CCCollectionViewCell.h"
#import <TwitterKit/TwitterKit.h>
#import <AsyncDisplayKit/AsyncDisplayKit.h>


static NSString *const CCTweetCellIdentifier = @"MyCell";


@interface ViewController () <UICollectionViewDataSource, UICollectionViewDelegate, ASImageCacheProtocol, ASNetworkImageNodeDelegate>
@property (weak, nonatomic) IBOutlet UICollectionView *collectionView;
@property (strong, nonatomic) TWTRLogInButton *logInButton;
@property (strong, nonatomic) CCTwitterClient *twitterClient;
@property (strong, nonatomic) NSArray *tweets;
@property (strong, nonatomic) ASBasicImageDownloader *basicDownloader;
@property (strong, nonatomic) NSMutableDictionary *memoryCache;
@end


@implementation ViewController


- (id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if (self) {
        _twitterClient = [CCTwitterClient new];
        _memoryCache = [@{} mutableCopy];
        _basicDownloader = [ASBasicImageDownloader new];
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
    [self.twitterClient fetchImageTweetsWithQueryString:@"from:EarthPix" onSuccess:^(NSArray *tweets) {
        
        self.tweets = tweets;
        [self.collectionView reloadData];
    } onError:nil];
}


# pragma mark -
# pragma mark Caching

- (NSString *)cacheKeyForURL:(NSURL *)url
{
    return [url absoluteString];
}


- (void)setCacheImage:(UIImage *)image forKey:(NSString *)key
{
    if (image == nil || key == nil) {
        NSLog(@"Failed to set cache image as object or key was nil.");
        return;
    }
    
    [self.memoryCache setObject:image forKey:key];
}


- (UIImage *)cachedImageForKey:(NSString *)key
{
    if (key == nil) {
        NSLog(@"Failed to retrieve cache item for key '%@'", key);
        return nil;
    }
    
    return [self.memoryCache objectForKey:key];
}


# pragma mark -
# pragma mark UICollectionView

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return self.tweets.count;
}


- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    CCCollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:CCTweetCellIdentifier forIndexPath:indexPath];
    
    if (cell.imageNode == nil) {
        cell.imageNode = [[ASNetworkImageNode alloc] initWithCache:self downloader:self.basicDownloader];
        cell.imageNode.delegate = self;
        cell.imageNode.frame = cell.contentView.bounds;
        [cell.contentView insertSubview:cell.imageNode.view atIndex:0];
    }
    
    // load URL if applicable
    CCTweet *tweet = self.tweets[indexPath.item];
    CCTweetMedia *media  = tweet.media.firstObject;
    if (media != nil) {
        NSURL *url = [NSURL URLWithString:media.url];
        [cell.imageNode setURL:url resetToDefault:YES];
    } else {
        [cell.imageNode setURL:nil];
    }
    
    return cell;
}


# pragma mark -
# pragma mark ASImageCacheProtocol

- (void)fetchCachedImageWithURL:(NSURL *)URL callbackQueue:(dispatch_queue_t)callbackQueue completion:(void (^)(CGImageRef))completion
{
    if (URL == nil) {
        completion(nil);
        return;
    }
    
    NSString *key = [self cacheKeyForURL:URL];
    UIImage *image = [self cachedImageForKey:key];
    if (image == nil) {
        completion(nil);
        return;
    }
    
    // return image from cache
    dispatch_async(callbackQueue ?: dispatch_get_main_queue(), ^{
        completion(image.CGImage);
    });
}


# pragma mark -
# pragma mark ASNetworkImageNodeDelegate

- (void)imageNode:(ASNetworkImageNode *)imageNode didLoadImage:(UIImage *)image
{
    NSString *key = [self cacheKeyForURL:imageNode.URL];
    [self setCacheImage:image forKey:key];
}


@end
