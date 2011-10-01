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
	[imageData release];
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
	
	
	if(currentlyDisplayedImageIndex + 1 < imageViews.count)
	{
		[[imageViews objectAtIndex:currentlyDisplayedImageIndex] removeFromSuperview];
		currentlyDisplayedImageIndex++;
		[self.view addSubview:[imageViews objectAtIndex:currentlyDisplayedImageIndex]];
		
	}
	
	// Is it time to load more images after the final one?
	if(currentlyDisplayedImageIndex == imageViews.count -3)
	{
		
		
		NSString *currentURL = [[_detailItem allValues] objectAtIndex:0];
		NSLog(@"currentURL: %@", currentURL);
		NSString *baseURL = [currentURL stringByDeletingLastPathComponent];
		NSString *finalName = [[imageData lastObject] objectForKey:@"name"];
		NSString *queryString = [NSString stringWithFormat:@"/.json?count=25&after=%@", finalName];
		NSString *newURL = [baseURL stringByAppendingString:queryString];
		
		[self loadImagesForURL:newURL];
	}
	
}

-(void)recognizedBackSwipe:(UISwipeGestureRecognizer *)gestureRecognizer;
{
	
	if(currentlyDisplayedImageIndex - 1 >= 0 && imageViews.count > 0)
	{
		[[imageViews objectAtIndex:currentlyDisplayedImageIndex] removeFromSuperview];
		currentlyDisplayedImageIndex--;
		[self.view addSubview:[imageViews objectAtIndex:currentlyDisplayedImageIndex]];
		
	}
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
		
		if(!imageData)
		{
			imageData = [[NSMutableArray alloc] init];
		}
		
		if(!imageViews)
		{
			imageViews = [[NSMutableArray alloc] init];
		}
		
		
		[accretion release];
		accretion = [[NSMutableData alloc] init];
		
		[connection release];
		NSURL *url = [NSURL URLWithString:urlString];
		NSURLRequest *request = [NSURLRequest requestWithURL:url];
		connection = [[NSURLConnection alloc] initWithRequest:request delegate:self startImmediately:YES];
	}
	
}

-(void)connection:(NSURLConnection *)theConnection didReceiveResponse:(NSHTTPURLResponse *)response
{
	NSLog(@"response: %@", response);
}

-(void)connection:(NSURLConnection *)theConnection didReceiveData:(NSData *)data
{
	if([connection isEqual:theConnection])
	[accretion appendData:data];
}


- (void)connectionDidFinishLoading:(NSURLConnection *)theConnection
{
	if([connection isEqual:theConnection])
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
						
						NSDictionary *importantInfo = [NSDictionary dictionaryWithObjectsAndKeys:
													   imageURL, @"imageURL",
													   [data objectForKey:@"name"], @"name",
													   nil];
						
						// Discard dupe images
						BOOL keep = YES;
						for(NSDictionary *existingInfo in imageData)
						{
							if([[existingInfo objectForKey:@"imageURL"] isEqualToString:imageURL])
							{
								keep = NO;
								break;
							}
						}
						
						if(keep)
						{
							[imageData addObject:importantInfo];
							NSLog(@"%@", importantInfo);
						}
					}
				}
			}
		}
		

		
		// Download each image
		int i = 0;
		for(NSDictionary *importantInfo in imageData)
		{
			RIAsyncImage *asyncImage = [[RIAsyncImage alloc] init];
			asyncImage.urlString = [importantInfo objectForKey:@"imageURL"];
			
			[imageViews addObject:asyncImage];
			
			// If this is the first image url, display it now
			if(i == currentlyDisplayedImageIndex)
			{
				[self.view addSubview:asyncImage];
			}
			
			[asyncImage release];
			
			i++;
		}
		
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
