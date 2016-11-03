//
//  FilterMenuView.m
//  Shelff
//
//  Created by Adam on 1/2/15.
//  Copyright (c) 2015 Adam. All rights reserved.
//

#import "FilterMenuView.h"
#import <UIKit/UIPickerView.h>
#import "AppDelegate.h"

@interface FilterMenuView () <UIPickerViewDataSource, UIPickerViewDelegate>

@property (nonatomic, strong) UIToolbar *keyboardToolbar;
@property (nonatomic, strong) UIPickerView *cityPicker;

@property (nonatomic, strong) NSArray *cityArray;
@property (weak, nonatomic) IBOutlet UIView *menuView;

@end

@implementation FilterMenuView
{
	BOOL locationPickerIsUp;
	BOOL shoeSizePickerIsUp;
}

-(NSArray *)cityArray
{
	if (!_cityArray)
	{
		 AppDelegate *appDelegate = [[UIApplication sharedApplication] delegate];
		_cityArray = appDelegate.cityArray;
	}
	return _cityArray;
}

-(UIPickerView *)cityPicker
{
	if (!_cityPicker)
	{
		_cityPicker = [[UIPickerView alloc] init];
		_cityPicker.delegate = self;
		_cityPicker.dataSource = self;
	}
	return _cityPicker;
}

-(instancetype)initWithFrame:(CGRect)frame
{
	self = [super initWithFrame: frame];
	if (self)
	{
		self = [[[NSBundle mainBundle] loadNibNamed:@"FilterMenu" owner:self options:nil] firstObject];
		self.shoeSizeTextField.inputAccessoryView = self.keyboardToolbar;
		self.locationTextField.inputAccessoryView = self.keyboardToolbar;
		self.locationTextField.inputView = self.cityPicker;
		self.menuView.layer.cornerRadius = 5;
	}
	return self;
}

-(UIToolbar *)keyboardToolbar
{
	if (!_keyboardToolbar)
	{
		_keyboardToolbar = [[UIToolbar alloc] initWithFrame: CGRectMake(0, 0, self.frame.size.width, 44)];
		UIBarButtonItem *doneButton = [[UIBarButtonItem alloc] initWithTitle: @"Done"
																	   style: UIBarButtonItemStyleDone
																	  target: self
																	  action: @selector(done)];
		doneButton.tintColor = [UIColor blackColor];
		[_keyboardToolbar setItems:@[doneButton]];
	}
	return _keyboardToolbar;
}

-(void)done
{
	if ([self.locationTextField isFirstResponder])
	{
		[self.locationTextField resignFirstResponder];
		[[self delegate] donePickingLocation: self.locationTextField.text];
	}
	if ([self.shoeSizeTextField isFirstResponder])
	{
		[self.shoeSizeTextField resignFirstResponder];
		[[self delegate] donePickingShoeSize: self.shoeSizeTextField.text];
	}
}

- (IBAction)onFilterPressed:(UIButton *)sender
{
	[[self delegate] filterButtonWasPressed];
}

- (IBAction)onShoeSizePressed:(UIButton *)sender
{
	[[self delegate] shoeSizeButtonWasPressed];
}

- (IBAction)onLocationPressed:(UIButton *)sender
{
	[[self delegate] locationButtonWasPressed];
}

#pragma mark - UIPickerView Delegate and Data Source

// returns the number of 'columns' to display.
- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView
{
	return 1;
}

// returns the # of rows in each component..
- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component
{
	return self.cityArray.count;
}

- (NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component
{
	return [self.cityArray objectAtIndex: row];
}

- (void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component
{
	self.locationTextField.text = [self.cityArray objectAtIndex: row];
}


@end
