//
//  MFTAppDelegate.m
//  RedditImages
//
//  Created by awixted on 10/1/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import "MFTAppDelegate.h"

#import "MFTMasterViewController.h"

#import "MFTDetailViewController.h"

#import "JSON.h"

#import "RIAsyncImage.h"

@implementation MFTAppDelegate

@synthesize window = _window;
@synthesize navigationController = _navigationController;
@synthesize splitViewController = _splitViewController;

- (void)dealloc
{
	[_window release];
	[_navigationController release];
	[_splitViewController release];
    [super dealloc];
}

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
	
	
    self.window = [[[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]] autorelease];
    // Override point for customization after application launch.
	if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone) {
	    MFTMasterViewController *masterViewController = [[[MFTMasterViewController alloc] initWithNibName:@"MFTMasterViewController_iPhone" bundle:nil] autorelease];
		
	    self.navigationController = [[[UINavigationController alloc] initWithRootViewController:masterViewController] autorelease];
	    self.window.rootViewController = self.navigationController;
	} else {
	    MFTMasterViewController *masterViewController = [[[MFTMasterViewController alloc] initWithNibName:@"MFTMasterViewController_iPad" bundle:nil] autorelease];
	    UINavigationController *masterNavigationController = [[[UINavigationController alloc] initWithRootViewController:masterViewController] autorelease];
	    
	    MFTDetailViewController *detailViewController = [[[MFTDetailViewController alloc] initWithNibName:@"MFTDetailViewController_iPad" bundle:nil] autorelease];
		
		
		currentDetailVC = [detailViewController retain];
		
	    UINavigationController *detailNavigationController = [[[UINavigationController alloc] initWithRootViewController:detailViewController] autorelease];
		
	    self.splitViewController = [[[UISplitViewController alloc] init] autorelease];
	    self.splitViewController.delegate = detailViewController;
	    self.splitViewController.viewControllers = [NSArray arrayWithObjects:masterNavigationController, detailNavigationController, nil];
	    
	    self.window.rootViewController = self.splitViewController;
	}
    [self.window makeKeyAndVisible];
	
	[self performSelector:@selector(fetchFrontPageData) withObject:nil afterDelay:0.1];
	
    return YES;
}

-(void)fetchFrontPageData
{
	[imageURLs release];
	imageURLs = [[NSMutableArray alloc] init];
	
	NSURL *url = [NSURL URLWithString:@"http://www.reddit.com/.json"];
	NSURLRequest *request = [NSURLRequest requestWithURL:url];
	connection = [[NSURLConnection alloc] initWithRequest:request delegate:self startImmediately:YES];
	
}

-(void)connection:(NSURLConnection *)connection didReceiveResponse:(NSHTTPURLResponse *)response
{
	NSLog(@"response: %@", response);
}

-(void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data
{
	if(!accretion)
	{
		accretion = [[NSMutableData alloc] init];
	}
	[accretion appendData:data];
}


- (void)connectionDidFinishLoading:(NSURLConnection *)connection
{
	NSString *dataString = [[NSString alloc] initWithData:accretion encoding:NSUTF8StringEncoding];
	//NSLog(@"data as string: %@", dataString);
	
	NSDictionary *object = [dataString JSONValue];
	//NSLog(@"\n\n\n\n\n\n\nobject: %@", object);
	
	if([object isKindOfClass:[NSDictionary class]])
	{
		NSArray *children = [[object objectForKey:@"data"] objectForKey:@"children"];
		
		for(NSDictionary *entry in children)
		{
			NSDictionary *data = [entry objectForKey:@"data"];
			
			NSString *imageURL = [data objectForKey:@"url"];
			if(imageURL)
			{
				if([imageURL hasSuffix:@".jpg"] || [imageURL hasSuffix:@".png"])
				{
					[imageURLs addObject:imageURL];
					NSLog(@"%@", imageURL);
				}
			}
		}
	}
	
	[asyncImageViews release];
	asyncImageViews = [[NSMutableArray alloc] initWithCapacity:imageURLs.count];
	
	// Download each image
	for(NSString *imageURL in imageURLs)
	{
		RIAsyncImage *asyncImage = [[RIAsyncImage alloc] init];
		asyncImage.urlString = imageURL;
		[asyncImageViews addObject:asyncImage];
		
		// Temporary - just throw the image up on the detail view controller for now
		[currentDetailVC.view addSubview:asyncImage];
		
		[asyncImage release];
	}
	
	
}


- (void)applicationWillResignActive:(UIApplication *)application
{
	/*
	 Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
	 Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
	 */
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
	/*
	 Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later. 
	 If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
	 */
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
	/*
	 Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
	 */
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
	/*
	 Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
	 */
}

- (void)applicationWillTerminate:(UIApplication *)application
{
	/*
	 Called when the application is about to terminate.
	 Save data if appropriate.
	 See also applicationDidEnterBackground:.
	 */
}

@end