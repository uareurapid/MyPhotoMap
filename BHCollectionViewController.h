//
//  BHCollectionViewController.h
//  CollectionViewTutorial
//
//  Created by Bryan Hansen on 11/3/12.
//  Copyright (c) 2012 Bryan Hansen. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SHK.h"
#import "BHPhotoAlbumLayout.h"
#import  <CoreLocation/CoreLocation.h>

static NSString * const PhotoCellIdentifier = @"PhotoCell";
static NSString * const AlbumTitleIdentifier = @"AlbumTitle";

@class MYAlbumViewController;
@class PhotosMapViewController;

@interface BHCollectionViewController : UICollectionViewController <UICollectionViewDataSource, UICollectionViewDelegate>

- (id)initWithNibName:(NSString *)nibName bundle:(NSBundle *)nibBundle;
- (void) readCameraRoll;
-(void) readExistingAlbums;
-(void) initTextFieldNewAlbum;
-(void) createNewAlbum: (NSString*) albumName;
- (IBAction)addAlbumClicked:(id)sender;
- (IBAction)settingsClicked:(id)sender;

@property (strong,nonatomic) MYAlbumViewController *albumViewController;
@property (strong, nonatomic) PhotosMapViewController *mapViewController;
//was retain
@property (strong,nonatomic) NSMutableArray *assetsURLs;
@property (retain, nonatomic) UINavigationController *navController;

@property (strong,nonatomic) CLLocation *location;

@property (nonatomic, strong) NSMutableArray *albums;
@property (nonatomic, weak) IBOutlet BHPhotoAlbumLayout *photoAlbumLayout;
@property (nonatomic, strong) NSOperationQueue *thumbnailQueue;

@property (strong, nonatomic) IBOutlet UITabBar *tabBarController;

@property (assign,nonatomic) NSInteger numExistingAlbums;

@property (strong, nonatomic) IBOutlet UITextField *albumTextField;
@property (strong,nonatomic) IBOutlet UIBarButtonItem *addAlbumButton;


@end
