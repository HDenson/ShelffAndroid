//
//  User.h
//  Shelff
//
//  Created by Adam on 11/11/14.
//  Copyright (c) 2014 Adam. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Foundation/Foundation.h>
#import "ParseUser.h"

@interface User : NSObject

@property (nonatomic, strong) NSString *userFirstName;
@property (nonatomic, strong) NSString *userFBid;
@property (nonatomic, strong) NSString *userLocation;
@property (nonatomic, strong) UIImage *userImage;

@property (nonatomic, strong) NSArray *shoes;
@property (nonatomic, strong) NSArray *fbFriendIds;
@property (nonatomic, strong) NSArray *messagePeopleFBids;
@property (nonatomic, strong) NSArray *blackList;

-(instancetype)initWithUserFBid:(NSString *)fbID;
-(void)saveUserToParse;
-(void)fillInWithRetrievedParseProfile:(ParseUser *)parseUser;

@end
