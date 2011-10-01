//
//  MFTAppDelegate.h
//  RedditImages
//
//  Created by awixted on 10/1/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@class MFTDetailViewController;

@interface MFTAppDelegate : UIResponder <UIApplicationDelegate, NSURLConnectionDelegate>
{

	
	MFTDetailViewController *currentDetailVC;
}

@property (strong, nonatomic) UIWindow *window;

@property (strong, nonatomic) UINavigationController *navigationController;

@property (strong, nonatomic) UISplitViewController *splitViewController;

@end
