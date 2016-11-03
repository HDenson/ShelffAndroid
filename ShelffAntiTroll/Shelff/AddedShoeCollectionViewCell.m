//
//  AddedShoeCollectionViewCell.m
//  Shelff
//
//  Created by Adam on 11/17/14.
//  Copyright (c) 2014 Adam. All rights reserved.
//

#import "AddedShoeCollectionViewCell.h"

@implementation AddedShoeCollectionViewCell

- (id)initWithFrame:(CGRect)frame
{
	self = [super initWithFrame:frame];
	if (self)
	{
		[self addSubview: self.shoeImageView];
	}
	return self;
}

-(UIImageView *)shoeImageView
{
	if (!_shoeImageView)
	{
		_shoeImageView = [[UIImageView alloc] initWithFrame: self.contentView.bounds];
		_shoeImageView.layer.cornerRadius = 5;
		_shoeImageView.clipsToBounds = YES;
	}
	return _shoeImageView;
}

@end
