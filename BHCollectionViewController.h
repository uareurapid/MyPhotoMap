//
//  BHCollectionViewController.h
//  CollectionViewTutorial
//
//  Created by Bryan Hansen on 11/3/12.
//  Copyright (c) 2012 Bryan Hansen. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SHK.h"
#import "BHAlbum.h"
#import "BHPhoto.h"
#import "BHPhotoAlbumLayout.h"
#import  <CoreLocation/CoreLocation.h>
#import <Photos/PHPhotoLibrary.h>
#import <Photos/PHAssetCollectionChangeRequest.h>
#import <Photos/Photos.h>

#define MAX_PHOTO_THUMBNAILS_PER_ALBUM 3

static NSString * const PhotoCellIdentifier = @"PhotoCell";
static NSString * const AlbumTitleIdentifier = @"AlbumTitle";

@class MYAlbumViewController;
@class PhotosMapViewController;

@interface BHCollectionViewController : UICollectionViewController <UICollectionViewDataSource, UICollectionViewDelegate>

- (id)initWithNibName:(NSString *)nibName bundle:(NSBundle *)nibBundle;
-(void) createNewAlbum: (NSString*) albumName completion:(void(^)(BOOL))callback;
-(void) deleteAlbum: (BHAlbum *) album completion:(void(^)(BOOL))callback;
- (void) fetchLocationRecordsFromDatabase;
- (IBAction)addAlbumClicked:(id)sender;
- (IBAction)settingsClicked:(id)sender;
-(void) reloadAssetsURLSForAlbumNamed: (PHAssetCollection *) albumCollection;

@property (strong,nonatomic) MYAlbumViewController *albumViewController;
@property (strong, nonatomic) PhotosMapViewController *mapViewController;

@property (strong, nonatomic) NSMutableArray *databaseRecords;
@property (strong, nonatomic) NSMutableArray *albumsYears;

@property (strong, nonatomic) NSMutableArray *existingAlbumsNames;

@property (strong,nonatomic) CLLocation *location;
//was retain
@property (strong,nonatomic) NSMutableArray *assetsURLs;
@property (retain, nonatomic) UINavigationController *navController;

@property (nonatomic, strong) NSMutableArray *albums;
@property (nonatomic, weak) IBOutlet BHPhotoAlbumLayout *photoAlbumLayout;

@property (strong, nonatomic) IBOutlet UITabBar *tabBarController;

@property (assign,nonatomic) NSInteger numExistingAlbums;

@property (strong, nonatomic) IBOutlet UITextField *albumTextField;
@property (strong,nonatomic) IBOutlet UIBarButtonItem *addAlbumButton;

@property (strong, nonatomic) NSManagedObjectContext *managedObjectContext;

@property (strong, nonatomic)  UIAlertView *alertViewProgress;

@property BOOL isLoaded;


@end
