//
//  CCCollectionViewCell.h
//  TweetRoll
//
//  Created by Cameron Cooke on 13/04/2016.
//  Copyright © 2016 Cameron Cooke. All rights reserved.
//

#import <UIKit/UIKit.h>


@class ASNetworkImageNode;


@interface CCCollectionViewCell : UICollectionViewCell
@property (strong, nonatomic) ASNetworkImageNode *imageNode;
@end
