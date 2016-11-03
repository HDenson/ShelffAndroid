//
//  User.m
//  Shelff
//
//  Created by Adam on 11/11/14.
//  Copyright (c) 2014 Adam. All rights reserved.
//

#import "User.h"
#import <FacebookSDK/FacebookSDK.h>
#import <Parse/Parse.h>

@implementation User

-(instancetype)initWithUserFBid:(NSString *)fbID
{
	self.userFBid = fbID;
	
	return self;
}

-(void)fillInWithRetrievedParseProfile:(ParseUser *)parseUser
{
	self.userFirstName = parseUser.userFirstName;
	self.userFBid = parseUser.userFBid;
	self.userLocation = parseUser.userLocation;
	self.fbFriendIds = parseUser.fbFriendIds;
	self.messagePeopleFBids = parseUser.messagePeopleFBids;
	self.blackList = parseUser.blackList;
	
	[parseUser.userImage getDataInBackgroundWithBlock:^(NSData *data, NSError *error) {
		if (!error)
		{
			self.userImage = [UIImage imageWithData: data];
		}
		else
		{
			[self handleParseError: error];
		}
	}];
}

-(void)saveUserToParse
{
	PFQuery *query = [ParseUser query];
	[query whereKey: @"userFBid" equalTo: self.userFBid];
	[query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error)
	{
		if (!error)
		{
			ParseUser *userProfile;
			
			if (objects.count > 0)
			{
				userProfile = [objects firstObject];
			}
			else
			{
				userProfile = [ParseUser object];
			}
			
			userProfile.userFirstName = self.userFirstName;
			userProfile.userFBid = self.userFBid;
			userProfile.userLocation = self.userLocation;
			userProfile.userImage = [PFFile fileWithData: UIImagePNGRepresentation(self.userImage)];
			userProfile.fbFriendIds = self.fbFriendIds;
			userProfile.messagePeopleFBids = self.messagePeopleFBids;
			userProfile.blackList = self.blackList;
			
			[userProfile.userImage saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
				if (!error)
				{
					[userProfile saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
						if (error != nil)
						{
							[self handleParseError: error];
							if ([error code] == kPFErrorConnectionFailed)
							{
								[userProfile saveEventually];
							}
						}
					}];
				}
				else
				{
					[self handleParseError: error];
				}
			}];
		}
	}];
}

-(void)handleParseError:(NSError *)error
{
	if ([error code] == kPFErrorObjectNotFound)
	{
		NSLog(@"No objects");
	}
	if ([error code] == kPFErrorConnectionFailed)
	{
		[[[UIAlertView alloc] initWithTitle: @"No Internet Connection Is Available"
									message: @"No network connection is available. Check to make sure either wifi or cellular data is turned on."
								   delegate: self
						  cancelButtonTitle: @"Ok"
						  otherButtonTitles:nil, nil] show];
	}
}

@end
