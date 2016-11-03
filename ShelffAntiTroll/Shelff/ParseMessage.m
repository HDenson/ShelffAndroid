//
//  ParseMessage.m
//  Shelff
//
//  Created by Adam on 11/22/14.
//  Copyright (c) 2014 Adam. All rights reserved.
//

#import "ParseMessage.h"
#import <Parse/PFObject+Subclass.h>


@implementation ParseMessage

@dynamic messageText;
@dynamic messageSenderID;
@dynamic messageSenderName;
@dynamic messageReceiverID;
@dynamic messageReceiverName;

+(NSString *)parseClassName
{
	return @"ParseMessage";
}

+(void)load
{
	[self registerSubclass];
}

@end
