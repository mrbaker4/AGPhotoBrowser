//
//  AGPhotoBrowserCell.h
//  AGPhotoBrowser
//
//  Created by Matthew Baker on 1/11/14.
//  Copyright (c) 2014 Andrea Giavatto. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface AGPhotoBrowserCell : UITableViewCell

@property (strong) UILabel *userLabel;
@property (strong) UILabel *dateTimeLabel;
@property (strong) UILabel *locationLabel;
@property (strong) UILabel *captionLabel;

- (void)setDetailsVisable:(BOOL)isVisable;
- (void)setCaption:(NSString *)caption withPosition:(CGFloat)position;

@end
