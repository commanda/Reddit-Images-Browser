//
//  RIAsyncImage.h
//  RedditImages
//
//  Created by awixted on 10/1/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface RIAsyncImage : UIImageView <NSURLConnectionDelegate, NSURLConnectionDataDelegate>
{
	NSString *urlString;
	NSURLConnection *connection;
	NSMutableData *accretion;
}

@property (nonatomic, retain) NSString *urlString;



@end
