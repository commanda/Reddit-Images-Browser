//
//  RIAsyncImage.m
//  RedditImages
//
//  Created by awixted on 10/1/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import "RIAsyncImage.h"

@implementation RIAsyncImage

@synthesize urlString;

-(void)setUrlString:(NSString *)newUrlString
{
	[urlString release];
	urlString = [newUrlString retain];
	
	// Create the data object that we'll put the data in as it comes down
	[accretion release];
	accretion = [[NSMutableData alloc] init];
	
	// Make a connection and start downloading the image
	[connection release];
	NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:urlString]];
	connection = [[NSURLConnection alloc] initWithRequest:request delegate:self startImmediately:YES];
}

-(void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data
{
	[accretion appendData:data];
}

-(void)connectionDidFinishLoading:(NSURLConnection *)connection
{
	UIImage *createdImage = [[UIImage alloc] initWithData:accretion];
	
	self.image = createdImage;
	self.frame = CGRectMake(self.frame.origin.x, self.frame.origin.y, createdImage.size.width, createdImage.size.height);
	
	[self setNeedsDisplay];
}





@end
