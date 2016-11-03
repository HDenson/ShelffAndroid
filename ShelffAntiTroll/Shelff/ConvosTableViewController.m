//
//  ConvosTableViewController.m
//  Shelff
//
//  Created by Adam on 12/7/14.
//  Copyright (c) 2014 Adam. All rights reserved.
//

#import "ConvosTableViewController.h"
#import "SWRevealViewController.h"
#import "ParseUser.h"
#import "AppDelegate.h"
#import "FriendProfileViewController.h"
#import "Reachable.h"
#import "ShelffColors.h"

#define convoCell @"convoCell"

@interface ConvosTableViewController ()

@property (nonatomic, strong) NSArray *arrayOfParseUsersToMessage;


@end



@implementation ConvosTableViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
	self.navigationController.navigationBar.titleTextAttributes = @{NSFontAttributeName : [UIFont fontWithName: @"Futura"
																										  size: 22.0], NSForegroundColorAttributeName : [ShelffColors shelffGreen]};
	self.navigationController.navigationBar.barTintColor = [ShelffColors shelffPurple];
	self.navigationController.navigationBar.translucent = NO;
	
	
	
	self.title = @"Conversations";
	//configure slide menu stuff
	SWRevealViewController *reveal = [self revealViewController];
	[reveal panGestureRecognizer];
	[reveal tapGestureRecognizer];
	
	self.tableView.allowsMultipleSelectionDuringEditing = NO;
	
	UIBarButtonItem *revealButton = [[UIBarButtonItem alloc] initWithImage: [UIImage imageNamed: @"menu.png"]
																	 style: UIBarButtonItemStylePlain
																	target: reveal
																	action: @selector(revealToggle:)];
	self.navigationItem.leftBarButtonItem = revealButton;
	self.navigationItem.leftBarButtonItem.tintColor = [ShelffColors shelffGreen];
	
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
		[self makeRequestForConversatingParseUsers];
	}
	
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)makeRequestForConversatingParseUsers
{
	AppDelegate *appDelegate = [[UIApplication sharedApplication] delegate];
	
	PFQuery *query = [ParseUser query];
	[query whereKey:@"userFBid" containedIn: appDelegate.shelffUser.messagePeopleFBids];
	[query whereKey:@"userFBid" notEqualTo: appDelegate.shelffUser.userFBid];
	[query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
		if (!error)
		{
			self.arrayOfParseUsersToMessage = objects;
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
    return self.arrayOfParseUsersToMessage.count;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier: convoCell forIndexPath: indexPath];
    
	if (!cell)
	{
		cell = [[UITableViewCell alloc] initWithStyle: UITableViewCellStyleDefault reuseIdentifier: convoCell];
	}
	
	ParseUser *user = [self.arrayOfParseUsersToMessage objectAtIndex: indexPath.row];
	
	cell.textLabel.text = user.userFirstName;
	cell.imageView.image = [UIImage imageNamed: @"Placeholder_person.png"];
	cell.imageView.clipsToBounds = YES;
	cell.imageView.layer.cornerRadius = 5;
	
	[user.userImage getDataInBackgroundWithBlock:^(NSData *data, NSError *error) {
		if (!error)
		{
			if (data)
			{
				UIImage *profileImage = [UIImage imageWithData: data];
				cell.imageView.image = profileImage;
			}
		}
		else
		{
			[self handleParseError: error];
		}
	}];
	
    return cell;
}

// Override to support conditional editing of the table view.
// This only needs to be implemented if you are going to be returning NO
// for some items. By default, all items are editable.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
	// Return YES if you want the specified item to be editable.
	return YES;
}

// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
	if (editingStyle == UITableViewCellEditingStyleDelete)
	{
		AppDelegate *appDelegate = [[UIApplication sharedApplication] delegate];
		//add code here for when you hit delete
		ParseUser *user = [self.arrayOfParseUsersToMessage objectAtIndex: indexPath.row];
		
		NSMutableArray *mutable = [appDelegate.shelffUser.messagePeopleFBids mutableCopy];
		if (!mutable) {mutable = [NSMutableArray new];}
		[mutable removeObject: user.userFBid];
		appDelegate.shelffUser.messagePeopleFBids = (NSArray *)mutable;
		
		[appDelegate.shelffUser saveUserToParse];
		
		NSMutableArray *mutableArrayOfMessagePeople = [self.arrayOfParseUsersToMessage mutableCopy];
		[mutableArrayOfMessagePeople removeObject: user];
		self.arrayOfParseUsersToMessage = (NSArray *)mutableArrayOfMessagePeople;
		[self.tableView reloadData];
	}
}

#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(UITableViewCell *)sender
{
	ParseUser *user = [self.arrayOfParseUsersToMessage objectAtIndex: [self.tableView indexPathForCell:sender].row];
	
	FriendProfileViewController *friendVC = (FriendProfileViewController *)[segue destinationViewController];
	friendVC.passedParseUser = user;
	friendVC.passedProfilePic = sender.imageView.image;
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
