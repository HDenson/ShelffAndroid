//
//  FacebookRequestStuff.h
//  Shelff
//
//  Created by Adam on 1/2/15.
//  Copyright (c) 2015 Adam. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@protocol FacebookRequestDelegate;

@interface FacebookRequestStuff : NSObject

@property (nonatomic, weak) id<FacebookRequestDelegate> delegate;

-(void)requestUserFbInfo;
-(void)requestFriendInfo:(NSString *)urlString withArray:(NSArray *)array;

@end

@protocol FacebookRequestDelegate <NSObject>

-(void)doneFetchingProfilePicture:(UIImage *)profilePic;
-(void)doneFetchingProfileInfo:(NSString *)info;

@end
