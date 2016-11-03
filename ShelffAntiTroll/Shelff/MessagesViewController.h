//
//  MessagesViewController.h
//  Shelff
//
//  Created by Adam on 12/7/14.
//  Copyright (c) 2014 Adam. All rights reserved.
//

#import "JSQMessagesViewController.h"
#import "AppDelegate.h"


@interface MessagesViewController : JSQMessagesViewController

@property (nonatomic, strong) ParseUser *passedParseProfile;
@property (nonatomic, strong) UIImage *passedProfilePicture;

@end
