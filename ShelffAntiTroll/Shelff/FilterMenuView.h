//
//  FilterMenuView.h
//  Shelff
//
//  Created by Adam on 1/2/15.
//  Copyright (c) 2015 Adam. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol FilterMenuDelegate;

@interface FilterMenuView : UIView

@property (nonatomic, weak) id<FilterMenuDelegate> delegate;

@property (weak, nonatomic) IBOutlet UIButton *shoeSizeButton;
@property (weak, nonatomic) IBOutlet UIButton *locationButton;
@property (weak, nonatomic) IBOutlet UIButton *filterButton;
@property (weak, nonatomic) IBOutlet UITextField *shoeSizeTextField;
@property (weak, nonatomic) IBOutlet UITextField *locationTextField;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *filterMenuSpinner;

@end

@protocol FilterMenuDelegate <NSObject>

-(void)filterButtonWasPressed;
-(void)shoeSizeButtonWasPressed;
-(void)locationButtonWasPressed;

-(void)donePickingLocation:(NSString *)location;
-(void)donePickingShoeSize:(NSString *)shoeSize;

@end
