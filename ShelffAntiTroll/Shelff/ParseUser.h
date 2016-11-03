//
//  ParseUser.h
//  Shelff
//
//  Created by Adam on 11/17/14.
//  Copyright (c) 2014 Adam. All rights reserved.
//

#import <Parse/Parse.h>

@interface ParseUser : PFObject <PFSubclassing>

@property (retain) NSString *userFirstName;
@property (retain) NSString *userFBid;
@property (retain) NSString *userLocation;
@property (retain) PFFile *userImage;

@property (retain) NSArray *fbFriendIds;
@property (retain) NSArray *messagePeopleFBids;
@property (retain) NSArray *blackList;

+(NSString *)parseClassName;

@end
