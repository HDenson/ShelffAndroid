//
//  PageViewController.m
//  Shelff
//
//  Created by Adam on 12/8/14.
//  Copyright (c) 2014 Adam. All rights reserved.
//

#import "PageViewController.h"

@interface PageViewController () <UIScrollViewDelegate>

@property (weak, nonatomic) IBOutlet UIScrollView *scrollView;

@end

@implementation PageViewController


- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
	
}

-(void)viewDidLayoutSubviews
{
	[super viewDidLayoutSubviews];
	
	[self.scrollView setContentSize: CGSizeMake(self.scrollView.frame.size.width * 3, self.scrollView.frame.size.height)];
	self.scrollView.pagingEnabled = YES;
	self.scrollView.delegate = self;
	
	
	[self setContentImageViews];
}

-(void)setContentImageViews
{
	for (int i = 0; i < 3; i++)
	{
		UIView *view = [self switchOutCorrectNibView: i];
		view.frame = CGRectMake(i * self.scrollView.frame.size.width, 0, self.view.frame.size.width, self.view.frame.size.height);
		[self.scrollView addSubview: view];
	}
	
	UIButton *button = [UIButton buttonWithType: UIButtonTypeRoundedRect];
	[button addTarget: self
			   action: @selector(dismissThis)
	 forControlEvents: UIControlEventTouchUpInside];
	[button setTitle:@"Enter" forState: UIControlStateNormal];
	[button setTitleColor: [UIColor whiteColor] forState: UIControlStateNormal];
	button.titleLabel.font = [UIFont fontWithName:@"Futura" size:24];
	button.frame = CGRectMake((self.view.frame.size.width * 2) + ((self.view.frame.size.width / 2) - 55), (self.view.frame.size.height / 2) - 20, 110, 40);
	button.layer.borderWidth = .4;
	button.layer.borderColor = [[UIColor whiteColor] CGColor];
	button.layer.cornerRadius = 5;
	[self.scrollView addSubview: button];
	[self.scrollView bringSubviewToFront: button];
	
}

-(void)dismissThis
{
	[self dismissViewControllerAnimated: YES completion: nil];
}

-(UIView *)switchOutCorrectNibView:(int)i
{
	switch (i)
	{
		case 0:
			return [[[NSBundle mainBundle] loadNibNamed:@"Page1" owner:self options:nil] firstObject];
		case 1:
			return [[[NSBundle mainBundle] loadNibNamed:@"Page2" owner:self options:nil] firstObject];
		case 2:
			return [[[NSBundle mainBundle] loadNibNamed:@"Page3" owner:self options:nil] firstObject];
		default:
			return nil;
	}
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}




#pragma mark - Scroll View Delegate

-(void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{

}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
	
}

@end
