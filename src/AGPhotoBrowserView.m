//
//  AGPhotoBrowserView.m
//  AGPhotoBrowser
//
//  Created by Hellrider on 7/28/13.
//  Copyright (c) 2013 Andrea Giavatto. All rights reserved.
//

#import "AGPhotoBrowserView.h"

#import <QuartzCore/QuartzCore.h>
#import "AGPhotoBrowserOverlayView.h"
#import "AGPhotoBrowserZoomableView.h"
#import <SDWebImage/UIImageView+WebCache.h>

@interface AGPhotoBrowserView () <
AGPhotoBrowserOverlayViewDelegate,
AGPhotoBrowserZoomableViewDelegate,
UITableViewDataSource,
UITableViewDelegate,
UIGestureRecognizerDelegate
> {
	CGPoint _startingPanPoint;
	BOOL _wantedFullscreenLayout;
    BOOL _navigationBarWasHidden;
	CGRect _originalParentViewFrame;
	NSInteger _currentlySelectedIndex;
}

@property (nonatomic, strong, readwrite) UIButton *doneButton;
@property (nonatomic, strong) UITableView *photoTableView;
@property (nonatomic, strong) AGPhotoBrowserOverlayView *overlayView;

@property (nonatomic, assign, getter = isDisplayingDetailedView) BOOL displayingDetailedView;

@end


static NSString *CellIdentifier = @"AGPhotoBrowserCell";

@implementation AGPhotoBrowserView

const NSInteger AGPhotoBrowserThresholdToCenter = 100;

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:[UIScreen mainScreen].bounds];
    if (self) {
        // Initialization code
		[self setupView];
    }
    return self;
}

- (void)setupView
{
	self.userInteractionEnabled = NO;
	self.backgroundColor = [UIColor colorWithWhite:0. alpha:0.];
	_currentlySelectedIndex = NSNotFound;

	[self addSubview:self.photoTableView];
	[self addSubview:self.doneButton];
	[self addSubview:self.overlayView];
}


#pragma mark - UITableViewDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
	NSInteger number = [_dataSource numberOfPhotosForPhotoBrowser:self];

    if (number > 0 && _currentlySelectedIndex == NSNotFound) {
        // initialize with info for the first photo in photoTable
        [self setupPhotoForIndex:0];
    }

    return number;
}

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
	cell.backgroundColor = [UIColor clearColor];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
		cell.selectionStyle = UITableViewCellSelectionStyleNone;
    }

    if ([self.dataSource respondsToSelector:@selector(photoBrowser:willDisplayActionButtonAtIndex:)]) {
        self.overlayView.actionButton.hidden = [self.dataSource photoBrowser:self willDisplayActionButtonAtIndex:indexPath.row];
    } else {
        self.overlayView.actionButton.hidden = NO;
    }

	[self setupPhotoForIndex:indexPath.row];

    [self configureCell:cell forRowAtIndexPath:indexPath];

    return cell;
}

- (void)configureCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
    AGPhotoBrowserZoomableView *imageView = (AGPhotoBrowserZoomableView *)[cell.contentView viewWithTag:1];
	if (!imageView) {
		imageView = [[AGPhotoBrowserZoomableView alloc] initWithFrame:self.bounds];
		imageView.userInteractionEnabled = YES;
        imageView.zoomableDelegate = self;

		UIPanGestureRecognizer *panGesture = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(p_imageViewPanned:)];
		panGesture.delegate = self;
		panGesture.maximumNumberOfTouches = 1;
		panGesture.minimumNumberOfTouches = 1;
		[imageView addGestureRecognizer:panGesture];
		imageView.tag = 1;

		[cell.contentView addSubview:imageView];
	}
    else {
        // reset to 'zoom out' state
        [imageView setZoomScale:1.0f];
    }

    if ([_dataSource respondsToSelector:@selector(photoBrowser:URLForImageAtIndex:)]) {
        [imageView setImageWithURL:[_dataSource photoBrowser:self URLForImageAtIndex:indexPath.row]];
    }
    else if ([_dataSource respondsToSelector:@selector(photoBrowser:imageAtIndex:)]) {
        [imageView setImage:[_dataSource photoBrowser:self imageAtIndex:indexPath.row]];
    }
}

- (void)setupPhotoForIndex:(int)index
{
    _currentlySelectedIndex = index;

	if ([_dataSource respondsToSelector:@selector(photoBrowser:titleForImageAtIndex:)]) {
		self.overlayView.title = [_dataSource photoBrowser:self titleForImageAtIndex:index];
	} else {
        self.overlayView.title = @"";
    }

	if ([_dataSource respondsToSelector:@selector(photoBrowser:descriptionForImageAtIndex:)]) {
		self.overlayView.description = [_dataSource photoBrowser:self descriptionForImageAtIndex:index];
	} else {
        self.overlayView.description = @"";
    }
}

#pragma mark - UITableViewDelegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    self.displayingDetailedView = !self.isDisplayingDetailedView;
}

- (void)didTapZoomableView:(AGPhotoBrowserZoomableView *)zoomableView
{
    self.displayingDetailedView = !self.isDisplayingDetailedView;
}

#pragma mark - Public methods

- (void)show
{
    [[[UIApplication sharedApplication].windows lastObject] addSubview:self];

	[UIView animateWithDuration:AGPhotoBrowserAnimationDuration
					 animations:^(){
						 self.backgroundColor = [UIColor colorWithWhite:0. alpha:1.];
					 }
					 completion:^(BOOL finished){
						 if (finished) {
							 self.userInteractionEnabled = YES;
							 self.displayingDetailedView = YES;
							 self.photoTableView.alpha = 1.;
							 [self.photoTableView reloadData];
						 }
					 }];
}

- (void)showFromIndex:(NSInteger)initialIndex
{
    [self.photoTableView reloadData];
	if (initialIndex < [_dataSource numberOfPhotosForPhotoBrowser:self]) {
		[self.photoTableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:initialIndex inSection:0] atScrollPosition:UITableViewScrollPositionMiddle animated:NO];
	}

	[self show];
}

- (void)hideWithCompletion:( void (^) (BOOL finished) )completionBlock
{
	[UIView animateWithDuration:AGPhotoBrowserAnimationDuration
					 animations:^(){
						 self.photoTableView.alpha = 0.;
						 self.backgroundColor = [UIColor colorWithWhite:0. alpha:0.];
					 }
					 completion:^(BOOL finished){
						 self.userInteractionEnabled = NO;
                         [self removeFromSuperview];
						 if(completionBlock) {
							 completionBlock(finished);
						 }
					 }];
}


#pragma mark - AGPhotoBrowserOverlayViewDelegate

- (void)sharingView:(AGPhotoBrowserOverlayView *)sharingView didTapOnActionButton:(UIButton *)actionButton
{
	if ([_delegate respondsToSelector:@selector(photoBrowser:didTapOnActionButton:atIndex:)]) {
		[_delegate photoBrowser:self didTapOnActionButton:actionButton atIndex:_currentlySelectedIndex];
	}
}

- (void)sharingView:(AGPhotoBrowserOverlayView *)sharingView didTapOnSeeMoreButton:(UIButton *)actionButton
{
	CGSize descriptionSize;
    NSDictionary *textAttributes = @{NSFontAttributeName : sharingView.descriptionLabel.font};
    CGRect descriptionBoundingRect = [sharingView.description boundingRectWithSize:CGSizeMake(CGRectGetWidth([UIScreen mainScreen].bounds) - 40, MAXFLOAT)
                                                                           options:NSStringDrawingUsesLineFragmentOrigin|NSStringDrawingUsesFontLeading attributes:textAttributes
                                                                           context:nil];
    descriptionSize = CGSizeMake(ceil(CGRectGetWidth(descriptionBoundingRect)), ceil(CGRectGetHeight(descriptionBoundingRect)));

	CGRect currentOverlayFrame = self.overlayView.frame;
	int newSharingHeight = CGRectGetHeight(currentOverlayFrame) -20 + ceil(descriptionSize.height);

	[UIView animateWithDuration:AGPhotoBrowserAnimationDuration
					 animations:^(){
						 self.overlayView.frame = CGRectMake(0, floor(CGRectGetHeight(self.frame) - newSharingHeight), CGRectGetWidth(self.frame), newSharingHeight);
					 }];
}


#pragma mark - UIGestureRecognizerDelegate

- (BOOL)gestureRecognizerShouldBegin:(UIPanGestureRecognizer *)gestureRecognizer
{
    UIView *imageView = [gestureRecognizer view];
    CGPoint translation = [gestureRecognizer translationInView:[imageView superview]];

    // -- Check for horizontal gesture
    if (fabsf(translation.x) > fabsf(translation.y)) {
        // Horizontal Swipe
        return YES;
	}

    return NO;
}


#pragma mark - Recognizers

- (void)p_imageViewPanned:(UIPanGestureRecognizer *)recognizer
{
	AGPhotoBrowserZoomableView *imageView = (AGPhotoBrowserZoomableView *)recognizer.view;

	if (recognizer.state == UIGestureRecognizerStateBegan) {
		// -- Disable table view scrolling
		self.photoTableView.scrollEnabled = NO;
		// -- Hide detailed view
		self.displayingDetailedView = NO;
		_startingPanPoint = imageView.center;
		return;
	}

	if (recognizer.state == UIGestureRecognizerStateEnded) {
		// -- Enable table view scrolling
		self.photoTableView.scrollEnabled = YES;
		// -- Check if user dismissed the view
		CGPoint endingPanPoint = [recognizer translationInView:self];
		CGPoint translatedPoint = CGPointMake(_startingPanPoint.x - endingPanPoint.x, _startingPanPoint.y);
		int horizontalDistance = abs(floor(_startingPanPoint.x - translatedPoint.x));

		if (horizontalDistance <= AGPhotoBrowserThresholdToCenter) {

			// -- Back to original center
			[UIView animateWithDuration:AGPhotoBrowserAnimationDuration
							 animations:^(){
								 self.backgroundColor = [UIColor colorWithWhite:0. alpha:1.];
								 imageView.center = self->_startingPanPoint;
							 } completion:^(BOOL finished){
								 // -- show detailed view?
								 self.displayingDetailedView = YES;
							 }];
		} else {
			// -- Animate out!
			typeof(self) weakSelf __weak = self;
			[self hideWithCompletion:^(BOOL finished){
				typeof(weakSelf) strongSelf __strong = weakSelf;
				if (strongSelf) {
					imageView.center = strongSelf->_startingPanPoint;
				}
			}];
		}
	} else {
		CGPoint middlePanPoint = [recognizer translationInView:self];
		CGPoint translatedPoint = CGPointMake(_startingPanPoint.x + middlePanPoint.x, _startingPanPoint.y);
		imageView.center = translatedPoint;
		int heightDifference = abs(floor(_startingPanPoint.x - translatedPoint.x));
		CGFloat ratio = (_startingPanPoint.x - heightDifference)/_startingPanPoint.x;
		self.backgroundColor = [UIColor colorWithWhite:0. alpha:ratio];
	}
}


#pragma mark - Setters

- (void)setDisplayingDetailedView:(BOOL)displayingDetailedView
{
	_displayingDetailedView = displayingDetailedView;

	CGFloat newAlpha;

	if (_displayingDetailedView) {
		[self.overlayView showOverlayAnimated:YES];
		newAlpha = 1.;
	} else {
		[self.overlayView hideOverlayAnimated:YES];
		newAlpha = 0.;
	}

	[UIView animateWithDuration:AGPhotoBrowserAnimationDuration
					 animations:^(){
						 self.doneButton.alpha = newAlpha;
					 }];
}


#pragma mark - Getters

- (UIButton *)doneButton
{
	if (!_doneButton) {
		int currentScreenWidth = CGRectGetWidth([[UIScreen mainScreen] bounds]);
		_doneButton = [[UIButton alloc] initWithFrame:CGRectMake(currentScreenWidth - 70, 12, 60, 32)];
		[_doneButton setTitle:@"Close" forState:UIControlStateNormal];
        [_doneButton setTitleColor:[UIColor whiteColor] forState:UIControlStateApplication];
		[_doneButton.titleLabel setFont:[UIFont boldSystemFontOfSize:16.0f]];
		_doneButton.alpha = 0.;
        [_doneButton setTitleShadowColor:[UIColor blackColor] forState:UIControlStateNormal];
        [_doneButton.titleLabel setShadowOffset:CGSizeMake(1.0, 1.0)];
		[_doneButton addTarget:self action:@selector(p_doneButtonTapped:) forControlEvents:UIControlEventTouchUpInside];
	}

	return _doneButton;
}

- (UITableView *)photoTableView
{
	if (!_photoTableView) {
		CGRect screenBounds = [[UIScreen mainScreen] bounds];
		_photoTableView = [[UITableView alloc] initWithFrame:screenBounds];
		_photoTableView.dataSource = self;
		_photoTableView.delegate = self;
		_photoTableView.separatorStyle = UITableViewCellSeparatorStyleNone;
		_photoTableView.backgroundColor = [UIColor clearColor];
		_photoTableView.rowHeight = screenBounds.size.height;
		_photoTableView.pagingEnabled = YES;
		_photoTableView.showsVerticalScrollIndicator = NO;
		_photoTableView.showsHorizontalScrollIndicator = NO;
		_photoTableView.alpha = 0.;
	}

	return _photoTableView;
}

- (AGPhotoBrowserOverlayView *)overlayView
{
	if (!_overlayView) {
		_overlayView = [[AGPhotoBrowserOverlayView alloc] initWithFrame:CGRectMake(0, CGRectGetHeight(self.frame) - AGPhotoBrowserOverlayInitialHeight, CGRectGetWidth(self.frame), AGPhotoBrowserOverlayInitialHeight)];
		_overlayView.delegate = self;
	}

	return _overlayView;
}


#pragma mark - Private methods

- (void)p_doneButtonTapped:(UIButton *)sender
{
	if ([_delegate respondsToSelector:@selector(photoBrowser:didTapOnDoneButton:)]) {
		self.displayingDetailedView = NO;
		[_delegate photoBrowser:self didTapOnDoneButton:sender];
	}
}


@end
