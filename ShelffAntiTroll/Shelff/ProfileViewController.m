//
//  ProfileViewController.m
//  Shelff
//
//  Created by Adam on 11/11/14.
//  Copyright (c) 2014 Adam. All rights reserved.
//

#import "ProfileViewController.h"
#import "SWRevealViewController.h"
#import <FacebookSDK/FacebookSDK.h>
#import "AppDelegate.h"
#import <Parse/Parse.h>
#import "ParseUser.h"
#import "CollectionShoeCollectionViewCell.h"
#import "DetailShoeCollectionViewCell.h"
#import "ParseShoe.h"
#import "EditShoeViewController.h"
#import "Reachable.h"
#import "FacebookRequestStuff.h"
#import "ShelffColors.h"

#define addSegue @"addShoe"
#define editSegue @"editSegue"
#define fbLoginSegue @"fblogin"
#define collectionViewCell @"smallCell"
#define detailViewCell @"largeCell"

#define pageViewSegue @"pageSegue"

@interface ProfileViewController () <UICollectionViewDataSource, UICollectionViewDelegate, UIPickerViewDelegate, UIPickerViewDataSource, FacebookRequestDelegate>

@property (weak, nonatomic) IBOutlet UIView *profileCardView;
@property (weak, nonatomic) IBOutlet UIImageView *profileImage;
@property (weak, nonatomic) IBOutlet UITextField *nameField;
@property (weak, nonatomic) IBOutlet UITextField *locationField;

@property (weak, nonatomic) IBOutlet UIView *buttonView;
@property (weak, nonatomic) IBOutlet UIButton *detailShoeButton;
@property (weak, nonatomic) IBOutlet UIButton *shoeCollectionButton;

@property (weak, nonatomic) IBOutlet UICollectionView *shoeCollectionView;
@property (weak, nonatomic) IBOutlet UICollectionView *detailCollectionView;


@property (weak, nonatomic) IBOutlet UIButton *logoutButton;

@property (weak, nonatomic) IBOutlet UIButton *editButton;

@property (nonatomic, strong) NSArray *arrayOfUserShoes;

@property (nonatomic, strong) UIPickerView *cityPicker;
@property (nonatomic, strong) NSArray *cityArray;

@property (nonatomic, strong) FacebookRequestStuff *fbRequestStuff;

@end

@implementation ProfileViewController
{
	BOOL isEditing;
	BOOL detailViewIsOn;
	BOOL collectionViewIsOn;
	ParseShoe *selectedShoe;
	NSString *chosenLocation;
}

-(FacebookRequestStuff *)fbRequestStuff
{
	if (!_fbRequestStuff)
	{
		_fbRequestStuff = [[FacebookRequestStuff alloc] init];
		_fbRequestStuff.delegate = self;
	}
	return _fbRequestStuff;
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

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
	
	self.title = @"My Shelff";
	
	self.shoeCollectionView.delegate = self;
	self.shoeCollectionView.dataSource = self;
	self.detailCollectionView.delegate = self;
	self.detailCollectionView.dataSource = self;
	
	[self.detailCollectionView registerClass: [DetailShoeCollectionViewCell class]
				forCellWithReuseIdentifier: detailViewCell];
	[self.shoeCollectionView registerClass: [CollectionShoeCollectionViewCell class]
				forCellWithReuseIdentifier: collectionViewCell];
	self.detailCollectionView.hidden = YES;
	
	self.navigationController.navigationBar.titleTextAttributes = @{NSFontAttributeName : [UIFont fontWithName: @"Futura"
																										  size: 22.0], NSForegroundColorAttributeName : [ShelffColors shelffGreen]};
	
	//configure slide menu stuff
	SWRevealViewController *reveal = [self revealViewController];
	[reveal panGestureRecognizer];
	[reveal tapGestureRecognizer];
	
	UIBarButtonItem *revealButton = [[UIBarButtonItem alloc] initWithImage: [UIImage imageNamed: @"menu.png"]
																	 style: UIBarButtonItemStylePlain
																	target: reveal
																	action: @selector(revealToggle:)];
	self.navigationItem.leftBarButtonItem = revealButton;
	self.navigationItem.leftBarButtonItem.tintColor = [ShelffColors shelffGreen];
	self.navigationController.navigationBar.barTintColor = [ShelffColors shelffPurple];
	self.navigationController.navigationBar.translucent = NO;
	
	UIImageView *backgroundImageView = [[UIImageView alloc] initWithFrame: self.view.frame];
	UIImage *shoeImage = [UIImage imageNamed: @"shoes2.png"];
	backgroundImageView.image = shoeImage;
	
	[self.view addSubview: backgroundImageView];
	[self.view sendSubviewToBack: backgroundImageView];
	
	self.profileImage.clipsToBounds = YES;
	self.profileImage.layer.cornerRadius = 30;
	self.profileImage.layer.borderColor = [[UIColor blackColor] CGColor];
	self.profileImage.layer.borderWidth = .5;
	
	self.profileCardView.layer.cornerRadius = 5;
	self.buttonView.layer.cornerRadius = 5;
	
	self.detailShoeButton.layer.cornerRadius = 5;
	self.shoeCollectionButton.layer.cornerRadius = 5;
	
	self.logoutButton.layer.cornerRadius = 5;
	self.logoutButton.layer.borderWidth = .3;
	self.logoutButton.layer.borderColor = [[UIColor whiteColor] CGColor];
	
	self.shoeCollectionView.layer.cornerRadius = 5;
	self.shoeCollectionView.clipsToBounds = YES;
	self.detailCollectionView.layer.cornerRadius = 5;
	self.shoeCollectionView.clipsToBounds = YES;
	
	self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithImage: [UIImage imageNamed: @"05-plus@2x.png"]
																			  style: UIBarButtonItemStylePlain
																			 target: self
																			 action: @selector(addShoe)];
	self.navigationItem.rightBarButtonItem.tintColor = [ShelffColors shelffGreen];
	
	isEditing = NO;
	self.locationField.enabled = NO;
	self.locationField.inputView = self.cityPicker;
	
	//make the collection view the default collection view
	collectionViewIsOn = YES;
	detailViewIsOn = NO;

}

-(void)viewWillAppear:(BOOL)animated
{
	[super viewWillAppear: YES];
	
	//check to see if this isn't the first time
	if ([[NSUserDefaults standardUserDefaults] objectForKey: @"firstTime"])
	{
		//this isn't the first time
		if (![FBSession activeSession].isOpen)
		{
			
			[self performSegueWithIdentifier: fbLoginSegue
									  sender: self];
			
		}
		else
		{
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
				[self fillInViewsFromAppDelegate];
				[self makeParseRequest];
				[self.fbRequestStuff requestFriendInfo: @"start"
							  withArray: @[]];
				[self.fbRequestStuff requestUserFbInfo];
			}
		}
	}
	else
	{
		//this is the first time
		[[NSUserDefaults standardUserDefaults] setObject:@1 forKey:@"firstTime"];
		[[NSUserDefaults standardUserDefaults] synchronize];
		
		[self performSegueWithIdentifier: pageViewSegue
								  sender: self];
	}
	
}

-(void)makeParseRequest
{
	AppDelegate *appDelegate = [[UIApplication sharedApplication] delegate];
	if (appDelegate.shelffUser.userFBid != nil)
	{
		PFQuery *query = [ParseUser query];
		[query whereKey: @"userFBid" equalTo: appDelegate.shelffUser.userFBid];
		[query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
			if (!error)
			{
				if (objects.count > 0)
				{
					ParseUser *parseUser = [objects firstObject];
					[appDelegate.shelffUser fillInWithRetrievedParseProfile: parseUser];
					[self fillInViewsFromAppDelegate];
					PFQuery *shoeQuery = [ParseShoe query];
					[shoeQuery whereKey:@"shoeOwnerFBid" equalTo: parseUser.userFBid];
					[shoeQuery findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
						if (!error)
						{
							self.arrayOfUserShoes = objects;
							
							if (detailViewIsOn)
							{
								[self.detailCollectionView reloadData];
							}
							if (collectionViewIsOn)
							{
								[self.shoeCollectionView reloadData];
							}
						}
					}];
				}
			}
			else
			{
				[self handleParseError: error];
			}
		}];
	}
}

-(void)fillInViewsFromAppDelegate
{
	AppDelegate *appDelegate = [[UIApplication sharedApplication] delegate];
	if (appDelegate.shelffUser != nil)
	{
		self.locationField.text = appDelegate.shelffUser.userLocation;
		self.profileImage.image = appDelegate.shelffUser.userImage;
		self.nameField.text = appDelegate.shelffUser.userFirstName;
	}
}

#pragma mark - Request For Facebook Info

-(void)doneFetchingProfileInfo:(NSString *)info
{
	self.nameField.text = info;
}

-(void)doneFetchingProfilePicture:(UIImage *)profilePic
{
	self.profileImage.image = profilePic;
}

#pragma mark - IBActionz
- (IBAction)onEditPressed:(UIButton *)sender
{
	if (isEditing)
	{
		[self.editButton setImage:[UIImage imageNamed: @"compose.png"]
						 forState: UIControlStateNormal];
		self.locationField.enabled = NO;
		isEditing = NO;
		
		[self.locationField resignFirstResponder];
		
		//save the updated location field
		AppDelegate *appDelegate = [[UIApplication sharedApplication] delegate];
		[appDelegate.shelffUser setUserLocation: chosenLocation];
		[appDelegate.shelffUser saveUserToParse];
		[self alterShoeLocations: chosenLocation withUserId: appDelegate.shelffUser.userFBid];
	}
	else
	{
		[self.editButton setImage: [UIImage imageNamed: @"checkbox.png"]
						 forState: UIControlStateNormal];
		self.locationField.enabled = YES;
		isEditing = YES;
		chosenLocation = self.locationField.text;
	}
}

-(void)alterShoeLocations:(NSString *)location withUserId:(NSString *)userId
{
	PFQuery *shoeQuery = [ParseShoe query];
	[shoeQuery whereKey: @"shoeOwnerFBid" equalTo: userId];
	[shoeQuery findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
		if (!error)
		{
			for (ParseShoe *shoe in objects)
			{
				shoe.shoeLocation = location;
				[shoe saveInBackground];
			}
		}
		else
		{
			[self handleParseError: error];
		}
	}];
}

-(void)addShoe
{
	[self performSegueWithIdentifier: addSegue sender: self];
}

- (IBAction)onDetailPressed:(UIButton *)sender
{
	
	if (!detailViewIsOn)
	{
		collectionViewIsOn = NO;
		detailViewIsOn = YES;
		self.shoeCollectionView.hidden = YES;
		self.detailCollectionView.hidden = NO;
		
		[self.detailCollectionView reloadData];
		
		//turn bar buttons off to avoid crash then turn them back on half a second later
		[self turnBarButtonsOff];
		NSTimer *detailTimer = [NSTimer timerWithTimeInterval: .5
								target: self
							  selector: @selector(turnBarButtonsOn)
							  userInfo: nil
							   repeats: NO];
		[[NSRunLoop currentRunLoop] addTimer: detailTimer forMode: NSRunLoopCommonModes];
	}
	
}

- (IBAction)onCollectionPressed:(id)sender
{
	if (!collectionViewIsOn)
	{
		collectionViewIsOn = YES;
		detailViewIsOn = NO;
		self.shoeCollectionView.hidden = NO;
		self.detailCollectionView.hidden = YES;
		
		[self.shoeCollectionView reloadData];
		//turn bar buttons off to avoid crash then turn them back on half a second later
		[self turnBarButtonsOff];
		NSTimer *collectionTimer = [NSTimer timerWithTimeInterval: .5
								target: self
							  selector: @selector(turnBarButtonsOn)
							  userInfo: nil
							   repeats: NO];
		[[NSRunLoop currentRunLoop] addTimer: collectionTimer forMode: NSRunLoopCommonModes];
	}
}

-(void)turnBarButtonsOff
{
	self.detailShoeButton.enabled = false;
	self.shoeCollectionButton.enabled = false;
}

-(void)turnBarButtonsOn
{
	self.detailShoeButton.enabled = true;
	self.shoeCollectionButton.enabled = true;
}

- (void)didReceiveMemoryWarning
{
	[super didReceiveMemoryWarning];
	// Dispose of any resources that can be recreated.
}

#pragma mark - UICollectionView

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
	collectionView.alpha = (self.arrayOfUserShoes.count == 0) ? .9 : 1.0;
	
	return self.arrayOfUserShoes.count;
}

// The cell that is returned must be retrieved from a call to -dequeueReusableCellWithReuseIdentifier:forIndexPath:
- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
	if (collectionViewIsOn)
	{
		CollectionShoeCollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier: collectionViewCell
																						   forIndexPath: indexPath];
		if (!cell)
		{
			cell = [[CollectionShoeCollectionViewCell alloc] init];
		}
		ParseShoe *shoe = [self.arrayOfUserShoes objectAtIndex: indexPath.row];
		cell.shoeImageView.image = [UIImage imageNamed: @"shoeplaceholder.png"];
		
		[shoe.shoePic1 getDataInBackgroundWithBlock:^(NSData *data, NSError *error) {
			if (!error)
			{
				UIImage *shoemage = [UIImage imageWithData: data];
				if (cell.shoeImageView.image != shoemage)
				{
					cell.shoeImageView.image = shoemage;
				}
			}
		}];
		
		return cell;
	}
	if (detailViewIsOn)
	{
		DetailShoeCollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier: detailViewCell
																					   forIndexPath: indexPath];
		
		ParseShoe *shoe = [self.arrayOfUserShoes objectAtIndex: indexPath.row];
		cell.shoeImageView.image = [UIImage imageNamed: @"shoeplaceholder.png"];
		
		[shoe.shoePic1 getDataInBackgroundWithBlock:^(NSData *data, NSError *error) {
			if (!error)
			{
				cell.shoeImageView.image = [UIImage imageWithData: data];
			}
		}];
		
		return cell;
	}
	
	return nil;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
	ParseShoe *shoe = [self.arrayOfUserShoes objectAtIndex: indexPath.row];
	selectedShoe = shoe;
	[self performSegueWithIdentifier: editSegue
							  sender: self];
}

-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
	if ([segue.identifier isEqualToString: editSegue])
	{
		EditShoeViewController *esvc = (EditShoeViewController *)[segue destinationViewController];
		esvc.passedParseShoe = selectedShoe;
	}
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
	chosenLocation = [self.cityArray objectAtIndex: row];
	self.locationField.text = chosenLocation;
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
