//
//  ViewController.m
//  AGPhotoBrowser
//
//  Created by Hellrider on 7/28/13.
//  Copyright (c) 2013 Andrea Giavatto. All rights reserved.
//

#import "ViewController.h"

#import "AGPhotoBrowserView.h"


#define SAMPLE_IMAGE_1			[NSURL URLWithString:@"http://upload.wikimedia.org/wikipedia/commons/b/b9/Steve_Jobs_Headshot_2010-CROP.jpg"]
#define SAMPLE_IMAGE_2			[NSURL URLWithString:@"http://static3.businessinsider.com/image/520a2c4d69beddde2e00000c/larry-ellison-describes-watching-his-close-friend-steve-jobs-die.jpg"]
#define SAMPLE_IMAGE_3			[NSURL URLWithString:@"http://s3.amazonaws.com/crunchbase_prod_assets/assets/images/resized/0001/0974/10974v7-max-250x250.jpg"]


@interface ViewController () <UITableViewDataSource, UITableViewDelegate, AGPhotoBrowserDelegate, AGPhotoBrowserDataSource> {
	NSArray *_samplePictures;
}

@property (nonatomic, weak) IBOutlet UITableView *tableView;
@property (nonatomic, strong) AGPhotoBrowserView *browserView;

@end

@implementation ViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.

	_samplePictures = @[
	@{
		  @"Image": SAMPLE_IMAGE_1,
		  @"Title" : @"Hot air balloons",
		  @"Description" : @"Really cool!"
	},
	  @{
		  @"Image": SAMPLE_IMAGE_2,
		  @"Title" : @"Drop on a leaf",
		  @"Description" : @"A very long and meaningful description about a drop on a leaf.\n\nThis description is so interesting that i am never bored reading it!\n\nI could go on and on and on and on and on and on..."
	},
	  @{
		  @"Image": SAMPLE_IMAGE_3,
		  @"Title" : @"Rainbow flower",
		  @"Description" : @"A colorful image"
	},
	];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


#pragma mark - UITableView Datasource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return _samplePictures.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
	return 140;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *cellIdentifier = @"SampleControllerCell";

    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];

    if(cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
		cell.selectionStyle = UITableViewCellSelectionStyleNone;
    }

	[self configureCell:cell forRowAtIndexPath:indexPath];

    return cell;
}


#pragma mark - UITableView Delegate methods

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	[self.browserView showFromIndex:indexPath.row];
}


#pragma mark - Private methods

- (void)configureCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
	UIImageView *imageView = (UIImageView *)[cell.contentView viewWithTag:1];
	if (!imageView) {
		imageView = [[UIImageView alloc] initWithFrame:CGRectMake(115, 35, 90, 90)];imageView.contentMode = UIViewContentModeScaleAspectFit;
		imageView.tag = 1;

		[cell.contentView addSubview:imageView];
	}

	UILabel *titleLabel = (UILabel *)[cell.contentView viewWithTag:2];
	if (!titleLabel) {
		titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(20, 15, 280, 15)];
		titleLabel.font = [UIFont boldSystemFontOfSize:17];
		titleLabel.textAlignment = NSTextAlignmentCenter;

		[cell.contentView addSubview:titleLabel];
	}

	titleLabel.text = [self photoBrowser:self.browserView titleForImageAtIndex:indexPath.row];
	//imageView.image = [self photoBrowser:self.browserView imageAtIndex:indexPath.row];
}


#pragma mark - AGPhotoBrowser datasource

- (NSInteger)numberOfPhotosForPhotoBrowser:(AGPhotoBrowserView *)photoBrowser
{
	return _samplePictures.count;
}

- (NSURL *)photoBrowser:(AGPhotoBrowserView *)photoBrowser URLForImageAtIndex:(NSInteger)index {
    return [[_samplePictures objectAtIndex:index] objectForKey:@"Image"];
}

- (NSString *)photoBrowser:(AGPhotoBrowserView *)photoBrowser titleForImageAtIndex:(NSInteger)index
{
	return [[_samplePictures objectAtIndex:index] objectForKey:@"Title"];
}

- (NSString *)photoBrowser:(AGPhotoBrowserView *)photoBrowser descriptionForImageAtIndex:(NSInteger)index
{
	return [[_samplePictures objectAtIndex:index] objectForKey:@"Description"];
}

- (BOOL)photoBrowser:(AGPhotoBrowserView *)photoBrowser willDisplayActionButtonAtIndex:(NSInteger)index
{
    // -- For testing purposes only
    if (index % 2) {
        return YES;
    }

    return NO;
}


#pragma mark - AGPhotoBrowser delegate

- (void)photoBrowser:(AGPhotoBrowserView *)photoBrowser didTapOnDoneButton:(UIButton *)doneButton
{
	// -- Dismiss
	NSLog(@"Dismiss the photo browser here");
	[self.browserView hideWithCompletion:^(BOOL finished){
		NSLog(@"Dismissed!");
	}];
}

- (void)photoBrowser:(AGPhotoBrowserView *)photoBrowser didTapOnActionButton:(UIButton *)actionButton atIndex:(NSInteger)index
{
	NSLog(@"Action button tapped at index %d!", index);
	UIActionSheet *action = [[UIActionSheet alloc] initWithTitle:@""
														delegate:nil
											   cancelButtonTitle:NSLocalizedString(@"Cancel", @"Cancel button")
										  destructiveButtonTitle:NSLocalizedString(@"Delete", @"Delete button")
											   otherButtonTitles:NSLocalizedString(@"Share", @"Share button"), nil];
	[action showInView:self.view];
}


#pragma mark - Getters

- (AGPhotoBrowserView *)browserView
{
	if (!_browserView) {
		_browserView = [[AGPhotoBrowserView alloc] initWithFrame:self.view.bounds];
		_browserView.delegate = self;
		_browserView.dataSource = self;
	}

	return _browserView;
}


@end
