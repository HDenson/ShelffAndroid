//
//  FriendProfileViewController.m
//  Shelff
//
//  Created by Adam on 11/14/14.
//  Copyright (c) 2014 Adam. All rights reserved.
//

#import "FriendProfileViewController.h"
#import "CollectionShoeCollectionViewCell.h"
#import "DetailShoeCollectionViewCell.h"
#import "AppDelegate.h"
#import "ParseShoe.h"
#import "SWRevealViewController.h"
#import "ShoeDetailViewController.h"
#import "MessagesViewController.h"
#import "Reachable.h"
#import "ShelffColors.h"

#define collectionViewCell @"smallCell"
#define detailViewCell @"largeCell"
#define detailSegue @"detailSegue"
#define friendMessageSegue @"friendMessage"

@interface FriendProfileViewController () <UICollectionViewDataSource, UICollectionViewDelegate>

@property (weak, nonatomic) IBOutlet UICollectionView *shoesCollectionView;
@property (weak, nonatomic) IBOutlet UICollectionView *detailCollectionView;

@property (weak, nonatomic) IBOutlet UIButton *messageButton;
@property (weak, nonatomic) IBOutlet UIButton *detailButton;
@property (weak, nonatomic) IBOutlet UIButton *collectionButton;

@property (weak, nonatomic) IBOutlet UIImageView *profileImageView;
@property (weak, nonatomic) IBOutlet UITextField *nameField;
@property (weak, nonatomic) IBOutlet UITextField *locationField;

@property (weak, nonatomic) IBOutlet UIView *profileCardView;
@property (weak, nonatomic) IBOutlet UIView *buttonView;


@property (nonatomic, strong) NSArray *arrayOfUserShoes;


@end

@implementation FriendProfileViewController
{
	BOOL detailViewIsOn;
	BOOL collectionViewIsOn;
	ParseShoe *selectedShoe;
	BOOL switchToMessages;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
	self.navigationController.navigationBar.tintColor = [UIColor blackColor];
	self.navigationController.navigationBar.titleTextAttributes = @{NSFontAttributeName : [UIFont fontWithName: @"Futura"
																										  size: 22.0], NSForegroundColorAttributeName: [ShelffColors shelffGreen]};
	self.navigationController.navigationBar.barTintColor = [ShelffColors shelffPurple];
	self.navigationController.navigationBar.translucent = NO;
	//self.view.clipsToBounds = YES;
	
	//configure slide menu stuff
	SWRevealViewController *reveal = [self revealViewController];
	[reveal panGestureRecognizer];
	[reveal tapGestureRecognizer];
	
	self.navigationItem.leftBarButtonItem.tintColor = [ShelffColors shelffGreen];
	
	UIImageView *backgroundImageView = [[UIImageView alloc] initWithFrame: self.view.frame];
	UIImage *shoeImage = [UIImage imageNamed: @"shoes2.png"];
	backgroundImageView.image = shoeImage;
	
	[self.view addSubview: backgroundImageView];
	[self.view sendSubviewToBack: backgroundImageView];
	
	self.profileImageView.clipsToBounds = YES;
	self.profileImageView.layer.cornerRadius = 30;
	self.profileImageView.layer.borderColor = [[UIColor blackColor] CGColor];
	self.profileImageView.layer.borderWidth = .5;
	
	self.shoesCollectionView.delegate = self;
	self.shoesCollectionView.dataSource = self;
	self.detailCollectionView.delegate = self;
	self.detailCollectionView.dataSource = self;
	
	self.shoesCollectionView.layer.cornerRadius = 5;
	self.detailCollectionView.layer.cornerRadius = 5;
	self.profileCardView.layer.cornerRadius = 5;
	self.buttonView.layer.cornerRadius = 5;
	
	[self.detailCollectionView registerClass: [DetailShoeCollectionViewCell class]
				  forCellWithReuseIdentifier: detailViewCell];
	[self.shoesCollectionView registerClass: [CollectionShoeCollectionViewCell class]
				forCellWithReuseIdentifier: collectionViewCell];
	self.detailCollectionView.hidden = YES;
	
	self.messageButton.layer.cornerRadius = 5;
	self.messageButton.layer.borderWidth = .3;
	self.messageButton.layer.borderColor = [[UIColor whiteColor] CGColor];
	
	self.detailButton.layer.cornerRadius = 5;
	self.collectionButton.layer.cornerRadius = 5;
	
	//make the collection view the default collection view
	collectionViewIsOn = YES;
	detailViewIsOn = NO;
	
	[self setFieldsFromParse];
	
	
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
		[self requestParseShoes];
	}
	
}

- (void)viewDidAppear:(BOOL)animated
{
	[super viewDidAppear: YES];
	
	if (switchToMessages)
	{
		[self performSegueWithIdentifier: friendMessageSegue
								  sender: self];
	}
}

-(void)viewDidDisappear:(BOOL)animated
{
	[super viewDidDisappear: YES];
	
	if (switchToMessages)
	{
		switchToMessages = NO;
	}
}

-(void)setFieldsFromParse
{
	self.title = [NSString stringWithFormat:@"%@'s Shelff", self.passedParseUser.userFirstName];
	self.locationField.text = self.passedParseUser.userLocation;
	self.nameField.text = self.passedParseUser.userFirstName;
	self.profileImageView.image = self.passedProfilePic;
}

-(void)requestParseShoes
{
	PFQuery *query = [ParseShoe query];
	[query whereKey:@"shoeOwnerFBid" equalTo:self.passedParseUser.userFBid];
	[query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
		if (!error)
		{
			self.arrayOfUserShoes = objects;
			
			if (detailViewIsOn)
			{
				[self.detailCollectionView reloadData];
			}
			if (collectionViewIsOn)
			{
				[self.shoesCollectionView reloadData];
			}
		}
	}];
}


#pragma mark - IBActionz

- (IBAction)onMessagePressed:(UIButton *)sender
{
	
}

- (IBAction)onDetailPressed:(UIButton *)sender
{
	if (!detailViewIsOn)
	{
		collectionViewIsOn = NO;
		detailViewIsOn = YES;
		self.shoesCollectionView.hidden = YES;
		self.detailCollectionView.hidden = NO;
		
		[self.detailCollectionView reloadData];
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

- (IBAction)onCollectionPressed:(UIButton *)sender
{
	if (!collectionViewIsOn)
	{
		collectionViewIsOn = YES;
		detailViewIsOn = NO;
		self.shoesCollectionView.hidden = NO;
		self.detailCollectionView.hidden = YES;
		
		[self.shoesCollectionView reloadData];
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
	self.detailButton.enabled = false;
	self.collectionButton.enabled = false;
}

-(void)turnBarButtonsOn
{
	self.detailButton.enabled = true;
	self.collectionButton.enabled = true;
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
	[self performSegueWithIdentifier: detailSegue
							  sender: self];
}

-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
	if ([segue.identifier isEqualToString: detailSegue])
	{
		ShoeDetailViewController *sdvc = (ShoeDetailViewController *)[segue destinationViewController];
		sdvc.passedParseShoe = selectedShoe;
	}
	if ([segue.identifier isEqualToString: friendMessageSegue])
	{
		MessagesViewController *messageVC = (MessagesViewController *)[segue destinationViewController];
		messageVC.passedParseProfile = self.passedParseUser;
		messageVC.passedProfilePicture = self.profileImageView.image;
	}
}

- (IBAction)unwindToGetToMessages:(UIStoryboardSegue *)sender
{
	switchToMessages = YES;
}

@end
