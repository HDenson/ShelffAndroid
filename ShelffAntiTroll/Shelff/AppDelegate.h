//
//  AppDelegate.h
//  Shelff
//
//  Created by Adam on 11/10/14.
//  Copyright (c) 2014 Adam. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "User.h"

@interface AppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) UIWindow *window;
@property (strong, nonatomic) User *shelffUser;
@property (strong, nonatomic) NSString *currentView;
@property (strong, nonatomic) NSArray *cityArray;

@end

