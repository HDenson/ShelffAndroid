//
//  EditShoeViewController.m
//  Shelff
//
//  Created by Adam on 11/17/14.
//  Copyright (c) 2014 Adam. All rights reserved.
//

#import "EditShoeViewController.h"
#import "AddedShoeCollectionViewCell.h"
#import "AppDelegate.h"
#import "Reachable.h"
#import "ShelffColors.h"

#define addImageCell @"addImageCell"

@interface EditShoeViewController () <UICollectionViewDataSource, UICollectionViewDelegate, UITextFieldDelegate, UITextViewDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate, UIActionSheetDelegate, UIAlertViewDelegate>

@property (weak, nonatomic) IBOutlet UIButton *deleteShoeButton;

@property (weak, nonatomic) IBOutlet UITextField *shoeTitleField;
@property (weak, nonatomic) IBOutlet UITextView *shoeDescriptionTextView;
@property (weak, nonatomic) IBOutlet UITextField *shoeSizeField;
@property (weak, nonatomic) IBOutlet UITextField *shoePriceField;

@property (weak, nonatomic) IBOutlet UILabel *shoeConditionLabel;
@property (weak, nonatomic) IBOutlet UISlider *shoeConditionSlider;
@property (weak, nonatomic) IBOutlet UIButton *addPictureButton;
@property (weak, nonatomic) IBOutlet UICollectionView *shoeCollectionView;
@property (weak, nonatomic) IBOutlet UIButton *discardButton;
@property (weak, nonatomic) IBOutlet UIButton *saveButton;
@property (weak, nonatomic) IBOutlet UISegmentedControl *privacySegmentedControl;

@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *spinnerTillSave;
@property (weak, nonatomic) IBOutlet UIScrollView *scrollView;
@property (weak, nonatomic) IBOutlet UIView *viewOnScrollView;
@property (strong, nonatomic) UIToolbar *keyboardToolbar;

@property (strong, nonatomic) NSArray *shoePictureArray;

@property (nonatomic) UIAlertView *removePictureAlertView;
@property (nonatomic) UIAlertView *deleteAlertView;

@end

@implementation EditShoeViewController
{
	UIImage *shoeImageToDelete;
	NSUInteger originalShoeArrayCount;
}

-(UIToolbar *)keyboardToolbar
{
	if (!_keyboardToolbar)
	{
		_keyboardToolbar = [[UIToolbar alloc] initWithFrame: CGRectMake(0, 0, self.view.frame.size.width, 44)];
		UIBarButtonItem *doneButton = [[UIBarButtonItem alloc] initWithTitle: @"Done"
																	   style: UIBarButtonItemStylePlain
																	  target: self
																	  action: @selector(done)];
		doneButton.tintColor = [UIColor blackColor];
		[_keyboardToolbar setItems: @[doneButton]];
	}
	return _keyboardToolbar;
}

-(void)done
{
	for (UIView *view in self.viewOnScrollView.subviews)
	{
		[view resignFirstResponder];
	}
}


-(NSArray *)shoePictureArray
{
	if (!_shoePictureArray)
	{
		_shoePictureArray = [[NSArray alloc] init];
	}
	return _shoePictureArray;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
	
	self.shoeCollectionView.delegate = self;
	self.shoeCollectionView.dataSource = self;
	[self.shoeCollectionView registerClass: [AddedShoeCollectionViewCell class]
				forCellWithReuseIdentifier: addImageCell];
	
	self.addPictureButton.layer.cornerRadius = 5;
	
	self.discardButton.layer.cornerRadius = 5;
	self.discardButton.layer.borderColor = [[ShelffColors shelffGreen] CGColor];
	self.discardButton.layer.borderWidth = .4;
	
	self.saveButton.layer.cornerRadius = 5;
	self.saveButton.layer.borderWidth = .4;
	self.saveButton.layer.borderColor = [[ShelffColors shelffGreen] CGColor];
	
	self.shoeDescriptionTextView.layer.cornerRadius = 5;
	self.scrollView.layer.cornerRadius = 5;
	self.scrollView.clipsToBounds = YES;
	
	self.shoeTitleField.inputAccessoryView = self.keyboardToolbar;
	self.shoeDescriptionTextView.inputAccessoryView = self.keyboardToolbar;
	self.shoePriceField.inputAccessoryView = self.keyboardToolbar;
	self.shoeSizeField.inputAccessoryView = self.keyboardToolbar;
	
	self.shoeTitleField.delegate = self;
	self.shoeDescriptionTextView.delegate = self;
	self.shoePriceField.delegate = self;
	self.shoeSizeField.delegate = self;
	
	[self setFieldsFromPassedShoe];
	
	//check for internet connection
	if ([Reachable internetNetworkIsUnreachable] && [Reachable wifiNetworkIsUnreachable])
	{
		[[[UIAlertView alloc] initWithTitle: @"No Internet Connection Is Available"
									message: @"No network connection is available. Check to make sure either wifi or cellular data is turned on."
								   delegate: self
						  cancelButtonTitle: @"Ok"
						  otherButtonTitles:nil, nil] show];
	}
	else
	{
		[self convertPFFilesToImagesAndPlaceInArrayInstance];
	}
	
}

-(void)viewDidLayoutSubviews
{
	[super viewDidLayoutSubviews];
	
	[self.scrollView setContentSize: self.viewOnScrollView.frame.size];
}

- (void)setFieldsFromPassedShoe
{
	if ([self.passedParseShoe.publicOrPrivate isEqualToString: @"private"])
	{
		[self.privacySegmentedControl setSelectedSegmentIndex: 1];
	}
	else
	{
		[self.privacySegmentedControl setSelectedSegmentIndex: 0];
	}
	
	self.shoeTitleField.text = self.passedParseShoe.shoeTitle;
	self.shoeDescriptionTextView.text = self.passedParseShoe.shoeDescription;
	self.shoeSizeField.text = self.passedParseShoe.shoeSize;
	self.shoePriceField.text = self.passedParseShoe.shoePrice;
	[self.shoeConditionSlider setValue: [self.passedParseShoe.shoeCondition floatValue]];
	self.shoeConditionLabel.text = self.passedParseShoe.shoeCondition;
}

//should be wrapped in an connection check so as to prevent six pop ups
-(void)convertPFFilesToImagesAndPlaceInArrayInstance
{
	NSMutableArray *mutablePFArray = [[NSMutableArray alloc] init];
	if (self.passedParseShoe.shoePic1) {[mutablePFArray addObject: self.passedParseShoe.shoePic1];}
	if (self.passedParseShoe.shoePic2) {[mutablePFArray addObject: self.passedParseShoe.shoePic2];}
	if (self.passedParseShoe.shoePic3) {[mutablePFArray addObject: self.passedParseShoe.shoePic3];}
	if (self.passedParseShoe.shoePic4) {[mutablePFArray addObject: self.passedParseShoe.shoePic4];}
	if (self.passedParseShoe.shoePic5) {[mutablePFArray addObject: self.passedParseShoe.shoePic5];}
	if (self.passedParseShoe.shoePic6) {[mutablePFArray addObject: self.passedParseShoe.shoePic6];}
	NSArray *shoePFArray = (NSArray *)mutablePFArray;
	
	for (int i = 0; i < shoePFArray.count; i++)
	{
		PFFile *parseShoeFile = [shoePFArray objectAtIndex: i];
		[parseShoeFile getDataInBackgroundWithBlock:^(NSData *data, NSError *error) {
			if (!error)
			{
				if (data)
				{
					NSMutableArray *mutable = [self.shoePictureArray mutableCopy];
					[mutable addObject: [UIImage imageWithData: data]];
					self.shoePictureArray = (NSArray *)mutable;
					originalShoeArrayCount = self.shoePictureArray.count;
					[self.shoeCollectionView reloadData];
				}
			}
			else
			{
				[self handleParseError: error];
			}
		}];
	}
	
}

#pragma mark - IBActionz

- (IBAction)onDeletePressed:(UIButton *)sender
{
	self.deleteAlertView = [[UIAlertView alloc] initWithTitle: @"Are You Sure You Want To Delete This Shoe?"
													  message: @"Deleting this shoe is permanent and will delete all data associated with it"
													 delegate: self
											cancelButtonTitle: @"Nevermind"
											otherButtonTitles: @"Yes, I'm Sure", nil];
	[self.deleteAlertView show];
}

- (IBAction)onShoeConditionChanged:(UISlider *)sender
{
	self.shoeConditionLabel.text = [NSString stringWithFormat:@"%d", (int)sender.value];
}

- (IBAction)onAddPicturePressed:(UIButton *)sender
{
	if (self.shoePictureArray.count >= 6)
	{
		[[[UIAlertView alloc] initWithTitle: @"Too Many Images"
									message: @"Only a max of six images are allowed, click and hold the shoe image you want to delete to make room for a different image"
								   delegate: self
						  cancelButtonTitle: @"Ok"
						  otherButtonTitles:nil, nil] show];
	}
	else
	{
		UIActionSheet *picActionSheet = [[UIActionSheet alloc] initWithTitle: @"Add an Image (Max 6)"
																	delegate: self
														   cancelButtonTitle: @"Nevermind"
													  destructiveButtonTitle: nil
														   otherButtonTitles: @"From Library", @"Take Picture", nil];
		[picActionSheet showInView: self.view];
	}
}

- (IBAction)onDiscardPressed:(UIButton *)sender
{
	[self dismissViewControllerAnimated: YES
							 completion: nil];
}

- (IBAction)onSavePressed:(UIButton *)sender
{
	if (![self checkForUnenteredFields])
	{
		[self.spinnerTillSave startAnimating];
		
		AppDelegate *appDelegate = [[UIApplication sharedApplication] delegate];
		
		self.passedParseShoe.shoeTitle = self.shoeTitleField.text;
		self.passedParseShoe.shoeOwnerFBid = appDelegate.shelffUser.userFBid;
		self.passedParseShoe.shoeDescription = self.shoeDescriptionTextView.text;
		self.passedParseShoe.shoeSize = self.shoeSizeField.text;
		self.passedParseShoe.shoePrice = self.shoePriceField.text;
		self.passedParseShoe.shoeCondition = self.shoeConditionLabel.text;
		
		//make public
		if (self.privacySegmentedControl.selectedSegmentIndex == 0)
		{
			self.passedParseShoe.publicOrPrivate = @"public";
		}
		//make private
		if (self.privacySegmentedControl.selectedSegmentIndex == 1)
		{
			self.passedParseShoe.publicOrPrivate = @"private";
		}
		//save shoe
		for (int i = 0; i < self.shoePictureArray.count; i++)
		{
			if ([self.shoePictureArray objectAtIndex: i])
			{
				UIImage *shoeImage = [self.shoePictureArray objectAtIndex: i];
				shoeImage = [EditShoeViewController imageWithImage: shoeImage scaledToSize: CGSizeMake(250, 250)];
				[self.passedParseShoe returnCorrectShoeSlot: i andSaveTheData: UIImagePNGRepresentation(shoeImage)];
				//if it's the last shoe save that bitch
				if (i == (self.shoePictureArray.count - 1))
				{
					if (self.shoePictureArray.count < originalShoeArrayCount)
					{
						switch (originalShoeArrayCount - self.shoePictureArray.count)
						{
							case 1:
								[self.passedParseShoe nullOutCorrectShoeSlot: (self.shoePictureArray.count)];
								break;
							case 2:
								[self.passedParseShoe nullOutCorrectShoeSlot: (self.shoePictureArray.count + 1)];
								break;
							case 3:
								[self.passedParseShoe nullOutCorrectShoeSlot: (self.shoePictureArray.count + 2)];
								break;
							case 4:
								[self.passedParseShoe nullOutCorrectShoeSlot: (self.shoePictureArray.count + 3)];
								break;
							case 5:
								[self.passedParseShoe nullOutCorrectShoeSlot: (self.shoePictureArray.count + 4)];
								break;
								
							default:
								break;
						}
					}
					[self.passedParseShoe saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
						if (error)
						{
							if ([error code] == kPFErrorConnectionFailed)
							{
								[self.passedParseShoe saveEventually];
							}
							else
							{
								NSLog(@"%@", [error localizedDescription]);
							}
						}
						
						[self dismissViewAfterSave];
					}];
				}
			}
		}
	}
}

-(void)dismissViewAfterSave
{
	[self.spinnerTillSave stopAnimating];
	[self dismissViewControllerAnimated: YES
							 completion: nil];
}

#pragma mark - UIAlertViewDelegate

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
	if (alertView == self.removePictureAlertView)
	{
		if (buttonIndex == 1)
		{
			NSMutableArray *mutable = [self.shoePictureArray mutableCopy];
			[mutable removeObject: shoeImageToDelete];
			self.shoePictureArray = (NSArray *)mutable;
			[self.shoeCollectionView reloadData];
		}
	}
	if (alertView == self.deleteAlertView)
	{
		if (buttonIndex == 1)
		{
			[self.spinnerTillSave startAnimating];
			[self.passedParseShoe deleteInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
				if (!error)
				{
					[self.spinnerTillSave stopAnimating];
					[self dismissViewControllerAnimated: YES
											 completion: nil];
				}
				else
				{
					[[[UIAlertView alloc] initWithTitle: @"There Was A Problem"
									   message: @"There was an error when deleting this shoe from the database, please try again"
											   delegate: self
									  cancelButtonTitle: @"Ok"
									  otherButtonTitles: nil, nil] show];
				}
			}];
		}
	}
}

#pragma mark - UICollectionView DataSource and Delegate

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
	
	return self.shoePictureArray.count;
}

- (AddedShoeCollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
	AddedShoeCollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier: addImageCell
																				  forIndexPath: indexPath];
	
	cell.shoeImageView.image = [self.shoePictureArray objectAtIndex: indexPath.row];
	
	return cell;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
	shoeImageToDelete = [self.shoePictureArray objectAtIndex: indexPath.row];
	
	self.removePictureAlertView = [[UIAlertView alloc] initWithTitle: @"Delete Photo"
													  message: @"Are you sure you want to delete this photo?" delegate: self
											cancelButtonTitle: @"Nevermind"
											otherButtonTitles: @"Yes, I'm Sure", nil];
	
	[self.removePictureAlertView show];
	
}

#pragma mark - UIAction Sheet Delegate

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
	if (buttonIndex == 0)
	{
		//from library
		UIImagePickerController *libraryPicker = [[UIImagePickerController alloc] init];
		libraryPicker.delegate = self;
		libraryPicker.allowsEditing = NO;
		if (![UIImagePickerController isSourceTypeAvailable: UIImagePickerControllerSourceTypePhotoLibrary])
		{
			UIAlertView *alertView = [[UIAlertView alloc] initWithTitle: @"Woops!"
																message: @"It seems the app doesn't have access to the provided library"
															   delegate: self
													  cancelButtonTitle: @"Ok"
													  otherButtonTitles: nil, nil];
			[alertView show];
		}
		else
		{
			libraryPicker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
			[self presentViewController:libraryPicker
							   animated:YES
							 completion:^{
								 
							 }];
		}
	}
	if (buttonIndex == 1)
	{
		//take picture
		UIImagePickerController *cameraPicker = [[UIImagePickerController alloc] init];
		cameraPicker.delegate = self;
		cameraPicker.allowsEditing = NO;
		if (![UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera])
		{
			UIAlertView *alert = [[UIAlertView alloc] initWithTitle: @"Woops!"
															message: @"It seems the camera isn't available"
														   delegate: self
												  cancelButtonTitle: @"Ok"
												  otherButtonTitles: nil, nil];
			[alert show];
		}
		else
		{
			cameraPicker.sourceType = UIImagePickerControllerSourceTypeCamera;
			[self presentViewController:cameraPicker
							   animated:YES
							 completion:^{
								 
							 }];
		}
	}
}

#pragma mark - UIImagePicker Delegate

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{
	UIImage *chosenImage = info[UIImagePickerControllerOriginalImage];
	NSMutableArray *mutableArr = [self.shoePictureArray mutableCopy];
	[mutableArr addObject: chosenImage];
	self.shoePictureArray = (NSArray *)mutableArr;
	[self.shoeCollectionView reloadData];
	
	[picker dismissViewControllerAnimated: YES
							   completion: nil];
	
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker
{
	[picker dismissViewControllerAnimated: YES
							   completion: nil];
}

#pragma mark - UITextField Delegate

-(CGFloat)quantityToShiftSoThatKeyboardIsRightUnderView:(UIView *)firstResponder inFrame:(CGRect)frame
{
	CGRect keyboardRect = CGRectMake(0,
									 (frame.size.height - 300),
									 frame.size.width,
									 300);
	double distanceBetweenKeyboardAndViewBottonOrigin = keyboardRect.origin.y - (firstResponder.frame.origin.y + firstResponder.frame.size.height);
	return -(abs(distanceBetweenKeyboardAndViewBottonOrigin));
}

- (void)textFieldDidBeginEditing:(UITextField *)textField
{
	if (textField == self.shoePriceField || textField == self.shoeSizeField)
	{
		[UIView animateWithDuration:.5f
							  delay:0
			 usingSpringWithDamping:.8
			  initialSpringVelocity:10
							options:UIViewAnimationOptionCurveEaseIn
						 animations:^{
							 CGRect frame = self.view.frame;
							 frame.origin.y = [self quantityToShiftSoThatKeyboardIsRightUnderView: textField
																						  inFrame: self.viewOnScrollView.frame];
							 self.view.frame = frame;
						 }
						 completion:^(BOOL finished) {
							 
						 }];
	}
	
}

-(void)textFieldDidEndEditing:(UITextField *)textField
{
	if (textField == self.shoePriceField || textField == self.shoeSizeField)
	{
		[UIView animateWithDuration:.4f
							  delay:0
			 usingSpringWithDamping:.8
			  initialSpringVelocity:10
							options:UIViewAnimationOptionCurveEaseOut
						 animations:^{
							 CGRect frame = self.view.frame;
							 frame.origin.y = 0;
							 self.view.frame = frame;
						 }
						 completion:^(BOOL finished) {
							 
						 }];
	}
	
}

#pragma mark - UITextViewDelegate

- (void)textViewDidBeginEditing:(UITextView *)textView
{
	[UIView animateWithDuration:.5f
						  delay:0
		 usingSpringWithDamping:.8
		  initialSpringVelocity:10
						options:UIViewAnimationOptionCurveEaseIn
					 animations:^{
						 CGRect frame = self.view.frame;
						 frame.origin.y = [self quantityToShiftSoThatKeyboardIsRightUnderView: textView
																					  inFrame: self.viewOnScrollView.frame];
						 self.view.frame = frame;
					 }
					 completion:^(BOOL finished) {
						 
					 }];
}

- (void)textViewDidEndEditing:(UITextView *)textView
{
	[UIView animateWithDuration:.4f
						  delay:0
		 usingSpringWithDamping:.8
		  initialSpringVelocity:10
						options:UIViewAnimationOptionCurveEaseOut
					 animations:^{
						 CGRect frame = self.view.frame;
						 frame.origin.y = 0;
						 self.view.frame = frame;
					 }
					 completion:^(BOOL finished) {
						 
					 }];
}

#pragma mark - Class method to resize images
+ (UIImage *)imageWithImage:(UIImage*)image scaledToSize:(CGSize)newSize
{
	UIGraphicsBeginImageContext( newSize );
	[image drawInRect:CGRectMake(0,0,newSize.width,newSize.height)];
	UIImage *newImage = UIGraphicsGetImageFromCurrentImageContext();
	UIGraphicsEndImageContext();
	
	return newImage;
}

#pragma mark - Check For Unentered Fields

-(BOOL)checkForUnenteredFields
{
	if ([[self.shoeTitleField.text stringByReplacingOccurrencesOfString:@" " withString:@""] isEqualToString:@""])
	{
		UIAlertView *titleAlert = [[UIAlertView alloc] initWithTitle: @"Title Field Empty"
															 message: @"Shoe must have a brief title (brand, style, etc.)"
															delegate: self
												   cancelButtonTitle: @"Ok"
												   otherButtonTitles: nil, nil];
		[titleAlert show];
		return YES;
	}
	else if ([[self.shoeDescriptionTextView.text stringByReplacingOccurrencesOfString:@" " withString:@""] isEqualToString: @""])
	{
		UIAlertView *descriptionAlert = [[UIAlertView alloc] initWithTitle: @"Shoe Description Empty"
																   message: @"Shoe must have at least a brief description."
																  delegate: self
														 cancelButtonTitle: @"Ok"
														 otherButtonTitles: nil, nil];
		[descriptionAlert show];
		return YES;
	}
	else if ([[self.shoePriceField.text stringByReplacingOccurrencesOfString:@" " withString:@""] isEqualToString: @""])
	{
		UIAlertView *priceAlert = [[UIAlertView alloc] initWithTitle: @"Shoe Price Empty"
															 message: @"Shoe must have a price"
															delegate: self
														 cancelButtonTitle: @"Ok"
														 otherButtonTitles: nil, nil];
		[priceAlert show];
		return YES;
	}
	else if ([[self.shoeSizeField.text stringByReplacingOccurrencesOfString:@" " withString:@""] isEqualToString: @""])
	{
		UIAlertView *sizeAlert = [[UIAlertView alloc] initWithTitle: @"Shoe Size Empty"
															message: @"Shoe must have a size"
														   delegate: self
												  cancelButtonTitle: @"Ok"
												  otherButtonTitles: nil, nil];
		[sizeAlert show];
		return YES;
	}
	else if (self.shoePictureArray.count == 0)
	{
		UIAlertView *imageAlert = [[UIAlertView alloc] initWithTitle: @"No Images Entered"
															 message: @"You need at least one image of the shoe to continue."
															delegate: self
												   cancelButtonTitle: @"Ok"
												   otherButtonTitles: nil, nil];
		[imageAlert show];
		return YES;
	}
	
	return NO;
}

-(void)handleParseError:(NSError *)error
{
	if ([error code] == kPFErrorConnectionFailed)
	{
		[[[UIAlertView alloc] initWithTitle: @"No Internet Connection"
									message: @"Make sure you have an active network connection"
								   delegate: self
						  cancelButtonTitle: @"Ok"
						  otherButtonTitles: nil, nil] show];
	}
	if ([error code] == kPFErrorObjectNotFound)
	{
		NSLog(@"No Object Doe %@", [error localizedDescription]);
	}
}


@end
