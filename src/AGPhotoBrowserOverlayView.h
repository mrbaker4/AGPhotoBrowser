//
//  AGPhotoBrowserOverlayView.h
//  AGPhotoBrowser
//
//  Created by Hellrider on 7/28/13.
//  Copyright (c) 2013 Andrea Giavatto. All rights reserved.
//

#import <UIKit/UIKit.h>

static const NSInteger AGPhotoBrowserOverlayInitialHeight = 120;

@class AGPhotoBrowserOverlayView;

@protocol AGPhotoBrowserOverlayViewDelegate <NSObject>

- (void)sharingView:(AGPhotoBrowserOverlayView *)sharingView didTapOnActionButton:(UIButton *)actionButton;

@end

@interface AGPhotoBrowserOverlayView : UIView

@property (nonatomic, weak) id<AGPhotoBrowserOverlayViewDelegate> delegate;

@property (nonatomic, assign, readonly, getter = isVisible) BOOL visible;

- (void)setUsername:(NSString *)username;
- (void)setDateTime:(NSString *)dateTime;
- (void)setLocation:(NSString *)location;

- (void)showOverlayAnimated:(BOOL)animated;
- (void)hideOverlayAnimated:(BOOL)animated;

- (void)resetOverlayView;

@end
