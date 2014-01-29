//
//  AGPhotoBrowserDataSource.h
//  AGPhotoBrowser
//
//  Created by Hellrider on 7/28/13.
//  Copyright (c) 2013 Andrea Giavatto. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol AGPhotoBrowserDataSource <NSObject>

- (NSInteger)numberOfPhotosForPhotoBrowser:(AGPhotoBrowserView *)photoBrowser;
- (NSURL *)photoBrowser:(AGPhotoBrowserView *)photoBrowser URLForImageAtIndex:(NSInteger)index;
- (NSString *)photoBrowser:(AGPhotoBrowserView *)photoBrowser userForImageAtIndex:(NSInteger)index;
- (NSString *)photoBrowser:(AGPhotoBrowserView *)photoBrowser dateTimeForImageAtIndex:(NSInteger)index;
- (NSString *)photoBrowser:(AGPhotoBrowserView *)photoBrowser locationForImageAtIndex:(NSInteger)index;
- (NSInteger)photoBrowser:(AGPhotoBrowserView *)photoBrowser viewsForImageAtIndex:(NSInteger)index;


@optional

- (NSInteger)photoBrowser:(AGPhotoBrowserView *)photoBrowser repostsForImageAtIndex:(NSInteger)index;
- (BOOL)photoBrowser:(AGPhotoBrowserView *)photoBrowser willDisplayActionButtonAtIndex:(NSInteger)index;

@end
