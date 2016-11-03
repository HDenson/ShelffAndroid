//
//  ParseShoe.m
//  Shelff
//
//  Created by Adam on 11/17/14.
//  Copyright (c) 2014 Adam. All rights reserved.
//

#import "ParseShoe.h"
#import <Parse/PFObject+Subclass.h>

@implementation ParseShoe

@dynamic shoeTitle;
@dynamic shoeOwnerFBid;
@dynamic shoeDescription;
@dynamic shoeSize;
@dynamic shoePrice;
@dynamic shoeCondition;
@dynamic publicOrPrivate;
@dynamic shoeLocation;

@dynamic shoePic1;
@dynamic shoePic2;
@dynamic shoePic3;
@dynamic shoePic4;
@dynamic shoePic5;
@dynamic shoePic6;

+(void)load
{
	[self registerSubclass];
}

+(NSString *)parseClassName
{
	return @"ParseShoe";
}

-(void)nullOutCorrectShoeSlot:(NSUInteger)i
{
	switch (i)
	{
		case 0:
			self.shoePic1 = nil;
			break;
			
		case 1:
			self.shoePic2 = nil;
			break;
			
		case 2:
			self.shoePic3 =  nil;
			break;
			
		case 3:
			self.shoePic4 = nil;
			break;
			
		case 4:
			self.shoePic5 = nil;
			break;
			
		case 5:
			self.shoePic6 = nil;
			break;
			
		default:
			break;
	}
}

-(void)returnCorrectShoeSlot:(int)i andSaveTheData:(NSData *)shoePicData
{
	switch (i)
	{
		case 0:
		{self.shoePic1 = [PFFile fileWithData: shoePicData];
			[self.shoePic1 saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
				[self handleParseError: error];
			}];
			break;}
			
		case 1:
		{self.shoePic2 = [PFFile fileWithData: shoePicData];
			[self.shoePic2 saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
				[self handleParseError: error];
			}];
			break;}
			
		case 2:
		{self.shoePic3 = [PFFile fileWithData: shoePicData];
			[self.shoePic3 saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
				[self handleParseError: error];
			}];
			break;}
			
		case 3:
		{self.shoePic4 = [PFFile fileWithData: shoePicData];
			[self.shoePic4 saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
				[self handleParseError: error];
			}];
			break;}
			
		case 4:
		{self.shoePic5 = [PFFile fileWithData: shoePicData];
			[self.shoePic5 saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
				[self handleParseError: error];
			}];
			break;}
			
		case 5:
		{self.shoePic6 = [PFFile fileWithData: shoePicData];
			[self.shoePic6 saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
				[self handleParseError: error];
			}];
			break;}
			
		default:
			break;
	}
}


-(void)handleParseError:(NSError *)error
{
	if ([error code] == kPFErrorConnectionFailed)
	{
		[[[UIAlertView alloc] initWithTitle: @"No Internet Connection"
									message: @"Make sure you have an active network connection"
								   delegate: self
						  cancelButtonTitle: @"Ok"
						  otherButtonTitles: nil, nil] show];
	}
	if ([error code] == kPFErrorObjectNotFound)
	{
		NSLog(@"No Object Doe %@", [error localizedDescription]);
	}
}

@end
