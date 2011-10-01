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

- (id)initWithFrame:(CGRect)frame urlString:(NSString *)theUrlString
{
    self = [super initWithFrame:frame];
    if (self) {
        self.urlString = theUrlString;
		self.backgroundColor = [UIColor magentaColor];
    }
    return self;
}



@end
