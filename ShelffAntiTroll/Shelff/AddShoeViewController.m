//
//  AddShoeViewController.m
//  Shelff
//
//  Created by Adam on 11/17/14.
//  Copyright (c) 2014 Adam. All rights reserved.
//

#import "AddShoeViewController.h"
#import "AddedShoeCollectionViewCell.h"
#import "ParseShoe.h"
#import "AppDelegate.h"
#import "ShelffColors.h"

#define addImageCell @"addImageCell"

@interface AddShoeViewController () <UINavigationControllerDelegate, UIImagePickerControllerDelegate, UIActionSheetDelegate, UICollectionViewDataSource, UICollectionViewDelegate, UIAlertViewDelegate, UITextFieldDelegate, UITextViewDelegate>

@property (weak, nonatomic) IBOutlet UITextField *shoeTitleField;
@property (weak, nonatomic) IBOutlet UITextView *shoeDescriptionTextView;
@property (weak, nonatomic) IBOutlet UITextField *shoeSizeField;
@property (weak, nonatomic) IBOutlet UITextField *shoePriceField;

@property (weak, nonatomic) IBOutlet UILabel *shoeConditionLabel;
@property (weak, nonatomic) IBOutlet UISlider *shoeConditionSlide;

@property (weak, nonatomic) IBOutlet UIButton *addPictureButton;
@property (weak, nonatomic) IBOutlet UICollectionView *pictureCollectionView;

@property (weak, nonatomic) IBOutlet UIButton *discardButton;
@property (weak, nonatomic) IBOutlet UIButton *saveButton;
@property (weak, nonatomic) IBOutlet UIScrollView *scrollView;
@property (weak, nonatomic) IBOutlet UIView *viewOnScrollView;
@property (strong, nonatomic) UIToolbar *keyboardToolbar;

@property (strong, nonatomic) NSArray *shoePictureArray;

@property (nonatomic) UIAlertView *saveAlertView;
@property (nonatomic) UIAlertView *deleteAlertView;

@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *spinnerUntilSave;

@end

@implementation AddShoeViewController
{
	UIImage *shoeImageToDelete;
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
	
	self.discardButton.layer.cornerRadius = 5;
	self.discardButton.layer.borderColor = [[ShelffColors shelffGreen] CGColor];
	self.discardButton.layer.borderWidth = .4;
	
	self.saveButton.layer.cornerRadius = 5;
	self.saveButton.layer.borderWidth = .4;
	self.saveButton.layer.borderColor = [[ShelffColors shelffGreen] CGColor];
	
	
	self.addPictureButton.layer.cornerRadius = 5;
	self.pictureCollectionView.layer.cornerRadius = 5;
	self.scrollView.layer.cornerRadius = 5;
	self.scrollView.clipsToBounds = YES;
	self.shoeDescriptionTextView.layer.cornerRadius = 5;
	
	self.shoeConditionLabel.text = [NSString stringWithFormat:@"%d", (int)self.shoeConditionSlide.value];
	
	self.pictureCollectionView.delegate = self;
	self.pictureCollectionView.dataSource = self;
	[self.pictureCollectionView registerClass: [AddedShoeCollectionViewCell class]
				   forCellWithReuseIdentifier: addImageCell];
	
	self.shoeTitleField.delegate = self;
	self.shoeDescriptionTextView.delegate = self;
	self.shoePriceField.delegate = self;
	self.shoeSizeField.delegate = self;
	
	self.shoeTitleField.inputAccessoryView = self.keyboardToolbar;
	self.shoeDescriptionTextView.inputAccessoryView = self.keyboardToolbar;
	self.shoePriceField.inputAccessoryView = self.keyboardToolbar;
	self.shoeSizeField.inputAccessoryView = self.keyboardToolbar;

}


-(void)viewDidLayoutSubviews
{
	[super viewDidLayoutSubviews];
	
	[self.scrollView setContentSize: self.viewOnScrollView.frame.size];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

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

#pragma mark - IBActionz
- (IBAction)shoeConditionChanged:(UISlider *)sender
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
	[self dismissViewControllerAnimated: YES completion: nil];
}

- (IBAction)onSavePressed:(UIButton *)sender
{
	if (![self checkForUnenteredFields])
	{
		//alert view to allow the user to make the shoe public or private
		self.saveAlertView = [[UIAlertView alloc] initWithTitle: @"Set Shoe to Public or Private"
								   message: @"Choose whether you want your shoe to be public or private. If made public, your shoe will be visible to all Shelff users, if made private it will only be visible to you. This setting can be changed at any time by editing the shoe"
								  delegate: self
						 cancelButtonTitle: nil
						  otherButtonTitles: @"Make Public", @"Make Private", nil];
		
		[self.saveAlertView show];
	}
}

#pragma mark - UIAlertView Delegate

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
	if (alertView == self.saveAlertView)
	{
		[self.spinnerUntilSave startAnimating];
		AppDelegate *appDelegate = [[UIApplication sharedApplication] delegate];

		ParseShoe *shoe = [ParseShoe object];
		shoe.shoeTitle = self.shoeTitleField.text;
		shoe.shoeOwnerFBid = appDelegate.shelffUser.userFBid;
		shoe.shoeDescription = self.shoeDescriptionTextView.text;
		shoe.shoeSize = self.shoeSizeField.text;
		shoe.shoePrice = self.shoePriceField.text;
		shoe.shoeCondition = self.shoeConditionLabel.text;
		
		//make public
		if (buttonIndex == 0)
		{
			shoe.publicOrPrivate = @"public";
		}
		//make private
		if (buttonIndex == 1)
		{
			shoe.publicOrPrivate = @"private";
		}
		//save shoe
		for (int i = 0; i < self.shoePictureArray.count; i++)
		{
			if ([self.shoePictureArray objectAtIndex: i])
			{
				UIImage *shoeImage = [self.shoePictureArray objectAtIndex: i];
				shoeImage = [AddShoeViewController imageWithImage: shoeImage scaledToSize: CGSizeMake(250, 250)];
				[shoe returnCorrectShoeSlot: i andSaveTheData: UIImagePNGRepresentation(shoeImage)];
				//if it's the last shoe save that bitch
				if (i == (self.shoePictureArray.count - 1))
				{
					[shoe saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
						if (error)
						{
							if ([error code] == kPFErrorConnectionFailed)
							{
								[shoe saveEventually];
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
	if (alertView == self.deleteAlertView)
	{
		if (buttonIndex == 1)
		{
			NSMutableArray *mutable = [self.shoePictureArray mutableCopy];
			[mutable removeObject: shoeImageToDelete];
			self.shoePictureArray = (NSArray *)mutable;
			[self.pictureCollectionView reloadData];
		}
	}
}

-(void)dismissViewAfterSave
{
	[self.spinnerUntilSave stopAnimating];
	[self dismissViewControllerAnimated: YES
							 completion: nil];
}

//class method to resize images
+ (UIImage *)imageWithImage:(UIImage*)image scaledToSize:(CGSize)newSize
{
	UIGraphicsBeginImageContext( newSize );
	[image drawInRect:CGRectMake(0,0,newSize.width,newSize.height)];
	UIImage *newImage = UIGraphicsGetImageFromCurrentImageContext();
	UIGraphicsEndImageContext();
	
	return newImage;
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
	[self.pictureCollectionView reloadData];
	
	[picker dismissViewControllerAnimated: YES
							   completion: nil];
	
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker
{
	[picker dismissViewControllerAnimated: YES
							   completion: nil];
}


#pragma mark - UICollectionView DataSource and Delegate

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{

	return self.shoePictureArray.count;
}

// The cell that is returned must be retrieved from a call to -dequeueReusableCellWithReuseIdentifier:forIndexPath:
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
	
	self.deleteAlertView = [[UIAlertView alloc] initWithTitle: @"Delete Photo"
													  message: @"Are you sure you want to delete this photo?" delegate: self
											cancelButtonTitle: @"Nevermind"
											otherButtonTitles: @"Yes, I'm Sure", nil];
	
	[self.deleteAlertView show];
	
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

@end
