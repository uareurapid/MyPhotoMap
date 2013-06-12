//
//  AlbumOptionsTableViewController.h
//  MyPhotoMap
//
//  Created by Paulo Cristo on 6/12/13.
//  Copyright (c) 2013 Paulo Cristo. All rights reserved.
//

#import <UIKit/UIKit.h>

@class MYAlbumViewController;
@interface AlbumOptionsTableViewController : UITableViewController


@property (strong,nonatomic) MYAlbumViewController *albumViewController;

- (id)initWithNibName:(NSString *)nibName bundle:(NSBundle *)nibBundle controller: (MYAlbumViewController*) albumController;
@end
