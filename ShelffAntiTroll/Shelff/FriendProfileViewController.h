//
//  FriendProfileViewController.h
//  Shelff
//
//  Created by Adam on 11/14/14.
//  Copyright (c) 2014 Adam. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ParseUser.h"

@interface FriendProfileViewController : UIViewController

@property (nonatomic, strong) ParseUser *passedParseUser;
@property (nonatomic, strong) UIImage *passedProfilePic;

@end
