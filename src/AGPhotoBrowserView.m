//
//  AGPhotoBrowserView.m
//  AGPhotoBrowser
//
//  Created by Hellrider on 7/28/13.
//  Copyright (c) 2013 Andrea Giavatto. All rights reserved.
//

#import "AGPhotoBrowserView.h"
#import "AGPhotoBrowserCell.h"
#import "AGPhotoBrowserZoomableView.h"
#import "AGPhotoBrowserConstants.h"
#import <SDWebImage/UIImageView+WebCache.h>
#import <QuartzCore/QuartzCore.h>

@interface AGPhotoBrowserView () <AGPhotoBrowserZoomableViewDelegate, UITableViewDataSource, UITableViewDelegate, UIGestureRecognizerDelegate>

@property (assign) CGPoint startingPanPoint;
@property (nonatomic, strong, readwrite) UIButton *doneButton;
@property (nonatomic, strong) UITableView *photoTableView;
@property (nonatomic, assign, getter = isShowingCellDetails) BOOL showCellDetail;

@end

static NSString *CellIdentifier = @"AGPhotoBrowserCell";
const NSInteger AGPhotoBrowserThresholdToCenter = 100;

@implementation AGPhotoBrowserView

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:[[UIScreen mainScreen] bounds]];
    if (self) {
        // Initialization code
		[self setupView];
    }
    return self;
}

- (void)setupView {
	self.userInteractionEnabled = NO;
	self.backgroundColor = [UIColor colorWithWhite:0.0 alpha:0.0];

	[self addSubview:self.photoTableView];
	[self addSubview:self.doneButton];
}


#pragma mark - UITableViewDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
	NSInteger number = [_dataSource numberOfPhotosForPhotoBrowser:self];

    return number;
}

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath {
	cell.backgroundColor = [UIColor clearColor];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return CGRectGetHeight([[UIScreen mainScreen] bounds]);
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    AGPhotoBrowserCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (!cell) {
        cell = [[AGPhotoBrowserCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
		cell.selectionStyle = UITableViewCellSelectionStyleNone;
    }


    [self configureCell:cell forRowAtIndexPath:indexPath];
    [cell setDetailsVisable:self.isShowingCellDetails];

    return cell;
}

- (void)configureCell:(AGPhotoBrowserCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath {
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

    [imageView setImageWithURL:[_dataSource photoBrowser:self URLForImageAtIndex:indexPath.row]];

    [cell.userLabel setText:[_dataSource photoBrowser:self userForImageAtIndex:indexPath.row]];
    [cell.locationLabel setText:[_dataSource photoBrowser:self locationForImageAtIndex:indexPath.row]];
    [cell.dateTimeLabel setText:[_dataSource photoBrowser:self dateTimeForImageAtIndex:indexPath.row]];
}

#pragma mark - UITableViewDelegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    self.showCellDetail = !self.isShowingCellDetails;
    AGPhotoBrowserCell *cell = (AGPhotoBrowserCell *)[tableView cellForRowAtIndexPath:indexPath];
    [cell setDetailsVisable:self.isShowingCellDetails];
}

- (void)didTapZoomableView:(AGPhotoBrowserZoomableView *)zoomableView {
    self.showCellDetail = !self.isShowingCellDetails;

    AGPhotoBrowserCell *cell = (AGPhotoBrowserCell *)[[self.photoTableView visibleCells] firstObject];
    [cell setDetailsVisable:self.isShowingCellDetails];
}

#pragma mark - Public methods

- (void)show {
    [[[UIApplication sharedApplication].windows lastObject] addSubview:self];

	[UIView animateWithDuration:AGPhotoBrowserAnimationDuration
					 animations:^(){
						 self.backgroundColor = [UIColor colorWithWhite:0. alpha:1.];
					 }
					 completion:^(BOOL finished){
						 if (finished) {
							 self.userInteractionEnabled = YES;
                             self.showCellDetail = YES;
							 self.photoTableView.alpha = 1.;
							 [self.photoTableView reloadData];
						 }
					 }];
}

- (void)showFromIndex:(NSInteger)initialIndex {
    [self.photoTableView reloadData];
	if (initialIndex < [_dataSource numberOfPhotosForPhotoBrowser:self]) {
		[self.photoTableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:initialIndex inSection:0] atScrollPosition:UITableViewScrollPositionMiddle animated:NO];
	}

	[self show];
}

- (void)hideWithCompletion:( void (^) (BOOL finished) )completionBlock {
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

#pragma mark - UIGestureRecognizerDelegate

- (BOOL)gestureRecognizerShouldBegin:(UIPanGestureRecognizer *)gestureRecognizer {
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

- (void)p_imageViewPanned:(UIPanGestureRecognizer *)recognizer {
	AGPhotoBrowserZoomableView *imageView = (AGPhotoBrowserZoomableView *)recognizer.view;

	if (recognizer.state == UIGestureRecognizerStateBegan) {
		// -- Disable table view scrolling
		self.photoTableView.scrollEnabled = NO;
		// -- Hide detailed view
        self.showCellDetail = NO;
		self.startingPanPoint = imageView.center;
		return;
	}

	if (recognizer.state == UIGestureRecognizerStateEnded) {
		// -- Enable table view scrolling
		self.photoTableView.scrollEnabled = YES;
		// -- Check if user dismissed the view
		CGPoint endingPanPoint = [recognizer translationInView:self];
		CGPoint translatedPoint = CGPointMake(self.startingPanPoint.x - endingPanPoint.x, self.startingPanPoint.y);
		int horizontalDistance = abs(floor(self.startingPanPoint.x - translatedPoint.x));

		if (horizontalDistance <= AGPhotoBrowserThresholdToCenter) {

			// -- Back to original center
			[UIView animateWithDuration:AGPhotoBrowserAnimationDuration
							 animations:^(){
								 self.backgroundColor = [UIColor colorWithWhite:0. alpha:1.];
								 imageView.center = self.startingPanPoint;
							 } completion:^(BOOL finished){
								 // -- show detailed view?
                                 self.showCellDetail = YES;
							 }];
		} else {
			// -- Animate out!
			typeof(self) weakSelf __weak = self;
			[self hideWithCompletion:^(BOOL finished){
				typeof(weakSelf) strongSelf __strong = weakSelf;
				if (strongSelf) {
					imageView.center = self.startingPanPoint;
				}
			}];
		}
	} else {
		CGPoint middlePanPoint = [recognizer translationInView:self];
		CGPoint translatedPoint = CGPointMake(self.startingPanPoint.x + middlePanPoint.x, self.startingPanPoint.y);
		imageView.center = translatedPoint;
		int heightDifference = abs(floor(self.startingPanPoint.x - translatedPoint.x));
		CGFloat ratio = (self.startingPanPoint.x - heightDifference)/self.startingPanPoint.x;
		self.backgroundColor = [UIColor colorWithWhite:0. alpha:ratio];
	}
}


#pragma mark - Setters

- (void)setShowCellDetail:(BOOL)showCellDetail {
	_showCellDetail = showCellDetail;

	[UIView animateWithDuration:AGPhotoBrowserAnimationDuration
					 animations:^(){
						 self.doneButton.alpha = _showCellDetail;
					 }];
}


#pragma mark - Getters

- (UIButton *)doneButton {
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

- (UITableView *)photoTableView {
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


#pragma mark - Private methods

- (void)p_doneButtonTapped:(UIButton *)sender {
	if ([_delegate respondsToSelector:@selector(photoBrowser:didTapOnDoneButton:)]) {
        self.showCellDetail = NO;
		[_delegate photoBrowser:self didTapOnDoneButton:sender];
	}
}


@end
