//
//  ParseMessage.h
//  Shelff
//
//  Created by Adam on 11/22/14.
//  Copyright (c) 2014 Adam. All rights reserved.
//

#import <Parse/Parse.h>

@interface ParseMessage : PFObject <PFSubclassing>

+(NSString *)parseClassName;

@property (retain) NSString *messageText;
@property (retain) NSString *messageSenderName;
@property (retain) NSString *messageSenderID;
@property (retain) NSString *messageReceiverName;
@property (retain) NSString *messageReceiverID;

@end
