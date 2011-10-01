//
//  MFTDetailViewController.m
//  RedditImages
//
//  Created by awixted on 10/1/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import "MFTDetailViewController.h"
#import "JSON.h"
#import "RIAsyncImage.h"

@interface MFTDetailViewController ()
@property (strong, nonatomic) UIPopoverController *masterPopoverController;
- (void)configureView;
-(void)loadImagesForURL:(NSString *)urlString;
@end

@implementation MFTDetailViewController

@synthesize detailItem = _detailItem;

@synthesize masterPopoverController = _masterPopoverController;



- (void)dealloc
{
	[_detailItem release];
	
	[_masterPopoverController release];
	[connection release];
	[accretion release];
	[imageURLs release];
    [super dealloc];
}

#pragma mark - Managing the detail item

- (void)setDetailItem:(id)newDetailItem
{
    if (_detailItem != newDetailItem) {
        [_detailItem release]; 
        _detailItem = [newDetailItem retain]; 

        // Update the view.
        [self configureView];
    }

    if (self.masterPopoverController != nil) {
        [self.masterPopoverController dismissPopoverAnimated:YES];
    }        
}

- (void)configureView
{
    // Update the user interface for the detail item.

	if (self.detailItem) {
		self.title = [[_detailItem allKeys] objectAtIndex:0];
		
		
		[self loadImagesForURL:[_detailItem objectForKey:self.title]];
	}
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Release any cached data, images, etc that aren't in use.
}

#pragma mark - View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
	[self configureView];
	
	// Add a swipe gesture recognizer
	UISwipeGestureRecognizer *rightSwipeRecognizer = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(recognizedBackSwipe:)];
	rightSwipeRecognizer.direction = (UISwipeGestureRecognizerDirectionRight);
	[self.view addGestureRecognizer:rightSwipeRecognizer];
	[rightSwipeRecognizer release];
	
	UISwipeGestureRecognizer *leftSwipeRecognizer = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(recognizedForwardSwipe:)];
	leftSwipeRecognizer.direction = (UISwipeGestureRecognizerDirectionLeft);
	[self.view addGestureRecognizer:leftSwipeRecognizer];
	[leftSwipeRecognizer release];
	
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}



- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
	if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone) {
	    return (interfaceOrientation != UIInterfaceOrientationPortraitUpsideDown);
	} else {
	    return YES;
	}
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
		self.title = NSLocalizedString(@"Detail", @"Detail");
    }
    return self;
}

-(void)recognizedForwardSwipe:(UISwipeGestureRecognizer *)gestureRecognizer;
{
	NSLog(@"recognized swipe %@", gestureRecognizer);
}

-(void)recognizedBackSwipe:(UISwipeGestureRecognizer *)gestureRecognizer;
{
	NSLog(@"recognized swipe %@", gestureRecognizer);
}

-(void)loadImagesForURL:(NSString *)urlString
{
	if(urlString)
	{
		// Remove all our existing subviews
		for (UIView *subview in self.view.subviews)
		{
			if([subview isKindOfClass:[RIAsyncImage class]])
			{
				[subview removeFromSuperview];
			}
		}
		
		[imageURLs release];
		imageURLs = [[NSMutableArray alloc] init];
		
		if(!imageViews)
		{
			imageViews = [[NSMutableArray alloc] init];
		}
		[imageViews removeAllObjects];
		
		[accretion release];
		accretion = [[NSMutableData alloc] init];
		
		
		NSURL *url = [NSURL URLWithString:urlString];
		NSURLRequest *request = [NSURLRequest requestWithURL:url];
		connection = [[NSURLConnection alloc] initWithRequest:request delegate:self startImmediately:YES];
	}
	
}

-(void)connection:(NSURLConnection *)connection didReceiveResponse:(NSHTTPURLResponse *)response
{
	NSLog(@"response: %@", response);
}

-(void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data
{
	
	[accretion appendData:data];
}


- (void)connectionDidFinishLoading:(NSURLConnection *)connection
{
	NSString *dataString = [[NSString alloc] initWithData:accretion encoding:NSUTF8StringEncoding];
	
	
	NSDictionary *object = [dataString JSONValue];
	
	
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
	

	
	// Download each image
	int i = 0;
	for(NSString *imageURL in imageURLs)
	{
		RIAsyncImage *asyncImage = [[RIAsyncImage alloc] init];
		asyncImage.urlString = imageURL;
		
		[imageViews addObject:asyncImage];
		
		// If this is the first image url, display it now
		if(i == 0)
		{
			[self.view addSubview:asyncImage];
		}
		
		[asyncImage release];
		
		i++;
	}
	
	
}


							
#pragma mark - Split view

- (void)splitViewController:(UISplitViewController *)splitController willHideViewController:(UIViewController *)viewController withBarButtonItem:(UIBarButtonItem *)barButtonItem forPopoverController:(UIPopoverController *)popoverController
{
    barButtonItem.title = NSLocalizedString(@"Master", @"Master");
    [self.navigationItem setLeftBarButtonItem:barButtonItem animated:YES];
    self.masterPopoverController = popoverController;
}

- (void)splitViewController:(UISplitViewController *)splitController willShowViewController:(UIViewController *)viewController invalidatingBarButtonItem:(UIBarButtonItem *)barButtonItem
{
    // Called when the view is shown again in the split view, invalidating the button and popover controller.
    [self.navigationItem setLeftBarButtonItem:nil animated:YES];
    self.masterPopoverController = nil;
}

@end
