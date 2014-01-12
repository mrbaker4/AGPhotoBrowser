//
//  AGPhotoBrowserOverlayView.m
//  AGPhotoBrowser
//
//  Created by Hellrider on 7/28/13.
//  Copyright (c) 2013 Andrea Giavatto. All rights reserved.
//

#import "AGPhotoBrowserOverlayView.h"

#import <QuartzCore/QuartzCore.h>


@interface AGPhotoBrowserOverlayView () {
	BOOL _animated;
}
@property (nonatomic, strong) UITapGestureRecognizer *tapGesture;
@property (nonatomic, strong) UIButton *seeMoreButton;

@property (strong) UILabel *userLabel;
@property (strong) UILabel *dateTimeLabel;
@property (strong) UILabel *locationLabel;

@property (nonatomic, assign, readwrite, getter = isVisible) BOOL visible;

@end


@implementation AGPhotoBrowserOverlayView

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
		[self setupView];
    }
    return self;
}

- (void)layoutSubviews
{
	[super layoutSubviews];

    CGRect screenSize = [[UIScreen mainScreen] bounds];
    float screenHeight = screenSize.size.height;
    float locationOffset = 0.0;
    if (![self.locationLabel.text length]) {
        locationOffset = 18.0;
    }
    [self.locationLabel setFrame:CGRectMake(80.0, screenHeight-36.0, 160.0, 20.0)];
    [self.dateTimeLabel setFrame:CGRectMake(80.0, screenHeight-54.0+locationOffset, 160.0, 20.0)];
    [self.userLabel setFrame:CGRectMake(80.0, screenHeight-74.0+locationOffset, 160.0, 20.0)];
}

- (void)setupView
{
	self.alpha = 0.0;
	self.userInteractionEnabled = NO;

    [self userLabelSetup];
    [self dateTimeLabelSetup];
    [self locationLabelSetup];

	[self addSubview:self.userLabel];
    [self addSubview:self.dateTimeLabel];
	[self addSubview:self.locationLabel];
    /*
     Uncomment the following line to add in an action button.
	[self addSubview:self.actionButton];
     */
}

- (void) userLabelSetup {
    self.userLabel = [[UILabel alloc] initWithFrame:CGRectMake(0.0, 0.0, 160.0, 20.0)];
    [self.userLabel setTextAlignment:NSTextAlignmentCenter];
    [self.userLabel setFont:[UIFont boldSystemFontOfSize:16.0]];
    [self.userLabel setBackgroundColor:[UIColor clearColor]];
    [self.userLabel setTextColor:[UIColor whiteColor]];
    [self.userLabel setShadowOffset:CGSizeMake(1.0, 1.0)];
    [self.userLabel setShadowColor:[UIColor colorWithWhite:0.0 alpha:0.75]];
}

- (void) dateTimeLabelSetup {
    self.dateTimeLabel = [[UILabel alloc] initWithFrame:CGRectMake(0.0, 0.0, 160.0, 20.0)];
    [self.dateTimeLabel setTextAlignment:NSTextAlignmentCenter];
    [self.dateTimeLabel setFont:[UIFont boldSystemFontOfSize:16.0]];
    [self.dateTimeLabel setBackgroundColor:[UIColor clearColor]];
    [self.dateTimeLabel setTextColor:[UIColor whiteColor]];
    [self.dateTimeLabel setShadowOffset:CGSizeMake(1.0, 1.0)];
    [self.dateTimeLabel setShadowColor:[UIColor colorWithWhite:0.0 alpha:0.75]];
}

- (void) locationLabelSetup {
    self.locationLabel = [[UILabel alloc] initWithFrame:CGRectMake(0.0, 0.0, 160.0, 20.0)];
    [self.locationLabel setTextAlignment:NSTextAlignmentCenter];
    [self.locationLabel setFont:[UIFont systemFontOfSize:12.0]];
    [self.locationLabel setTextColor:[UIColor whiteColor]];
    [self.locationLabel setShadowOffset:CGSizeMake(1.0, 1.0)];
    [self.locationLabel setShadowColor:[UIColor colorWithWhite:0.0 alpha:0.75]];
}

#pragma mark - Public methods

- (void)showOverlayAnimated:(BOOL)animated
{
	_animated = animated;
	self.visible = YES;
}

- (void)hideOverlayAnimated:(BOOL)animated
{
	_animated = animated;
	self.visible = NO;
}

- (void)resetOverlayView
{
	if (floor(CGRectGetHeight(self.frame)) != AGPhotoBrowserOverlayInitialHeight) {
		__block CGRect initialSharingFrame = self.frame;
		initialSharingFrame.origin.y = round(CGRectGetHeight([UIScreen mainScreen].bounds) - AGPhotoBrowserOverlayInitialHeight);

		[UIView animateWithDuration:0.15
						 animations:^(){
							 self.frame = initialSharingFrame;
						 } completion:^(BOOL finished){
							 initialSharingFrame.size.height = AGPhotoBrowserOverlayInitialHeight;
							 [self setNeedsLayout];
							 [UIView animateWithDuration:AGPhotoBrowserAnimationDuration
											  animations:^(){
												  self.frame = initialSharingFrame;
											  }];
						 }];
	}
}


#pragma mark - Buttons

- (void)p_actionButtonTapped:(UIButton *)sender
{
	if ([_delegate respondsToSelector:@selector(sharingView:didTapOnActionButton:)]) {
		[_delegate sharingView:self didTapOnActionButton:sender];
	}
}


#pragma mark - Recognizers

- (void)p_tapGestureTapped:(UITapGestureRecognizer *)recognizer
{
	[self resetOverlayView];
}


#pragma mark - Setters
- (void)setVisible:(BOOL)visible
{
	_visible = visible;

	CGFloat newAlpha = _visible ? 1. : 0.;

	NSTimeInterval animationDuration = _animated ? AGPhotoBrowserAnimationDuration : 0;

	[UIView animateWithDuration:animationDuration
					 animations:^(){
						 self.alpha = newAlpha;
					 }];
}

- (void)setUsername:(NSString *)username {

    if (username) {
        self.userLabel.text = username;
    }

    [self setNeedsLayout];
}

- (void)setDateTime:(NSString *)dateTime {
	if (dateTime) {
        self.dateTimeLabel.text = dateTime;
	}

    [self setNeedsLayout];
}

- (void)setLocation:(NSString *)location {
    if ([location length]) {
        self.locationLabel.text = location;
    } else {
        self.locationLabel.text = @"";
    }

    [self setNeedsLayout];
}


#pragma mark - Getters

- (UIButton *)seeMoreButton
{
	if (!_seeMoreButton) {
		_seeMoreButton = [[UIButton alloc] initWithFrame:CGRectMake(180, CGRectGetHeight(self.frame) - 10 - 23, 65, 20)];
		[_seeMoreButton setTitle:NSLocalizedString(@"See More", @"Title for See more button") forState:UIControlStateNormal];
		[_seeMoreButton setBackgroundColor:[UIColor clearColor]];
		[_seeMoreButton setTitleColor:[UIColor grayColor] forState:UIControlStateNormal];
		_seeMoreButton.titleLabel.font = [UIFont boldSystemFontOfSize:13];
        _seeMoreButton.hidden = YES;

		[_seeMoreButton addTarget:self action:@selector(p_seeMoreButtonTapped:) forControlEvents:UIControlEventTouchUpInside];
	}

	return _seeMoreButton;
}

- (UITapGestureRecognizer *)tapGesture
{
	if (!_tapGesture) {
		_tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(p_tapGestureTapped:)];
		_tapGesture.numberOfTouchesRequired = 1;
	}

	return _tapGesture;
}

@end
