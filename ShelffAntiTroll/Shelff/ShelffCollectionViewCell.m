//
//  ShelffCollectionViewCell.m
//  Shelff
//
//  Created by Adam on 12/7/14.
//  Copyright (c) 2014 Adam. All rights reserved.
//

#import "ShelffCollectionViewCell.h"
#import "ShelffColors.h"

@implementation ShelffCollectionViewCell

- (id)initWithFrame:(CGRect)frame
{
	self = [super initWithFrame:frame];
	if (self)
	{
		UIView *purpleBackView = [[UIView alloc] initWithFrame: CGRectMake(0, 0, 285, 314)];
		purpleBackView.backgroundColor = [ShelffColors shelffPurple];
		purpleBackView.layer.cornerRadius = 10;
		purpleBackView.clipsToBounds = YES;
		purpleBackView.layer.borderColor = [[ShelffColors shelffGreen] CGColor];
		purpleBackView.layer.borderWidth = .7;
		[self addSubview: purpleBackView];
		[purpleBackView addSubview:self.shoeImageView];
		[purpleBackView addSubview: self.shoeLabel];
	}
	return self;
}

-(UIImageView *)shoeImageView
{
	if (!_shoeImageView)
	{
		_shoeImageView = [[UIImageView alloc] initWithFrame: CGRectMake(22, 16, 241, 240)];
		_shoeImageView.layer.cornerRadius = 5;
		_shoeImageView.clipsToBounds = YES;
		_shoeImageView.layer.shadowColor = [[UIColor darkGrayColor] CGColor];
		_shoeImageView.layer.shadowOffset = CGSizeMake(2, -2);
	}
	return _shoeImageView;
}

-(UILabel *)shoeLabel
{
	if (!_shoeLabel)
	{
		_shoeLabel = [[UILabel alloc] initWithFrame:CGRectMake(22, 273, 241, 24)];
		_shoeLabel.textAlignment = NSTextAlignmentCenter;
		_shoeLabel.textColor = [UIColor whiteColor];
		_shoeLabel.font = [UIFont fontWithName:@"HelveticaNeue-CondensedBold"
										  size:17.0];
		_shoeLabel.minimumScaleFactor = .5;
		_shoeLabel.layer.cornerRadius = 5;
		_shoeLabel.clipsToBounds = YES;
		_shoeLabel.backgroundColor = [UIColor whiteColor];
		_shoeLabel.textColor = [ShelffColors shelffPurple];
	}
	return _shoeLabel;
}

@end
