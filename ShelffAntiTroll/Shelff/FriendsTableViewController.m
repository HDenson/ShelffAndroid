//
//  FriendsTableViewController.m
//  Shelff
//
//  Created by Adam on 11/12/14.
//  Copyright (c) 2014 Adam. All rights reserved.
//

#import "FriendsTableViewController.h"
#import "SWRevealViewController.h"
#import "AppDelegate.h"
#import "ParseUser.h"
#import "FriendProfileViewController.h"
#import "Reachable.h"
#import "ShelffColors.h"

@interface FriendsTableViewController ()

@property (nonatomic, strong) NSArray *facebookFriendsParseProfiles;


@end

#define friendCell @"friendCell"
#define friendSegue @"friendSegue"

@implementation FriendsTableViewController


- (void)viewDidLoad
{
    [super viewDidLoad];
    // Uncomment the following line to preserve selection between presentations.
	
	//configure slide menu stuff
	SWRevealViewController *reveal = [self revealViewController];
	[reveal panGestureRecognizer];
	[reveal tapGestureRecognizer];
	
	UIBarButtonItem *revealButton = [[UIBarButtonItem alloc] initWithImage: [UIImage imageNamed: @"menu.png"]
																	 style: UIBarButtonItemStylePlain
																	target: reveal
																	action: @selector(revealToggle:)];
	self.navigationController.navigationBar.translucent = NO;
	self.navigationController.navigationBar.barTintColor = [ShelffColors shelffPurple];
	self.navigationItem.leftBarButtonItem = revealButton;
	self.navigationItem.leftBarButtonItem.tintColor = [ShelffColors shelffGreen];
	
	self.navigationController.navigationBar.titleTextAttributes = @{NSFontAttributeName : [UIFont fontWithName: @"Futura"
																										  size: 22.0], NSForegroundColorAttributeName: [ShelffColors shelffGreen]};
	
	self.title = @"Friends On Shelff";
	
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
		[self makeParseRequestForFbFriendsParseProfiles];
	}
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
	
}

-(void)makeParseRequestForFbFriendsParseProfiles
{
	AppDelegate *appDelegate = [[UIApplication sharedApplication] delegate];
	
	PFQuery *query = [ParseUser query];
	[query whereKey:@"userFBid" containedIn: appDelegate.shelffUser.fbFriendIds];
	[query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
		if (!error)
		{
			self.facebookFriendsParseProfiles = objects;
			[self.tableView reloadData];
		}
		else
		{
			[self handleParseError: error];
		}
	}];
}

#pragma mark - Table view data source

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    return self.facebookFriendsParseProfiles.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier: friendCell forIndexPath:indexPath];
    
    // Configure the cell...
	ParseUser *user = [self.facebookFriendsParseProfiles objectAtIndex: indexPath.row];
	cell.textLabel.text = user.userFirstName;
	cell.imageView.image = [UIImage imageNamed:@"Placeholder_person.png"];
	cell.imageView.layer.cornerRadius = 5;
	cell.imageView.clipsToBounds = YES;
	
	[user.userImage getDataInBackgroundWithBlock:^(NSData *data, NSError *error) {
		if (!error)
		{
			if (data)
			{
				cell.imageView.image = [UIImage imageWithData: data];
			}
		}
		else
		{
			[self handleParseError: error];
		}
	}];
	
    return cell;
}

#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(UITableViewCell *)sender
{
	ParseUser *userAtIndex = [self.facebookFriendsParseProfiles objectAtIndex: [self.tableView indexPathForCell: sender].row];
	UIImage *imageToPass = sender.imageView.image;
	
	FriendProfileViewController *fpvc = (FriendProfileViewController *)[segue destinationViewController];
	fpvc.passedParseUser = userAtIndex;
	fpvc.passedProfilePic = imageToPass;
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
