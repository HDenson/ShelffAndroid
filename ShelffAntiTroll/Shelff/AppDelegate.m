//
//  AppDelegate.m
//  Shelff
//
//  Created by Adam on 11/10/14.
//  Copyright (c) 2014 Adam. All rights reserved.
//

#import "AppDelegate.h"
#import <FacebookSDK/FacebookSDK.h>
#import <Parse/Parse.h>
#import "ParseShoe.h"
#import "ParseUser.h"
#import "ParseMessage.h"

@interface AppDelegate ()

@end

@implementation AppDelegate

-(NSArray *)cityArray
{
	if (!_cityArray)
	{
		NSMutableArray *cityUnordered = [[NSMutableArray alloc] initWithArray: @[@"New York City, NY", @"Los Angeles, CA", @"Chicago, IL", @"Houston, TX", @"Philadelphia, PA", @"Phoenix, AZ", @"San Antonio, TX", @"San Diego, CA", @"Dallas, TX", @"San Jose, CA", @"Austin, TX", @"Indianapolis, IN", @"Jacksonville, FL", @"San Francisco, CA", @"Columbus, OH", @"Charlotte, NC", @"Fort Worth, TX", @"Detroit, MI", @"El Paso, TX", @"Memphis, TN", @"Seattle, WA", @"Denver, CO", @"Washington DC", @"Boston, MA", @"Nashville, TN", @"Baltimore, MD", @"Oklahoma City, OK", @"Louisville, KY", @"Portland, OR", @"Las Vegas, NV", @"Milwaukee, WI", @"Albuquerque, NM", @"Tucson, AZ", @"Fresno, CA", @"Sacramento, CA", @"Long Beach, CA", @"Kansas City, MO", @"Virginia Beach, VA", @"Atlanta, GA", @"Omaha, NE", @"Raleigh, NC", @"Miami, Florida", @"Oakland, CA", @"Minneapolis, MN", @"Tulsa, OK", @"Cleveland, OH", @"Wichita, KS", @"New Orleans, LA", @"Tampa, FL", @"St. Louis, MO", @"Pittsburgh, PA", @"Cincinnati, OH", @"Newark, NJ", @"Trenton, NJ", @"Orlando, FL", @"Birmingham, AL", @"Anchorage, AK", @"Little Rock, AR", @"Bridgeport, CT", @"Wilmington, DE", @"Honolulu, HI", @"Boise, ID", @"Portland, ME", @"Jackson, MI", @"Columbia, SC", @"Providence, RI", @"Charleston, WV", @"Salt Lake City, UT", @"Cheyenne, WY"]];
		
		[cityUnordered sortUsingComparator:^NSComparisonResult(NSString *obj1, NSString *obj2) {
			return [obj1 caseInsensitiveCompare: obj2];
		}];
		
		_cityArray = (NSArray *)cityUnordered;
	}
	
	return _cityArray;
}


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
	// Override point for customization after application launch.
	[FBLoginView class];
	[FBProfilePictureView class];
	
	[ParseUser load];
	[ParseShoe load];
	[ParseMessage load];
	[Parse setApplicationId:@"0yVidURDROy0YRt2ZFhIa5Livc4fcEftNgoKZSG9"
				  clientKey:@"IRBoCRGYbiVUIgNk0PItJtgmdMH6eCtxr5Kezc9Y"];
	[PFAnalytics trackAppOpenedWithLaunchOptions:launchOptions];
	
	UIUserNotificationType userNotificationTypes = (UIUserNotificationTypeAlert |
													UIUserNotificationTypeBadge |
													UIUserNotificationTypeSound);
	UIUserNotificationSettings *settings = [UIUserNotificationSettings settingsForTypes:userNotificationTypes
																			 categories:nil];
	[application registerUserNotificationSettings:settings];
	[application registerForRemoteNotifications];
	
	NSLog(@"%@", self.cityArray);
	
	return YES;
}

- (void)applicationWillResignActive:(UIApplication *)application
{
	// Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
	// Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
	// Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
	// If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
	// Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
	// Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
	PFInstallation *currentInstallation = [PFInstallation currentInstallation];
	if (currentInstallation.badge != 0)
	{
		currentInstallation.badge = 0;
		[currentInstallation saveInBackground];
	}
}

-(void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo
{
	//sent when you receive pushes from inside the app
	if ([userInfo[@"type"] isEqualToString: @"message"] && [self.currentView isEqualToString:@"message"])
	{
		[[NSNotificationCenter defaultCenter] postNotificationName: @"messageReceived"
															object: self
														  userInfo: userInfo];
	}
	else
	{
		[PFPush handlePush:userInfo];
	}
	
}

-(void)application:(UIApplication *)application didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)deviceToken
{
	PFInstallation *currentInstallation = [PFInstallation currentInstallation];
	[currentInstallation setDeviceTokenFromData: deviceToken];
	[currentInstallation saveInBackground];
}

-(void)application:(UIApplication *)application didFailToRegisterForRemoteNotificationsWithError:(NSError *)error
{
	NSLog(@"%@", [error localizedDescription]);
}

- (void)applicationWillTerminate:(UIApplication *)application
{
	// Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

- (BOOL)application:(UIApplication *)application openURL:(NSURL *)url sourceApplication:(NSString *)sourceApplication annotation:(id)annotation
{
	// attempt to extract a token from the url
	return [FBAppCall handleOpenURL:url sourceApplication:sourceApplication];
}

@end
