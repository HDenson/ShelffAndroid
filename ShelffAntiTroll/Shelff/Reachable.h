//
//  Reachable.h
//  Shelff
//
//  Created by Adam on 12/8/14.
//  Copyright (c) 2014 Adam. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Reachable : NSObject

+(BOOL)internetNetworkIsUnreachable;
+(BOOL)wifiNetworkIsUnreachable;

@end
