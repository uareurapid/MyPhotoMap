//
//  MYAlbumViewController.h
//  CollectionViewTutorial
//
//  Created by Paulo Cristo on 6/6/13.
//  Copyright (c) 2013 Bryan Hansen. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BHAlbum.h"
#import "BHPhoto.h"
#import <AssetsLibrary/AssetsLibrary.h>
#import "BHAlbumPhotoCell.h"
#import "BHAlbumTitleReusableView.h"
#import "BHPhotoAlbumLayout.h"
#import "BHCollectionViewController.h"
#import "PhotoDetailViewController.h"
#import "AlbumsListViewController.h"
#import <Photos/PHPhotoLibrary.h>
#import <Photos/PHAssetCollectionChangeRequest.h>
#import <Photos/Photos.h>
#import <QBImagePickerController/QBImagePickerController.h>

#define DELETE_ABUM_TAG 1000
#define ADD_ALBUM_ATG 1001
#define PERSIST_ALBUM_TAG 1002
//#import <Photos/PHAssetCollection.h>
@class PhotosMapViewController;
@class AlbumsListViewController;

//typedef void (^ALAssetsLibraryAssetForURLResultBlock)(ALAsset *asset);
//typedef void (^ALAssetsLibraryAccessFailureBlock)(NSError *error);


@interface MYAlbumViewController : UICollectionViewController <UICollectionViewDataSource, UICollectionViewDelegate, UIImagePickerControllerDelegate, QBImagePickerControllerDelegate>//BHCollectionViewController

@property (retain,nonatomic) PhotoDetailViewController *detailViewController;

@property (retain,nonatomic) AlbumsListViewController *listAlbumsAvailableController;//available for save


@property (strong,nonatomic) BHCollectionViewController *rootViewController;

//will actaully be abums of just one photo/thumbnail

@property (strong, nonatomic) PhotosMapViewController *mapViewController;

@property (strong, nonatomic) NSString *previouslySelectedAlbum;

@property (strong, nonatomic) BHAlbum *selectedAlbum;
@property (strong, nonatomic) BHAlbum *selectedPhoto;
@property (assign, nonatomic) NSUInteger selectedAlbumIndex;

@property (nonatomic, strong) NSMutableArray *albumsNames;

@property (assign, nonatomic) NSInteger selectedAction;
@property (strong, nonatomic) NSMutableArray *selectedItems;
@property (strong,nonatomic) CLLocation *location;

@property (nonatomic, strong) NSMutableArray *albums;

@property (assign, nonatomic) ALAssetsLibrary* assetslibrary;

@property (strong, nonatomic) NSManagedObjectContext *managedObjectContext;

@property (strong,nonatomic) NSMutableDictionary *dictionary;


//@property (nonatomic, strong) NSMutableArray *selectedPhotoItems;


@property BOOL isFirstLoad;

-(void) reloadAllAlbumInfo: (NSString *) albumName;
-(void) addPhotoWithAssetURLToAlbum: (NSArray *) assetURLS albumName: (NSString *) album;
//- (void)showDetailView: (NSString *) imgURL;
-(void) addAlbumsNamesFromArray: (NSMutableArray*) names;
- (void)readAlbumThumbnails;

- (IBAction)takePhoto:(id)sender;
-(IBAction)settingsClicked:(id)sender;
-(IBAction)addLocation:(id)sender;
-(IBAction)deleteAlbum:(id)sender;
-(IBAction)addPhotosToCurrentAlbum:(id)sender;

@property (nonatomic, weak) IBOutlet BHPhotoAlbumLayout *photoAlbumLayout;
@property (strong, nonatomic) IBOutlet UITabBar *tabBarController;

/*! Write the asset to the assets library (camera roll). (Private)
 *
 * \param assetURL The asset URL
 * \param albumName Custom album name
 * \param failure Block to be executed when failed to add the asset to the custom photo album
 */
-(void)_addAssetURL:(NSURL *)assetURL
            toAlbum:(NSString *)albumName
            failure:(ALAssetsLibraryAccessFailureBlock)failure;

/*! A block wraper to be executed after asset adding process done. (Private)
 *
 * \param albumName Custom album name
 * \param completion Block to be executed when succeed to add the asset to the assets library (camera roll)
 * \param failure Block to be executed when failed to add the asset to the custom photo album
 */
- (ALAssetsLibraryWriteImageCompletionBlock)_resultBlockOfAddingToAlbum:(NSString *)albumName
                                                             completion:(ALAssetsLibraryWriteImageCompletionBlock)completion
                                                                failure:(ALAssetsLibraryAccessFailureBlock)failure;

@end
