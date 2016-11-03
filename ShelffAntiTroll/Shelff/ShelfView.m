//
//  ShelfView.m
//  Shelff
//
//  Created by Adam on 12/7/14.
//  Copyright (c) 2014 Adam. All rights reserved.
//

#import "ShelfView.h"
#import <QuartzCore/QuartzCore.h>

const NSString *kShelfViewKind = @"ShelfView";

@implementation ShelfView

- (id)initWithFrame:(CGRect)frame
{
	self = [super initWithFrame:frame];
	if (self)
	{
		// Initialization code
		[self setBackgroundColor:[UIColor colorWithPatternImage:[UIImage imageNamed:@"Apple-Wood"]]];
		self.layer.shadowOpacity = 0.5;
		self.layer.shadowOffset = CGSizeMake(0,5);
	}
	return self;
}

- (void)layoutSubviews
{
	CGRect shadowBounds = CGRectMake(0, -5, self.bounds.size.width, self.bounds.size.height + 5);
	self.layer.shadowPath = [UIBezierPath bezierPathWithRect:shadowBounds].CGPath;
}

+ (NSString *)kind
{
	return (NSString *)kShelfViewKind;
}

@end
