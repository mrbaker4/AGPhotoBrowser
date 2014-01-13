//
//  AGPhotoBrowserCell.m
//  AGPhotoBrowser
//
//  Created by Matthew Baker on 1/11/14.
//  Copyright (c) 2014 Andrea Giavatto. All rights reserved.
//

#import "AGPhotoBrowserCell.h"
#import "AGPhotoBrowserConstants.h"
#import <PNChart.h>

@interface AGPhotoBrowserCell ()
@property (strong) PNCircleChart *circleChart;
@end

@implementation AGPhotoBrowserCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code

        [self userLabelSetup];
        [self dateTimeLabelSetup];
        [self locationLabelSetup];
        [self circleChartSetup];

        [self moveLabelsToPosition];

        [self addSubview:self.circleChart];
        [self addSubview:self.userLabel];
        [self addSubview:self.dateTimeLabel];
        [self addSubview:self.locationLabel];
    }
    return self;
}


#pragma mark - Cell Setup
- (void) moveLabelsToPosition {
    CGRect screenSize = [[UIScreen mainScreen] bounds];
    float screenHeight = screenSize.size.height;
    float locationOffset = 0.0;
    if ([self.locationLabel.text length]) {
        locationOffset = 18.0;
    }

    [self.locationLabel setFrame:CGRectMake(80.0, screenHeight-36.0, 160.0, 20.0)];
    [self.dateTimeLabel setFrame:CGRectMake(80.0, screenHeight-54.0+locationOffset, 160.0, 20.0)];
    [self.userLabel setFrame:CGRectMake(80.0, screenHeight-74.0+locationOffset, 160.0, 20.0)];
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

- (void) circleChartSetup {
    self.circleChart = [[PNCircleChart alloc] initWithFrame:CGRectMake(10.0, 10.0, 75.0, 75.0) andTotal:[NSNumber numberWithInt:0] andCurrent:[NSNumber numberWithInt:0]];
    self.circleChart.backgroundColor = [UIColor clearColor];
    [self.circleChart setStrokeColor:PNGreen];
}

#pragma mark - Cell Actions

- (void)setDetailsVisable:(BOOL)isVisable {
    [UIView animateWithDuration:AGPhotoBrowserAnimationDuration
					 animations:^(){
                         [self.userLabel setHidden:!isVisable];
                         [self.dateTimeLabel setHidden:!isVisable];
                         [self.locationLabel setHidden:!isVisable];
					 }];
}

- (void)setViews:(NSInteger)views andReposts:(NSInteger)reposts {
    [self.circleChart setCurrent:[NSNumber numberWithInt:views]];
    [self.circleChart setTotal:[NSNumber numberWithInt:reposts]];
    [self.circleChart strokeChart];
}

@end
