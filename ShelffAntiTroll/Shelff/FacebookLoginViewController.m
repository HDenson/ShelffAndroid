//
//  FacebookLoginViewController.m
//  Shelff
//
//  Created by Adam on 11/14/14.
//  Copyright (c) 2014 Adam. All rights reserved.
//

#import "FacebookLoginViewController.h"
#import <FacebookSDK/FacebookSDK.h>
#import "AppDelegate.h"
#import "Reachable.h"

@interface FacebookLoginViewController () <FBLoginViewDelegate>

@property (weak, nonatomic) IBOutlet FBProfilePictureView *profilePicView;
@property (weak, nonatomic) IBOutlet UILabel *nameLabel;
@property (weak, nonatomic) IBOutlet FBLoginView *fbLoginView;
@property (weak, nonatomic) IBOutlet UIButton *confirmButton;
@property (weak, nonatomic) IBOutlet UIView *stuffView;

@end

@implementation FacebookLoginViewController
{
	BOOL loggedIn;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
	self.fbLoginView.delegate = self;
	self.fbLoginView.readPermissions = @[@"public_profile", @"user_friends"];
	
	self.profilePicView.layer.cornerRadius = 55;
	self.profilePicView.layer.borderColor = [[UIColor blackColor] CGColor];
	self.profilePicView.layer.borderWidth = .5;
	self.stuffView.layer.cornerRadius = 5;
	
	UIImageView *backgroundImageView = [[UIImageView alloc] initWithFrame: self.view.frame];
	UIImage *shoeImage = [UIImage imageNamed: @"shoes2.png"];
	backgroundImageView.image = shoeImage;
	
	[self.view addSubview: backgroundImageView];
	[self.view sendSubviewToBack: backgroundImageView];
	
	//check for internet connection
	if ([Reachable internetNetworkIsUnreachable] && [Reachable wifiNetworkIsUnreachable])
	{
		[[[UIAlertView alloc] initWithTitle: @"No Internet Connection Is Available"
									message: @"No network connection is available. Check to make sure either wifi or cellular data is turned on."
								   delegate: self
						  cancelButtonTitle: @"Ok"
						  otherButtonTitles:nil, nil] show];
	}
}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)onEnterPressed:(UIButton *)sender
{
	[self dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - Facebook Login View Delegate

- (void)loginViewShowingLoggedInUser:(FBLoginView *)loginView
{
	self.profilePicView.hidden = NO;
	self.nameLabel.hidden = NO;
	self.confirmButton.hidden = NO;
	loggedIn = YES;
	
	
}

- (void)loginViewFetchedUserInfo:(FBLoginView *)loginView
							user:(id<FBGraphUser>)user
{
	self.profilePicView.profileID = user.objectID;
	self.nameLabel.text = user.name;
	loggedIn = YES;
	
	//set the singleton user profile
	AppDelegate *appDelegate = [[UIApplication sharedApplication] delegate];
	appDelegate.shelffUser = [[User alloc] initWithUserFBid: user.objectID];
	
	PFInstallation *currentInstallation = [PFInstallation currentInstallation];
	[currentInstallation setObject: user.objectID
							forKey: @"user"];
	[currentInstallation saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error)
	 {
		 if (error)
		 {
			 if ([error code] == kPFErrorConnectionFailed)
			 {
				 [[[UIAlertView alloc] initWithTitle: @"No Internet Connection Is Available"
											 message: @"No network connection is available. Check to make sure either wifi or cellular data is turned on."
											delegate: self
								   cancelButtonTitle: @"Ok"
								   otherButtonTitles:nil, nil] show];
			 }
			 [currentInstallation saveEventually];
		 }
		 
	 }];
	
}

- (void)loginViewShowingLoggedOutUser:(FBLoginView *)loginView
{
	self.profilePicView.hidden = YES;
	self.nameLabel.hidden = YES;
	self.confirmButton.hidden = YES;
	loggedIn = NO;
	
	//nil out the singleton user profile
	AppDelegate *appDelegate = [[UIApplication sharedApplication] delegate];
	appDelegate.shelffUser = nil;
}

- (void)loginView:(FBLoginView *)loginView
	  handleError:(NSError *)error
{
	[self handleAuthError:error];
}

- (void)handleAuthError:(NSError *)error
{
	NSString *alertText;
	NSString *alertTitle;
	if ([FBErrorUtility shouldNotifyUserForError:error] == YES)
	{
		// Error requires people using you app to make an action outside your app to recover
		alertTitle = @"Something went wrong";
		alertText = [FBErrorUtility userMessageForError:error];
		[self showMessage:alertText withTitle:alertTitle];
		
	}
	else
	{
		// You need to find more information to handle the error within your app
		if ([FBErrorUtility errorCategoryForError:error] == FBErrorCategoryUserCancelled)
		{
			//The user refused to log in into your app, either ignore or...
			alertTitle = @"Login cancelled";
			alertText = @"You need to login to access this part of the app";
			[self showMessage:alertText withTitle:alertTitle];
			
		}
		else
		{
			// All other errors that can happen need retries
			// Show the user a generic error message
			alertTitle = @"Something went wrong";
			alertText = @"Please retry";
			[self showMessage:alertText withTitle:alertTitle];
		}
	}
}

- (void)showMessage:(NSString *)text withTitle:(NSString *)title
{
	[[[UIAlertView alloc] initWithTitle:title
								message:text
							   delegate:self
					  cancelButtonTitle:@"OK"
					  otherButtonTitles:nil] show];
}


@end
