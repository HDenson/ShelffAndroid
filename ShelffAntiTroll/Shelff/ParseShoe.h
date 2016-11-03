//
//  ParseShoe.h
//  Shelff
//
//  Created by Adam on 11/17/14.
//  Copyright (c) 2014 Adam. All rights reserved.
//

#import <Parse/Parse.h>

@interface ParseShoe : PFObject <PFSubclassing>

//shoe basic info
@property (retain) NSString *shoeTitle;
@property (retain) NSString *shoeOwnerFBid;
@property (retain) NSString *shoeDescription;
@property (retain) NSString *shoeSize;
@property (retain) NSString *shoePrice;
@property (retain) NSString *shoeCondition;
@property (retain) NSString *publicOrPrivate;
@property (retain) NSString *shoeLocation;

@property (retain) PFFile *shoePic1;
@property (retain) PFFile *shoePic2;
@property (retain) PFFile *shoePic3;
@property (retain) PFFile *shoePic4;
@property (retain) PFFile *shoePic5;
@property (retain) PFFile *shoePic6;

+(NSString *)parseClassName;

-(void)returnCorrectShoeSlot:(int)i andSaveTheData:(NSData *)shoePicData;
-(void)nullOutCorrectShoeSlot:(NSUInteger)i;

@end
