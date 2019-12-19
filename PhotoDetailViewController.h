//
//  PhotoDetailViewController.h
//  CollectionViewTutorial
//
//  Created by Paulo Cristo on 6/6/13.
//  Copyright (c) 2013 Bryan Hansen. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <ImageIO/CGImageSource.h>
#import <ImageIO/CGImageProperties.h>
#import <AVFoundation/AVFoundation.h>
#import <CoreLocation/CoreLocation.h>
#import "SearchLocationViewController.h"
#import "BHAlbum.h"
#import "BHPhoto.h"
#import "LocationDataModel.h"
#import "BHPhotoAlbumView.h"
#import "PhotosMapViewController.h"
//need to put this just in one location



@interface PhotoDetailViewController : UIViewController



@property (retain, nonatomic) IBOutlet BHPhotoAlbumView *photoCellView;


@property (nonatomic, strong) NSMutableArray *singleAlbums;//BHAlbums with 1 pic each

@property (copy, nonatomic) NSString *assetURL;
@property (assign,nonatomic) NSInteger selectedIndex;
@property (strong, nonatomic) BHAlbum *enclosingAlbum;

@property (strong, nonatomic) PhotosMapViewController *mapViewController;

@property (nonatomic, retain) NSMutableArray *locationEntitiesArray;

@property (strong, nonatomic) LocationDataModel *dataModel;

@property (strong, nonatomic) UIImage *thumbnail;//to pass to the map

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil;
-(IBAction)closeWindow:(id)sender;
- (void)readFullSizeImageForSharing;
-(void)readThumbnailSizedImage;
-(void) resetAlbumsListFromList: (NSMutableArray *) listOfAlbums;
@end
