//
//  ShoeDetailViewController.m
//  Shelff
//
//  Created by Adam on 12/6/14.
//  Copyright (c) 2014 Adam. All rights reserved.
//

#import "ShoeDetailViewController.h"
#import "DetailShoeCollectionViewCell.h"
#import "MessagesViewController.h"
#import "ParseUser.h"
#import "ShelffColors.h"

#define friendShoeCell @"friendShoeCell"
#define messageSegue @"shelffMessage"

@interface ShoeDetailViewController () <UICollectionViewDataSource, UICollectionViewDelegate>

@property (weak, nonatomic) IBOutlet UILabel *shoeTitleLabel;
@property (weak, nonatomic) IBOutlet UITextView *shoeDescriptionTextView;
@property (weak, nonatomic) IBOutlet UITextField *shoeSizeField;
@property (weak, nonatomic) IBOutlet UITextField *shoePriceField;
@property (weak, nonatomic) IBOutlet UILabel *shoeConditionLabel;
@property (weak, nonatomic) IBOutlet UILabel *shoeLocationLabel;

@property (weak, nonatomic) IBOutlet UICollectionView *shoeCollectionView;

@property (weak, nonatomic) IBOutlet UIButton *dismissButton;
@property (weak, nonatomic) IBOutlet UIButton *interestButton;

@property (nonatomic, strong) NSArray *pfFileArray;
@property (weak, nonatomic) IBOutlet UIView *viewInScrollView;
@property (weak, nonatomic) IBOutlet UIScrollView *scrollView;

@property (nonatomic, strong) ParseUser *passedShoeOwner;

@end

@implementation ShoeDetailViewController

-(NSArray *)pfFileArray
{
	if (!_pfFileArray)
	{
		NSMutableArray *mutable = [[NSMutableArray alloc] init];
		if (self.passedParseShoe.shoePic1) {[mutable addObject: self.passedParseShoe.shoePic1];}
		if (self.passedParseShoe.shoePic2) {[mutable addObject: self.passedParseShoe.shoePic2];}
		if (self.passedParseShoe.shoePic3) {[mutable addObject: self.passedParseShoe.shoePic3];}
		if (self.passedParseShoe.shoePic4) {[mutable addObject: self.passedParseShoe.shoePic4];}
		if (self.passedParseShoe.shoePic5) {[mutable addObject: self.passedParseShoe.shoePic5];}
		if (self.passedParseShoe.shoePic6) {[mutable addObject: self.passedParseShoe.shoePic6];}
		_pfFileArray = (NSArray *)mutable;
	}
	return _pfFileArray;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
	
	self.shoeCollectionView.delegate = self;
	self.shoeCollectionView.dataSource = self;
	
	[self.shoeCollectionView registerClass: [DetailShoeCollectionViewCell class]
				forCellWithReuseIdentifier: friendShoeCell];
	
	self.scrollView.layer.cornerRadius = 5;
	
	self.shoeDescriptionTextView.layer.cornerRadius = 5;
	
	self.dismissButton.layer.cornerRadius = 5;
	self.dismissButton.layer.borderWidth = .4;
	self.dismissButton.layer.borderColor = [[ShelffColors shelffGreen] CGColor];
	
	self.interestButton.layer.cornerRadius = 5;
	self.interestButton.layer.borderWidth = .4;
	self.interestButton.layer.borderColor = [[ShelffColors shelffGreen] CGColor];
	
	[self setParseShoeFields];
	
	if (self.fromGlobalShelff)
	{
		[self makeParseRequestForUserId];
	}
}

-(void)viewDidLayoutSubviews
{
	[super viewDidLayoutSubviews];
	
	[self.scrollView setContentSize: self.viewInScrollView.frame.size];
}

-(void)setParseShoeFields
{
	self.shoeTitleLabel.text = self.passedParseShoe.shoeTitle;
	self.shoeDescriptionTextView.text = self.passedParseShoe.shoeDescription;
	self.shoeSizeField.text = self.passedParseShoe.shoeSize;
	self.shoePriceField.text = self.passedParseShoe.shoePrice;
	self.shoeConditionLabel.text = self.passedParseShoe.shoeCondition;
	self.shoeLocationLabel.text = self.passedParseShoe.shoeLocation;
}

//need to make this request so you can check the blacklist when the detail originates from the feed
-(void)makeParseRequestForUserId
{
	PFQuery *query = [ParseUser query];
	[query whereKey: @"userFBid" equalTo: self.passedParseShoe.shoeOwnerFBid];
	[query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
		if (!error)
		{
			self.passedShoeOwner = [objects firstObject];
		}
		else
		{
			[self handleParseError: error];
		}
	}];
}

#pragma mark - IBActionz

- (IBAction)onDismissPressed:(UIButton *)sender
{
	[self dismissViewControllerAnimated: YES
							 completion: nil];
}
- (IBAction)onInterestedPressed:(id)sender
{
	if (self.fromGlobalShelff)
	{
		AppDelegate *appDelegate = [[UIApplication sharedApplication] delegate];
		//make sure the person is not on the black list so you can't add them unintentionally
		if (![appDelegate.shelffUser.blackList containsObject: self.passedParseShoe.shoeOwnerFBid])
		{
			//make sure you are not on the other person's black list
			if (![self.passedShoeOwner.blackList containsObject: appDelegate.shelffUser.blackList])
			{
				if (![appDelegate.shelffUser.messagePeopleFBids containsObject: self.passedParseShoe.shoeOwnerFBid])
				{
					//save the owner to message list, so you can contact them
					NSMutableArray *mutable = [appDelegate.shelffUser.messagePeopleFBids mutableCopy];
					if (!mutable) {mutable = [NSMutableArray new];}
					[mutable addObject: self.passedParseShoe.shoeOwnerFBid];
					appDelegate.shelffUser.messagePeopleFBids = (NSArray *)mutable;
					[appDelegate.shelffUser saveUserToParse];
				}
				[[[UIAlertView alloc] initWithTitle: @"Interest Expressed"
											message: @"You have added the owner of this shoe to your active conversations, head over to your messages to contact the owner about purchasing"
										   delegate: self
								  cancelButtonTitle: @"Ok"
								  otherButtonTitles: nil, nil] show];
				
				[self dismissViewControllerAnimated: YES
										 completion: nil];
			}
			else
			{
				[[[UIAlertView alloc] initWithTitle: @"You've Been Blocked"
											message: @"You have been blocked by the owner of this shoe in the past, so he/she will not be added to your conversations."
										   delegate: self
								  cancelButtonTitle: @"Ok"
								  otherButtonTitles: nil, nil] show];
			}
		}
		else
		{
			[[[UIAlertView alloc] initWithTitle: @"You've Blocked This User"
										message: @"You have blocked the owner of this shoe in the past, so he/she will not be added to your conversations."
									   delegate: self
							  cancelButtonTitle: @"Ok"
							  otherButtonTitles: nil, nil] show];
		}

	}
}

#pragma mark - UICollectionView Data Source and Delegate
- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
	return self.pfFileArray.count;
}

// The cell that is returned must be retrieved from a call to -dequeueReusableCellWithReuseIdentifier:forIndexPath:
- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
	DetailShoeCollectionViewCell *cell = (DetailShoeCollectionViewCell *)[collectionView dequeueReusableCellWithReuseIdentifier: friendShoeCell
																				   forIndexPath: indexPath];
	
	if (!cell)
	{
		cell = [[DetailShoeCollectionViewCell alloc] init];
	}
	
	cell.shoeImageView.image = [UIImage imageNamed: @"shoeplaceholder.png"];
	
	PFFile *shoeFile = [self.pfFileArray objectAtIndex: indexPath.row];
	[shoeFile getDataInBackgroundWithBlock:^(NSData *data, NSError *error) {
		if (!error)
		{
			if (data)
			{
				UIImage *shoeMage = [UIImage imageWithData: data];
				cell.shoeImageView.image = shoeMage;
			}
		}
		else
		{
			[self handleParseError: error];
		}
	}];
	
	
	return cell;
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
