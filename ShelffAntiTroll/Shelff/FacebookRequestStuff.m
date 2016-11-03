//
//  FacebookRequestStuff.m
//  Shelff
//
//  Created by Adam on 1/2/15.
//  Copyright (c) 2015 Adam. All rights reserved.
//

#import "FacebookRequestStuff.h"
#import "AppDelegate.h"
#import <FacebookSDK/FacebookSDK.h>

@implementation FacebookRequestStuff

-(void)requestUserFbInfo
{
	[FBRequestConnection startForMeWithCompletionHandler:^(FBRequestConnection *connection, id result, NSError *error)
	 {
		 if (!error)
		 {
			 NSDictionary *resultDictionary = (NSDictionary *)result;
			 
			 NSString *firstName = resultDictionary[@"first_name"];
			 [[self delegate] doneFetchingProfileInfo: firstName];
			 
			 AppDelegate *appDelegate = [[UIApplication sharedApplication] delegate];
			 [appDelegate.shelffUser setUserFirstName: firstName];
			 [self getProfilePicture];
		 }
		 else
		 {
			 [self handleAPICallError: error];
		 }
	 }];
}


-(void)requestFriendInfo:(NSString *)urlString withArray:(NSArray *)array
{
	if ([urlString isEqualToString:@"start"])
	{
		[FBRequestConnection startWithGraphPath: @"me?fields=friends"
							  completionHandler:^(FBRequestConnection *connection, id result, NSError *error)
		 {
			 if (!error)
			 {
				 NSDictionary *friendsDic = (NSDictionary *)result[@"friends"];
				 NSArray *newArray = (NSArray *)friendsDic[@"data"];
				 NSMutableArray *newFriends = [NSMutableArray new];
				 for (NSDictionary *dic in newArray)
				 {
					 //add solely the ids to an array
					 NSString *friendId = dic[@"id"];
					 [newFriends addObject: friendId];
					 
				 }
				 NSDictionary *pagingDic = result[@"paging"];
				 [self requestFriendInfo: pagingDic[@"next"]
							   withArray: (NSArray *)newFriends];
			 }
			 else
			 {
				 NSLog(@"req 1 %@", [error localizedDescription]);
				 [self handleAPICallError:error];
			 }
		 }];
	}
	if (urlString == nil)
	{
		AppDelegate *appDelegate = [[UIApplication sharedApplication] delegate];
		appDelegate.shelffUser.fbFriendIds = array;
	}
	if (urlString != nil && ![urlString isEqualToString:@"start"])
	{
		NSURL *url = [NSURL URLWithString: urlString];
		NSURLRequest *request = [NSURLRequest requestWithURL:url];
		
		[NSURLConnection sendAsynchronousRequest:request
										   queue:[NSOperationQueue mainQueue]
							   completionHandler:^(NSURLResponse *response, NSData *data, NSError *connectionError)
		 {
			 if (!connectionError)
			 {
				 NSError *error;
				 NSDictionary *mainDic = (NSDictionary *)[NSJSONSerialization
														  JSONObjectWithData: data
														  options:NSJSONReadingAllowFragments
														  error: &error];
				 if (!error)
				 {
					 NSDictionary *friendsDic = (NSDictionary *)mainDic[@"friends"];
					 NSArray *friendsArray = (NSArray *)friendsDic[@"data"];
					 
					 NSMutableArray *newFriends = [[NSMutableArray alloc] initWithArray: array];
					 for (NSDictionary *dic in friendsArray)
					 {
						 //add solely the ids to an array
						 NSString *friendId = dic[@"id"];
						 [newFriends addObject: friendId];
						 
					 }
					 NSDictionary *pagingDic = mainDic[@"paging"];
					 [self requestFriendInfo: pagingDic[@"next"]
								   withArray: (NSArray *)newFriends];
				 }
				 else
				 {
					 NSLog(@"req 2 %@", [error localizedDescription]);
				 }
				 
			 }
			 else
			 {
				 NSLog(@"req error %@, %@", [connectionError localizedDescription], urlString);
				 [[[UIAlertView alloc] initWithTitle:@"Error connecting to the server"
											 message:@"Make sure there is a valid network connection"
											delegate:self
								   cancelButtonTitle:@"OK"
								   otherButtonTitles:nil] show];
			 }
		 }];
	}
	
}

-(void)getProfilePicture
{
	AppDelegate *appDelegate = [[UIApplication sharedApplication] delegate];
	NSString *profPicURLString = [NSString stringWithFormat:@"http://graph.facebook.com/%@/picture?type=large", appDelegate.shelffUser.userFBid];
	NSURL *url = [NSURL URLWithString:profPicURLString];
	UIImage *image = [UIImage imageWithData: [NSData dataWithContentsOfURL: url]];
	[[self delegate] doneFetchingProfilePicture: image];
	[appDelegate.shelffUser setUserImage: image];
	[appDelegate.shelffUser saveUserToParse];
}

// Helper method to handle errors during API calls
-(void)handleAPICallError:(NSError *)error
{
	// For all other errors...
	NSString *alertText;
	NSString *alertTitle;
	
	// If the user should be notified, we show them the corresponding message
	if ([FBErrorUtility shouldNotifyUserForError:error])
	{
		alertTitle = @"Something Went Wrong";
		alertText = [FBErrorUtility userMessageForError:error];
		
	}
	else
	{
		// show a generic error message
		NSLog(@"Unexpected error using open graph: %@", error);
		alertTitle = @"Something went wrong";
		alertText = @"Please try again later.";
	}
	[self showMessage: alertText withTitle: alertTitle];
}

-(void)showMessage:(NSString *)text withTitle:(NSString *)title
{
	[[[UIAlertView alloc] initWithTitle: title
								message: text
							   delegate: self
					  cancelButtonTitle: @"OK"
					  otherButtonTitles: nil] show];
}

@end
