//
//  ShelffViewController.m
//  Shelff
//
//  Created by Adam on 12/7/14.
//  Copyright (c) 2014 Adam. All rights reserved.
//

#import "ShelffViewController.h"
#import "ShelffCollectionViewCell.h"
#import "ShelfView.h"
#import "GridLayout.h"
#import <Parse/Parse.h>
#import "ParseShoe.h"
#import "SWRevealViewController.h"
#import "ShoeDetailViewController.h"
#import "Reachable.h"
#import "FilterMenuView.h"
#import "ShelffColors.h"

#define shelffCell @"shelffCell"
#define detailSegue @"detailSegue2"

@interface ShelffViewController () <UICollectionViewDataSource, UICollectionViewDelegate, FilterMenuDelegate, UIScrollViewDelegate>

@property (weak, nonatomic) IBOutlet UICollectionView *shelffCollectionView;
@property (nonatomic, strong) FilterMenuView *filterMenu;

@property (nonatomic, strong) NSArray *arrayOfAllShoes;
@property (nonatomic, strong) NSArray *arrayOfPublicShoes;

@end

@implementation ShelffViewController
{
	ParseShoe *selectedShoe;
	BOOL filterMenuIsOut;
	CGPoint filterMenuOrigin;
	
	NSString *chosenLocation;
	NSString *chosenSize;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
	
	self.navigationController.navigationBar.titleTextAttributes = @{NSFontAttributeName : [UIFont fontWithName: @"Futura"
																										  size: 22.0], NSForegroundColorAttributeName: [ShelffColors shelffGreen]};
	self.navigationController.navigationBar.barTintColor = [ShelffColors shelffPurple];
	self.navigationController.navigationBar.translucent = NO;
	
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
	
	self.title = @"Global Shelff";
	
	[self.shelffCollectionView setCollectionViewLayout: [[GridLayout alloc] init]];
	self.shelffCollectionView.delegate = self;
	self.shelffCollectionView.dataSource = self;
	self.shelffCollectionView.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"woodBackground"]];
	[self.shelffCollectionView registerClass:[ShelffCollectionViewCell class] forCellWithReuseIdentifier: shelffCell];
	
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
		[self makeParseShoeRequest];
	}
	
	[self configureFilterMenu];
}



-(void)makeParseShoeRequest
{
	PFQuery *query = [ParseShoe query];
	[query whereKey:@"publicOrPrivate" equalTo: @"public"];
	[query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
		if (!error)
		{
			self.arrayOfAllShoes = objects;
			self.arrayOfPublicShoes = objects;
			[self.shelffCollectionView reloadData];
		}
		else
		{
			[self handleParseError: error];
		}
	}];
}

/*
-(void)makeParseShoeRequestFromFilterMenuWithLocation:(NSString *)location andSize:(NSString *)size
{
	PFQuery *query = [ParseShoe query];
	[query whereKey:@"publicOrPrivate" equalTo: @"public"];
	
	//both location and size are entered
	if (location != nil && size != nil)
	{
		[query whereKey: @"shoeLocation" equalTo: location];
		[query whereKey: @"shoeSize" equalTo: size];
	}
	//just location entered
	if (location != nil && size == nil)
	{
		[query whereKey: @"shoeLocation" equalTo: location];
	}
	//just size entered
	if (location == nil && size != nil)
	{
		[query whereKey: @"shoeSize" equalTo: size];
	}
	[self.filterMenu.filterMenuSpinner startAnimating];
	[query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
		if (!error)
		{
			self.arrayOfPublicShoes = objects;
			[self.shelffCollectionView reloadData];
			[self.filterMenu.filterMenuSpinner stopAnimating];
		}
		else
		{
			[self handleParseError: error];
		}
	}];
}
 */

-(void)filterWithLocation:(NSString *)location andSize:(NSString *)size
{
	NSPredicate *predicate;
	//both location and size are entered
	if (location != nil && size != nil)
	{
		predicate = [NSPredicate predicateWithFormat: @"%@ == shoeLocation AND %@ == shoeSize", location, size];
	}
	//just location entered
	if (location != nil && size == nil)
	{
		predicate = [NSPredicate predicateWithFormat: @"%@ == shoeLocation", location];
	}
	//just size entered
	if (location == nil && size != nil)
	{
		predicate = [NSPredicate predicateWithFormat: @"%@ == shoeSize", size];
	}
	if (location == nil && size == nil)
	{
		self.arrayOfPublicShoes = self.arrayOfAllShoes;
		[self.shelffCollectionView reloadData];
		return;
	}
	
	self.arrayOfPublicShoes = [self.arrayOfAllShoes filteredArrayUsingPredicate: predicate];
	[self.shelffCollectionView reloadData];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Filter Menu Configuration and Delegate

-(void)configureFilterMenu
{
	//set up the filter menu
	self.filterMenu = [[FilterMenuView alloc] initWithFrame: self.view.frame];
	self.filterMenu.delegate = self;
	[self.shelffCollectionView addSubview: self.filterMenu];
	CGRect filterFrame = self.filterMenu.frame;
	filterFrame.origin.x = self.view.frame.size.width - (-self.filterMenu.filterButton.frame.origin.x + self.filterMenu.filterButton.frame.size.width - 10);
	self.filterMenu.frame = filterFrame;
	filterMenuOrigin = self.filterMenu.frame.origin;
	[self.shelffCollectionView bringSubviewToFront: self.filterMenu];
}

-(void)shoeSizeButtonWasPressed
{
	[self.filterMenu.shoeSizeTextField becomeFirstResponder];
}

-(void)locationButtonWasPressed
{
	[self.filterMenu.locationTextField becomeFirstResponder];
}

-(void)donePickingLocation:(NSString *)location
{
	chosenLocation = ([[location stringByReplacingOccurrencesOfString:@" " withString: @""] isEqualToString: @""] || location == nil) ? nil : location;
	[self filterWithLocation: chosenLocation andSize: chosenSize];
	//[self makeParseShoeRequestFromFilterMenuWithLocation: chosenLocation andSize: chosenSize];
	[self.shelffCollectionView setContentOffset: CGPointMake(0, 0) animated:YES];
}

-(void)donePickingShoeSize:(NSString *)shoeSize
{
	chosenSize = ([[shoeSize stringByReplacingOccurrencesOfString:@" " withString:@""] isEqualToString: @""] || shoeSize == nil) ? nil : shoeSize;
	[self filterWithLocation: chosenLocation andSize: chosenSize];
	//[self makeParseShoeRequestFromFilterMenuWithLocation: chosenLocation andSize: chosenSize];
	[self.shelffCollectionView setContentOffset: CGPointMake(0, 0) animated:YES];
}

-(void)filterButtonWasPressed
{
	if (filterMenuIsOut)
	{
		filterMenuIsOut = NO;
		[UIView animateWithDuration: .3f
							  delay: .0f
			 usingSpringWithDamping: .8f
			  initialSpringVelocity: .1f
							options: UIViewAnimationOptionCurveEaseOut
						 animations:^{
							 
							 CGRect filterFrame = self.filterMenu.frame;
							 filterFrame.origin = filterMenuOrigin;
							 self.filterMenu.frame = filterFrame;
						 }
						 completion:^(BOOL finished) {
							 
						 }];
	}
	else
	{
		filterMenuIsOut = YES;
		[UIView animateWithDuration: .3f
							  delay: .0f
			 usingSpringWithDamping: .8f
			  initialSpringVelocity: .1f
							options: UIViewAnimationOptionCurveEaseIn
						 animations:^{
							 
							 CGRect filterFrame = self.filterMenu.frame;
							 filterFrame.origin.x = self.filterMenu.frame.origin.x - (self.filterMenu.locationTextField.frame.origin.x + self.filterMenu.locationTextField.frame.size.width);
							 self.filterMenu.frame = filterFrame;
						 }
						 completion:^(BOOL finished) {
							 
						 }];
	}
}


#pragma mark - UICollection View Delegate and Data Source

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
	return self.arrayOfPublicShoes.count;
}

// The cell that is returned must be retrieved from a call to -dequeueReusableCellWithReuseIdentifier:forIndexPath:
- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
	ShelffCollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier: shelffCell forIndexPath: indexPath];
	if (!cell)
	{
		cell = [[ShelffCollectionViewCell alloc] init];
	}
	
	ParseShoe *shoeBitch = [self.arrayOfPublicShoes objectAtIndex: indexPath.row];
	cell.shoeLabel.text = shoeBitch.shoeTitle;
	cell.shoeImageView.image = [UIImage imageNamed:@"shoeplaceholder.png"];
	
	[shoeBitch.shoePic1 getDataInBackgroundWithBlock:^(NSData *data, NSError *error) {
		if (!error)
		{
			UIImage *shoemage = [UIImage imageWithData: data];
			cell.shoeImageView.image = shoemage;
		}
	}];
	
	return cell;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
	ParseShoe *shoe = [self.arrayOfPublicShoes objectAtIndex: indexPath.row];
	selectedShoe = shoe;
	UIAlertController *alert = [UIAlertController alertControllerWithTitle: @"Are you sure you want to delete this troll post?"
																   message: @"This will permanently delete this inappropriate post"
															preferredStyle: UIAlertControllerStyleAlert];
	UIAlertAction *yesDelete = [UIAlertAction actionWithTitle:@"Yes, I'm Sure" style: UIAlertActionStyleDestructive handler:^(UIAlertAction *action) {
		[shoe deleteInBackground];
		[alert dismissViewControllerAnimated: YES completion: nil];
	}];
	UIAlertAction *noDontDelete = [UIAlertAction actionWithTitle:@"Nevermind" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
		[alert dismissViewControllerAnimated: YES completion: nil];
	}];
	
	[alert addAction: yesDelete];
	[alert addAction: noDontDelete];
	
	[self presentViewController: alert animated: YES completion:nil];
}

-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
	if ([segue.identifier isEqualToString: detailSegue])
	{
		ShoeDetailViewController *sdvc = (ShoeDetailViewController *)[segue destinationViewController];
		sdvc.passedParseShoe = selectedShoe;
		sdvc.fromGlobalShelff = YES;
	}
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

#pragma mark - Scroll View Delegate

- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
	[UIView animateWithDuration: .1f
					 animations:^{
						 CGRect recto = self.filterMenu.frame;
						 recto.origin.y = scrollView.contentOffset.y;
						 self.filterMenu.frame = recto;
					 }];
}

@end
