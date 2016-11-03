//
//  ShoeDetailViewController.h
//  Shelff
//
//  Created by Adam on 12/6/14.
//  Copyright (c) 2014 Adam. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ParseShoe.h"

@interface ShoeDetailViewController : UIViewController

@property (nonatomic, strong) ParseShoe *passedParseShoe;
@property BOOL fromGlobalShelff;

@end
