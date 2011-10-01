//
//  RIAsyncImage.h
//  RedditImages
//
//  Created by awixted on 10/1/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface RIAsyncImage : UIImageView
{
	NSString *urlString;
}

@property (nonatomic, retain) NSString *urlString;

- (id)initWithFrame:(CGRect)frame urlString:(NSString *)theUrlString;

@end
