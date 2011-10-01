//
//  MFTMasterViewController.h
//  RedditImages
//
//  Created by awixted on 10/1/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@class MFTDetailViewController;

@interface MFTMasterViewController : UITableViewController
{
	NSDictionary *tableData;
}

@property (strong, nonatomic) MFTDetailViewController *detailViewController;

@end
