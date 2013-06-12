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


typedef void (^ALAssetsLibraryAssetForURLResultBlock)(ALAsset *asset);
typedef void (^ALAssetsLibraryAccessFailureBlock)(NSError *error);


@interface MYAlbumViewController : BHCollectionViewController <UICollectionViewDataSource, UICollectionViewDelegate, UIImagePickerControllerDelegate>


@property (retain,nonatomic) PhotoDetailViewController *detailViewController;

@property (retain,nonatomic) AlbumsListViewController *listAlbums;//available for save

//will actaully be abums of just one photo/thumbnail
@property (strong, nonatomic) NSMutableArray *albumPhotos;

@property (strong, nonatomic) BHAlbum *selectedAlbum;




- (void)showDetailView: (NSString *) imgURL;

- (void)readAlbumThumbnails;

- (IBAction)takePhoto:(id)sender;




@end
