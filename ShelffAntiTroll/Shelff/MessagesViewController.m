//
//  MessagesViewController.m
//  Shelff
//
//  Created by Adam on 12/7/14.
//  Copyright (c) 2014 Adam. All rights reserved.
//

#import "MessagesViewController.h"
#import "JSQMessages.h"
#import "JSQMessagesAvatarFactory.h"
#import "ParseMessage.h"
#import "Reachable.h"
#import "ShelffColors.h"

@interface MessagesViewController () <JSQMessagesCollectionViewDataSource, JSQMessagesCollectionViewDelegateFlowLayout, UIAlertViewDelegate>

@property (strong, nonatomic) UIImageView *outgoingBubbleImageView;
@property (strong, nonatomic) UIImageView *incomingBubbleImageView;

@property (strong, nonatomic) NSArray *arrayOfMessageDictionaries;
@property (strong, nonatomic) NSMutableArray *arrayOfJSQMessages;
@property (strong, nonatomic) NSArray *arrayOfParseMessages;

@property (nonatomic, strong) UIImage *myAvatar;
@property (nonatomic, strong) UIImage *yourAvatar;

@property (nonatomic) UIAlertView *blockAlert;


@end

@implementation MessagesViewController

-(NSMutableArray *)arrayOfJSQMessages
{
	if (!_arrayOfJSQMessages)
	{
		_arrayOfJSQMessages = [[NSMutableArray alloc] init];
	}
	return _arrayOfJSQMessages;
}

- (void)viewDidLoad
{
	[super viewDidLoad];
	// Do any additional setup after loading the view.
	
	AppDelegate *appDelegate = [[UIApplication sharedApplication] delegate];
	appDelegate.currentView = @"message";
	
	self.sender = appDelegate.shelffUser.userFirstName;
	
	[[NSNotificationCenter defaultCenter] addObserver: self
											 selector: @selector(onIncomingChat)
												 name: @"messageReceived"
											   object: nil];
	
	CGFloat outgoingDiameter = self.collectionView.collectionViewLayout.outgoingAvatarViewSize.width;
	CGFloat incomingDiameter = self.collectionView.collectionViewLayout.incomingAvatarViewSize.width;
	
	self.myAvatar = [JSQMessagesAvatarFactory avatarWithImage: appDelegate.shelffUser.userImage
													 diameter: outgoingDiameter];
	if (self.passedProfilePicture)
	{
		self.yourAvatar = [JSQMessagesAvatarFactory avatarWithImage: self.passedProfilePicture
														   diameter: incomingDiameter];
	}
	else
	{
		self.yourAvatar = [JSQMessagesAvatarFactory avatarWithImage: [UIImage imageNamed:@"Placeholder_person.png"]
														   diameter: incomingDiameter];
	}
	
	self.outgoingBubbleImageView = [JSQMessagesBubbleImageFactory outgoingMessageBubbleImageViewWithColor:[UIColor jsq_messageBubbleBlueColor]];
	self.incomingBubbleImageView = [JSQMessagesBubbleImageFactory incomingMessageBubbleImageViewWithColor:[UIColor jsq_messageBubbleLightGrayColor]];
	
	
	[[NSNotificationCenter defaultCenter] addObserver: self
											 selector: @selector(queryForParseMessages)
												 name: UIApplicationDidBecomeActiveNotification
											   object: nil];
	
	self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle: @"Block "
																			  style: UIBarButtonItemStyleDone
																			 target: self
																			 action: @selector(onBlockPressed)];
	self.navigationItem.rightBarButtonItem.tintColor = [UIColor redColor];
	self.navigationItem.leftBarButtonItem.tintColor = [ShelffColors shelffGreen];
	self.navigationController.navigationBar.translucent = NO;
	self.navigationController.navigationBar.barTintColor = [ShelffColors shelffPurple];
	
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
		[self queryForParseMessages];
	}
	
}

-(void)onBlockPressed
{
	self.blockAlert = [[UIAlertView alloc] initWithTitle: [NSString stringWithFormat: @"Are you sure you want to block %@?", self.passedParseProfile.userFirstName]
												 message: [NSString stringWithFormat: @"Blocking %@ is permanent, and will prevent all communication in the future, so make sure this is what you intend to do", self.passedParseProfile.userFirstName]
												delegate: self
									   cancelButtonTitle: @"Nevermind"
									   otherButtonTitles: @"Yes, I'm Sure", nil];
	[self.blockAlert show];
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
	//handle blocking of an individual
	if (buttonIndex == 1)
	{
		AppDelegate *appDelegate = [[UIApplication sharedApplication] delegate];
		
		//add user's id to blacklist
		NSMutableArray *mutableBlackList = [appDelegate.shelffUser.blackList mutableCopy];
		if (!mutableBlackList) {mutableBlackList = [NSMutableArray new];}
		[mutableBlackList addObject: self.passedParseProfile.userFBid];
		appDelegate.shelffUser.blackList = (NSArray *)mutableBlackList;
		
		//remove user's id from message list
		NSMutableArray *mutableMessageArray = [appDelegate.shelffUser.messagePeopleFBids mutableCopy];
		if (!mutableMessageArray) {mutableMessageArray = [NSMutableArray new];}
		[mutableMessageArray removeObject: self.passedParseProfile.userFBid];
		appDelegate.shelffUser.messagePeopleFBids = (NSArray *)mutableMessageArray;
		
		[appDelegate.shelffUser saveUserToParse];
		
		//remove this profile id from the blocked user's
		[self.passedParseProfile removeObject: appDelegate.shelffUser.userFBid forKey: @"messagePeopleFBids"];
		[self.passedParseProfile saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
			if (error)
			{
				if ([error code] == kPFErrorConnectionFailed)
				{
					[self.passedParseProfile saveEventually];
				}
			}
		}];
		
		[[[UIAlertView alloc] initWithTitle: [NSString stringWithFormat:@"%@ Successfully Blocked", self.passedParseProfile.userFirstName]
									message: nil
								   delegate: self
						  cancelButtonTitle: @"Ok"
						  otherButtonTitles: nil, nil] show];
		
	}
}

-(void)viewWillDisappear:(BOOL)animated
{
	[super viewWillDisappear:NO];
	AppDelegate *appDelegate = [[UIApplication sharedApplication] delegate];
	appDelegate.currentView = @"";
	[[NSNotificationCenter defaultCenter] removeObserver: self
													name: UIApplicationDidBecomeActiveNotification
												  object: nil];
}

-(void)queryForParseMessages
{
	AppDelegate *appDelegate = [[UIApplication sharedApplication] delegate];
	
	PFQuery *messageIDquery = [ParseMessage query];
	[messageIDquery whereKey: @"messageSenderID" containedIn: @[appDelegate.shelffUser.userFBid, self.passedParseProfile.userFBid]];
	[messageIDquery whereKey: @"messageReceiverID" containedIn: @[appDelegate.shelffUser.userFBid, self.passedParseProfile.userFBid]];
	
	self.arrayOfJSQMessages = [NSMutableArray new];
	
	[messageIDquery findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
		self.arrayOfParseMessages = objects;
		NSSortDescriptor *descriptor = [[NSSortDescriptor alloc] initWithKey:@"createdAt"
																   ascending: YES];
		self.arrayOfParseMessages = [self.arrayOfParseMessages sortedArrayUsingDescriptors: @[descriptor]];
		for (ParseMessage *message in self.arrayOfParseMessages)
		{
			[self.arrayOfJSQMessages addObject: [self jsqmessageFromParseMessage: message]];
		}
		[self.collectionView reloadData];
		
		//autoscroll to bottom of chat
		NSIndexPath *path = [NSIndexPath indexPathForItem: self.arrayOfJSQMessages.count - 1
												inSection: 0];
		if (self.arrayOfJSQMessages.count > 0)
		{
			[self.collectionView scrollToItemAtIndexPath: path
										atScrollPosition: UICollectionViewScrollPositionBottom
												animated: YES];
		}
		
	}];
}

-(void)onIncomingChat
{
	[self queryForParseMessages];
}

-(JSQMessage *)jsqmessageFromParseMessage:(ParseMessage *)parseMessage
{
	JSQMessage *message = [[JSQMessage alloc] init];
	message.sender = parseMessage.messageSenderName;
	message.date = parseMessage.createdAt;
	message.text = parseMessage.messageText;
	
	return message;
}

- (void)didReceiveMemoryWarning
{
	[super didReceiveMemoryWarning];
	// Dispose of any resources that can be recreated.
}

#pragma mark - JSQMessages implementation

- (void)didPressSendButton:(UIButton *)button
		   withMessageText:(NSString *)text
					sender:(NSString *)sender
					  date:(NSDate *)date
{
	JSQMessage *message = [[JSQMessage alloc] initWithText:text
													sender:sender
													  date:date];
	[self.arrayOfJSQMessages addObject:message];
	[self.collectionView reloadData];
	
	AppDelegate *appDelegate = [[UIApplication sharedApplication] delegate];
	
	NSDictionary *messageDic = @{@"type": @"message", @"profileID" : appDelegate.shelffUser.userFBid, @"badge" : @"Increment", @"alert" : [NSString stringWithFormat:@"%@ just sent you a message!", appDelegate.shelffUser.userFirstName]};
	
	PFQuery *pushQuery = [PFInstallation query];
	[pushQuery whereKey: @"user"
				equalTo: self.passedParseProfile.userFBid];
	
	PFPush *push = [[PFPush alloc] init];
	[push setQuery: pushQuery];
	[push setData: messageDic];
	
	[push sendPushInBackground];
	[self finishSendingMessage];
	
	//save message to parse
	ParseMessage *parseMessageToSave = [ParseMessage object];
	parseMessageToSave.messageReceiverID = self.passedParseProfile.userFBid;
	parseMessageToSave.messageReceiverName = self.passedParseProfile.userFirstName;
	parseMessageToSave.messageSenderID = appDelegate.shelffUser.userFBid;
	parseMessageToSave.messageSenderName = appDelegate.shelffUser.userFirstName;
	parseMessageToSave.messageText = text;
	[parseMessageToSave saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
		if (error)
		{
			[[[UIAlertView alloc] initWithTitle: @"Problem Sending Message"
										message: @"Make sure you are connected to the network and try again"
									   delegate: self
							  cancelButtonTitle: @"Ok"
							  otherButtonTitles: nil, nil] show];
		}
	}];
	
	//if this is the first time the two people are conversating, add them to the array of message id's
	if (![appDelegate.shelffUser.messagePeopleFBids containsObject: self.passedParseProfile.userFBid])
	{
		NSMutableArray *mutable = [appDelegate.shelffUser.messagePeopleFBids mutableCopy];
		if (!mutable) {mutable = [NSMutableArray new];}
		[mutable addObject: self.passedParseProfile.userFBid];
		appDelegate.shelffUser.messagePeopleFBids = (NSArray *)mutable;
		[appDelegate.shelffUser saveUserToParse];
	}
	if (![self.passedParseProfile.messagePeopleFBids containsObject: appDelegate.shelffUser.userFBid])
	{
		NSMutableArray *mutable = [self.passedParseProfile.messagePeopleFBids mutableCopy];
		if (!mutable) {mutable = [NSMutableArray new];}
		[mutable addObject: appDelegate.shelffUser.userFBid];
		self.passedParseProfile.messagePeopleFBids = (NSArray *)mutable;
		[self.passedParseProfile saveInBackground];
	}
	
}

- (id<JSQMessageData>)collectionView:(JSQMessagesCollectionView *)collectionView messageDataForItemAtIndexPath:(NSIndexPath *)indexPath
{
	if (self.arrayOfJSQMessages.count <= indexPath.item)
	{
		return [[JSQMessage alloc] init];
	}
	return [self.arrayOfJSQMessages objectAtIndex: indexPath.item];
}

//configure bubbles
- (UIImageView *)collectionView:(JSQMessagesCollectionView *)collectionView bubbleImageViewForItemAtIndexPath:(NSIndexPath *)indexPath
{
	if (self.arrayOfJSQMessages.count == 0 || self.arrayOfJSQMessages == nil)
	{
		return [[UIImageView alloc] init];
	}
	JSQMessage *message = [self.arrayOfJSQMessages objectAtIndex:indexPath.item];
	
	if ([message.sender isEqualToString:self.sender])
	{
		return [[UIImageView alloc] initWithImage:self.outgoingBubbleImageView.image
								 highlightedImage:self.outgoingBubbleImageView.highlightedImage];
	}
	
	return [[UIImageView alloc] initWithImage:self.incomingBubbleImageView.image
							 highlightedImage:self.incomingBubbleImageView.highlightedImage];
}

- (UIImageView *)collectionView:(JSQMessagesCollectionView *)collectionView avatarImageViewForItemAtIndexPath:(NSIndexPath *)indexPath
{
	if (self.arrayOfJSQMessages.count == 0 || self.arrayOfJSQMessages == nil)
	{
		return [[UIImageView alloc] init];
	}
	JSQMessage *message = [self.arrayOfJSQMessages objectAtIndex:indexPath.row];
	if ([message.sender isEqualToString:self.sender])
	{
		UIImageView *imageView = [[UIImageView alloc] initWithImage:self.myAvatar];
		return imageView;
	}
	
	UIImageView *imageView = [[UIImageView alloc] initWithImage:self.yourAvatar];
	
	return imageView;
	
}

- (NSAttributedString *)collectionView:(JSQMessagesCollectionView *)collectionView attributedTextForCellTopLabelAtIndexPath:(NSIndexPath *)indexPath
{
	if (self.arrayOfJSQMessages != nil && self.arrayOfJSQMessages.count > 0)
	{
		if (indexPath.item % 3 == 0)
		{
			JSQMessage *message = [self.arrayOfJSQMessages objectAtIndex:indexPath.item];
			return [[JSQMessagesTimestampFormatter sharedFormatter] attributedTimestampForDate: message.date];
		}
	}
	
	return nil;
}

- (NSAttributedString *)collectionView:(JSQMessagesCollectionView *)collectionView attributedTextForMessageBubbleTopLabelAtIndexPath:(NSIndexPath *)indexPath
{
	if (self.arrayOfJSQMessages.count > 0 && self.arrayOfJSQMessages != nil)
	{
		JSQMessage *message = [self.arrayOfJSQMessages objectAtIndex:indexPath.item];
		
		/**
		 *  iOS7-style sender name labels
		 */
		if ([message.sender isEqualToString:self.sender])
		{
			return nil;
		}
		
		if (indexPath.item - 1 > 0)
		{
			JSQMessage *previousMessage = [self.arrayOfJSQMessages objectAtIndex:indexPath.item - 1];
			if ([[previousMessage sender] isEqualToString: message.sender])
			{
				return nil;
			}
		}
		
		/**
		 *  Don't specify attributes to use the defaults.
		 */
		return [[NSAttributedString alloc] initWithString: message.sender];
	}
	
	return nil;
}

- (NSAttributedString *)collectionView:(JSQMessagesCollectionView *)collectionView attributedTextForCellBottomLabelAtIndexPath:(NSIndexPath *)indexPath
{
	return nil;
}

#pragma mark - UICollectionView DataSource

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
	return [self.arrayOfJSQMessages count];
}

- (UICollectionViewCell *)collectionView:(JSQMessagesCollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
	
	JSQMessagesCollectionViewCell *cell = (JSQMessagesCollectionViewCell *)[super collectionView:collectionView cellForItemAtIndexPath:indexPath];
	
	if (self.arrayOfJSQMessages.count == 0 || self.arrayOfJSQMessages == nil)
	{
		return cell;
	}
	JSQMessage *msg = [self.arrayOfJSQMessages objectAtIndex:indexPath.item];
	
	if ([msg.sender isEqualToString:self.sender])
	{
		cell.textView.textColor = [UIColor blackColor];
	}
	else
	{
		cell.textView.textColor = [UIColor blackColor];
	}
	
	cell.textView.linkTextAttributes = @{ NSForegroundColorAttributeName : cell.textView.textColor,
										  NSUnderlineStyleAttributeName : @(NSUnderlineStyleSingle | NSUnderlinePatternSolid) };
	
	return cell;
}

#pragma mark - JSQMessages collection view flow layout delegate

#pragma mark - Adjusting cell label heights

- (CGFloat)collectionView:(JSQMessagesCollectionView *)collectionView
				   layout:(JSQMessagesCollectionViewFlowLayout *)collectionViewLayout heightForCellTopLabelAtIndexPath:(NSIndexPath *)indexPath
{
	
	if (indexPath.item % 3 == 0)
	{
		return kJSQMessagesCollectionViewCellLabelHeightDefault;
	}
	
	return 0.0f;
}

- (CGFloat)collectionView:(JSQMessagesCollectionView *)collectionView
				   layout:(JSQMessagesCollectionViewFlowLayout *)collectionViewLayout heightForMessageBubbleTopLabelAtIndexPath:(NSIndexPath *)indexPath
{
	/**
	 *  iOS7-style sender name labels
	 */
	
	if (self.arrayOfJSQMessages.count == 0 || self.arrayOfJSQMessages == nil)
	{
		return 0.0f;
	}
	JSQMessage *currentMessage = [self.arrayOfJSQMessages objectAtIndex:indexPath.item];
	if ([[currentMessage sender] isEqualToString:self.sender])
	{
		return 0.0f;
	}
	
	if (indexPath.item - 1 > 0) {
		JSQMessage *previousMessage = [self.arrayOfJSQMessages objectAtIndex:indexPath.item - 1];
		if ([[previousMessage sender] isEqualToString:[currentMessage sender]])
		{
			return 0.0f;
		}
	}
	
	return kJSQMessagesCollectionViewCellLabelHeightDefault;
}

- (CGFloat)collectionView:(JSQMessagesCollectionView *)collectionView
				   layout:(JSQMessagesCollectionViewFlowLayout *)collectionViewLayout heightForCellBottomLabelAtIndexPath:(NSIndexPath *)indexPath
{
	return 0.0f;
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
