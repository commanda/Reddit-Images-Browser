//
//  MFTDetailViewController.h
//  RedditImages
//
//  Created by awixted on 10/1/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface MFTDetailViewController : UIViewController <UISplitViewControllerDelegate>
{
	NSURLConnection *connection;
	NSMutableData *accretion;
	NSMutableArray *imageURLs;
	NSMutableArray *imageViews;
}

@property (strong, nonatomic) id detailItem;



@end
