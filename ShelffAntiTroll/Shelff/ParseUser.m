//
//  ParseUser.m
//  Shelff
//
//  Created by Adam on 11/17/14.
//  Copyright (c) 2014 Adam. All rights reserved.
//

#import "ParseUser.h"
#import <Parse/PFObject+Subclass.h>

@implementation ParseUser

@dynamic userFirstName;
@dynamic userFBid;
@dynamic userLocation;
@dynamic userImage;

@dynamic fbFriendIds;
@dynamic messagePeopleFBids;
@dynamic blackList;

+(void)load
{
	[self registerSubclass];
}

+(NSString *)parseClassName
{
	return @"ParseUser";
}

@end
